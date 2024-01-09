import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({
    origin: [
      'http://localhost:5500', //the ip address of the frontend server
    ],
    methods: ["GET", "POST"],
    credentials: true,
  });

  await app.listen(3000);
}
bootstrap();
