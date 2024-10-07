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
    const resultDetails = await this.prisma.transactions.create({
      data: data,
    });

    console.log(resultDetails);
  }
}
