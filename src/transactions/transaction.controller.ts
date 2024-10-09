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

  //   @Get(':id')
  //   findOne(@Param('id') id: string) {
  //     return this.transactionService.findOne(+id);
  //   }
}
