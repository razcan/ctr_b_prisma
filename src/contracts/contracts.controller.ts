
import {
  Controller, Get, Post, Body, Patch, Param, Header, HttpStatus,
  Delete, UploadedFile, UploadedFiles, HttpException, HttpCode,
  Request, UseGuards, UsePipes, ValidationPipe, Res, Headers
} from '@nestjs/common';
import { ContractFinancialDetail, ContractFinancialDetailSchedule, Contracts, Prisma } from '@prisma/client';

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
import { sha256 } from 'crypto-hash';
import { createHash } from 'crypto';

import { AuthGuard } from 'src/auth/auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { v4 as uuidv4 } from 'uuid';
import { Cron, CronExpression } from '@nestjs/schedule';

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


  async geUserEmailById(userId: any) {
    const user = await this.prisma.user.findFirst({
      where: {
        id: parseInt(userId),
      },
      select: {
        email: true
      }
    })
    return user;
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

    data.contractId = parseInt(id);

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


  @Get('additionals/:id')
  async getAditionals(
    @Param('id') id: any): Promise<any> {
    const content = await this.prisma.contracts.findMany({
      where: {
        parentId: parseInt(id),
      },
      include: {
        entity: true,
        partner: true,
        EntityAddress: true,
        PartnerAddress: true,
        type: true,
        status: true
      },
    })
    return content;
  }






  @Post()
  async createContract(@Body() data: any): Promise<any> {

    const header = data[0]

    const dynamicInfo = data[1]

    const result = await this.prisma.contracts.create({
      data: header
    });

    dynamicInfo.contractId = result.id;

    const existdynamicInfo = await this.prisma.contractDynamicFields.findFirst({
      where: { contractId: result.id }
    })

    if (existdynamicInfo) {
      const resdynamicInfo = await this.prisma.contractDynamicFields.updateMany({
        where: { contractId: result.id },
        data: dynamicInfo,
      })
    } else {
      const resdynamicInfo = await this.prisma.contractDynamicFields.create({ data: dynamicInfo })
    }

    const audit = this.prisma.contractsAudit.create({
      data: {
        operationType: "I",
        id: result.id,
        number: header.number,
        typeId: header.typeId,
        statusId: header.statusId,
        start: header.start,
        end: header.end,
        sign: header.sign,
        completion: header.completion,
        remarks: header.remarks,
        categoryId: header.categoryId,
        departmentId: header.departmentId,
        cashflowId: header.cashflowId,
        itemId: header.itemId,
        costcenterId: header.costcenterId,
        automaticRenewal: header.automaticRenewal,
        partnersId: header.partnersId,
        entityId: header.entityId,
        partnerpersonsId: header.partnerpersonsId,
        entitypersonsId: header.entitypersonsId,
        entityaddressId: header.entityaddressId,
        partneraddressId: header.partneraddressId,
        entitybankId: header.entitybankId,
        partnerbankId: header.partnerbankId,
        userId: header.userId
      }
    });

    return audit;
  }

  @Patch('/:id')
  async update(@Param('id') id: number, @Body() data: any) {

    const header = data[0]

    const dynamicInfo = data[1]

    const existdynamicInfo = await this.prisma.contractDynamicFields.findFirst({
      where: { contractId: +id }
    })

    if (existdynamicInfo) {
      const resdynamicInfo = await this.prisma.contractDynamicFields.updateMany({
        where: { contractId: +id },
        data: dynamicInfo,
      })
    } else {
      const resdynamicInfo = await this.prisma.contractDynamicFields.create({ data: dynamicInfo })
    }

    const contract = await this.prisma.contracts.update({
      where: { id: +id },
      data: header,
    })

    const audit = this.prisma.contractsAudit.create({
      data: {
        operationType: "U",
        id: contract.id,
        number: header.number,
        typeId: header.typeId,
        statusId: header.statusId,
        start: header.start,
        end: header.end,
        sign: header.sign,
        completion: header.completion,
        remarks: header.remarks,
        categoryId: header.categoryId,
        departmentId: header.departmentId,
        cashflowId: header.cashflowId,
        itemId: header.itemId,
        costcenterId: header.costcenterId,
        automaticRenewal: header.automaticRenewal,
        partnersId: header.partnersId,
        entityId: header.entityId,
        partnerpersonsId: header.partnerpersonsId,
        entitypersonsId: header.entitypersonsId,
        entityaddressId: header.entityaddressId,
        partneraddressId: header.partneraddressId,
        entitybankId: header.entitybankId,
        partnerbankId: header.partnerbankId,
        userId: header.userId
      }


    });

    return audit;
  }


  @Get('dynamicfields/:id')
  async getDynamicfields(@Body() data: Prisma.ContractDynamicFieldsCreateInput, @Param('id') id: any): Promise<any> {
    const content = await this.prisma.contractDynamicFields.findMany({
      where: {
        contractId: parseInt(id),
      },
    })
    return content;
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

  @Get('generalreport')
  async getGeneralReport() {

    const result1 = await this.prisma.$queryRaw(
      Prisma.sql`SELECT * FROM public.get_contract_details()`
    )
    return result1;
  }

  @Get('cashflowreport')
  async getCashFlowReport() {

    const result1 = await this.prisma.$queryRaw(
      Prisma.sql`SELECT * FROM  public.report_cashflow()`
    )
    return result1;
  }

  @Get('wfactiverules')
  async wfactiverules() {

    const result1 = await this.prisma.$queryRaw(
      Prisma.sql`SELECT * FROM public.active_wf_rulesok()`
    )
    console.log(result1);
    return result1;
  }

  @Get('cashflow')
  async getCalculate_cashflow() {


    const result3: { tip: string, billingvalue: string, month_number: number }[]
      = await this.prisma.$queryRaw(
        Prisma.sql`select * from public.calculate_cashflow_func()`
      )

    const start_date = new Date()
    let month = 1 + start_date.getMonth();


    const Receipts = result3
      .filter(item => item.tip === "I")


    const Payments = result3
      .filter(item => item.tip === "P")

    const rec: any[] = [];
    // const maxMonth = Math.max(...Receipts.map(item => item.month_number));
    const maxMonth = month + 5;

    for (let i = month; i <= maxMonth; i++) {
      const found = Receipts.find(item => item.month_number == i);
      if (found) {
        rec.push(found);
      } else {
        rec.push({ tip: 'I', billingvalue: 0, month_number: i });
      }
    }

    const Receipts2 = rec
      .map(item => parseFloat(item.billingvalue)
      );



    const pay: any[] = [];

    for (let i = month; i <= maxMonth; i++) {
      const found = Payments.find(item => item.month_number == i);
      if (found) {
        pay.push(found);
      } else {
        pay.push({ tip: 'P', billingvalue: 0, month_number: i });
      }
    }

    const Payments2 = pay
      .map(item => parseFloat(item.billingvalue)
      );

    const final = []
    final.push(Receipts2);
    final.push(Payments2);
    final.push(month);
    final.push(maxMonth);

    return final;
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

    // const result = await this.prisma.contractFinancialDetailSchedule.findMany({
    //   where:
    //   {
    //     contractfinancialItemId: ctrfinDetailId.id
    //   }
    // })

    const resultw = await this.prisma.contractFinancialDetailSchedule.deleteMany({
      where:
      {
        contractfinancialItemId: ctrfinDetailId.id
      }
    });

    return resultw;
  }


  generateArrayHash(arr: any[]): string {
    const hash = createHash('sha256');
    hash.update(JSON.stringify(arr));
    return hash.digest('hex');
  }


  @Patch('updatecontractItems/:id/:ctrId/:contractfinancialItemId')
  async updatecontractItems(
    @Param('id') id: string,
    @Param('ctrId') ctrId: string,
    @Param('contractfinancialItemId') contractfinancialItemId: string,
    @Body() data: any): Promise<any> {
    // console.log(id, ctrId, contractfinancialItemId)


    const result = await this.prisma.contractItems.update({
      where: { id: parseInt(id) },
      data: data[0]
    })

    const finDetail: any = data[1]
    const finCtrFinDetail: Prisma.ContractFinancialDetailUncheckedUpdateInput = finDetail

    const result2 = this.prisma.contractFinancialDetail.update({
      where: { id: parseInt(contractfinancialItemId) },
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
        guaranteeLetterCurrencyid: finCtrFinDetail.guaranteeLetterCurrencyid,
        totalContractValue: finCtrFinDetail.totalContractValue
      }
    }
    );
    // console.log(await result2)

    let schBill = data[2]
    let x = parseInt(id)

    const resultId = await this.prisma.contractFinancialDetail.findFirst({
      where: { contractItemId: parseInt(id) }
    })

    const result4 = await this.prisma.contractFinancialDetailSchedule.findMany({
      where: { contractfinancialItemId: resultId.id }
    })

    const objString: any = JSON.stringify(result4);

    const hash1 = this.generateArrayHash(objString);

    const objStringschBill: any = JSON.stringify(schBill)

    const hash2 = this.generateArrayHash(objStringschBill);

    // console.log("hash1: ", hash1)
    // console.log("hash2: ", hash2)

    if (hash1 !== hash2) {
      for (let i = 0; i < schBill.length; i++) {
        schBill[i].contractfinancialItemId = resultId.id
      }

      const result5 = await this.prisma.contractFinancialDetailSchedule.deleteMany({
        where: { contractfinancialItemId: resultId.id }
      })

      const result3 = this.prisma.contractFinancialDetailSchedule.createMany({
        data: schBill,
      });

      return result3;
    }
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





  @Post('workflow')
  async createworkflow(@Body() data: any): Promise<any> {
    // console.log(data)

    const uuid = uuidv4();
    console.log("uuid", uuid)

    const wfg = data[0];
    const rules = data[1];
    const settings = data[2];
    const users = data[3];

    console.log(users)

    const size = rules.length;
    const result = await this.prisma.workFlow.create({
      data: wfg,
    });

    for (let i = 0; i < size; i++) {
      rules[i].workflowId = result.id
    }

    const result1 = await this.prisma.workFlowRules.createMany({
      data: rules,
    });

    settings.workflowId = result.id;

    const result2 = await this.prisma.workFlowTaskSettings.create({
      data: settings,
    });

    users.workflowTaskSettingsId = result2.id

    interface userss {
      workflowTaskSettingsId: number,
      userId: number,
      approvalOrderNumber: number
    }

    const users_final: userss[] = []

    for (let j = 0; j < users.target.length; j++) {
      const add: userss = {
        workflowTaskSettingsId: result2.id,
        userId: users.target[j].id,
        approvalOrderNumber: j + 1
      }
      users_final.push(add)
    }

    const result3 = await this.prisma.workFlowTaskSettingsUsers.createMany({
      data: users_final,
    });


    console.log(result1, result2, result3)
    //return result;
  }

  @Patch('workflow/:id')
  async updateWorkflow(@Body() data: any, @Param('id') id: any): Promise<any> {
    // console.log(data)

    const wfg = data[0];
    const rules = data[1];
    const settings = data[2];
    const users = data[3];


    const size = rules.length;
    const result = await this.prisma.workFlow.update({
      where: {
        id: parseInt(id)
      },
      data: wfg,
    });


    if (rules.length > 0) {
      const result1 = await this.prisma.workFlowRules.deleteMany({
        where: {
          workflowId: parseInt(id)
        }
      })

      for (let i = 0; i < rules.length; i++) {
        const result1 = await this.prisma.workFlowRules.createMany({
          data: {
            workflowId: parseInt(id),
            ruleFilterName: rules[i].ruleFilterName,
            ruleFilterSource: rules[i].ruleFilterSource,
            ruleFilterValue: rules[i].ruleFilterValue,
            ruleFilterValueName: rules[i].ruleFilterValueName
          }
          ,
        });
      }
    }

    if (rules.length == 0) {
      const result1 = await this.prisma.workFlowRules.deleteMany({
        where: {
          workflowId: parseInt(id)
        }
      })
    }

    if (settings.length > 0) {

      const result1 = await this.prisma.workFlowTaskSettings.deleteMany({
        where: {
          workflowId: parseInt(id)
        }
      })

      for (let i = 0; i < rules.length; i++) {
        const result2 = await this.prisma.workFlowTaskSettings.createMany({
          data: {
            workflowId: parseInt(id),
            approvedByAll: settings[i].approvedByAll,
            approvalTypeInParallel: settings[i].approvalTypeInParallel,
            taskName: settings[i].taskName,
            taskDueDateId: settings[i].taskDueDateId,
            taskNotes: settings[i].taskNotes,
            taskSendNotifications: settings[i].taskSendNotifications,
            taskSendReminders: settings[i].taskSendReminders,
            taskReminderId: settings[i].taskReminderId,
            taskPriorityId: settings[i].taskPriorityId
          }
        });
      }

    }


    interface userss {
      workflowTaskSettingsId: number,
      userId: number,
      approvalOrderNumber: number
    }

    const users_final: userss[] = []

    for (let j = 0; j < users.target.length; j++) {
      const add: userss = {
        workflowTaskSettingsId: users.workflowTaskSettingsId,
        userId: users.target[j].id,
        approvalOrderNumber: j + 1
      }
      users_final.push(add)
    }

    console.log(users_final)

    const wfid = await this.prisma.workFlowTaskSettings.findFirst({
      where: {
        workflowId: parseInt(id)
      }
    })

    if (users_final.length > 0) {

      const result3 = await this.prisma.workFlowTaskSettingsUsers.deleteMany({
        where: {
          workflowTaskSettingsId: wfid.id
        }
      })
      for (let j = 0; j < users_final.length; j++) {

        const result = await this.prisma.workFlowTaskSettingsUsers.createMany({
          data: {
            workflowTaskSettingsId: wfid.id,
            userId: users_final[j].userId,
            approvalOrderNumber: users_final[j].approvalOrderNumber
          },
        });
      }
    }
  }


  @Get('workflow/:id')
  async getworkflowbyId(@Param('id') id: any): Promise<any> {
    const result = await this.prisma.workFlow.findUnique({
      where: {
        id: parseInt(id)
      },
      include: {
        WorkFlowRules: true,
        WorkFlowTaskSettings: {
          include: {
            WorkFlowTaskSettingsUsers: true
          }
        }
      }
    })
    return result;
  }

  @Get('wflist')
  async getAllWF(@Body() data: Prisma.WorkFlowContractTasksCreateInput): Promise<any> {
    const result = await this.prisma.workFlow.findMany()
    return result;
  }


  @Get('priority')
  async getAllPriority(@Body() data: Prisma.ContractTasksPriorityCreateInput): Promise<any> {
    const result = await this.prisma.contractTasksPriority.findMany()
    return result;
  }

  @Get('reminders')
  async getAllReminders(@Body() data: Prisma.ContractTasksRemindersCreateInput): Promise<any> {
    const result = await this.prisma.contractTasksReminders.findMany()
    return result;
  }

  @Get('duedates')
  async getAllDueDates(@Body() data: Prisma.ContractTasksDueDatesCreateInput): Promise<any> {
    const result = await this.prisma.contractTasksDueDates.findMany()
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

  @Get('cashflownom')
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

  // @Post('type')
  // async createEntity(@Body() data: Prisma.EntityCreateInput): Promise<any> {

  //   const result = this.prisma.contractType.create({
  //     data,
  //   });
  //   return result;
  // }

  @Post('task')
  async createTask(@Body() data: Prisma.ContractTasksCreateInput): Promise<any> {

    const result = await this.prisma.contractTasks.create({
      data,
    });

    const assigned = this.geUserEmailById(result.assignedId)
    const assigned_email = (await assigned).email

    const requestor = this.geUserEmailById(result.requestorId)
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
        // include:
        // {
        //   requestor: true,
        //   assigned: true,
        //   status: true
        // }
      });
    return result;
  }

  // @Get('usertask/:userId')
  // async getAllTasksByUserId(
  //   @Param('userId') userId: any,
  //   @Body() data: Prisma.ContractTasksCreateInput): Promise<any> {

  //   const result = await this.prisma.contractTasks.findMany(
  //     {
  //       include:
  //       {
  //         requestor: true,
  //         assigned: true,
  //         status: true
  //       },
  //       where: {
  //         assignedId: parseInt(userId)
  //       },
  //     }
  //   );
  //   return result;
  // }

  @Get('usertask/:userId')
  async getAllTasksByUserId(
    @Param('userId') userId: any,
    @Body() data: Prisma.ContractTasksCreateInput): Promise<any> {

    const result = await this.prisma.contractTasks.findMany(
      {
        include:
        {
          requestor: {
            select: {
              name: true
            }
          },
          assigned: {
            select: {
              name: true
            }
          },
          status: {
            select: {
              name: true
            }
          },
        },
        where: {
          assignedId: parseInt(userId),
          progress: {
            lt: 100
            // Filter tasks where progress is less than or equal to 100
          },
          statusId: 1
        },
      }
    );
    return result;
  }



  @Get('task/:id')
  async getTasksByContractId(@Param('id') id: any, @Body() data: Prisma.ContractTasksCreateInput): Promise<any> {

    const result = await this.prisma.contractTasks.findMany({
      include:
      {
        requestor: {
          select: {
            name: true
          }
        },
        assigned: {
          select: {
            name: true
          }
        },
        status: {
          select: {
            name: true
          }
        }
      },
      where: {
        contractId: parseInt(id),
        progress: {
          lte: 100 // Filter tasks where progress is less than or equal to 100
        },
        statusId: 1
      },
    });
    return result;
  }


  @Patch('task/:id/:contractId')
  async updateTasks(
    @Param('id') id: any,
    @Param('contractId') contractId: any,
    @Body() data: any): Promise<any> {

    const result = await this.prisma.contractTasks.update({
      where: { id: parseInt(id) },
      data: data,
    });

    const assigned = this.geUserEmailById((await result).assignedId)
    const assigned_email = (await assigned).email

    const requestor = this.geUserEmailById((await result).requestorId)
    const requestor_email = (await requestor).email

    const dateString = (await result).due;
    const dateDue = new Date(dateString);

    const formattedDate = dateDue.toLocaleDateString('en-GB', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    });

    // --to be implemented contract id instead of this hardcoding
    const ctr = this.findContractById(contractId)
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
  async getEntity(@Body() data: any): Promise<any> {
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


  @UseGuards(AuthGuard)
  // @Roles('Administrator', 'Editor') // Set multiple roles here
  @Roles('Administrator', 'Editor')
  @UseGuards(RolesGuard)
  @Get('/:purchasing')
  async findAll(
    @Param('purchasing') purchasing: any,
    @Body() data: any,
    @Headers() headers): Promise<any> {

    const entity = headers.entity.split(',');


    const final: number[] = []
    entity.map(entity => final.push(parseInt(entity, 10))
    )

    let res: boolean = purchasing.toLowerCase() === "true";
    const isSales: boolean = res ? true : false;
    const contracts = await this.prisma.contracts.findMany(
      {
        where: {
          parentId: 0,
          entityId: {
            in: final
          },
          isPurchasing: isSales
        },
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

  @UseGuards(AuthGuard)
  // @Roles('Administrator', 'Editor') // Set multiple roles here
  @Roles('Administrator', 'Editor')
  @UseGuards(RolesGuard)
  @Get('')
  async findAllWithoutFilters(
    @Body() data: any,
    @Headers() headers): Promise<any> {

    const entity = headers.entity.split(',');


    const final: number[] = []
    entity.map(entity => final.push(parseInt(entity, 10))
    )

    const contracts = await this.prisma.contracts.findMany(
      {
        where: {
          parentId: 0,
          entityId: {
            in: final
          },
        },
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
  //cf
  @Post('stackedbar')
  async StackedBar(): Promise<any> {

    const overSixMonths = new Date();
    overSixMonths.setMonth(overSixMonths.getMonth() + 6);


    const receipts = await this.prisma.contractItems.findMany({
      where: {
        active: true
      },
      include: {
        ContractFinancialDetail: {
          where: {
            active: true
          },
          include: {
            ContractFinancialDetailSchedule: {
              where: {
                active: true,
                date: {
                  lte: overSixMonths.toISOString(),
                  gte: new Date().toISOString()
                }
              }
            }
          }
        },
        contract: {
          where: {
            isPurchasing: false,
            id: 5
          }
        }
      }
    });

    const x = receipts.map(res => res.ContractFinancialDetail)

    interface Reee {
      date: Date,
      billingValue: Number,
      currencyid: Number,
      type: String
    }
    const receipts_final: Reee[] = []
    for (let i = 1; i < x[0][0].ContractFinancialDetailSchedule.length; i++) {

      receipts_final.push({
        date: x[0][0].ContractFinancialDetailSchedule[i].date,
        billingValue: x[0][0].ContractFinancialDetailSchedule[i].billingValue,
        currencyid: x[0][0].ContractFinancialDetailSchedule[i].currencyid,
        type: "I"
      }
      )
    }

    console.log(receipts_final)
    //treb sa returnez ce gasesc in ContractFinancialDetailSchedule zi,luna ,valoare,
    // return x;


  }

  // @Post('stackedbar')
  // async StackedBar(): Promise<any> {

  //   const counts = await this.prisma.contracts.groupBy({
  //     by: ['isPurchasing'],
  //     _count: true,
  //     // _sum: true
  //   }

  //   );

  //   return counts;
  // }

  @Post('cashflow')
  async getCashflow() {
    try {
      const userTransactions = await this.prisma.contractItems.findMany({
        // where: {
        //   statusId: {
        //     gt: 1,
        //   },
        // },
        // include: {
        //   ContractItems: true,
        // },
        //  groupBy: ['isPurchasing'],
        // _sum: {
        //   amount: true,
        // },
      });

      console.log(userTransactions);
      return (userTransactions)
      // userTransactions will contain an array of objects,
      // each object representing a user and their total transaction amount.
    } catch (error) {
      console.error('Error fetching user transaction sum:', error);
    } finally {
      await this.prisma.$disconnect();
    }
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
  public async findContractById(@Param('id') id: any) {
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


  formatDate = (actuallDate: Date) => {

    if (actuallDate) {
      const originalDate = new Date(actuallDate.toString());
      const day = originalDate.getDate().toString().padStart(2, '0'); // Get the day and pad with leading zero if needed
      const month = (originalDate.getMonth() + 1).toString().padStart(2, '0'); // Get the month (January is 0, so we add 1) and pad with leading zero if needed
      const year = originalDate.getFullYear(); // Get the full year
      const date = `${day}.${month}.${year}`;
      return (date)
    }
    else return
  }

  // trebuie escape char in loc de " trebuie \"
  // trebuie trimis json de forma  {"text": "CONTRACT..."} 
  @Post('replacePlaceholders/:CtrId')
  async replacePlaceholders(
    @Body() data: any,
    @Param('CtrId') CtrId: any,
  ): Promise<any> {

    const actualContract = await this.findContractById(CtrId)

    const originalString: any = data.text;

    const contract_Sign = this.formatDate(actualContract?.sign);
    const contract_Number = actualContract?.number;
    const contract_Partner = actualContract?.partner.name;
    const contract_Entity = actualContract?.entity.name;
    const contract_Start = this.formatDate(actualContract?.start);
    const contract_End = this.formatDate(actualContract?.end);
    const contract_remarks = actualContract?.remarks;
    const contract_PartnerFiscalCode = actualContract?.partner.fiscal_code;
    const contract_PartnerComercialReg = actualContract?.partner.commercial_reg;
    const contract_PartnerAddress = actualContract?.PartnerAddress.completeAddress;
    const contract_PartnerStreet = actualContract?.PartnerAddress.Street;
    const contract_PartnerCity = actualContract?.PartnerAddress.City;
    const contract_PartnerCounty = actualContract?.PartnerAddress.County;
    const contract_PartnerCountry = actualContract?.PartnerAddress.Country;
    const contract_PartnerBank = actualContract?.PartnerBank.bank;
    const contract_PartnerBranch = actualContract?.PartnerBank.branch;
    const contract_PartnerIban = actualContract?.PartnerBank.iban;
    const contract_PartnerCurrency = actualContract?.PartnerBank.currency;
    const contract_PartnerPerson = actualContract?.PartnerPerson.name;
    const contract_PartnerEmail = actualContract?.PartnerPerson.email;
    const contract_PartnerPhone = actualContract?.PartnerPerson.phone;
    const contract_PartnerRole = actualContract?.PartnerPerson.role;
    const contract_EntityFiscalCode = actualContract?.entity.fiscal_code;
    const contract_EntityComercialReg = actualContract?.entity.commercial_reg;
    const contract_EntityAddress = actualContract?.EntityAddress.completeAddress;
    const contract_EntityStreet = actualContract?.EntityAddress.Street;
    const contract_EntityCity = actualContract?.EntityAddress.City;
    const contract_EntityCounty = actualContract?.EntityAddress.County;
    const contract_EntityCountry = actualContract?.EntityAddress.Country;
    const contract_EntityBranch = actualContract?.EntityBank.branch;
    const contract_EntityIban = actualContract?.EntityBank.iban;
    const contract_EntityCurrency = actualContract?.EntityBank.currency;
    const contract_EntityPerson = actualContract?.EntityPerson.name;
    const contract_EntityEmail = actualContract?.EntityPerson.email;
    const contract_EntityPhone = actualContract?.EntityPerson.phone;
    const contract_EntityRole = actualContract?.EntityPerson.role;
    const contract_Type = actualContract?.type.name;


    //de adaugat cod uni de inregistrare si r, 
    const replacements: { [key: string]: string } = {
      "ContractNumber": contract_Number,
      "SignDate": contract_Sign,
      "StartDate": contract_Start,
      "FinalDate": contract_End,
      "PartnerName": contract_Partner,
      "EntityName": contract_Entity,
      "ShortDescription": contract_remarks,
      "PartnerComercialReg": contract_PartnerComercialReg,
      "PartnerFiscalCode": contract_PartnerFiscalCode,
      "EntityFiscalCode": contract_EntityFiscalCode,
      "EntityComercialReg": contract_EntityComercialReg,
      "PartnerAddress": contract_PartnerAddress,
      "PartnerStreet": contract_PartnerStreet,
      "PartnerCity": contract_PartnerCity,
      "PartnerCounty": contract_PartnerCounty,
      "PartnerCountry": contract_PartnerCountry,
      "PartnerBank": contract_PartnerBank,
      "PartnerBranch": contract_PartnerBranch,
      "PartnerIban": contract_PartnerIban,
      "PartnerCurrency": contract_PartnerCurrency,
      "PartnerPerson": contract_PartnerPerson,
      "PartnerEmail": contract_PartnerEmail,
      "PartnerPhone": contract_PartnerPhone,
      "PartnerRole": contract_PartnerRole,
      "EntityAddress": contract_EntityAddress,
      "EntityStreet": contract_EntityStreet,
      "EntityCity": contract_EntityCity,
      "EntityCounty": contract_EntityCounty,
      "EntityCountry": contract_EntityCountry,
      "EntityBranch": contract_EntityBranch,
      "EntityIban": contract_EntityIban,
      "EntityCurrency": contract_EntityCurrency,
      "EntityPerson": contract_EntityPerson,
      "EntityEmail": contract_EntityEmail,
      "EntityPhone": contract_EntityPhone,
      "EntityRole": contract_EntityRole,
      "Type": contract_Type
    };

    let replacedString: string = originalString;
    for (const key in replacements) {
      if (Object.prototype.hasOwnProperty.call(replacements, key)) {
        replacedString = replacedString.replace(key, replacements[key]);
      }
    }
    return replacedString
  }


  @Get('approveTask/:uuid')
  async approveTask(
    @Param('uuid') uuid: any
  ): Promise<any> {

    const approve = await this.prisma.workFlowContractTasks.updateMany({
      where: {
        uuid: uuid
      },
      data: {
        statusId: 4
        // aprobat
      }
    })
    if (approve.count > 0) {
      const response = "Task-ul a fost aprobat cu succes!"
      return (response)
    }
    else {
      const response = "Task-ul nu a fost aprobat cu succes!"
      return (response)
    }
  }

  @Get('rejectTask/:uuid')
  async rejectTask(
    @Param('uuid') uuid: any
  ): Promise<any> {

    const approve = await this.prisma.workFlowContractTasks.updateMany({
      where: {
        uuid: uuid
      },
      data: {
        statusId: 5
        // aprobat
      }
    })
    if (approve.count > 0) {
      const response = "Task-ul a fost respins cu succes!"
      return (response)
    }
    else {
      const response = "Task-ul nu a fost respins!"
      return (response)
    }

  }

  // const result = await this.prisma.contractTasks.update({
  //   where: { id: parseInt(id) },
  //   data: data,
  // });



  // @Cron(CronExpression.EVERY_10_SECONDS)
  // async Parser(): Promise<any> {
  //   const all_wf = await this.prisma.workFlowRules.findMany({
  //     where: {
  //       workflow: {
  //         status: true
  //       }
  //     },
  //     include: {
  //       workflow: true
  //     }
  //   });
  //   console.log("iupi", all_wf);
  // }


}