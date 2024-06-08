import { PartialType } from '@nestjs/swagger';
import { CreateCreatepdfDto } from './create-createpdf.dto';

export class UpdateCreatepdfDto extends PartialType(CreateCreatepdfDto) {}
