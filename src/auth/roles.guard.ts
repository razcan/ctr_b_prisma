import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
// import { User } from '../user/entities/user.entity'
import { User } from './user.model';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const roles = this.reflector.get<string[]>('roles', context.getHandler());

    // console.log(roles)

    if (!roles) {
      throw new UnauthorizedException();
    }
    const request = context.switchToHttp().getRequest();

    // console.log(request.headers)

    const headers = request.headers;

    const AllRoles = headers['user-role'].split(',').map((role) => role.trim());

    // const existsAdministrator = AllRoles.includes(roles[0]);

    // const isAdminOrReader =
    //     roles.includes('Administrator') || roles.includes('Reader') || roles.includes('Requestor') || roles.includes('Editor');

    //ce este pus pe ruta
    const routeRoles = roles;
    //ce vine de la user
    const allUserRolles = AllRoles;

    //Pentru a verifica dacă cel puțin un singur element dintr - o matrice face parte dintr - o altă matrice
    const atLeastOneMatch = allUserRolles.some((element) =>
      routeRoles.includes(element),
    );

    if (!atLeastOneMatch) {
      //   console.log(`The user doesn't the right roles`);
      throw new UnauthorizedException();
    }

    // Check if user has any of the allowed roles
    // const allowedRoles = roles;
    // const hasAllowedRole = allUserRolles.role && allowedRoles.includes(allUserRolles.role);
    // console.log(hasAllowedRole)

    // return hasAllowedRole;

    // if (allUserRolles.role === 'Administrator') {
    //     return true; // Allow access for administrators
    // }

    // const allElementsInArray1 = routeRoles.every(element => allUserRolles.includes(element));

    // if (allElementsInArray1) {
    //     console.log('Toate elementele din array1 fac parte din array2.');
    // } else {
    //     console.log('Nu toate elementele din array1 fac parte din array2.');
    // }

    return atLeastOneMatch;
  }
}
