import { Body, Injectable, Param } from '@nestjs/common';
import { CreateInvoiceDto } from './dto/create-invoice.dto';
import { UpdateInvoiceDto } from './dto/update-invoice.dto';
import { PrismaService } from 'src/prisma.service';
import { Prisma } from '@prisma/client';
import { Address } from 'src/address/entities';

@Injectable()
export class InvoiceService {
  constructor(private prisma: PrismaService) {}

  async patchDocSeriesByDocTypeIdandSerieId(
    @Param('documentTypeId') documentTypeId: any,
    @Param('id') id: any,
  ): Promise<any> {
    const actual_nr = await this.prisma.documentSeries.findFirst({
      where: {
        documentTypeId: parseInt(documentTypeId),
        id: parseInt(id),
      },
    });

    const result = this.prisma.documentSeries.updateMany({
      data: {
        last_number: actual_nr.last_number + 1,
      },
      where: {
        documentTypeId: parseInt(documentTypeId),
        id: parseInt(id),
      },
    });

    return result;
  }

  async create(@Body() data: any) {
    const header = data[0];
    const details = data[1];

    // console.log(details);

    try {
      const result = this.prisma.invoice.create({
        data: header,
      });

      //console.log((await result).id, 'inv id');

      //console.log(details.length, 'marime');
      for (let i = 0; i < details.length; i++) {
        details[i].invoiceId = (await result).id;
        // console.log((await result).id, 'inv id');
      }
      //console.log(details, 'ici');

      const resultDetails = await this.prisma.invoiceDetail.createMany({
        data: details,
      });

      //console.log(resultDetails);

      this.patchDocSeriesByDocTypeIdandSerieId(header.typeId, header.seriesId);

      return result;
    } catch (error) {
      console.error('Error creating Invoice:', error);
    }
  }

  // async create(createInvoiceDto: CreateInvoiceDto) {
  //   const { details, ...invoiceData } = createInvoiceDto;

  //   return this.prisma.invoice.create({
  //     data: {
  //       ...invoiceData,
  //       details: {
  //         create: details,
  //       },
  //     },
  //     include: {
  //       details: true,
  //     },
  //   });
  // }

  async findAll() {
    const result = await this.prisma.invoice.findMany({
      include: {
        partner: true,
        type: true,
        status: true,
        entity: true,
        currency: true,
        series: true,
      },
    });
    return result;
  }

  async findOne(id: number) {
    const result = await this.prisma.invoice.findMany({
      where: {
        id: id,
      },
      include: {
        partner: true,
        partnerAddress: true,
        type: true,
        status: true,
        entity: true,
        currency: true,
        InvoiceDetail: {
          include: {
            item: {
              include: {
                measuringUnit: true,
                vat: true,
              },
            },
          },
        },
        series: true,
      },
    });
    return result;
  }

  update(id: number, updateInvoiceDto: UpdateInvoiceDto) {
    return `This action updates a #${id} invoice`;
  }

  remove(id: number) {
    return `This action removes a #${id} invoice`;
  }
}

// const contracts = await this.prisma.contracts.findUnique({
//   include: {
//     costcenter: true,
//     entity: true,
//     partner: true,
//     PartnerPerson: true,
//     EntityPerson: true,

//     EntityBank: true,
//     PartnerBank: true,

//     EntityAddress: true,
//     PartnerAddress: true,
//     location: true,
//     departament: true,
//     Category: true,
//     cashflow: true,
//     type: true,
//     status: true,
//   },
//   where: {
//     id: parseInt(id),
//   },
// });

// const content = await this.prisma.contracts.findMany({
//   where: {
//     parentId: parseInt(id),
//   },
//   include: {
//     entity: true,
//     partner: true,
//     EntityAddress: true,
//     PartnerAddress: true,
//     type: true,
//     status: true,
//   },
// });
