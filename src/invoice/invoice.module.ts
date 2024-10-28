import { Module } from '@nestjs/common';
import { InvoiceService } from './invoice.service';
import { InvoiceController } from './invoice.controller';
import { PrismaService } from 'src/prisma.service';
import { JwtService } from '@nestjs/jwt';
import { AuthService } from '../auth/auth.service';
import { UsersService } from 'src/user/user.service';

@Module({
  controllers: [InvoiceController],
  providers: [
    InvoiceService,
    PrismaService,
    JwtService,
    AuthService,
    UsersService,
  ],
  // exports: [InvoiceController]
})
export class InvoiceModule {}
