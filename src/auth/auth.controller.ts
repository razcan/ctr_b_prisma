import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Request,
  UseGuards
} from '@nestjs/common';
import { AuthGuard } from './auth.guard';
import { AuthService } from './auth.service';
// import { format } from 'date-fns-tz';


@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) { }

  @HttpCode(HttpStatus.OK)
  @Post('login')
  signIn(@Body() data: any) {
    return this.authService.signIn(data.username, data.password);
  }

  @UseGuards(AuthGuard)
  @Get('profile')
  getProfile(@Request() req) {
    return req.user;
  }

  @UseGuards(AuthGuard)
  @Get('jwt')
  getTest(@Request() req) {
    // console.log(req.user.exp)
    const currentDate: Date = new Date
    // Multiply by 1000 to convert seconds to milliseconds
    const expirationDate: Date = new Date(req.user.exp * 1000);
    const localTimezone = 'Europe/Bucharest';
    // const formattedHour = format(expirationDate, 'HH:mm:ss', { timeZone: localTimezone });

    if (currentDate > expirationDate) {
      console.log('naspa, a expirat cerificatul')
    }
    else {
      // console.log(`cerificatul este valid pana la ora ${formattedHour}`)
    }


    // console.log(formattedHour)
    return req.user;

  }
}
