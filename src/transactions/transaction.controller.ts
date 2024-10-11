import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Header,
  HttpStatus,
  Headers,
  Delete,
  UploadedFile,
  UploadedFiles,
  HttpException,
  HttpCode,
  Request,
  UseGuards,
  UsePipes,
  ValidationPipe,
  Res,
  UseInterceptors,
  InternalServerErrorException,
} from '@nestjs/common';
import { TransactionService } from './transaction.service';
import { PrismaService } from 'src/prisma.service';
import { Prisma } from '@prisma/client';

@Controller('transactions')
export class TransactionController {
  constructor(
    private readonly transactionService: TransactionService,
    private prisma: PrismaService,
  ) {}

  @Post()
  create(@Body() transaction: any) {
    return this.transactionService.create(transaction);
  }

  @Patch(':id')
  update(@Body() transaction: any, @Param('id') id: string) {
    return this.transactionService.update(+id, transaction);
  }

  @Get('findAll/:entityId')
  async findAll(@Param('entityId') entityId: string) {
    return await this.transactionService.findMany(+entityId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.transactionService.findOne(+id);
  }

  // @Get('findAllbyPartnerId/:entityId/:partnerId')
  // async findAllbyPartnerId(
  //   @Param('entityId') entityId: string,
  //   @Param('partnerId') partnerId: string,
  // ) {
  //   return this.invoiceService.findAllbyPartnerId(+entityId, +partnerId);
  // }

  // @Get('findFiltered/:entityId/:partnerId/:currencyId')
  // async findFiltered(
  //   @Param('entityId') entityId: string,
  //   @Param('partnerId') partnerId: string,
  //   @Param('currencyId') currencyId: string,
  // ) {
  //   return this.invoiceService.findFiltered(+entityId, +partnerId, +currencyId);
  // }
}
