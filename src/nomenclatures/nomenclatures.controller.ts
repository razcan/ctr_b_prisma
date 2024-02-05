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


  @Get('billingfrequency')
  async getbillingfrequency() {
    const billingfrequency = await this.prisma.billingFrequency.findMany()
    return billingfrequency;
  }

  @Get('paymenttype')
  async getpaymenttype() {
    const paymenttype = await this.prisma.paymentType.findMany()
    return paymenttype;
  }

  @Get('measuringunit')
  async getmeasuringunit() {
    const measuringunit = await this.prisma.measuringUnit.findMany()
    return measuringunit;
  }




  @Post('partners')
  async createPartner(@Body() data: Prisma.PartnersCreateInput): Promise<any> {
    const result = this.prisma.partners.create({
      data,
    });

    return result;
  }

  @Get('contracttype')
  async getAllContractTypes() {
    const contracttype = await this.prisma.contractType.findMany()
    return contracttype;
  }

  @Get('contractstatus')
  async getAllContractStatuses() {
    const contractstatus = await this.prisma.contractStatus.findMany()
    return contractstatus;
  }


  @Get('partners')
  async getAllPartners() {
    const partner = await this.prisma.partners.findMany(
      {
        where: {
          type: {
            in: ['Furnizor', 'Client']
          }
        },
      }
    )
    return partner;
  }

  @Get('entity')
  async getAllEntities() {
    const partner = await this.prisma.partners.findMany(
      {
        where: {
          type: {
            in: ['Entitate']
          }
        },
      }
    )
    return partner;
  }

  @Get('allparties')
  async getAllParties() {
    const partner = await this.prisma.partners.findMany(
      {}
    )
    return partner;
  }


  //returns only partners of type entity
  @Get('partnersdetails/:id')
  async getAllPartnersDetails(@Param('id') id: any) {

    const partner = await this.prisma.partners.findMany(
      {
        include: {
          Persons: true,
          Address: true,
          Banks: true
        },
        where: {
          id: parseInt(id),
          type: {
            in: ['Furnizor', 'Client']
          }
        },
      }
    )
    return partner;
  }

  //returns only partners of type entity
  @Get('entitydetails/:id')
  async getAllEntityDetails(@Param('id') id: any) {
    const partner = await this.prisma.partners.findMany(
      {
        include: {
          Persons: true,
          Address: true,
          Banks: true
        },
        where: {
          id: parseInt(id),
          type: "Entitate"
        },
      }
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

  @Delete('partners/:id')
  async deletePartner(@Param('id') id: any) {
    const partner = await this.prisma.partners.delete({
      where: {
        id: parseInt(id),
      },
    })
    return partner;
  }

  @Patch('partners/:id')
  async UpdatePartner(@Body() data: Prisma.PartnersCreateInput, @Param('id') id: any): Promise<any> {
    const partner = await this.prisma.partners.update({
      where: {
        id: parseInt(id),
      },
      data: data,
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

  @Get('allbanks')
  async getallBanks() {
    const banks = await this.prisma.bank.findMany({
    })
    return banks;
  }

  @Get('allcurrencies')
  async getallCurrencies() {
    const currencies = await this.prisma.currency.findMany({
    })
    return currencies;
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

  @Delete('address/:addressid')
  async deleteAddressId(@Param('addressid') addressid: any) {
    const address = await this.prisma.address.delete({
      where: {
        id: parseInt(addressid),
      },
    })
    return address;
  }

  @Patch('address/:addressid')
  async getUpdateAddressByAddressId(@Body() data: Prisma.AddressCreateInput, @Param('addressid') addressid: any): Promise<any> {
    const adress = await this.prisma.address.update({
      where: {
        id: parseInt(addressid),
      },
      data: data,
    })
    return adress;
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

  @Patch('bank/:bankid')
  async getUpdateBank(@Body() data: Prisma.BanksCreateInput, @Param('bankid') bankid: any): Promise<any> {
    const bank = await this.prisma.banks.update({
      where: {
        id: parseInt(bankid),
      },
      data: data,
    })
    return bank;
  }

  @Delete('bank/:bankid')
  async deleteBank(@Param('bankid') bankid: any) {
    const bank = await this.prisma.banks.delete({
      where: {
        id: parseInt(bankid),
      },
    })
    return bank;
  }

  // @Delete(':id')
  // remove(@Param('id') id: string) {
  //   return this.nomenclaturesService.remove(+id);
  // }
}
