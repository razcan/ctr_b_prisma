import { Test, TestingModule } from '@nestjs/testing';
import { CreatepdfService } from './createpdf.service';

describe('CreatepdfService', () => {
  let service: CreatepdfService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [CreatepdfService],
    }).compile();

    service = module.get<CreatepdfService>(CreatepdfService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
