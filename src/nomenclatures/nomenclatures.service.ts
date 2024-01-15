import { Injectable } from '@nestjs/common';
import { CreateNomenclatureDto } from './dto/create-nomenclature.dto';
import { UpdateNomenclatureDto } from './dto/update-nomenclature.dto';

@Injectable()
export class NomenclaturesService {
  create(createNomenclatureDto: CreateNomenclatureDto) {
    return 'This action adds a new nomenclature';
  }

  findAll() {
    return `This action returns all nomenclatures`;
  }

  findOne(id: number) {
    return `This action returns a #${id} nomenclature`;
  }

  update(id: number, updateNomenclatureDto: UpdateNomenclatureDto) {
    return `This action updates a #${id} nomenclature`;
  }

  remove(id: number) {
    return `This action removes a #${id} nomenclature`;
  }
}
