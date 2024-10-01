import { Body, Injectable, Param } from '@nestjs/common';
import { CreateInvoiceDto } from './dto/create-invoice.dto';
import { UpdateInvoiceDto } from './dto/update-invoice.dto';
import { PrismaService } from 'src/prisma.service';
import { Invoice, Prisma } from '@prisma/client';
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

    const result = this.prisma.documentSeries.update({
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
    // const header = data[0];
    // const details = data[1];

    const header: Prisma.InvoiceUncheckedCreateInput = {
      // id: data.id,
      updateadAt: data.updateadAt,
      createdAt: data.createdAt,
      partnerId: data.partnerId,
      entityId: data.entityId,
      number: data.number,
      date: data.date,
      duedate: data.duedate,
      totalAmount: data.totalAmount,
      vatAmount: data.vatAmount,
      totalPayment: data.totalPayment,
      typeId: data.typeId,
      transactionTypeId: data.transactionTypeId,
      statusId: data.statusId,
      entitybankId: data.entitybankId,
      partneraddressId: data.partneraddressId,
      currencyRate: data.currencyRate,
      userId: data.userId,
      currencyId: data.currencyId,
      remarks: data.remarks,
      seriesId: data.seriesId,
      serialNumber: data.serialNumber,
      eqvTotalAmount: data.eqvTotalAmount,
      eqvVatAmount: data.eqvVatAmount,
      eqvTotalPayment: data.eqvTotalPayment,
      vatOnReceipt: data.vatOnReceipt,
    };

    const details = [];
    data.InvoiceDetails.map((inv_detail: any) => details.push(inv_detail));

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

      const resultDetails = await this.prisma.invoiceDetail.createMany({
        data: details,
      });

      this.patchDocSeriesByDocTypeIdandSerieId(header.typeId, header.seriesId);

      return result;
    } catch (error) {
      console.error('Error creating Invoice:', error);
    }
  }

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

  async delete(id: number) {
    try {
      const resultdetail = await this.prisma.invoiceDetail.deleteMany({
        where: {
          invoiceId: id,
        },
      });

      const result = await this.prisma.invoice.delete({
        where: {
          id: id,
        },
      });
      return 'The invoice was deleted!';
    } catch (error) {
      console.error('Error deleting Invoice:', error);
    }
  }

  async update(id: any, @Body() data: any) {
    // console.log(data.InvoiceDetails);

    const header: Prisma.InvoiceUncheckedCreateInput = {
      // id: data.id,
      updateadAt: data.updateadAt,
      createdAt: data.createdAt,
      partnerId: data.partnerId,
      entityId: data.entityId,
      number: data.number,
      date: data.date,
      duedate: data.duedate,
      totalAmount: data.totalAmount,
      vatAmount: data.vatAmount,
      totalPayment: data.totalPayment,
      typeId: data.typeId,
      transactionTypeId: data.transactionTypeId,
      statusId: data.statusId,
      entitybankId: data.entitybankId,
      partneraddressId: data.partneraddressId,
      currencyRate: data.currencyRate,
      userId: data.userId,
      currencyId: data.currencyId,
      remarks: data.remarks,
      seriesId: data.seriesId,
      serialNumber: data.serialNumber,
      eqvTotalAmount: data.eqvTotalAmount,
      eqvVatAmount: data.eqvVatAmount,
      eqvTotalPayment: data.eqvTotalPayment,
      vatOnReceipt: data.vatOnReceipt,
    };

    const details = [];
    data.InvoiceDetails.map((inv_detail: any) => details.push(inv_detail));

    try {
      const existingContent = await this.prisma.invoice.findUnique({
        where: {
          id: parseInt(id),
        },
      });

      if (existingContent) {
        const updatedHeader = await this.prisma.invoice.update({
          where: { id: parseInt(id) },
          data: header,
        });

        const deleteExistingDetails =
          await this.prisma.invoiceDetail.deleteMany({
            where: { invoiceId: parseInt(id) },
          });

        const resultDetails = await this.prisma.invoiceDetail.createMany({
          data: details,
        });

        return resultDetails;
      } else {
        const newHeaderContent = await this.prisma.invoice.create({
          data: header,
        });
        return newHeaderContent;
      }
    } catch (error) {
      console.error('Error updating Invoice:', error);
    }
  }
}
