import { Module } from '@nestjs/common';
import { CreatepdfService } from './createpdf.service';
import { CreatepdfController } from './createpdf.controller';

@Module({
  controllers: [CreatepdfController],
  providers: [CreatepdfService],
})
export class CreatepdfModule {}
