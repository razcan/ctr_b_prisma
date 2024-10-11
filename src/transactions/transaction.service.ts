import { Body, Injectable, Param } from '@nestjs/common';
import { PrismaService } from 'src/prisma.service';
import { Prisma } from '@prisma/client';
@Injectable()
export class TransactionService {
  constructor(private prisma: PrismaService) {}

  async patchDocSeriesByDocTypeIdandSerieId(
    @Param('documentTypeId') documentTypeId: any,
    @Param('id') id: any,
  ): Promise<any> {
    try {
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
    } catch (error) {
      throw error;
    }
  }

  async findMany(@Param('entityId') entityId: any) {
    const result = this.prisma.transactions.findMany({
      where: {
        entityId: entityId,
      },
      include: {
        partner: true,
        type: true,
        status: true,
        entity: true,
        currency: true,
      },
    });
    return result;
  }

  async create(@Body() data: any) {
    console.log(data);

    const header: Prisma.TransactionsUncheckedCreateInput = {
      partnerId: data.partnerId,
      entityId: parseInt(data.entityId),
      number: data.number,
      date: data.date,
      currencyId: data.currencyId,
      paymentValue: data.paymentValue,
      exchangeRate: data.exchangeRate,
      eqvTotalPayment: data.eqvTotalPayment,
      typeId: data.typeId,
      entitybankId: data.entitybankId,
      partnerbankId: data.partnerbankId,
      bank: data.bank,
      cash: data.cash,
      card: data.card,
      meal: data.meal,
      remarks: data.remarks,
      userId: data.userId,
      statusId: data.statusId,
      seriesId: data.seriesId,
    };

    // const details = data[1];

    const details = [];
    data.toAddDetails.map((inv_detail: any) => details.push(inv_detail));

    const events = [];
    data.events.map((event: any) => events.push(event));

    // console.log(events);

    try {
      const result = await this.prisma.transactions.create({
        data: header,
      });

      //   this.patchDocSeriesByDocTypeIdandSerieId(header.typeId, header.seriesId);

      //console.log(details.length, 'marime');
      for (let i = 0; i < details.length; i++) {
        details[i].transactionId = result.id;
        // console.log((await result).id, 'inv id');
      }

      for (let z = 0; z < details.length; z++) {
        const resultDetails = await this.prisma.transactionDetail.create({
          data: details[z],
        });

        //we find the invoice , make a sum from all payments details , and after, we upate the restPayment at invoice level
        const findInvoice = await this.prisma.invoice.findUnique({
          where: {
            id: details[z].invoiceId,
          },
        });

        const findPayments = await this.prisma.transactionDetail.findMany({
          where: {
            invoiceId: details[z].invoiceId,
          },
        });

        const sum_payments = findPayments.reduce(
          (total, invoice) => total + (invoice.eqvTotalPayment || 0),
          0,
        );

        if (findInvoice.eqvTotalPayment - sum_payments) {
          const restPayment = findInvoice.eqvTotalPayment - sum_payments;
          findInvoice.restPayment = restPayment;

          const updateInvoice = await this.prisma.invoice.update({
            where: {
              id: details[z].invoiceId,
            },
            data: findInvoice,
          });
        }

        const eventsDetails = await this.prisma.transactionDetailEvents.create({
          data: {
            transactionDetailId: resultDetails.id,
            invoiceId: parseInt(events[z].invoiceId),
            entityId: parseInt(events[z].entityId),
            partnerId: parseInt(events[z].partnerId),
            partPaymentValue: parseFloat(events[z].partPaymentValue),
            eqvTotalPayment: 0,
            restAmount: 0,
            payFromDate: new Date('1900-01-01'),
            payToDate: new Date(),
            currencyId: parseInt(events[z].currencyId),
          },
        });
      }

      //   this.patchDocSeriesByDocTypeIdandSerieId(header.typeId, header.seriesId);

      return result;
    } catch (e) {
      if (e.code) {
        throw e.code;
        // in order to get an error, i need to set this throw in all endpoints
      } else {
        console.error('An unexpected error occurred: ', e);
      }
    }
  }

  async update(@Body() transaction: any, @Param('id') id: string) {}
}
