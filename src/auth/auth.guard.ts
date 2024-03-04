import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { jwtConstants } from './constants';
import { Request } from 'express';
import jwt from 'jsonwebtoken';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private jwtService: JwtService) { }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    // console.log("fin guard : ", request)



    // const token = 'your_jwt_token_here';

    const token = this.extractTokenFromHeader(request);

    // Decode the token to get the payload
    const decodedToken: any = jwt.decode(token);
    console.log(decodedToken)
    // Check if the token is valid and the payload is decoded
    if (decodedToken) {
      // Check if the token has an expiration time (exp)
      if (decodedToken.exp) {
        // Convert expiration timestamp (in seconds) to milliseconds and create a Date object
        const expirationDate = new Date(decodedToken.exp * 1000);
        console.log('Expiration Date:', expirationDate);
      } else {
        console.log('Token does not have an expiration date.');
      }
    } else {
      console.log('Invalid token.');
    }


    if (!token) {
      throw new UnauthorizedException();
    }
    try {
      const payload = await this.jwtService.verifyAsync(
        token,
        {
          secret: jwtConstants.secret
        }
      );
      // 💡 We're assigning the payload to the request object here
      // so that we can access it in our route handlers
      request['user'] = payload;
    } catch {
      throw new UnauthorizedException();
    }
    return true;
  }

  private extractTokenFromHeader(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}