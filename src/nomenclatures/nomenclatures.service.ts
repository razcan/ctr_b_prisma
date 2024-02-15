import { Injectable } from '@nestjs/common';
import { CreateNomenclatureDto } from './dto/create-nomenclature.dto';
import { UpdateNomenclatureDto } from './dto/update-nomenclature.dto';
import { Prisma } from '@prisma/client';
import { PrismaService } from 'src/prisma.service';


@Injectable()
export class NomenclaturesService {
  constructor(
    private prisma: PrismaService) { }

  create(createNomenclatureDto: CreateNomenclatureDto) {
    return 'This action adds a new nomenclature';
  }

  findAll() {
    return `This action returns all nomenclatures`;
  }

  findOne(id: number) {
    return `This action returns a #${id} nomenclature`;
  }

  async getPersonById(personid: any) {
    const persons = await this.prisma.persons.findFirst({
      where: {
        id: parseInt(personid),
      },
    })
    return persons;
  }


  update(id: number, updateNomenclatureDto: UpdateNomenclatureDto) {
    return `This action updates a #${id} nomenclature`;
  }

  remove(id: number) {
    return `This action removes a #${id} nomenclature`;
  }
}
