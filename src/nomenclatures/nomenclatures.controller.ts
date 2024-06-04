import { PrismaService } from 'src/prisma.service';
import bcrypt from 'bcrypt';

import {
  Controller, Get, Post, Body, Patch, Param, Header, HttpStatus, Headers,
  Delete, UploadedFile, UploadedFiles, HttpException, HttpCode, Request,
  UseGuards, UsePipes, ValidationPipe, Res, UseInterceptors, InternalServerErrorException
} from '@nestjs/common';
import { NomenclaturesService } from './nomenclatures.service';
import { ContractFinancialDetail, ContractFinancialDetailSchedule, Contracts, Prisma } from '@prisma/client';

import { Injectable } from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import {
  ParseFilePipeBuilder,
} from '@nestjs/common';
import type { Response } from 'express';
import { Express } from 'express'
import { createReadStream } from 'fs';
import { AuthService } from '../auth/auth.service';


import { AuthGuard } from '../auth/auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ApiParam, ApiQuery, ApiTags } from '@nestjs/swagger';
import { v4 as uuidv4 } from 'uuid';
import { MailerService } from 'src/alerts/mailer.service';
import { Entity } from 'src/entity/entities/entity.entity';
import _ from 'lodash';


@ApiTags('Nomenclatures')
@Controller('nomenclatures')
export class NomenclaturesController {
  constructor(
    private readonly nomenclaturesService: NomenclaturesService,
    private prisma: PrismaService,
    private readonly authService: AuthService,
    private mailerService: MailerService,
  ) { }


  async hashPassword(password: string): Promise<any> {
    const saltRounds = 99;
    const hashedPassword = bcrypt.hash(password, saltRounds);
    return hashedPassword;
  }

  async verifyPassword(password: string, hashedPassword: string): Promise<boolean> {
    // Verify the password
    const isMatch = await bcrypt.compare(password, hashedPassword);

    return isMatch;
  }

  @Post('checkuser')
  async checkuser(
    @Body() data: any,
  ): Promise<any> {

    const user = await this.prisma.user.findUnique({
      where: {
        email: data.email
      }

    })

    let response = "NA";
    if (user !== null && Object.keys(user).length > 0) {
      response = 'Exist'
    }
    else {
      response = 'Not exist'
    };

    return response;

  }



  @Post('forgotpass')
  async forgotpass(
    @Body() data: any,
  ): Promise<any> {

    const user = await this.prisma.user.findUnique({
      where: {
        email: data.email
      }
    })

    const uuid = uuidv4();

    interface add_forgot_pass {
      email: string,
      actual_password: string,
      old_password: string,
      uuid: string,
      userId: number,
    }

    const add: add_forgot_pass = {
      email: user.email,
      actual_password: user.password,
      old_password: user.password,
      uuid: uuid,
      userId: user.id,
    }

    const user_forgot = await this.prisma.forgotPass.create({
      data: add
    })

    const to = user.email;
    const bcc = '';
    const subject = 'Recuperare parola aplicatie ContractsHub';
    const url = `http://localhost:5500/auth/forgottenpassword/rp?uuid=${uuid}`

    const text = `Va rugam sa accesati linkul de mai jos pentru a va modifica parola: ${url}`;

    const html = `Va rugam sa accesati linkul de mai jos pentru a va modifica parola: ${url}`;
    const attachments = [];

    this.mailerService.sendMail(to.toString(), bcc.toString(), subject, text, html, attachments)
      .then(() => console.log('Email sent successfully.'))
      .catch(error => console.error('Error sending email:', error));

    return user_forgot;

  }

  // @Get('forgotpass/:uuid')
  // async getforgotpass(
  //   @Param('uuid') uuid: any,
  // ): Promise<any> {
  //   const rp = await this.prisma.forgotPass.findFirst({
  //     where: {
  //       uuid: uuid
  //     }
  //   })
  //   return rp;
  // }


  @Post('forgotpass/:uuid')
  async postforgotpass(
    @Body() data: any,
    @Param('uuid') uuid: any,
  ): Promise<any> {

    // console.log(data.password)
    const hashedPassword = bcrypt.hash(data.password, 2);

    const rp = await this.prisma.forgotPass.update({
      where: {
        uuid: uuid
      },
      data: {
        actual_password: await hashedPassword
      }
    })

    // console.log(rp)

    await this.prisma.user.update({
      where: {
        id: rp.userId
      },
      data: {
        password: await hashedPassword
      }
    })
    return rp;
  }


  @Patch('user/:id')
  @UseInterceptors(FilesInterceptor('avatar'))
  async updateUser(
    @Param('id') id: any,
    @Body() data: any,
    @UploadedFiles() avatar: Express.Multer.File,
  ): Promise<any> {
    try {


      const existing_roles = data.roles
      const arr = existing_roles.split(',');

      const user = await this.prisma.user.findUnique({
        where: { id: parseInt(id) }
        ,
        include:
        {
          roles: true,
          User_Groups: true,
        }, // Include the current roles of the user
      });

      const exist_roles = []
      for (let i = 0; i < user.roles.length; i++) {
        exist_roles.push(user.roles[i].roleId)
      }

      const newSetRolles: number[] = arr.map((str) => parseInt(str, 10));
      const toBeDeleted: number[] = exist_roles.filter((element) => !newSetRolles.includes(element));

      const updatedUser = await this.prisma.role_User.deleteMany({
        where: {
          roleId: {
            in: (toBeDeleted)
          },
          userId: parseInt(id)
        },
      });

      const toBeInserted: number[] = newSetRolles.filter((element) => !exist_roles.includes(element));
      const roleUserPromises = toBeInserted.map(async (roleId) => {
        const newRoleUser = await this.prisma.role_User.create({
          data: {
            user: { connect: { id: parseInt(id) } },
            role: { connect: { id: roleId } }
          }
        });
      })

      const exist_groups: number[] = []
      for (let i = 0; i < user.User_Groups.length; i++) {
        exist_groups.push(user.User_Groups[i].id)
      }

      const resultArray: number[] = data.User_Groups.split(',').map(Number);

      const GroupstoBeConnected: number[] = resultArray.filter((element) => !exist_groups.includes(element));
      const GroupstoBeDisconnected: number[] = exist_groups.filter((element) => !resultArray.includes(element));


      const roleGroupsPromisesC = GroupstoBeConnected.map(async (id_group) => {
        const connectUserGroup = await this.prisma.user.update({
          where: { id: parseInt(id) },
          data: {
            User_Groups: {
              connect: { id: id_group }
            }
          }
        });
      })
      const roleGroupsPromisesD = GroupstoBeDisconnected.map(async (id_group) => {
        const disconnectUserGroup = await this.prisma.user.update({
          where: { id: parseInt(id) },
          data: {
            User_Groups: {
              disconnect: { id: id_group }
            }
          }
        });
      })

      data.status = (data.status === "true") ? true : false;
      data.picture = avatar[0] ? avatar[0].filename : user.picture;
      const hashedPassword = bcrypt.hash(data.password, 2);

      const result = await this.prisma.user.update({
        where: {
          id: parseInt(id)
        },
        data: {
          name: data.name,
          email: data.email,
          password: await hashedPassword,
          status: data.status,
          picture: data.picture,
        }

      });

    } catch (error) {
      console.error("Error updating user roles:", error);
      throw new Error("Failed to update user roles.");
    }
  }



  @Post('users')
  @UseInterceptors(FilesInterceptor('avatar'))
  async createUser(
    @Body() data: any,
    @UploadedFiles() avatar: Express.Multer.File,
  ): Promise<any> {

    try {

      data.status = (data.status === "true") ? true : false;
      data.picture = avatar[0] ? avatar[0].filename : 'default.jpeg'

      try {

        const jsonData = JSON.parse(data.roles);
        const jsonUser_Groups = JSON.parse(data.User_Groups);
        const hashedPassword = bcrypt.hash(data.password, 2);
        const result = await this.prisma.user.create({
          data: {
            name: data.name,
            email: data.email,
            // password: data.password,
            password: await hashedPassword,
            status: data.status,
            picture: data.picture,
            roles: jsonData,
            User_Groups: jsonUser_Groups
          }

        });
      } catch (error) {
        // If an error occurs during the execution of the await function, it will be caught here
        console.error("Error occurred during password hashing:", error);
      }

      const status = "User was created!"
      return status;
    } catch (error) {
      console.error("Error occurred during password hashing:", error);
      throw new InternalServerErrorException("Error occurred during password hashing");
    }
  }


  @Get('download/:filename')
  downloadFile(@Param('filename') filename: string, @Res() res: Response) {
    const folderPath = '/Users/razvanmustata/Projects/contracts/backend/Uploads'
    const fileStream = createReadStream(`${folderPath}/${filename}`);
    fileStream.pipe(res);
  }


  @Get('exchangerates')
  async GetExchageRates() {
    const exchangeRates = await this.prisma.exchangeRates.findMany({
      where: {
        name: {
          not: {
            contains: "RON"
          }
        }
      }
    })
    return exchangeRates;
  }

  @Get('exchangerates/:date')
  async GetExchageRatesbyDate(@Param('date') date: any): Promise<any> {
    const exchangeRates = await this.prisma.exchangeRates.findMany(
      {
        where: {
          date: date,
          name: {
            not: {
              contains: "RON"
            }
          }
        }
      }
    )
    return exchangeRates;
  }


  @Get('exchangerates/:date/:currencycode')
  async GetExchageRatesbyDateCurrency(@Param('date') date: any,
    @Param('currencycode') currencycode: any
  ): Promise<any> {
    const exchangeRates = await this.prisma.exchangeRates.findMany(
      {
        where: {
          date: date,
          name: currencycode
        }
      }
    )
    return exchangeRates;
  }

  @Get('exchangeratesbet/:start/:end/:currencycode')
  async GetExchageRatesFiltered(
    @Param('start') start: any,
    @Param('end') end: any,
    @Param('currencycode') currencycode: any
  ): Promise<any> {

    const exchangeRates = await this.prisma.exchangeRates.findMany(
      {
        where: {
          date: {
            gte: start,
            lte: end,
          },
          name: currencycode
        }
      }
    )
    return exchangeRates;
  }



  @UseGuards(AuthGuard)
  // @Roles('Administrator', 'Editor') // Set multiple roles here
  @Roles('Editor')
  @UseGuards(RolesGuard)
  @Get('users')
  async getUsers(@Body() data: any, @Headers() headers): Promise<any> {

    const entity: string[] = [headers.entity]

    const intArray: number[] = entity.map(str => parseInt(str, 10));
    const users = await this.prisma.user.findMany({

      select: {
        id: true,
        name: true,
        email: true,
        status: true,
        picture: true,
        roles: true,
        User_Groups: {
          include: {
            entity: {
              where: {
                id: {
                  in: intArray
                },
              }
            }
          }
        }
      },
    });
    return users;
  }

  // @UseGuards(AuthGuard)
  // @Roles('Editor', 'Administrator')
  // @UseGuards(RolesGuard)
  @Get('userentity/:userid')
  async getUserEntity(@Body() data: any, @Param('userid') userid: any): Promise<any> {


    const users = await this.prisma.user.findUnique({
      include: {
        User_Groups: {
          include: {
            entity: true
          }
        }
      },
      where: {
        id: parseInt(userid)
      }
    });

    // Initialize an empty Set to store unique entity names
    const uniqueEntities = new Set();

    // Iterate through the User_Groups array
    users.User_Groups.forEach(group => {
      // Check if the entity array exists in the group
      if (group.entity) {
        // Iterate through each entity in the entity array
        group.entity.forEach(entity => {
          // Add the entity name to the Set (Set automatically handles duplicates)
          uniqueEntities.add(entity);
        });
      }
    });

    const distinctEntities = Array.from(uniqueEntities);

    const uniqueEntities2 = _.uniqBy(distinctEntities, 'id');

    return uniqueEntities2;

  }



  @UseGuards(AuthGuard)
  // @Roles('Administrator', 'Editor') // Set multiple roles here
  @Roles('Administrator', 'Editor')
  @UseGuards(RolesGuard)
  @Get('susers')
  async getSimplifyUsers(@Body() data: any, @Headers() headers): Promise<any> {

    const entity: string[] = [headers.entity]

    const intArray: number[] = entity.map(str => parseInt(str, 10));
    const users = await this.prisma.user.findMany({

      select: {
        id: true,
        name: true,
        email: true,
        status: true,
      },
    });
    return users;
  }

  // @UseGuards(AuthGuard)
  // @Roles('Administrator', 'Editor')
  // @UseGuards(RolesGuard)
  @Get('susers/:userId')
  async getSimplifyUsersById(@Param('userId') userId: any, @Body() data: any, @Headers() headers): Promise<any> {

    const entity: string[] = [headers.entity]

    const intArray: number[] = entity.map(str => parseInt(str, 10));
    const users = await this.prisma.user.findUnique({
      where: {
        id: parseInt(userId)
      },
      select: {
        id: true,
        name: true,
        email: true,
        status: true,
      },
    });
    return users;
  }


  @Get('user/:id')
  async getUser3(@Param('id') id: any) {
    const users = await this.prisma.user.findUnique({
      where: {
        id: parseInt(id)
      },
      select: {
        id: true,
        name: true,
        email: true,
        status: true,
        picture: true,
        User_Groups:
        {
          select: {
            createdAt: true,
            description: true,
            id: true,
            name: true,
            updateadAt: true,
            entity: true
          }
        },
        roles: {
          // include : role
          select: {
            // id: true,
            // userId: true
            role: true
          },
        },
      },
    });
    return users
  }

  @Delete('user/:id')
  async deleteUser(@Param('id') id: any) {

    const roles = await this.prisma.role_User.deleteMany({
      where: {
        userId: parseInt(id),
      },
    })


    const user = await this.prisma.user.delete({
      where: {
        id: parseInt(id),
      },
    })
    return user;
  }

  //   async function getTotalSalesByCategory() {
  //   const totalSalesByCategory = await prisma.order.aggregate({
  //     groupBy: {
  //       category: {
  //         // Assuming 'category' is the field you want to group by
  //         category: true,
  //       },
  //     },
  //     sum: {
  //       // Assuming 'totalAmount' is the field you want to sum
  //       totalAmount: true,
  //     },
  //   });

  //   return totalSalesByCategory;
  // }



  @Post('documentseries')
  async createDocumentSeries(@Body() data: Prisma.DocumentSeriesCreateInput): Promise<any> {
    const result = this.prisma.documentSeries.create({
      data,
    });
    return result;
  }



  @Get('documentseries')
  async getAllDocumentSeries(@Body() data: Prisma.DocumentSeriesCreateInput): Promise<any> {
    const result = this.prisma.documentSeries.findMany({
    });
    return result;
  }


  @Get('documentseries/:id')
  async getDocumentSeriesById(@Param('id') id: any): Promise<any> {
    const result = this.prisma.documentSeries.findUnique({
      where: {
        id: parseInt(id)
      },
    });
    return result;
  }

  @Patch('documentseries/:id')
  async editDocumentSeriesById(
    @Param('id') id: any,
    @Body() data: Prisma.DocumentSeriesCreateInput): Promise<any> {
    const result = this.prisma.documentSeries.update({
      where: {
        id: parseInt(id)
      },
      data: data
    });
    return result;
  }



  @Get('roles')
  async getUserRoles() {
    const roles = await this.prisma.role.findMany()
    return roles;
  }

  @Post('groups')
  async createGroup(@Body() data: Prisma.GroupsCreateInput): Promise<any> {
    const result = this.prisma.groups.create({
      data,
    });
    return result;
  }

  @Post('dynamicfield')
  async createDynamicfield(@Body() data: Prisma.DynamicFieldsCreateInput): Promise<any> {
    const result = this.prisma.dynamicFields.create({
      data,
    });
    return result;
  }

  @Get('dynamicfield')
  async getDynamicfield(@Body() data: Prisma.DynamicFieldsCreateInput): Promise<any> {
    const result = this.prisma.dynamicFields.findMany({
      orderBy: {
        fieldorder: 'asc', // 'asc' for ascending order, 'desc' for descending order
      },
    });
    return result;
  }



  @Get('groups')
  async getAllGroups(@Body() data: Prisma.GroupsCreateInput): Promise<any> {
    const result = this.prisma.groups.findMany({
    });
    return result;
  }


  @Get('groups/:id')
  async getGroupById(@Param('id') id: any): Promise<any> {
    const result = this.prisma.groups.findUnique({
      where: {
        id: parseInt(id)
      },
      include: {
        entity: true
      }
    });
    return result;
  }



  @Get('billingfrequency')
  async getbillingfrequency() {
    const billingfrequency = await this.prisma.billingFrequency.findMany()
    return billingfrequency;
  }

  @Get('paymenttype')
  async getpaymenttype() {
    const paymenttype = await this.prisma.paymentType.findMany()
    return paymenttype;
  }

  @Get('measuringunit')
  async getmeasuringunit() {
    const measuringunit = await this.prisma.measuringUnit.findMany()
    return measuringunit;
  }


  @Get('vatquota')
  async vatquota() {
    const vatquota = await this.prisma.vatQuota.findMany()
    return vatquota;
  }

  @Post('partners')
  async createPartner(
    @Body() data: Prisma.PartnersCreateInput,
  ): Promise<any> {

    const result = this.prisma.partners.create({
      data,
    });

    return result;
  }


  @Post('partnerlogo/:partnerId')
  @UseInterceptors(FilesInterceptor('logo'))
  async createPartnerLogo(
    @UploadedFiles() logo: Express.Multer.File,
    @Param('partnerId') partnerId: any
  ): Promise<any> {

    const picture = logo[0] ? logo[0].filename : 'default.jpeg'

    const result = this.prisma.partners.update({
      where: {
        id: parseInt(partnerId)
      },
      data: {
        picture: picture
      }
    });
    return result;
  }

  @Delete('partnerlogo/:partnerId')
  async deletePartnerLogo(
    @Param('partnerId') partnerId: any
  ): Promise<any> {

    const result = this.prisma.partners.update({
      where: {
        id: parseInt(partnerId)
      },
      data: {
        picture: null
      }
    });
    return result;
  }


  @Get('extrarates/:partnerid')
  async getExtraRates(@Param('partnerid') partnerid: any): Promise<any> {
    const result = this.prisma.partnersBanksExtraRates.findMany({
      where: {
        partnersId: parseInt(partnerid)
      },
      include: {
        currency: true
      }

    });
    return result;
  }

  @Delete('extrarates/:id')
  async deleteExtraRates(@Param('id') id: any): Promise<any> {
    const result = this.prisma.partnersBanksExtraRates.delete({
      where: {
        id: parseInt(id)
      }
    });
    return result;
  }

  @Patch('extrarates/:id')
  async updateExtraRates(@Body() data: any, @Param('id') id: any): Promise<any> {
    const result = this.prisma.partnersBanksExtraRates.update({
      where: {
        id: parseInt(id)
      },
      data: data

    });
    return result;
  }


  @Post('extrarates')
  async addExtraRates(@Body() data: any): Promise<any> {
    const result = this.prisma.partnersBanksExtraRates.createMany({
      data: data
    });
    return result;
  }



  @Get('contracttype')
  async getAllContractTypes() {
    const contracttype = await this.prisma.contractType.findMany()
    return contracttype;
  }

  @Get('contractstatus')
  async getAllContractStatuses() {
    const contractstatus = await this.prisma.contractStatus.findMany()
    return contractstatus;
  }

  @Get('contractwfstatus')
  async getAllContractWFStatuses() {
    const contractwfstatus = await this.prisma.contractWFStatus.findMany()
    return contractwfstatus;
  }


  @Get('partners')
  async getAllPartners() {
    const partner = await this.prisma.partners.findMany(
      {
        where: {
          type: {
            in: ['Furnizor', 'Client']
          }
        },
      }
    )
    return partner;
  }

  @Get('entity')
  async getAllEntities() {
    const partner = await this.prisma.partners.findMany(
      {
        where: {
          type: {
            in: ['Entitate']
          }
        },
      }
    )
    return partner;
  }

  @Get('allparties')
  async getAllParties() {
    const partner = await this.prisma.partners.findMany(
      {}
    )
    return partner;
  }

  @Get('taskStatus')
  async getAllTaskStatus() {
    const status = await this.prisma.contractTasksStatus.findMany(
      {}
    )
    return status;
  }


  //returns only partners of type entity
  @Get('partnersdetails/:id')
  async getAllPartnersDetails(@Param('id') id: any) {

    const partner = await this.prisma.partners.findMany(
      {
        include: {
          Persons: true,
          Address: true,
          Banks: true
        },
        where: {
          id: parseInt(id),
          type: {
            in: ['Furnizor', 'Client']
          }
        },
      }
    )
    return partner;
  }

  //returns only partners of type entity
  @Get('entitydetails/:id')
  async getAllEntityDetails(@Param('id') id: any) {
    const partner = await this.prisma.partners.findMany(
      {
        include: {
          Persons: true,
          Address: true,
          Banks: true
        },
        where: {
          id: parseInt(id),
          type: "Entitate"
        },
      }
    )
    return partner;
  }


  @Get('partners/:id')
  async getPartnerById(@Param('id') id: any) {
    const partner = await this.prisma.partners.findUnique(
      {
        include: {
          Persons: true,
        },
        where: {
          id: parseInt(id),
        },
      })
    return partner;
  }

  @Delete('partners/:id')
  async deletePartner(@Param('id') id: any) {
    const partner = await this.prisma.partners.delete({
      where: {
        id: parseInt(id),
      },
    })
    return partner;
  }

  @Patch('partners/:id')
  async UpdatePartner(@Body() data: Prisma.PartnersCreateInput, @Param('id') id: any): Promise<any> {
    const partner = await this.prisma.partners.update({
      where: {
        id: parseInt(id),
      },
      data: data,
    })
    return partner;
  }

  //audit partner
  @Get('auditPartner')
  async getPartnerAudit(@Param('partnerid') partnerid: any) {

    const partner = '%rr%'
    const result = await this.prisma.$queryRaw(
      Prisma.sql`SELECT * FROM partners_audit WHERE name like ${partner}`
    )
    return result;
  }

  //execute a procedure CALL my_procedure(123, 'Hello');
  @Get('executeAuditPartner/:id')
  async getExecutePartnerAudit(@Param('id') id: any) {

    let contractid: number = parseInt(id, 10);
    const result = await this.prisma.$queryRaw(
      // Prisma.sql`SELECT delete()`
      Prisma.sql`select * from public.GetAuditContract2(${contractid}::int4)`
      //Prisma.sql`select * from public."ContractsAudit"`
    )
    return result;
  }


  // @Get('alerts')
  // async getAlerts() {
  //   const alerts = await this.prisma.alerts.findMany()
  //   return alerts;
  // }

  // @Patch('alerts/:id')
  // async UpdateAlert(@Body() data: Prisma.AlertsCreateInput, @Param('id') id: any): Promise<any> {
  //   const alert = await this.prisma.alerts.update({
  //     where: {
  //       id: parseInt(id),
  //     },
  //     data: data,
  //   })
  //   return alert;
  // }


  @Post('contracttemplates')
  async createContractTemplate(@Body() data: Prisma.ContractTemplatesCreateInput): Promise<any> {
    const result = this.prisma.contractTemplates.create({
      data,
    });
    return result;
  }

  @Patch('contracttemplates/:id')
  async updateContractTemplate(
    @Param('id') id: any,
    @Body() data: Prisma.ContractTemplatesUpdateInput): Promise<any> {
    const result = this.prisma.contractTemplates.update(
      {
        where: {
          id: parseInt(id)
        },
        data,
      }
    );
    return result;
  }

  @Delete('contracttemplates/:id')
  async deleteContractTemplate(
    @Param('id') id: any,
    @Body() data: Prisma.ContractTemplatesWhereInput): Promise<any> {
    const result = this.prisma.contractTemplates.delete(
      {
        where: {
          id: parseInt(id)
        },
      }
    );
    return result;
  }

  @Get('contracttemplates')
  async getContractTemplate(@Body() data: Prisma.ContractTemplatesFindManyArgs): Promise<any> {
    const result = this.prisma.contractTemplates.findMany({
      include: {
        contractType: true
      }
    });
    return result;
  }

  @Get('contracttemplates/:id')
  async getContractTemplateById(@Param('id') id: any) {
    const result = this.prisma.contractTemplates.findUnique({
      where: {
        id: id
      },
      include: {
        contractType: true
      }
    });
    return result;
  }

  @Post('persons')
  async createPerson(@Body() data: Prisma.PersonsCreateInput): Promise<any> {
    const result = this.prisma.persons.create({
      data,
    });
    return result;
  }

  @Get('persons/:partnerid')
  async getPersonsByPartnerId(@Param('partnerid') partnerid: any) {
    const persons = await this.prisma.persons.findMany({
      where: {
        partnerId: parseInt(partnerid),
      },
    })
    return persons;
  }

  @Get('personsById/:personid')
  async getPersonById(@Param('personid') personid: any) {
    return this.nomenclaturesService.getPersonById(personid);
  }

  @Patch('persons/:personid')
  async getUpdatePersonsByPersonId(@Body() data: Prisma.PersonsCreateInput, @Param('personid') personid: any): Promise<any> {
    const persons = await this.prisma.persons.update({
      where: {
        id: parseInt(personid),
      },
      data: data,
    })
    return persons;
  }



  @Delete('persons/:personid')
  async deletePersonId(@Param('personid') personid: any) {
    const persons = await this.prisma.persons.delete({
      where: {
        id: parseInt(personid),
      },
    })
    return persons;
  }

  @Post('address')
  async createAddress(@Body() data: Prisma.AddressCreateInput): Promise<any> {
    const result = this.prisma.address.create({
      data,
    });
    return result;
  }

  @Get('allbanks')
  async getallBanks() {
    const banks = await this.prisma.bank.findMany({
    })
    return banks;
  }

  @Get('allcurrencies')
  async getallCurrencies() {
    const currencies = await this.prisma.currency.findMany({
    })
    return currencies;
  }



  @Get('address/:partnerid')
  async getAddressByPartnerId(@Param('partnerid') partnerid: any) {
    const address = await this.prisma.address.findMany({
      where: {
        partnerId: parseInt(partnerid),
      },
    })
    return address;
  }

  @Delete('address/:addressid')
  async deleteAddressId(@Param('addressid') addressid: any) {
    const address = await this.prisma.address.delete({
      where: {
        id: parseInt(addressid),
      },
    })
    return address;
  }

  @Patch('address/:addressid')
  async getUpdateAddressByAddressId(@Body() data: Prisma.AddressCreateInput, @Param('addressid') addressid: any): Promise<any> {
    const adress = await this.prisma.address.update({
      where: {
        id: parseInt(addressid),
      },
      data: data,
    })
    return adress;
  }

  @Post('bank')
  async createBank(@Body() data: Prisma.BanksCreateInput): Promise<any> {
    const result = this.prisma.banks.create({
      data,
    });
    return result;
  }

  @Get('bank/:partnerid')
  async getBanksByPartnerId(@Param('partnerid') partnerid: any) {
    const banks = await this.prisma.banks.findMany({
      where: {
        partnerId: parseInt(partnerid),
      },
    })
    return banks;
  }

  @Patch('bank/:bankid')
  async getUpdateBank(@Body() data: Prisma.BanksCreateInput, @Param('bankid') bankid: any): Promise<any> {
    const bank = await this.prisma.banks.update({
      where: {
        id: parseInt(bankid),
      },
      data: data,
    })
    return bank;
  }

  @Delete('bank/:bankid')
  async deleteBank(@Param('bankid') bankid: any) {
    const bank = await this.prisma.banks.delete({
      where: {
        id: parseInt(bankid),
      },
    })
    return bank;
  }

  @Post('location')
  async createLocation(@Body() data: Prisma.LocationCreateInput): Promise<any> {
    const result = this.prisma.location.create({
      data,
    });
    return result;
  }

  @Get('location')
  async getAllLocation(@Body() data: Prisma.LocationCreateInput): Promise<any> {
    const result = await this.prisma.location.findMany()
    return result;
  }

  @Delete('location/:id')
  async removelocation(@Param('id') id: any) {
    const location = await this.prisma.location.delete({
      where: {
        id: parseInt(id),
      },
    })
    return location;
  }

  // @Delete(':id')
  // remove(@Param('id') id: string) {
  //   return this.nomenclaturesService.remove(+id);
  // }
}