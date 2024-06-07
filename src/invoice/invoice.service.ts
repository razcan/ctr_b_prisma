import { Body, Injectable } from '@nestjs/common';
import { CreateInvoiceDto } from './dto/create-invoice.dto';
import { UpdateInvoiceDto } from './dto/update-invoice.dto';
import { PrismaService } from 'src/prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class InvoiceService {

  constructor(private prisma: PrismaService) { }

  async create(@Body() data: any) {

    const result = this.prisma.invoice.create({
      data,
    });
    return result;
  }


  // async createDepartment(@Body() data: Prisma.DepartmentCreateInput): Promise<any> {

  //   const result = this.prisma.department.create({
  //     data,
  //   });
  //   return result;
  // }


  findAll() {
    return `This action returns all invoice`;
  }

  findOne(id: number) {
    return `This action returns a #${id} invoice`;
  }

  update(id: number, updateInvoiceDto: UpdateInvoiceDto) {
    return `This action updates a #${id} invoice`;
  }

  remove(id: number) {
    return `This action removes a #${id} invoice`;
  }
}
