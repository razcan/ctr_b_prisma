import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ContractsModule } from './contracts/contracts.module';
import { PrismaService } from './prisma.service'
import { NomenclaturesModule } from './nomenclatures/nomenclatures.module';
import { AlertsModule } from './alerts/alerts.module';
import { ScheduleModule } from '@nestjs/schedule';
import { NomenclaturesService } from './nomenclatures/nomenclatures.service';
import { AuthModule } from './auth/auth.module';
import { AuthService } from './auth/auth.service'
import { JwtService } from '@nestjs/jwt';
import { UsersService } from './user/user.service'
import { InvoiceModule } from './invoice/invoice.module';
import { CreatepdfModule } from './createpdf/createpdf.module';

@Module({
  imports: [ContractsModule, NomenclaturesModule, AlertsModule,
    ScheduleModule.forRoot(), AuthModule, InvoiceModule, CreatepdfModule],
  controllers: [AppController],
  providers: [AppService, PrismaService, NomenclaturesService, AuthService, JwtService, UsersService],
})
export class AppModule { }