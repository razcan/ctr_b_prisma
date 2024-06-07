import { Body, Injectable, Param } from '@nestjs/common';
import { CreateInvoiceDto } from './dto/create-invoice.dto';
import { UpdateInvoiceDto } from './dto/update-invoice.dto';
import { PrismaService } from 'src/prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class InvoiceService {

  constructor(private prisma: PrismaService) { }

  async patchDocSeriesByDocTypeIdandSerieId(
    @Param('documentTypeId') documentTypeId: any,
    @Param('id') id: any): Promise<any> {

    const actual_nr = await this.prisma.documentSeries.findFirst({
      where: {
        documentTypeId: parseInt(documentTypeId),
        id: parseInt(id)
      },
    });

    const result = this.prisma.documentSeries.updateMany({
      data: {
        last_number: actual_nr.last_number + 1
      },
      where: {
        documentTypeId: parseInt(documentTypeId),
        id: parseInt(id)
      },
    });

    return result;
  }


  async create(@Body() data: any) {

    const header = data[0];
    const details = data[1];

    try {

      const result = this.prisma.invoice.create({
        data: header,
      });


      for (let i = 0; i < details.length; i++) {
        details[i].invoiceId = (await result).id
      }

      const resultDetails = this.prisma.invoiceDetail.createMany({
        data: details,
      });

      this.patchDocSeriesByDocTypeIdandSerieId(header.typeId, header.seriesId);

      return (result)

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



  findAll() {
    return `This action returns all invoice`;
  }

  findOne(id: number) {
    return `This action returns a #${id} invoice`;
  }

  update(id: number, updateInvoiceDto: UpdateInvoiceDto) {
    return `This action updates a #${id} invoice`;
  }

  remove(id: number) {
    return `This action removes a #${id} invoice`;
  }
}
