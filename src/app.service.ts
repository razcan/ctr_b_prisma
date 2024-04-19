import { Injectable } from '@nestjs/common';
import BNR = require("bnr")
import { Cron, CronExpression } from '@nestjs/schedule';

@Injectable()
export class AppService {

  // getExchangeForEUR(): any {

  //   let result = BNR.convert(1, "EUR", "RON", function (err, amount, output) {
  //     if (err) { return console.error(err); }
  //     console.log(`Result: ${amount}`);
  //     //     console.log(`${output.input.amount} ${output.input.currency} is ${output.output.amount} ${output.output.currency}`);
  //   });
  // }

  // @Cron('05 * * * * *')
  // handleCron() {
  //   console.log('Executing scheduled task at', new Date().toLocaleString());
  // }

}