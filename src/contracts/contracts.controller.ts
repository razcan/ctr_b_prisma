import { Controller, Get, Post, Body, Patch, Param, Delete, HttpException, HttpStatus } from '@nestjs/common';
import { Contracts, ContractsDetails, Prisma } from '@prisma/client';

import { PrismaService } from 'src/prisma.service';
import { ContractsService } from './contracts.service';
import { CreateContractsDto } from '../contracts/dto/create-contracts.dto'
import { CreateContractsDetailsDto } from '../contractsDetails/dto/create-contractsDetails.dto'
import { UpdateContractDto } from './dto/update-contract.dto';
import { CreateCategoryDto } from '../category/dto/create-category.dto'
import { Injectable } from '@nestjs/common';

@Controller('contracts')
export class ContractsController {
  constructor(
    private readonly contractsService: ContractsService,
    private prisma: PrismaService
  ) { }

  @Post()
  async createContract(@Body() data: Prisma.ContractsCreateInput): Promise<any> {

    const result = this.prisma.contracts.create({
      data,
    });

    return result;
  }


  @Post('category')
  async createCategory(@Body() data: Prisma.CategoryCreateInput): Promise<any> {

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
