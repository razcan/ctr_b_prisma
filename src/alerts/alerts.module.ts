import { Module } from '@nestjs/common';
import { AlertsController } from './alerts.controller';
import { AlertService } from './alerts.service';

import { PrismaService } from '../prisma.service';
import { ContractsController } from '../contracts/contracts.controller'
import { ContractsService } from 'src/contracts/contracts.service';


@Module({
    controllers: [AlertsController, ContractsController],
    providers: [PrismaService, ContractsService, AlertService, ContractsController],

})
export class AlertsModule { }
