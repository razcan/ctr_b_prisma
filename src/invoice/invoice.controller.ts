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
  ) {}

  @Post()
  create(@Body() createInvoiceDto: any) {
    return this.invoiceService.create(createInvoiceDto);
  }

  @Get('findAll')
  async findAll() {
    return this.invoiceService.findAll();
  }

  @Get('findAllbyMovmentTypeId/:entityId/:movementTypeId')
  async findAllbyMovmentTypeId(
    @Param('entityId') entityId: string,
    @Param('movementTypeId') movementTypeId: string,
  ) {
    return this.invoiceService.findAllbyMovmentTypeId(
      +entityId,
      +movementTypeId,
    );
  }

  @Get('findAllbyPartnerId/:entityId/:partnerId')
  async findAllbyPartnerId(
    @Param('entityId') entityId: string,
    @Param('partnerId') partnerId: string,
  ) {
    return this.invoiceService.findAllbyPartnerId(+entityId, +partnerId);
  }

  @Get('findFiltered/:entityId/:partnerId/:currencyId')
  async findFiltered(
    @Param('entityId') entityId: string,
    @Param('partnerId') partnerId: string,
    @Param('currencyId') currencyId: string,
  ) {
    return this.invoiceService.findFiltered(+entityId, +partnerId, +currencyId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.invoiceService.findOne(+id);
  }

  // async updateContent(@Body() data: any, @Param('id') id: any): Promise<any> {
  //

  @Patch(':id')
  update(@Param('id') id: string, @Body() data) {
    return this.invoiceService.update(+id, data);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.invoiceService.delete(+id);
  }
}
