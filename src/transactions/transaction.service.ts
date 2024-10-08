import { Body, Injectable, Param } from '@nestjs/common';
import { PrismaService } from 'src/prisma.service';
import { Invoice, Prisma } from '@prisma/client';
import { Address } from 'src/address/entities';

@Injectable()
export class TransactionService {
  constructor(private prisma: PrismaService) {}

  async patchDocSeriesByDocTypeIdandSerieId(
    @Param('documentTypeId') documentTypeId: any,
    @Param('id') id: any,
  ): Promise<any> {}

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

      //console.log(details.length, 'marime');
      for (let i = 0; i < details.length; i++) {
        details[i].transactionId = result.id;
        // console.log((await result).id, 'inv id');
      }

      console.log(details);

      //parcurgere lista si facut insert pt fiecare val, luat id si bagat in event
      for (let z = 0; z < details.length; z++) {
        const resultDetails = await this.prisma.transactionDetail.create({
          data: details[z],
        });

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
    } catch (error) {
      console.error('Error creating Invoice:', error);
    }
  }
}
