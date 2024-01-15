import { Test, TestingModule } from '@nestjs/testing';
import { NomenclaturesController } from './nomenclatures.controller';
import { NomenclaturesService } from './nomenclatures.service';

describe('NomenclaturesController', () => {
  let controller: NomenclaturesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [NomenclaturesController],
      providers: [NomenclaturesService],
    }).compile();

    controller = module.get<NomenclaturesController>(NomenclaturesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
