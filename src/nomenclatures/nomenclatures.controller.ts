import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from 'src/prisma.service';

import { NomenclaturesService } from './nomenclatures.service';
import { CreateNomenclatureDto } from './dto/create-nomenclature.dto';
import { UpdateNomenclatureDto } from './dto/update-nomenclature.dto';

@Controller('nomenclatures')
export class NomenclaturesController {
  constructor(
    private readonly nomenclaturesService: NomenclaturesService,
    private prisma: PrismaService) { }


  @Post('partners')
  async createPartner(@Body() data: Prisma.PartnersCreateInput): Promise<any> {
    const result = this.prisma.partners.create({
      data,
    });

    return result;
  }

  @Get('partners')
  async getAllPartners() {
    const partner = await this.prisma.partners.findMany(
      //   {
      //   include: {
      //     Persons: true,
      //   }
      // }
    )
    return partner;
  }


  @Get('partners/:id')
  async getPartnerById(@Param('id') id: any) {
    const partner = await this.prisma.partners.findUnique({
      include: {
        Persons: true,
      },
      where: {
        id: parseInt(id),
      },
    })
    return partner;
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

  @Get('address/:partnerid')
  async getAddressByPartnerId(@Param('partnerid') partnerid: any) {
    const address = await this.prisma.address.findMany({
      where: {
        partnerId: parseInt(partnerid),
      },
    })
    return address;
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

  // @Get()
  // findAll() {
  //   return this.nomenclaturesService.findAll();
  // }

  // @Get(':id')
  // findOne(@Param('id') id: string) {
  //   return this.nomenclaturesService.findOne(+id);
  // }

  // @Patch(':id')
  // update(@Param('id') id: string, @Body() updateNomenclatureDto: UpdateNomenclatureDto) {
  //   return this.nomenclaturesService.update(+id, updateNomenclatureDto);
  // }

  // @Delete(':id')
  // remove(@Param('id') id: string) {
  //   return this.nomenclaturesService.remove(+id);
  // }
}
