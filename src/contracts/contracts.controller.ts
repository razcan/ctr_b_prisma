
import {
  Controller, Get, Post, Body, Patch, Param, Header, HttpStatus,
  Delete, UploadedFile, UploadedFiles, HttpException, HttpCode, Request, UseGuards, UsePipes, ValidationPipe, Res
} from '@nestjs/common';
import { Contracts, ContractsDetails, Prisma } from '@prisma/client';

import { PrismaService } from 'src/prisma.service';
import { ContractsService } from './contracts.service';
import { CreateContractsDto } from '../contracts/dto/create-contracts.dto'
import { CreateContractsDetailsDto } from '../contractsDetails/dto/create-contractsDetails.dto'
import { UpdateContractDto } from './dto/update-contract.dto';
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


@Controller('contracts')
export class ContractsController {
  constructor(
    private readonly contractsService: ContractsService,
    private prisma: PrismaService
  ) { }



  @Post('file')
  @UseInterceptors(FilesInterceptor('files'))
  uploadFiles(
    @UploadedFiles() files: Express.Multer.File,
  ) {
    let data: any = files
    const result = this.prisma.contractAttachments.createMany({
      data,
    });
    return result;

  }

  @Get('file')
  async getAllFilesByContractId(): Promise<any> {
    const result = await this.prisma.contractAttachments.findMany()
    return result;
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
    const content = await this.prisma.contractContent.findUnique({
      where: {
        id: parseInt(id),
      },
    })
    return content;
  }




  @Post()
  async createContract(@Body() data: any): Promise<any> {

    console.log(data);

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

  @Get('details/:id')
  async findContractById(@Param('id') id: any) {
    const contracts = await this.prisma.contracts.findMany(
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

  @Patch(':id')
  async update(@Param('id') id: number, @Body() updateContractDto: UpdateContractDto) {

    const contract = await this.prisma.contracts.update({
      where: { id: +id },
      data: {
        number: updateContractDto.number
      },
    })

    return contract;
  }

  // @Delete(':id')
  // remove(@Param('id') id: string) {
  //   return this.contractsService.remove(+id);
  // }
}
