import { Injectable } from '@nestjs/common';
import { Param, Response } from '@nestjs/common';
import { PrismaService } from 'src/prisma.service';

// This should be a real class/interface representing a user entity
export type User = any;

@Injectable()
export class UsersService {

  constructor(
    private prisma: PrismaService
  ) { }


  async findUser(username: string) {

    const user = await this.prisma.user.findMany({
      where: {
        name: username
      },
      select: {
        id: true,
        name: true,
        email: true,
        status: true,
        picture: true,
        roles: true
      },
    });
    return user;

  }


  async findUserPass(username: string) {
    const user = await this.prisma.user.findMany({
      where: {
        name: username
      },
      select: {
        id: true,
        password: true
      },
    })
    return user[0].password;
  }
}