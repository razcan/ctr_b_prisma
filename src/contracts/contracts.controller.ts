
import {
  Controller, Get, Post, Body, Patch, Param, Header, HttpStatus,
  Delete, UploadedFile, UploadedFiles, HttpException, HttpCode, Request, UseGuards, UsePipes, ValidationPipe, Res
} from '@nestjs/common';
import { ContractFinancialDetail, ContractFinancialDetailSchedule, Contracts, ContractsDetails, Prisma } from '@prisma/client';

import { PrismaService } from 'src/prisma.service';
import { ContractsService } from './contracts.service';
import { CreateCategoryDto } from '../category/dto/create-category.dto'
import { Injectable } from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import {
  ParseFilePipeBuilder,
  UseInterceptors,
} from '@nestjs/common';
import type { Response } from 'express';
import { Express } from 'express'
import { createReadStream } from 'fs';
import * as fs from 'fs';
import * as path from 'path';
import { Persons } from 'src/persons/entities/persons.entity';
import { MailerService } from 'src/alerts/mailer.service';
import { NomenclaturesService } from 'src/nomenclatures/nomenclatures.service';

@Controller('contracts')
export class ContractsController {
  constructor(
    private readonly contractsService: ContractsService,
    private prisma: PrismaService,
    private mailerService: MailerService,
    // private nomenclatures: NomenclaturesService

  ) { }



  @Post('file/:id')
  @UseInterceptors(FilesInterceptor('files'))
  async uploadFiles(
    @Param('id') id: any,
    @UploadedFiles() files: Express.Multer.File,
  ) {
    let data: any = files
    const result = await this.prisma.contractAttachments.createMany({
      data,
    });

    // console.log(data, id, result, data.length)

    for (let i = 0; i < data.length; i++) {
      await this.prisma.contractAttachments.updateMany({
        where: { filename: data[i].filename },
        data: { contractId: parseInt(id) },
      })
    }
    return result;
  }

  @Get('files')
  async getAllFiles(): Promise<any> {
    const result = await this.prisma.contractAttachments.findMany()
    return result;
  }

  @Get('file/:id')
  async getAllFilesByContractId(@Param('id') id: any): Promise<any> {
    const contractId: number = parseInt(id);
    const result = await this.prisma.contractAttachments.findMany(
      {
        where: {
          contractId: contractId,
        }
      }
    )
    return result;
  }

  async getPersonById(personid: any) {
    const persons = await this.prisma.persons.findFirst({
      where: {
        id: parseInt(personid),
      },
    })
    return persons;
  }

  // @Get('download/:filename')
  // downloadFile(@Param('filename') filename: string, @Res() res: Response) {
  //   const folderPath = '/Users/razvanmustata/Projects/contracts/backend/Uploads/'
  //   const fileStream = createReadStream(`${folderPath}/${filename}`);
  //   res.setHeader('Content-Type', 'application/octet-stream');
  //   res.setHeader('Content-Disposition', `attachment; filename=${filename}`);
  //   fileStream.pipe(res);
  // }

  @Get('download/:filename')
  downloadFileTwo(@Param('filename') filename: string, @Res() res: Response): void {
    const filePath = `/Users/razvanmustata/Projects/contracts/backend/Uploads/${filename}`

    // Check if the file exists
    if (fs.existsSync(filePath)) {
      // Set appropriate headers for file download
      res.setHeader('Content-Type', 'application/octet-stream');

      // Suggest to the browser to prompt the user for download with a specific filename
      res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);

      // Pipe the file stream to the response
      const fileStream = fs.createReadStream(filePath);
      fileStream.pipe(res);
    } else {
      // Return a 404 response if the file does not exist
      res.status(404).send('File not found');
    }
  }

  @Delete('delete/:filename')
  async deleteFile(@Param('filename') filename: string): Promise<any> {
    try {
      const folderPath = '/Users/razvanmustata/Projects/contracts/backend/Uploads/'
      fs.unlinkSync(`${folderPath}/${filename}`);

      const filedeleted = await this.prisma.contractAttachments.deleteMany(
        {
          where: {
            filename: filename,
          }
        })

      console.log(`File ${filename} deleted successfully.`);
    } catch (err) {
      console.error(`Error deleting file ${filename}: ${err.message}`);
    };
  }


  //trb facut si pt delete file

  @Post('content')
  async createContent(@Body() data: Prisma.ContractContentCreateInput): Promise<any> {
    const content = this.prisma.contractContent.create({
      data,
    });

    return content;
  }

  // @Patch('content/:id')
  // async updateContent(@Body() data: any, @Param('id') id: any): Promise<any> {

  //   const content = await this.prisma.contractContent.upsert({
  //     where: {
  //       contractId: parseInt(id),
  //     },
  //     data: data,
  //   })
  //   return content;
  // }

  @Patch('content/:id')
  async updateContent(@Body() data: any, @Param('id') id: any): Promise<any> {
    const existingContent = await this.prisma.contractContent.findUnique({
      where: {
        contractId: parseInt(id)
      }
    });

    if (existingContent) {
      const updatedContent = await this.prisma.contractContent.update({
        where: { contractId: parseInt(id) },
        data: data,
      });
      return updatedContent;
    } else {
      const newContent = await this.prisma.contractContent.create({
        data: data
      });
      return newContent;
    }
  }


  @Get('content/:id')
  async getContent(@Body() data: Prisma.ContractContentFindFirstArgs, @Param('id') id: any): Promise<any> {
    const content = await this.prisma.contractContent.findMany({
      where: {
        contractId: parseInt(id),
      },
    })
    return content;
  }




  @Post()
  async createContract(@Body() data: any): Promise<any> {

    // console.log(data);

    const result = await this.prisma.contracts.create({
      data,
    });


    const audit = this.prisma.contractsAudit.create({
      data: {
        operationType: "I",
        id: result.id,
        number: data.number,
        typeId: data.typeId,
        statusId: data.statusId,
        start: data.start,
        end: data.end,
        sign: data.sign,
        completion: data.completion,
        remarks: data.remarks,
        categoryId: data.categoryId,
        departmentId: data.departmentId,
        cashflowId: data.cashflowId,
        itemId: data.itemId,
        costcenterId: data.costcenterId,
        automaticRenewal: data.automaticRenewal,
        partnersId: data.partnersId,
        entityId: data.entityId,
        partnerpersonsId: data.partnerpersonsId,
        entitypersonsId: data.entitypersonsId,
        entityaddressId: data.entityaddressId,
        partneraddressId: data.partneraddressId,
        entitybankId: data.entitybankId,
        partnerbankId: data.partnerbankId
      }
    });

    return audit;
  }


  @Post('contractItems')
  async createContractItems(@Body()
  dataAll: any
  ): Promise<any> {

    let dataItem: Prisma.ContractItemsCreateManyInput = dataAll[0];
    const result = this.prisma.contractItems.create({
      data: dataItem,
    });

    const finDetail: any = dataAll[1]
    finDetail.contractItemId = (await result).id
    const finCtrFinDetail: Prisma.ContractFinancialDetailUncheckedCreateInput = finDetail

    const result2 = this.prisma.contractFinancialDetail.create({
      data: finCtrFinDetail,
    });

    let schBill = dataAll[2]
    let x = (await result2).id

    for (let i = 0; i < schBill.length; i++) {
      schBill[i].contractfinancialItemId = x
    }

    const finCtrFinSchDetail: Prisma.ContractFinancialDetailScheduleCreateManyInput = schBill
    // console.log(schBill)
    const result3 = this.prisma.contractFinancialDetailSchedule.createMany({
      data: finCtrFinSchDetail,
    });

    return result3;
  }

  @Post('financialDetail')
  async createFinancialDetail(@Body()
  data: Prisma.ContractFinancialDetailCreateInput): Promise<any> {
    // console.log(data)
    const result = this.prisma.contractFinancialDetail.create({
      data,
    });
    return result;
  }

  @Post('financialDetailSchedule')
  async createFinancialSchedule(@Body() data: Prisma.ContractFinancialDetailScheduleCreateManyInput): Promise<any> {
    //console.log(data)
    const result = this.prisma.contractFinancialDetailSchedule.createMany({
      data,
    });
    return result;
  }


  @Patch('/:id')
  async update(@Param('id') id: number, @Body() data: any) {

    const contract = await this.prisma.contracts.update({
      where: { id: +id },
      data: data,
    })

    const audit = this.prisma.contractsAudit.create({
      data: {
        operationType: "U",
        id: contract.id,
        number: data.number,
        typeId: data.typeId,
        statusId: data.statusId,
        start: data.start,
        end: data.end,
        sign: data.sign,
        completion: data.completion,
        remarks: data.remarks,
        categoryId: data.categoryId,
        departmentId: data.departmentId,
        cashflowId: data.cashflowId,
        itemId: data.itemId,
        costcenterId: data.costcenterId,
        automaticRenewal: data.automaticRenewal,
        partnersId: data.partnersId,
        entityId: data.entityId,
        partnerpersonsId: data.partnerpersonsId,
        entitypersonsId: data.entitypersonsId,
        entityaddressId: data.entityaddressId,
        partneraddressId: data.partneraddressId,
        entitybankId: data.entitybankId,
        partnerbankId: data.partnerbankId
      }
    });

    return audit;
  }


  @Delete('financialDetailSchedule/:id')
  async deleteFinancialSchedule(
    @Param('id') id: string,
    @Body() data: any): Promise<any> {

    const ctrfinDetailId =
      await this.prisma.contractFinancialDetail.findFirst(
        {
          where: {
            contractItemId: parseInt(id)
          },
        })

    const result = await this.prisma.contractFinancialDetailSchedule.findMany({
      where:
      {
        contractfinancialItemId: ctrfinDetailId.id
      }
    })

    const resultw = await this.prisma.contractFinancialDetailSchedule.deleteMany({
      where:
      {
        contractfinancialItemId: ctrfinDetailId.id
      }
    });

    return resultw;
  }

  @Patch('updatecontractItems/:id/:ctrId/:contractfinancialItemId')
  async updatecontractItems(
    @Param('id') id: string,
    @Param('ctrId') ctrId: string,
    @Param('contractfinancialItemId') contractfinancialItemId: string,
    @Body() data: any): Promise<any> {
    console.log(id, ctrId, contractfinancialItemId)


    const result = await this.prisma.contractItems.update({
      where: { id: parseInt(id) },
      data: data[0]
    })

    let dataItem: Prisma.ContractFinancialDetailUpdateInput = data[1];
    const result22 = this.prisma.contractFinancialDetail.update
      (
        {
          where: { id: 49 }
          ,
          data: dataItem,
        });

    // return result22

    const finDetail: any = data[1]
    const finCtrFinDetail: Prisma.ContractFinancialDetailUncheckedUpdateInput = finDetail

    const result2 = this.prisma.contractFinancialDetail.update({
      where: { id: 50 },
      data: {
        itemid: finCtrFinDetail.itemid,
        currencyValue: finCtrFinDetail.currencyValue,
        currencyPercent: finCtrFinDetail.currencyPercent,
        paymentTypeid: finCtrFinDetail.paymentTypeid,
        billingDay: finCtrFinDetail.billingDay,
        billingQtty: finCtrFinDetail.billingQtty,
        billingFrequencyid: finCtrFinDetail.billingFrequencyid,
        remarks: finCtrFinDetail.remarks,
        billingDueDays: finCtrFinDetail.billingDueDays,
        billingPenaltyPercent: finCtrFinDetail.billingDueDays,
        guaranteeLetter: finCtrFinDetail.guaranteeLetter,
        guaranteeLetterDate: finCtrFinDetail.guaranteeLetterDate,
        guaranteeLetterValue: finCtrFinDetail.guaranteeLetterValue,
        active: finCtrFinDetail.active,
        currencyid: finCtrFinDetail.currencyid,
        guaranteeLetterCurrencyid: finCtrFinDetail.guaranteeLetterCurrencyid
      }
    }
      //   itemid                          Int ?
      //     totalContractValue              Float
      // currency                        Currency ? @relation("item", fields: [currencyid], references: [id])
      // currencyid                      Int ?
      //     currencyValue                   Float ?
      //     currencyPercent                 Float ?
      //     billingDay                      Int
      // billingQtty                     Float
      // billingFrequencyid              Int ?
      //     measuringUnit                   MeasuringUnit ? @relation(fields: [measuringUnitid], references: [id])
      // measuringUnitid                 Int ?
      //     paymentType                     PaymentType ? @relation(fields: [paymentTypeid], references: [id])
      // paymentTypeid                   Int ?
      //     billingPenaltyPercent           Float
      // billingDueDays                  Int
      // remarks                         String ? @db.VarChar(150)
      // guaranteeLetter                 Boolean ?
      //     guaranteecurrency               Currency ? @relation("guarantee", fields: [guaranteeLetterCurrencyid], references: [id])
      // guaranteeLetterCurrencyid       Int ?
      //     guaranteeLetterDate             DateTime ?
      //     guaranteeLetterValue            Float ?
      //     active                          Boolean ? @default(true)
      // items                           ContractItems?                    @relation(fields: [contractItemId], references: [id], onDelete: Cascade, onUpdate: Cascade)
      // contractItemId                  Int?
      // ContractFinancialDetailSchedule ContractFinancialDetailSchedule[]
    );

    console.log(result2)
    return result2

    // const result2 = await this.prisma.contractFinancialDetail.findFirst({
    //   where: { contractItemId: 118 }
    // })

    // const result3 = await this.prisma.contractFinancialDetail.findUnique({
    //   where: { id: 49 }
    // })


    // const result4 = await this.prisma.contractFinancialDetailSchedule.findMany({
    //   where: { id: parseInt(contractfinancialItemId) }
    // })

    // const result5 = await this.prisma.contractFinancialDetailSchedule.findMany({
    //   where: { contractfinancialItemId: parseInt(contractfinancialItemId) }
    // })

    // const sch: Prisma.ContractFinancialDetailScheduleUpdateManyMutationInput = data[2];
    // const result6 = await this.prisma.contractFinancialDetailSchedule.updateMany({
    //   where: { contractfinancialItemId: parseInt(contractfinancialItemId) },
    //   data: sch
    // })

    // // console.log(result2)
    // console.log(result5)

    // const result2 = await this.prisma.contractFinancialDetail.update({
    //   where: { id: parseInt(contractfinancialItemId) },
    //   data: data[1]
    // })

    // return result22

    // const result2 = await this.prisma.contractFinancialDetail.findUnique({
    //   where: { id: parseInt(contractfinancialItemId) }
    // })

    // const result2 = await this.prisma.contractFinancialDetail.update({
    //   where: { id: parseInt(contractfinancialItemId) },
    //   data: data[1]
    // })

    // return result2

  }


  @Get('contractItems/:id')
  async getcontractItems(@Param('id') id: any, @Body() data: Prisma.ContractItemsCreateManyArgs): Promise<any> {

    const result = await this.prisma.contractItems.findMany({
      where:
      {
        contractId: parseInt(id)
      },
      include: {
        item: true,
        frequency: true,
        contract: true,
        currency: true
      }
    });
    return result;
  }


  @Get('contractItemsEditDetails/:id')
  async editcontractItemsDetails(@Param('id') id: any): Promise<any> {

    const result = await this.prisma.contractItems.findMany({
      where:
      {
        id: parseInt(id)
      },
      include: {
        contract: true,
        item: true,
        frequency: true,
        currency: true,
        ContractFinancialDetail: {
          include: {
            ContractFinancialDetailSchedule:
            {
              include: {
                item: true,
                currency: true,
                measuringUnit: true,

              }
            }
            ,
            measuringUnit: true,
            paymentType: true,
            currency: true,
            items: true,
            guaranteecurrency: true
          }
        }
      }
    });
    return result;
  }

  @Get('contractItemsDetails/:id')
  async getcontractItemsDetails(@Param('id') id: any): Promise<any> {

    const result = await this.prisma.contractItems.findMany({
      where:
      {
        contractId: parseInt(id)
      },
      include: {
        contract: true,
        item: true,
        frequency: true,
        currency: true,
        ContractFinancialDetail: {
          include: {
            ContractFinancialDetailSchedule:
            {
              include: {
                item: true,
                currency: true,
                measuringUnit: true,
              }
            }
            ,
            measuringUnit: true,
            paymentType: true,
            currency: true,
            items: true
          }
        }
      }
    });
    return result;
  }




  @Post('category')
  async createCategory(@Body() data: Prisma.CategoryCreateInput): Promise<any> {
    console.log(data)
    const result = this.prisma.category.create({
      data,
    });
    return result;
  }

  @Get('category')
  async getAllCategory(@Body() data: Prisma.CategoryCreateInput): Promise<any> {
    const result = await this.prisma.category.findMany()
    return result;
  }

  @Delete('category/:id')
  async remove(@Param('id') id: any) {
    const category = await this.prisma.category.delete({
      where: {
        id: parseInt(id),
      },
    })
    return category;
  }


  @Post('department')
  async createDepartment(@Body() data: Prisma.DepartmentCreateInput): Promise<any> {

    const result = this.prisma.department.create({
      data,
    });
    return result;
  }

  @Get('department')
  async getAllDepartments(@Body() data: Prisma.DepartmentCreateInput): Promise<any> {
    const result = await this.prisma.department.findMany()
    return result;
  }

  @Delete('department/:id')
  async removeDepartment(@Param('id') id: any) {
    const department = await this.prisma.department.delete({
      where: {
        id: parseInt(id),
      },
    })
    return department;
  }


  @Post('cashflow')
  async createCashFlow(@Body() data: Prisma.CashflowCreateInput): Promise<any> {

    const result = this.prisma.cashflow.create({
      data,
    });
    return result;
  }

  @Get('cashflow')
  async getAllCashflow(@Body() data: Prisma.CashflowCreateInput): Promise<any> {
    const result = await this.prisma.cashflow.findMany()
    return result;
  }

  @Delete('cashflow/:id')
  async removeCashFlow(@Param('id') id: any) {
    const cashflow = await this.prisma.cashflow.delete({
      where: {
        id: parseInt(id),
      },
    })
    return cashflow;
  }


  @Post('item')
  async createItem(@Body() data: Prisma.ItemCreateInput): Promise<any> {

    const result = this.prisma.item.create({
      data,
    });
    return result;
  }

  @Get('item')
  async getItem(@Body() data: Prisma.ItemCreateInput): Promise<any> {
    const result = await this.prisma.item.findMany()
    return result;
  }

  @Delete('item/:id')
  async removeItem(@Param('id') id: any) {
    const item = await this.prisma.item.delete({
      where: {
        id: parseInt(id),
      },
    })
    return item;
  }

  @Post('costcenter')
  async createCostCenter(@Body() data: Prisma.CostCenterCreateInput): Promise<any> {

    const result = this.prisma.costCenter.create({
      data,
    });
    return result;
  }

  @Get('costcenter')
  async getCostCenter(@Body() data: Prisma.CostCenterCreateInput): Promise<any> {
    const result = await this.prisma.costCenter.findMany()
    return result;
  }

  @Delete('costcenter/:id')
  async removeCostCenter(@Param('id') id: any) {
    try {
      const costCenter = await this.prisma.costCenter.delete({
        where: {
          id: parseInt(id),
        },
      })
      return costCenter
    }
    catch (error) {
      let field = error.meta.field_name
      if (error.code === 'P2003') {
        throw new HttpException({
          status: HttpStatus.CONFLICT,
          error: `Foreign key constraint failed on the field.(${field})`,
        }, HttpStatus.CONFLICT, {
          cause: error
        });
      }
    }
  }

  @Post('type')
  async createEntity(@Body() data: Prisma.EntityCreateInput): Promise<any> {

    const result = this.prisma.contractType.create({
      data,
    });
    return result;
  }

  @Post('task')
  async createTask(@Body() data: Prisma.ContractTasksCreateInput): Promise<any> {

    const result = await this.prisma.contractTasks.create({
      data,
    });

    const assigned = this.getPersonById(result.assignedId)
    const assigned_email = (await assigned).email

    const requestor = this.getPersonById(result.requestorId)
    const requestor_email = (await requestor).email

    const dateString = result.due;
    const dateDue = new Date(dateString);

    const formattedDate = dateDue.toLocaleDateString('en-GB', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    });

    // --to be implemented contract id instead of this hardcoding
    const ctr = this.findContractById(result.contractId)
    const ctr_number = (await ctr).number
    const ctr_partener = (await ctr).partner.name
    const ctr_entity = (await ctr).entity.name

    const to = assigned_email;
    const bcc = '';
    const subject = 'Ti-a fost asignat un nou task';

    const text = `Ti-a fost asignat un nou task pe compania ${ctr_entity} de catre utilizatorul ${requestor_email} cu numele "${result.taskName}" pentru contractul cu nr. ${ctr_number} 
    si partenerul ${ctr_partener} care trebuie rezolvat pana la data de ${formattedDate}.`;

    const html = `Ti-a fost asignat un nou task pe compania ${ctr_entity} de catre utilizatorul ${requestor_email} cu numele "${result.taskName}" pentru contractul cu nr. ${ctr_number} 
    si partenerul ${ctr_partener} care trebuie rezolvat pana la data de ${formattedDate}.`;
    const attachments = [];

    this.mailerService.sendMail(to.toString(), bcc.toString(), subject, text, html, attachments)
      .then(() => console.log('Email sent successfully.'))
      .catch(error => console.error('Error sending email:', error));

    console.log(result)
    return result;
  }

  @Get('task')
  async getAllTasks(@Body() data: Prisma.ContractTasksCreateInput): Promise<any> {

    const result = await this.prisma.contractTasks.findMany(
      {
        include:
        {
          requestor: true,
          assigned: true,
          status: true
        }
      });
    return result;
  }

  @Get('task/:id')
  async getTasksByContractId(@Param('id') id: any, @Body() data: Prisma.ContractTasksCreateInput): Promise<any> {

    const result = await this.prisma.contractTasks.findMany({
      include:
      {
        requestor: true,
        assigned: true,
        status: true
      },
      where: { contractId: parseInt(id) },
    });
    return result;
  }


  @Patch('task/:id')
  async updateTasks(@Param('id') id: number, @Body() data: any): Promise<any> {

    const result = await this.prisma.contractTasks.update({
      where: { id: +id },
      data: data,
    });

    const assigned = this.getPersonById((await result).assignedId)
    const assigned_email = (await assigned).email

    const requestor = this.getPersonById((await result).requestorId)
    const requestor_email = (await requestor).email

    const dateString = (await result).due;
    const dateDue = new Date(dateString);

    const formattedDate = dateDue.toLocaleDateString('en-GB', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    });

    // --to be implemented contract id instead of this hardcoding
    const ctr = this.findContractById(4)
    const ctr_number = (await ctr).number
    const ctr_partener = (await ctr).partner.name
    const ctr_entity = (await ctr).entity.name

    const to = assigned_email;
    const bcc = '';
    const subject = 'A fost editat un task asignat tie';

    // const text = `test`
    // const html = `test`
    const text = `A fost editat un task pe compania ${ctr_entity} de catre utilizatorul ${requestor_email} cu numele "${result.taskName}" pentru contractul cu nr. ${ctr_number} 
    si partenerul ${ctr_partener} care trebuie rezolvat pana la data de ${formattedDate}.`;

    const html = `A fost editat un task pe compania ${ctr_entity} de catre utilizatorul ${requestor_email} cu numele "${result.taskName}" pentru contractul cu nr. ${ctr_number} 
    si partenerul ${ctr_partener} care trebuie rezolvat pana la data de ${formattedDate}.`;
    const attachments = [];

    this.mailerService.sendMail(to.toString(), bcc.toString(), subject, text, html, attachments)
      .then(() => console.log('Email sent successfully.'))
      .catch(error => console.error('Error sending email:', error));


    return result;
  }

  @Get('task/:id')
  async getTaskById(@Param('id') id: any): Promise<any> {

    const result = this.prisma.contractTasks.findFirst({
      where: {
        id: parseInt(id)
      }
    });
    return result;
  }

  @Get('type')
  async getEntity(@Body() data: Prisma.EntityCreateInput): Promise<any> {
    const result = await this.prisma.contractType.findMany()
    return result;
  }

  @Delete('type/:id')
  async removeEntity(@Param('id') id: any) {
    const entity = await this.prisma.contractType.delete({
      where: {
        id: parseInt(id),
      },
    })
    return entity;
  }



  @Get()
  async findAll() {
    const contracts = await this.prisma.contracts.findMany(
      {
        include: {
          costcenter: true,
          partner: true,
          entity: true,
          item: true,
          departament: true,
          Category: true,
          cashflow: true,
          type: true,
          status: true
        },
      }
    )

    return contracts;
  }

  @Get('basic/:id')
  async findSimplifiedCtr(@Param('id') id: any) {
    const contract = await this.prisma.contracts.findUnique(
      {
        where: {
          id: parseInt(id),
        },
      }
    )
    return contract.entityId;
  }

  @Get('onlycontract/:id')
  async returnCotract(@Param('id') id: any) {
    const contract = await this.prisma.contracts.findUnique(
      {
        where: {
          id: parseInt(id),
        },
      }
    )
    return contract;
  }


  @Get('alerts')
  async findAllContracts() {
    const contracts = await this.prisma.contracts.findMany(
      {
        include: {
          partner: {
            include: {
              Persons: true
            }
          },
          entity: true,
        },
      }
    )
    return contracts;
  }

  @Get('details/:id')
  async findContractById(@Param('id') id: any) {
    const contracts = await this.prisma.contracts.findUnique(
      {
        include: {
          costcenter: true,
          entity: true,
          partner: true
          // {
          //   include:
          //   {
          //     Address: true
          //   }
          // }
          ,
          PartnerPerson: true,
          EntityPerson: true,

          EntityBank: true,
          PartnerBank: true,

          EntityAddress: true,
          PartnerAddress: true,
          item: true,
          departament: true,
          Category: true,
          cashflow: true,
          type: true,
          status: true
        },
        where: {
          id: parseInt(id),
        },
      }
    )

    return contracts;
  }

  // @Get('a3b')
  // async findOnePlus() {
  //   // return this.contractsService.findAll();
  //   const contracts = await this.prisma.contracts.findMany(
  //     {
  //       where: {
  //         partner: {
  //           contains: 'a3b'
  //         }
  //       },

  //       include: {
  //         contract: true, // Include the related posts
  //       },
  //     })
  //   console.log(contracts);
  //   return contracts;
  // }

  // @Get(':id')
  // async findOne(@Param('id') id: number) {

  //   const user = await this.prisma.contracte.findUnique({
  //     where: {
  //       id: 2,
  //     },
  //   })
  //   console.log(user);
  // }


}