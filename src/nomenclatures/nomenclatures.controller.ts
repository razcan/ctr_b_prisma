import { PrismaService } from 'src/prisma.service';
import bcrypt from 'bcrypt';

import {
  Controller, Get, Post, Body, Patch, Param, Header, HttpStatus,
  Delete, UploadedFile, UploadedFiles, HttpException, HttpCode, Request,
  UseGuards, UsePipes, ValidationPipe, Res, UseInterceptors
} from '@nestjs/common';
import { NomenclaturesService } from './nomenclatures.service';
import { ContractFinancialDetail, ContractFinancialDetailSchedule, Contracts, ContractsDetails, Prisma } from '@prisma/client';

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


@Controller('nomenclatures')
export class NomenclaturesController {
  constructor(
    private readonly nomenclaturesService: NomenclaturesService,
    private prisma: PrismaService,
    private readonly authService: AuthService
  ) { }

  @Post('login')
  async login(@Body()
  credentials: { username: string, password: string }): Promise<any> {
    // Validate user credentials - Implement your validation logic here

    // For demonstration purposes, let's assume the credentials are valid
    // const user = { id: 1, username: credentials.username, roles: ['user'] };

    const user = { username: credentials.username, password: credentials.password };

    // Generate a token with the user payload
    const token = await this.authService.signIn(user.username, user.password);

    console.log(token)

    // signIn

    // Return the token to the client
    return { user };
  }


  async hashPassword(password: string): Promise<string> {
    const saltRounds = 99;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    return hashedPassword;
  }

  async verifyPassword(password: string, hashedPassword: string): Promise<boolean> {
    // Verify the password
    const isMatch = await bcrypt.compare(password, hashedPassword);

    return isMatch;
  }


  @Post('users')
  @UseInterceptors(FilesInterceptor('avatar'))
  async createUser(
    @Body() data: any,
    @UploadedFiles() avatar: Express.Multer.File,
  ): Promise<any> {

    data.status = (data.status === "true") ? true : false;
    data.picture = avatar[0].filename

    // console.log(data)


    // const hashedPassword = await bcrypt.hash(data.password, 10);
    // console.log("Hashed Password:", hashedPassword);
    // console.log("original Password:", data.password);
    // console.log("Check Password:", await this.verifyPassword(data.password, hashedPassword));


    // Parse the JSON string into a JavaScript object
    // const jsonData = JSON.parse(data.json);


    const jsonData = JSON.parse(data.roles);
    const jsonUser_Groups = JSON.parse(data.User_Groups);

    const result = this.prisma.user.create({
      data: {
        name: data.name,
        email: data.email,
        password: await this.hashPassword(data.password),
        status: data.status,
        picture: data.picture,
        roles: jsonData,
        User_Groups: jsonUser_Groups
      }

    });
    return result;

  }

  @Get('download/:filename')
  downloadFile(@Param('filename') filename: string, @Res() res: Response) {
    const folderPath = '/Users/razvanmustata/Projects/contracts/backend/Uploads'
    const fileStream = createReadStream(`${folderPath}/${filename}`);
    fileStream.pipe(res);
  }

  @Get('users')
  async getUsers() {
    const users = await this.prisma.user.findMany({
      select: {
        id: true,
        name: true,
        email: true,
        status: true,
        picture: true,
        roles: true
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
            updateadAt: true
            // entity: true
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




  @Post('partners')
  async createPartner(@Body() data: Prisma.PartnersCreateInput): Promise<any> {
    const result = this.prisma.partners.create({
      data,
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
      Prisma.sql`select * from public.GetAuditContract(${contractid}::int4)`
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

  // @Delete(':id')
  // remove(@Param('id') id: string) {
  //   return this.nomenclaturesService.remove(+id);
  // }
}
