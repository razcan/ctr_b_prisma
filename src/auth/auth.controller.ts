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
// import { format } from 'date-fns';
// import { format } from 'date-fns-tz';
import moment from 'moment-timezone';


@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) { }

  @HttpCode(HttpStatus.OK)
  @Post('login')
  signIn(@Body() data: any) {
    return this.authService.signIn(data.username, data.password);
  }

  //   @UseGuards(AuthGuard)
  //   @Get('profile')
  //   getProfile(@Request() req) {
  //     return req.user;
  //   }

  //   @UseGuards(AuthGuard)
  //   @Get('jwt')
  //   getTest(@Request() req) {
  //     // console.log(req.user.exp)
  //     const currentDate: Date = new Date


  //     // Assuming `date` is your date object
  //     const date = new Date(); // or any other valid date object

  //     // Multiply by 1000 to convert seconds to milliseconds
  //     const expirationDate: Date = new Date(req.user.exp * 1000);

  //     // Convert to local timezone
  //     const localDate = moment(date).tz(moment.tz.guess());

  //     // Format the local date
  //     const formattedDate = localDate.format('YYYY-MM-DD HH:mm:ss');

  //     const date1 = new Date(formattedDate);


  //     console.log("controller auth", localDate);

  //     // const formattedHour = format(expirationDate, 'HH:mm:ss', { timeZone: localTimezone });
  //     // const formattedHour = format(currentDate, 'HH:mm:ss', { timeZone: 'local' });

  //     if (currentDate > date1) {
  //       console.log('naspa, a expirat cerificatul')
  //     }
  //     else {
  //       console.log(`cerificatul este valid pana la ora ${date1}`)
  //     }


  //     // console.log(formattedHour)
  //     // return req.user;

  //   }

}
