import { Module } from '@nestjs/common';
import { ContractsService } from './contracts.service';
import { ContractsController } from './contracts.controller';
import { PrismaService } from '../prisma.service'
import { multerConfig } from '../multer.config';
import { MulterModule } from '@nestjs/platform-express';
import { MailerService } from '../alerts/mailer.service'
import { AlertsModule } from 'src/alerts/alerts.module';
import { NomenclaturesService } from 'src/nomenclatures/nomenclatures.service';
import { NomenclaturesModule } from 'src/nomenclatures/nomenclatures.module';
import { NomenclaturesController } from 'src/nomenclatures/nomenclatures.controller';
import { AlertsController } from 'src/alerts/alerts.controller';
import { AlertService } from 'src/alerts/alerts.service';


@Module({
  controllers: [ContractsController, NomenclaturesController],
  providers: [ContractsService, PrismaService, MailerService, AlertService, NomenclaturesService],
  imports: [MulterModule.register(multerConfig), AlertsModule, NomenclaturesModule]
})
export class ContractsModule { }
