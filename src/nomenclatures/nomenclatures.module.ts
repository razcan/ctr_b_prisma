import { Module } from '@nestjs/common';
import { NomenclaturesService } from './nomenclatures.service';
import { NomenclaturesController } from './nomenclatures.controller';
import { PrismaService } from '../prisma.service'
import { JwtService } from '@nestjs/jwt';
import { AuthService } from '../auth/auth.service';
import { UsersService } from '../user/user.service'
import { MailerService } from '../alerts/mailer.service'

@Module({
  controllers: [NomenclaturesController],
  providers: [NomenclaturesService, PrismaService, JwtService, 
    AuthService, UsersService, MailerService],
  exports: [NomenclaturesService]
})
export class NomenclaturesModule { }
