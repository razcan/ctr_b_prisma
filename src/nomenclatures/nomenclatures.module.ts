import { Module } from '@nestjs/common';
import { NomenclaturesService } from './nomenclatures.service';
import { NomenclaturesController } from './nomenclatures.controller';
import { PrismaService } from '../prisma.service'

@Module({
  controllers: [NomenclaturesController],
  providers: [NomenclaturesService, PrismaService],
})
export class NomenclaturesModule { }
