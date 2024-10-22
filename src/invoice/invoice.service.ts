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
    @Param('entityId') entityId: any,
  ): Promise<any> {
    const actual_nr = await this.prisma.documentSeries.findFirst({
      where: {
        documentTypeId: parseInt(documentTypeId),
        entityId: parseInt(entityId),
      },
    });

    const result = this.prisma.documentSeries.update({
      data: {
        last_number: actual_nr.last_number + 1,
      },
      where: {
        documentTypeId: parseInt(documentTypeId),
        id: parseInt(entityId),
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
      parentId: data.parentId,
      restPayment: data.restPayment,
      movement_type: data.movement_type,
      contractId: data.contractId,
      contractfinancialItemId: data.contractfinancialItemId,
      contractFinancialScheduleId: data.scontractFinancialScheduleId,
      allocationSummary: data.allocationSummary,
    };

    // console.log(header);

    const scheduleLine =
      await this.prisma.contractFinancialDetailSchedule.findFirst({
        where: {
          contractfinancialItemId: data.scontractFinancialScheduleId,
        },
      });

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

      if (header.seriesId) {
        this.patchDocSeriesByDocTypeIdandSerieId(
          header.typeId,
          header.entityId,
        );
      }

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

  async findAllbyPartnerId(entityId: number, partnerId: number) {
    // console.log(partnerId, 'partnerId');
    const result = await this.prisma.invoice.findMany({
      where: {
        partnerId: partnerId,
        entityId: entityId,
        statusId: 2, //Validat
        restPayment: {
          not: {
            in: [0], //only invoices with restPayment - unpayed
          },
        },
      },
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

  async findAllbyMovmentTypeId(entityId: number, movementTypeId: number) {
    const result = await this.prisma.invoice.findMany({
      where: {
        movement_type: movementTypeId,
        entityId: entityId,
      },
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

  async findFiltered(entityId: number, partnerId: number, currencyId: number) {
    // console.log(partnerId, 'partnerId');
    const result = await this.prisma.invoice.findMany({
      where: {
        partnerId: partnerId,
        entityId: entityId,
        statusId: 2, //Validat
        currencyId: currencyId,
        restPayment: {
          not: {
            in: [0, -1], //only invoices with restPayment - unpayed
          },
          gt: 0,
        },
      },
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
      contractId: data.contractId,
      contractfinancialItemId: data.contractfinancialItemId,
      contractFinancialScheduleId: data.contractFinancialScheduleId,
      allocationSummary: data.allocationSummary,
    };

    const scheduleLine =
      await this.prisma.contractFinancialDetailSchedule.update({
        where: {
          id: parseInt(data.contractFinancialScheduleId),
        },
        data: {
          isInvoiced: true,
        },
      });
    console.log(scheduleLine, 'scheduleLine');

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
