import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ContractsModule } from './contracts/contracts.module';
import { PrismaService } from './prisma.service';
import { NomenclaturesModule } from './nomenclatures/nomenclatures.module';
import { AlertsModule } from './alerts/alerts.module';
import { ScheduleModule } from '@nestjs/schedule';
import { NomenclaturesService } from './nomenclatures/nomenclatures.service';
import { AuthModule } from './auth/auth.module';
import { AuthService } from './auth/auth.service';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from './user/user.service';
import { InvoiceModule } from './invoice/invoice.module';
import { TransactionModule } from './transactions/transaction.module';
import { CreatepdfModule } from './createpdf/createpdf.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { DevtoolsModule } from '@nestjs/devtools-integration';
import { APP_FILTER } from '@nestjs/core';
import { HttpExceptionFilter } from './filters/http-exception.filter';
import { PrismaErrorService } from './filters/prisma-error.service';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    DevtoolsModule.register({
      http: process.env.NODE_ENV !== 'production',
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      url: process.env.DATABASE_URL,
      autoLoadEntities: true,
      synchronize: true,
    }),
    ContractsModule,
    NomenclaturesModule,
    AlertsModule,
    ScheduleModule.forRoot(),
    AuthModule,
    InvoiceModule,
    CreatepdfModule,
    TransactionModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    PrismaService,
    NomenclaturesService,
    AuthService,
    JwtService,
    UsersService,
    PrismaErrorService,
    {
      provide: APP_FILTER,
      useClass: HttpExceptionFilter,
    },
  ],
})
export class AppModule {}

// import { Module } from '@nestjs/common';
// import { AppController } from './app.controller';
// import { AppService } from './app.service';
// import { TypeOrmModule } from '@nestjs/typeorm';
// import { ConfigModule } from '@nestjs/config';
// import { PrismaService } from './prisma.service';

// @Module({
//   imports: [
//     ConfigModule.forRoot({ isGlobal: true }),
//     TypeOrmModule.forRoot({
//       type: 'postgres',
//       url: process.env.DATABASE_URL,
//       autoLoadEntities: true,
//       synchronize: true,
//     }),
//   ],
//   controllers: [AppController],
//   providers: [AppService, PrismaService],
// })
// export class AppModule {}
