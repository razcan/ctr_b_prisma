import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../user/user.service';
import { JwtService } from '@nestjs/jwt';
import bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async signIn(username, password) {
    const getUserRoles = async (Id: any) => {
      const roles = await fetch(
        `http://localhost:3000/nomenclatures/user/${Id}`,
      ).then((res) => res.json());

      const roles_array = [];
      for (let i = 0; i < (await roles.roles.length); i++) {
        roles_array.push(roles.roles[i].role);
      }

      const roles_array_final = [];
      for (let i = 0; i < roles_array.length; i++) {
        roles_array_final.push(roles_array[i].roleName);
      }

      const user_groups = [];
      for (let i = 0; i < (await roles.User_Groups.length); i++) {
        user_groups.push(roles.User_Groups[i].entity);
      }

      // console.log(user_groups)

      const user_groups_final = [];
      for (let i = 0; i < user_groups.length; i++) {
        for (let j = 0; j < user_groups[i].length; j++) {
          user_groups_final.push(user_groups[i][j].id);
        }
      }

      let distinctGroupsArray = Array.from(new Set(user_groups_final));

      interface ReturnValue {
        type: any;
        value: any;
      }

      let result: ReturnValue[] = [
        { type: 'Roles', value: roles_array_final },
        { type: 'Groups', value: distinctGroupsArray },
      ];

      return result;
    };

    const hashedPassword = bcrypt.hash(password, 2);
    // console.log('hashedPassword', await hashedPassword);

    const pass = await this.usersService.findUserPass(username);
    // console.log('pass', pass);

    const isMatch = await bcrypt.compare(password, pass);
    // console.log('isMatch', isMatch);

    if (isMatch) {
      const current_user = await this.usersService.findUser(username);
      // console.log(current_user[0].id)

      if (current_user[0].status === false) {
        throw new UnauthorizedException();
      }

      const props = await getUserRoles(current_user[0].id);

      const roles = props[0].value;
      const entity = props[1].value;

      if (current_user.length == 0) {
        throw new UnauthorizedException();
      }
      const payload = {
        username: username,
        password: password,
        roles: roles,
        entity: entity,
      };

      const currentDate = new Date();

      // Add 1488 - 24 hours - minutes to the current date
      const futureDate = new Date(currentDate.getTime());
      futureDate.setMinutes(currentDate.getMinutes() + 1488);

      return {
        access_token: await this.jwtService.signAsync(payload),
        username: username,
        userid: current_user[0].id,
        roles: roles,
        entity: entity,
      };
    } else {
      return 'The password is incorrect';
    }

    //const isMatch = bcrypt.compare(password, pass);

    //treb implementat sol se verifica username , dupa care se preia pass si se verifica cu cea
    //trimisa
  }
}
