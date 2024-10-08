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

    // // console.log(details);

    try {
      const result = await this.prisma.transactions.create({
        data: header,
      });

      //console.log(details.length, 'marime');
      for (let i = 0; i < details.length; i++) {
        details[i].transactionId = (await result).id;
        // console.log((await result).id, 'inv id');
      }

      const resultDetails = await this.prisma.transactionDetail.createMany({
        data: details,
      });

      //   this.patchDocSeriesByDocTypeIdandSerieId(header.typeId, header.seriesId);

      return result;
    } catch (error) {
      console.error('Error creating Invoice:', error);
    }
  }
}
