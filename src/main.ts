import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
require("dotenv").config();

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.enableCors({
    origin: [
      'http://localhost:5500', //the ip address of the frontend server
    ],
    methods: ["GET", "POST", "DELETE", "PATCH"],
    credentials: true,
  });


  const config = new DocumentBuilder()
    .setTitle('Contracts')
    .setDescription('The Contracts App API description')
    .setVersion('1.0')
    .addTag('contracts')
    .build();

  const document = SwaggerModule.createDocument(app, config);

  SwaggerModule.setup('api', app, document);

  await app.listen(3000);
}
bootstrap();
