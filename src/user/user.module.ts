import { Module } from '@nestjs/common';
import { UsersService } from './user.service';
import { PrismaService } from 'src/prisma.service';

@Module({
  providers: [UsersService, PrismaService],
  exports: [UsersService]
})
export class UsersModule { }

