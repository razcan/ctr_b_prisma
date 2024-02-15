import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ContractsModule } from './contracts/contracts.module';
import { PrismaService } from './prisma.service'
import { NomenclaturesModule } from './nomenclatures/nomenclatures.module';
import { AlertsModule } from './alerts/alerts.module';
import { ScheduleModule } from '@nestjs/schedule';
import { NomenclaturesService } from './nomenclatures/nomenclatures.service';

@Module({
  imports: [ContractsModule, NomenclaturesModule, AlertsModule, ScheduleModule.forRoot()],
  controllers: [AppController],
  providers: [AppService, PrismaService, NomenclaturesService],
})
export class AppModule { }
