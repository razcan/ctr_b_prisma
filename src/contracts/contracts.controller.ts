import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { PrismaService } from 'src/prisma.service';
import { ContractsService } from './contracts.service';
import { CreateContractDto } from './dto/create-contract.dto';
import {CreateContractsDto} from '../contracts/dto/create-contracts.dto'
import {CreateContractsDetailsDto} from '../contractsDetails/dto/create-contractsDetails.dto'
import { UpdateContractDto } from './dto/update-contract.dto';

@Controller('contracts')
export class ContractsController {
  constructor(
    private readonly contractsService: ContractsService,
    private prisma: PrismaService
    ) {}

  @Post()
  async create(@Body() CreateContractsDto: CreateContractDto, CreateContractsDetailsDto: CreateContractsDetailsDto) {
    const contract: CreateContractsDto = await this.prisma.contracts.create
    ({
      data:     
      {
       
        "number": "23AAA5",
        "type": "Service5",
        "partner": "Gigi Enterprise5",
        "status": "Activ1",
        "start": "1970-01-01T00:00:00.000Z",
        "end": "1970-01-01T00:00:00.000Z",
        "sign": "1970-01-01T00:00:00.000Z",
        "completion": "1970-01-01T00:00:00.000Z",
        "remarks": " e smecher ctr5"
    },
    })
    const contractDetails: CreateContractsDetailsDto = await this.prisma.contractsDetails.create
    ({
      data:     
      {
        "name":  "detaliu",
        "itemid": 5 ,
        "contractId": 5   
    },
    })
  
  }

  @Get()
  async findAll() {
    // return this.contractsService.findAll();
    const users = await  this.prisma.contracts.findMany(
      {include: {
        contract: true, // Include the related posts
      },
  })
    console.log(users);
    return users;
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

  // @Patch(':id')
  // update(@Param('id') id: string, @Body() updateContractDto: UpdateContractDto) {
  //   return this.contractsService.update(+id, updateContractDto);
  // }

  // @Delete(':id')
  // remove(@Param('id') id: string) {
  //   return this.contractsService.remove(+id);
  // }
}
