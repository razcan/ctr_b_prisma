import { Module } from '@nestjs/common';
import { TransactionService } from './transaction.service';
import { TransactionController } from './transaction.controller';
import { PrismaService } from 'src/prisma.service';
import { PrismaErrorService } from '../filters/prisma-error.service';

@Module({
  controllers: [TransactionController],
  providers: [TransactionService, PrismaService, PrismaErrorService],
  // exports: [InvoiceController]
})
export class TransactionModule {}
