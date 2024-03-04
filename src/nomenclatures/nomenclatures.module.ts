import { Module } from '@nestjs/common';
import { NomenclaturesService } from './nomenclatures.service';
import { NomenclaturesController } from './nomenclatures.controller';
import { PrismaService } from '../prisma.service'
import { JwtService } from '@nestjs/jwt';
import { AuthService } from '../auth/auth.service';
import { UsersService } from '../user/user.service'


@Module({
  controllers: [NomenclaturesController],
  providers: [NomenclaturesService, PrismaService, JwtService, AuthService, UsersService],
  exports: [NomenclaturesService]
})
export class NomenclaturesModule { }
