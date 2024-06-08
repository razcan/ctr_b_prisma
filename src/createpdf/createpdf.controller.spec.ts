import { Test, TestingModule } from '@nestjs/testing';
import { CreatepdfController } from './createpdf.controller';
import { CreatepdfService } from './createpdf.service';

describe('CreatepdfController', () => {
  let controller: CreatepdfController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [CreatepdfController],
      providers: [CreatepdfService],
    }).compile();

    controller = module.get<CreatepdfController>(CreatepdfController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
