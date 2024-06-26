import {
  Controller, Get, Post, Body, Patch, Param, Header, HttpStatus, Headers,
  Delete, UploadedFile, UploadedFiles, HttpException, HttpCode, Request,
  UseGuards, UsePipes, ValidationPipe, Res, UseInterceptors, InternalServerErrorException
} from '@nestjs/common';
import { InvoiceService } from './invoice.service';
import { CreateInvoiceDto } from './dto/create-invoice.dto';
import { UpdateInvoiceDto } from './dto/update-invoice.dto';
import { PrismaService } from 'src/prisma.service';
import { Prisma } from '@prisma/client';

@Controller('invoice')
export class InvoiceController {

  constructor(
    private readonly invoiceService: InvoiceService,
    private prisma: PrismaService,
  ) { }


  @Post()
  create(@Body() createInvoiceDto: any) {
    return this.invoiceService.create(createInvoiceDto);
  }

  @Get()
  findAll() {
    return this.invoiceService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.invoiceService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateInvoiceDto: UpdateInvoiceDto) {
    return this.invoiceService.update(+id, updateInvoiceDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.invoiceService.remove(+id);
  }
}
