import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../user/user.service';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService
  ) { }

  async signIn(username, password) {
    const userrzc = await this.usersService.findUser(username, password);
    if (userrzc.length == 0) {
      throw new UnauthorizedException();
    }
    const payload = { username: username, password: password };

    const currentDate = new Date();

    // Add 10 minutes to the current date
    const futureDate = new Date(currentDate.getTime());
    futureDate.setMinutes(currentDate.getMinutes() + 10);


    return {
      access_token: await this.jwtService.signAsync(payload),
      expire_date_token: futureDate,
      username: username
    };
  }
}

//unde se verifica daca tokenul a expirat? se salveaza in bd data de expirare?