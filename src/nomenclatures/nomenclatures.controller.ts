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
