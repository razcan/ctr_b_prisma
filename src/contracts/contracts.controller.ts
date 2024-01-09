import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { PrismaService } from 'src/prisma.service';
import { ContractsService } from './contracts.service';
import { CreateContractDto } from './dto/create-contract.dto';
import { CreateContractsDto } from '../contracts/dto/create-contracts.dto'
import { CreateContractsDetailsDto } from '../contractsDetails/dto/create-contractsDetails.dto'
import { UpdateContractDto } from './dto/update-contract.dto';
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


  // @Post('total')
  // async create(@Body()
  // contractsDto: CreateContractDto, contractsDetailsDto: CreateContractsDetailsDto
  // ) {
  //   const contract: CreateContractsDto = await this.prisma.contracts.create
  //     ({
  //       data:
  //       {

  //         "number": "23AAA5",
  //         "type": "Service5",
  //         "partner": "Gigi Enterprise5",
  //         "status": "Activ1",
  //         "start": "1970-01-01T00:00:00.000Z",
  //         "end": "1970-01-01T00:00:00.000Z",
  //         "sign": "1970-01-01T00:00:00.000Z",
  //         "completion": "1970-01-01T00:00:00.000Z",
  //         "remarks": " e smecher ctr5"
  //       },
  //     })
  //   const contractDetails: CreateContractsDetailsDto = await this.prisma.contractsDetails.create
  //     ({
  //       data:
  //       {
  //         "name": "detaliu",
  //         "itemid": 5,
  //         "contractId": 5
  //       },
  //     })

  // }

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

  @Get(':id')
  async findOne(@Param('id') id: number) {

    const user = await this.prisma.contracte.findUnique({
      where: {
        id: 2,
      },
    })
    console.log(user);
  }

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
