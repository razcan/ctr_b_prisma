import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { HttpExceptionFilter } from './filters/http-exception.filter';
require('dotenv').config();

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    snapshot: true,
  });

  app.useGlobalFilters(new HttpExceptionFilter());
  
  app.enableCors({
    origin: [
      'http://localhost:5500',
      'http://localhost:3000/swagger',
      //the ip address of the frontend server
    ],
    // origin: '*', // Allow all origins
    methods: ['GET', 'POST', 'DELETE', 'PATCH'],
    credentials: true,
  });

  const config = new DocumentBuilder()
    .setTitle('Contracts')
    .setDescription('The Contracts App API description')
    .setVersion('1.0')
    .build();

  const document = SwaggerModule.createDocument(app, config);

  SwaggerModule.setup('swagger', app, document);

  await app.listen(3000);
}
bootstrap();
