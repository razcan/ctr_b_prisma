
import {
  Controller, Get, Post, Body, Patch, Param, Header, HttpStatus,
  Delete, UploadedFile, UploadedFiles, HttpException, HttpCode, Request, UseGuards, UsePipes, ValidationPipe, Res
} from '@nestjs/common';
import { Contracts, ContractsDetails, Prisma } from '@prisma/client';

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

    console.log(data, id, result, data.length)

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

  // @Get('content/:id')
  // async getContent(@Body() data: Prisma.ContractContentFindFirstArgs, @Param('id') id: any): Promise<any> {

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

  @Patch('content/:id')
  async updateContent(@Body() data: Prisma.ContractContentCreateInput, @Param('id') id: any): Promise<any> {

    const content = await this.prisma.contractContent.update({
      where: {
        id: parseInt(id),
      },
      data: data,
    })
    return content;
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
  async createContractItems(@Body() data: Prisma.ContractItemsCreateManyInput): Promise<any> {
    // console.log(data)
    const result = this.prisma.contractItems.createMany({
      data,
    });
    return result;
  }


  @Get('contractItems/:id')
  async getcontractItems(@Param('id') id: any, @Body() data: Prisma.ContractItemsCreateManyArgs): Promise<any> {

    const result = await this.prisma.contractItems.findMany({
      where: { contractId: parseInt(id) },
    });
    return result;
  }

  @Post('financialDetail')
  async createFinancialDetail(@Body() data: Prisma.ContractFinancialDetailCreateInput): Promise<any> {
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

    const assigned = this.getPersonById(result.assigned)
    const assigned_email = (await assigned).email

    const requestor = this.getPersonById(result.requestor)
    const requestor_email = (await requestor).email

    const dateString = result.due;
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
    const subject = 'Ti-a fost asignat un nou task';

    const text = `Ti-a fost asignat un nou task pe compania ${ctr_entity} de catre utilizatorul ${requestor_email} cu numele "${result.taskName}" pentru contractul cu nr. ${ctr_number} 
    si partenerul ${ctr_partener} care trebuie rezolvat pana la data de ${formattedDate}.`;

    const html = `Ti-a fost asignat un nou task pe compania ${ctr_entity} de catre utilizatorul ${requestor_email} cu numele "${result.taskName}" pentru contractul cu nr. ${ctr_number} 
    si partenerul ${ctr_partener} care trebuie rezolvat pana la data de ${formattedDate}.`;
    const attachments = [];

    this.mailerService.sendMail(to.toString(), bcc.toString(), subject, text, html, attachments)
      .then(() => console.log('Email sent successfully.'))
      .catch(error => console.error('Error sending email:', error));

    // console.log(result)
    return result;
  }

  @Get('task')
  async getAllTasks(@Body() data: Prisma.ContractTasksCreateInput): Promise<any> {

    const result = await this.prisma.contractTasks.findMany({});
    return result;
  }

  @Get('task/:id')
  async getTasksByContractId(@Param('id') id: any, @Body() data: Prisma.ContractTasksCreateInput): Promise<any> {

    const result = await this.prisma.contractTasks.findMany({
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

    const assigned = this.getPersonById((await result).assigned)
    const assigned_email = (await assigned).email

    const requestor = this.getPersonById((await result).requestor)
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
}