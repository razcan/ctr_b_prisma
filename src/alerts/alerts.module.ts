import { Module } from '@nestjs/common';
import { AlertsController } from './alerts.controller';
import { AlertService } from './alerts.service';

import { PrismaService } from '../prisma.service';
// import { ContractsController } from '../contracts/contracts.controller'
// import { ContractsService } from 'src/contracts/contracts.service';
import { MailerService } from './mailer.service'


@Module({
    controllers: [AlertsController],
    providers: [PrismaService,
        AlertService, MailerService
        // ContractsController, ContractsService
    ],

})
export class AlertsModule { }
