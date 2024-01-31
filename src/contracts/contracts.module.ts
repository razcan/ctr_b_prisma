import { Module } from '@nestjs/common';
import { ContractsService } from './contracts.service';
import { ContractsController } from './contracts.controller';
import { PrismaService } from '../prisma.service'
import { multerConfig } from '../multer.config';
import { MulterModule } from '@nestjs/platform-express';

@Module({
  controllers: [ContractsController],
  providers: [ContractsService, PrismaService],
  imports: [MulterModule.register(multerConfig)]
})
export class ContractsModule { }
