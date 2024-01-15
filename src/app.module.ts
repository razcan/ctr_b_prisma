import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ContractsModule } from './contracts/contracts.module';
import {PrismaService} from './prisma.service'
import { NomenclaturesModule } from './nomenclatures/nomenclatures.module';


@Module({
  imports: [ContractsModule, NomenclaturesModule],
  controllers: [AppController],
  providers: [AppService, PrismaService],
})
export class AppModule {}
