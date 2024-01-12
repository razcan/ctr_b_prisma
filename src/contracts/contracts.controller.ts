import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { PrismaService } from 'src/prisma.service';
import { ContractsService } from './contracts.service';
import { CreateContractDto } from './dto/create-contract.dto';
import { CreateContractsDto } from '../contracts/dto/create-contracts.dto'
import { CreateContractsDetailsDto } from '../contractsDetails/dto/create-contractsDetails.dto'
import { UpdateContractDto } from './dto/update-contract.dto';
import { CreateCategoryDto } from '../category/dto/create-category.dto'
import { Injectable } from '@nestjs/common';
import { Contracts, ContractsDetails, Prisma } from '@prisma/client';

@Controller('contracts')
export class ContractsController {
  constructor(
    private readonly contractsService: ContractsService,
    private prisma: PrismaService
  ) { }

  @Post()
  async createContract(@Body() data: Prisma.ContractsCreateInput): Promise<any> {

    const rezult = this.prisma.contracts.create({
      data,
    });

    return rezult;
  }


  @Post('category')
  async createCategory(@Body() data: Prisma.CategoryCreateInput): Promise<any> {

    const rezult = this.prisma.category.create({
      data,
    });
    return rezult;
  }

  @Get('category')
  async getAllCategory(@Body() data: Prisma.CategoryCreateInput): Promise<any> {
    const rezult = await this.prisma.category.findMany()
    return rezult;
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

    const rezult = this.prisma.department.create({
      data,
    });
    return rezult;
  }

  @Get('department')
  async getAllDepartments(@Body() data: Prisma.DepartmentCreateInput): Promise<any> {
    const rezult = await this.prisma.department.findMany()
    return rezult;
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


  @Get()
  async findAll() {
    // return this.contractsService.findAll();
    const contracts = await this.prisma.contracts.findMany(
      {
        include: {
          contract: true, // Include the related posts
        },
      })
    console.log(contracts);
    return contracts;
  }

  @Get('a3b')
  async findOnePlus() {
    // return this.contractsService.findAll();
    const contracts = await this.prisma.contracts.findMany(
      {
        where: {
          partner: {
            contains: 'a3b'
          }
        },

        include: {
          contract: true, // Include the related posts
        },
      })
    console.log(contracts);
    return contracts;
  }

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
        number: updateContractDto.number,
        type: updateContractDto.type
      },
    })

    return contract;
  }

  // @Delete(':id')
  // remove(@Param('id') id: string) {
  //   return this.contractsService.remove(+id);
  // }
}
