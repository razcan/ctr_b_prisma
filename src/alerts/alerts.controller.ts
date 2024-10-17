import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  SetMetadata,
  Logger,
  HttpException,
} from '@nestjs/common';
import { PrismaService } from 'src/prisma.service';
// import { v4 as uuidv4 } from 'uuid';
import { MailerService } from './mailer.service';
import { Cron, CronExpression } from '@nestjs/schedule';
// import { ContractsController } from '../contracts/contracts.controller'
import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { async } from 'rxjs';
import BNR = require('bnr');
import { Interface } from 'readline';
import fetch from 'node-fetch';
// import { parseString } from 'xml2js';
import { AlertsHistory } from 'src/alertsHistory/entities/alertsHistory.entity';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ApiParam, ApiQuery, ApiTags } from '@nestjs/swagger';
import { exec } from 'child_process';
import { promisify } from 'util';
import axios from 'axios';
import OpenAI from 'openai';

export interface CurrencyInterface {
  date: string;
  amount: number;
  name: string;
  multiplier?: string;
}

@ApiTags('Alerts')
@Controller('alerts')
export class AlertsController {
  constructor(
    private prisma: PrismaService,
    // private contracts: ContractsController
  ) {}

  async findAllContracts() {
    const contracts = await this.prisma.contracts.findMany({
      include: {
        partner: {
          include: {
            Persons: true,
          },
        },
        entity: true,
      },
    });
    return contracts;
  }
  //ccc//

  async fetchExchangeRates(): Promise<CurrencyInterface[] | null> {
    try {
      const response = await fetch('https://www.bnr.ro/nbrfxrates.xml');
      const data = await response.text();

      // Parse XML data
      const result = await new Promise<any>((resolve, reject) => {
        parseString(data, (err, result) => {
          if (err) {
            console.error('Error parsing XML:', err);
            reject(err);
          }
          resolve(result);
        });
      });

      // Access XML elements and attributes
      const rates = result.DataSet.Body[0].Cube[0].Rate;
      const atdate = result.DataSet.Body[0].Cube[0].$.date;
      const currencyResult: CurrencyInterface[] = [];
      rates.forEach((rate: any) => {
        const currency = rate.$.currency;
        let multiplier = rate.$.multiplier;
        if (!multiplier) {
          multiplier = 1;
        }
        const value = rate._;
        const toAdd: CurrencyInterface = {
          date: atdate,
          amount: parseFloat(value),
          name: currency,
          multiplier: '1',
        };
        currencyResult.push(toAdd);
      });
      console.log(currencyResult);

      const dateObject = new Date();
      const dateOnlyString = dateObject.toISOString().split('T')[0];

      const ins = await this.prisma.exchangeRatesBNR.findFirst({
        where: {
          date: dateOnlyString,
        },
      });

      if (ins && ins.date !== undefined && ins.amount !== null) {
        // Property exists and has a non-null value
        console.log('we already have the foreign exchanges');
      } else {
        // Property does not exist or has a null value
        for (let i = 0; i < currencyResult.length; i++) {
          await this.prisma.exchangeRatesBNR.create({
            data: {
              date: currencyResult[i].date,
              amount: currencyResult[i].amount,
              name: currencyResult[i].name,
              multiplier: currencyResult[i].multiplier,
            },
          });
        }
      }

      return currencyResult;
    } catch (error) {
      console.error('Error fetching XML:', error);
      return null;
    }
  }

  // @Cron(CronExpression.EVERY_30_SECONDS)
  @Get('bnr')
  async exampleUsage() {
    const exchangeRates = await this.fetchExchangeRates();
    return exchangeRates;
  }

  @Cron('0 */30 9-11 * * *')
  // @Cron('0 */1 9-15 * * *')
  getExchangeForEUR(): any {
    BNR.getRates(async (err, rates) => {
      // console.log(err || rates);

      const res = rates;

      interface currency_interface {
        date: string;
        amount: number;
        name: string;
        multiplier: number;
      }

      const jsonArray = Object.values(rates);
      // console.log(jsonArray);
      const dateObject = new Date();
      const dateOnlyString = dateObject.toISOString().split('T')[0];
      const currency_result: currency_interface[] = [];
      jsonArray.map((result) => {
        const toAdd = {
          date: dateOnlyString,
          amount: result.amount,
          name: result.name,
          multiplier: result.multiplier,
        };
        currency_result.push(toAdd);
      });
      // const x = currency_result.findIndex((name) => name.name == "RON")
      // currency_result.splice(x, 1)

      currency_result.map((save) =>
        this.prisma.exchangeRates.create({
          data: {
            date: save.date,
            amount: save.amount,
            name: save.name,
            multiplier: save.multiplier,
          },
        }),
      );

      const ins = await this.prisma.exchangeRates.findFirst({
        where: {
          date: dateOnlyString,
        },
      });

      if (ins && ins.date !== undefined && ins.amount !== null) {
        // Property exists and has a non-null value
        console.log('we already have the foreign exchanges');
      } else {
        // Property does not exist or has a null value
        for (let i = 0; i < currency_result.length; i++) {
          await this.prisma.exchangeRates.create({
            data: {
              date: currency_result[i].date,
              amount: currency_result[i].amount,
              name: currency_result[i].name,
              multiplier: currency_result[i].multiplier,
            },
          });
        }
      }
    });

    // The promise way
    BNR.getRates().then(console.log);

    let result = BNR.convert(1, 'EUR', 'RON', function (err, amount, output) {
      if (err) {
        return console.error(err);
      }
      console.log(`Result: ${amount}`);
      // console.log(
      //   `${output.input.amount} ${output.input.currency} is ${output.output.amount} ${output.output.currency}`,
      // );
    });
    return result;
  }

  execPromise = promisify(exec);

  @Post('runPython')
  async runPython() {
    try {
      // Execute the Python script
      const { stdout, stderr } = await this.execPromise(
        'python3 python-scripts/create_pdf_invoice.py',
      );

      if (stderr) {
        console.error(`Error: ${stderr}`);
        throw new Error(stderr);
      }

      return stdout;
    } catch (error) {
      console.error(`Execution failed: ${error.message}`);
      throw error;
    }
  }

  @Get('')
  async getAlerts() {
    const alerts = await this.prisma.alerts.findMany();
    // this.sendMail();
    return alerts;
  }

  @Get('byId/:id')
  async getAlertById(@Param('id') id: any) {
    const alerts = await this.prisma.alerts.findUnique({
      where: {
        id: parseInt(id),
      },
    });
    return alerts;
  }

  @Get('contractId/:id')
  async getAlertsByContractId(@Param('id') id: any) {
    const alerts = await this.prisma.contractAlertSchedule.findMany({
      where: {
        contractId: parseInt(id),
      },
    });
    return alerts;
  }

  //   @Patch('/:id')
  //   async UpdateAlert(
  //     @Body() data: Prisma.AlertsCreateInput,
  //     @Param('id') id: any,
  //   ): Promise<any> {
  //     console.log(data);
  //     const alert = await this.prisma.alerts.update({
  //       where: {
  //         id: parseInt(id),
  //       },
  //       data: data,
  //     });
  //     return alert;
  //   }

  differenceInDays(date1: Date, date2: Date): number {
    const oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds
    const diffInTime = date2.getTime() - date1.getTime();
    return Math.round(diffInTime / oneDay);
  }

  //sa se modifice starea ctr automat cand acestea expira si sa se trimita alerta

  @Cron(CronExpression.EVERY_10_SECONDS)
  PopulateAlertContractsCronId2() {
    const allcontracts = this.findAllContracts();

    const emailSettings = this.getAlertById(2);

    allcontracts.then((ctr) => {
      emailSettings.then(async (settings) => {
        for (let i = 0; i < ctr.length; i++) {
          let alertDay = new Date(
            ctr[i].end.getTime() - settings.nrofdays * 24 * 60 * 60 * 1000,
          );
          //console.log(ctr[i].id, settings.id, settings.name, alertDay, settings.isActive, true, settings.subject, settings.nrofdays)
          const alertExist = await this.prisma.contractAlertSchedule.findFirst({
            where: {
              contractId: ctr[i].id,
              alertId: settings.id,
              // datetoBeSent: alertDay
            },
          });

          if (alertExist !== null) {
            // await this.prisma.contractAlertSchedule.deleteMany({
            //     where: {
            //         contractId: ctr[i].id,
            //         alertId: settings.id
            //     },
            // })
            // console.log("Exist")
          } else {
            console.log('To be inserted');
            await this.prisma.contractAlertSchedule.create({
              data: {
                contractId: ctr[i].id,
                alertId: settings.id,
                alertname: settings.name,
                datetoBeSent: alertDay,
                isActive: settings.isActive,
                status: true,
                subject: settings.subject,
                nrofdays: settings.nrofdays,
              },
            });
          }
        }
      });
    });
  }

  @Cron(CronExpression.EVERY_10_MINUTES)
  PopulateAlertContractsCronId1() {
    const allcontracts = this.findAllContracts();

    const emailSettings = this.getAlertById(1);

    allcontracts.then((ctr) => {
      emailSettings.then(async (settings) => {
        for (let i = 0; i < ctr.length; i++) {
          let alertDay = new Date(
            ctr[i].end.getTime() - settings.nrofdays * 24 * 60 * 60 * 1000,
          );
          //console.log(ctr[i].id, settings.id, settings.name, alertDay, settings.isActive, true, settings.subject, settings.nrofdays)
          const alertExist = await this.prisma.contractAlertSchedule.findFirst({
            where: {
              contractId: ctr[i].id,
              alertId: settings.id,
              // datetoBeSent: alertDay
            },
          });

          if (alertExist !== null) {
            // await this.prisma.contractAlertSchedule.deleteMany({
            //     where: {
            //         contractId: ctr[i].id,
            //         alertId: settings.id
            //     },
            // })
            // console.log("Exist")
          } else {
            console.log('To be inserted');
            await this.prisma.contractAlertSchedule.create({
              data: {
                contractId: ctr[i].id,
                alertId: settings.id,
                alertname: settings.name,
                datetoBeSent: alertDay,
                isActive: settings.isActive,
                status: true,
                subject: settings.subject,
                nrofdays: settings.nrofdays,
              },
            });
          }
        }
      });
    });
  }

  //to be done : taskuri ce au au depasit termenul - o fereastra cu taskurile atasate - eventual un grafic de unde cu click - un badge langa user icon
  //odata ce a fost trimis o alerta sa nu se mai trimita si a doua oara
  //logare toate mesajele trimise
  //EVERY_DAY_AT_10AM
  //inchidere inainte de termen
  //@Cron(CronExpression.EVERY_30_SECONDS)

  // async findAllContracts() {
  //     const contracts = await this.prisma.contracts.findMany(
  //         {
  //             include: {
  //                 partner: {
  //                     include: {
  //                         Persons: true
  //                     }
  //                 },
  //                 entity: true,
  //             },
  //         }
  //     )
  //     return contracts;
  // }

  public async findContractById(id: any) {
    const contracts = await this.prisma.contracts.findUnique({
      include: {
        costcenter: true,
        entity: true,
        partner: true,
        PartnerPerson: true,
        EntityPerson: true,

        EntityBank: true,
        PartnerBank: true,

        EntityAddress: true,
        PartnerAddress: true,
        location: true,
        departament: true,
        Category: true,
        cashflow: true,
        type: true,
        status: true,
      },
      where: {
        id: parseInt(id),
      },
    });

    return contracts;
  }

  public async findContractSchById(id: any) {
    const contracts = await this.prisma.contracts.findUnique({
      include: {
        ContractItems: {
          include: {
            ContractFinancialDetail: true,
          },
        },
      },
      where: {
        id: parseInt(id),
      },
    });

    if (
      contracts.ContractItems &&
      contracts.ContractItems[0] &&
      contracts.ContractItems[0].ContractFinancialDetail &&
      contracts.ContractItems[0].ContractFinancialDetail[0] &&
      contracts.ContractItems[0].ContractFinancialDetail[0].itemid !== undefined
    ) {
      const itemid =
        contracts.ContractItems[0].ContractFinancialDetail[0].itemid;
      const itemres = await this.prisma.item.findUnique({
        where: {
          id: itemid,
        },
      });
      const item = itemres.name;
      // console.log(item)

      const currencyid =
        contracts.ContractItems[0].ContractFinancialDetail[0].currencyid;
      const currencyres = await this.prisma.currency.findUnique({
        where: {
          id: currencyid,
        },
      });
      const currency = currencyres.code;
      // console.log(currency)

      const billingFrequencyid =
        contracts.ContractItems[0].ContractFinancialDetail[0]
          .billingFrequencyid;
      const frequencyres = await this.prisma.billingFrequency.findUnique({
        where: {
          id: billingFrequencyid,
        },
      });
      const frequency = frequencyres.name;
      // console.log(frequency)

      const measuringUnitid =
        contracts.ContractItems[0].ContractFinancialDetail[0].measuringUnitid;
      const measuringUnitres = await this.prisma.measuringUnit.findUnique({
        where: {
          id: measuringUnitid,
        },
      });
      const measuringUnit = measuringUnitres.name;
      // console.log(measuringUnit)

      const paymentTypeid =
        contracts.ContractItems[0].ContractFinancialDetail[0].paymentTypeid;
      const paymentTyperes = await this.prisma.paymentType.findUnique({
        where: {
          id: paymentTypeid,
        },
      });
      const paymentType = paymentTyperes.name;
      // console.log(paymentType)

      const res = {
        item: item ? item : 'NA',
        currency: currency ? currency : 'NA',
        frequency: frequency ? frequency : 'NA',
        measuringUnit: measuringUnit ? measuringUnit : 'NA',
        paymentType: paymentType ? paymentType : 'NA',
        price: contracts.ContractItems[0].ContractFinancialDetail[0].price,
        remarks: contracts.ContractItems[0].ContractFinancialDetail[0].remarks,
      };

      return res;
    } else
      return {
        item: 'NA',
        currency: 'NA',
        frequency: 'NA',
        measuringUnit: 'NA',
        paymentType: 'NA',
        price: 0,
        remarks: 'NA',
      };
  }

  formatDate = (actuallDate: Date) => {
    if (actuallDate) {
      const originalDate = new Date(actuallDate.toString());
      const day = originalDate.getDate().toString().padStart(2, '0'); // Get the day and pad with leading zero if needed
      const month = (originalDate.getMonth() + 1).toString().padStart(2, '0'); // Get the month (January is 0, so we add 1) and pad with leading zero if needed
      const year = originalDate.getFullYear(); // Get the full year
      const date = `${day}.${month}.${year}`;
      return date;
    } else return;
  };

  async replacePlaceholders(CtrId: any, data: any): Promise<any> {
    const actualContract = await this.findContractById(CtrId);
    const actualContractFin = await this.findContractSchById(CtrId);
    // console.log(actualContractFin)

    const originalString: any = data;

    const contract_Sign = this.formatDate(actualContract?.sign);
    const contract_Number = actualContract?.number;
    const contract_Partner = actualContract?.partner.name;
    const contract_Entity = actualContract?.entity.name;
    const contract_Start = this.formatDate(actualContract?.start);
    const contract_End = this.formatDate(actualContract?.end);
    const contract_remarks = actualContract?.remarks;
    const contract_PartnerFiscalCode = actualContract?.partner.fiscal_code;
    const contract_PartnerComercialReg = actualContract?.partner.commercial_reg;
    const contract_PartnerAddress =
      actualContract?.PartnerAddress.completeAddress;
    const contract_PartnerStreet = actualContract?.PartnerAddress.Street;
    const contract_PartnerCity = actualContract?.PartnerAddress.City;
    const contract_PartnerCounty = actualContract?.PartnerAddress.County;
    const contract_PartnerCountry = actualContract?.PartnerAddress.Country;
    const contract_PartnerBank = actualContract?.PartnerBank.bank;
    const contract_PartnerBranch = actualContract?.PartnerBank.branch;
    const contract_PartnerIban = actualContract?.PartnerBank.iban;
    const contract_PartnerCurrency = actualContract?.PartnerBank.currency;
    const contract_PartnerPerson = actualContract?.PartnerPerson.name;
    const contract_PartnerEmail = actualContract?.PartnerPerson.email;
    const contract_PartnerPhone = actualContract?.PartnerPerson.phone;
    const contract_PartnerRole = actualContract?.PartnerPerson.role;
    const contract_EntityFiscalCode = actualContract?.entity.fiscal_code;
    const contract_EntityComercialReg = actualContract?.entity.commercial_reg;
    const contract_EntityAddress =
      actualContract?.EntityAddress.completeAddress;
    const contract_EntityStreet = actualContract?.EntityAddress.Street;
    const contract_EntityCity = actualContract?.EntityAddress.City;
    const contract_EntityCounty = actualContract?.EntityAddress.County;
    const contract_EntityCountry = actualContract?.EntityAddress.Country;
    const contract_EntityBranch = actualContract?.EntityBank.branch;
    const contract_EntityIban = actualContract?.EntityBank.iban;
    const contract_EntityCurrency = actualContract?.EntityBank.currency;
    const contract_EntityPerson = actualContract?.EntityPerson.name;
    const contract_EntityEmail = actualContract?.EntityPerson.email;
    const contract_EntityPhone = actualContract?.EntityPerson.phone;
    const contract_EntityRole = actualContract?.EntityPerson.role;
    const contract_Type = actualContract?.type.name;

    // if (actualContractFin && actualContractFin !== undefined) {
    const contract_Item = actualContractFin.item;
    const contract_Currency = actualContractFin.currency;
    const contract_Frequency = actualContractFin.frequency;
    const contract_MeasuringUnit = actualContractFin.measuringUnit;
    const contract_PaymentType = actualContractFin.paymentType;
    const contract_TotalContractValue = actualContractFin.price;
    const contract_Remarks = actualContractFin.remarks;
    // }

    //de adaugat cod uni de inregistrare si r,
    const replacements: { [key: string]: string } = {
      ContractNumber: contract_Number,
      SignDate: contract_Sign,
      StartDate: contract_Start,
      FinalDate: contract_End,
      PartnerName: contract_Partner,
      EntityName: contract_Entity,
      ShortDescription: contract_remarks,
      PartnerComercialReg: contract_PartnerComercialReg,
      PartnerFiscalCode: contract_PartnerFiscalCode,
      EntityFiscalCode: contract_EntityFiscalCode,
      EntityComercialReg: contract_EntityComercialReg,
      PartnerAddress: contract_PartnerAddress,
      PartnerStreet: contract_PartnerStreet,
      PartnerCity: contract_PartnerCity,
      PartnerCounty: contract_PartnerCounty,
      PartnerCountry: contract_PartnerCountry,
      PartnerBank: contract_PartnerBank,
      PartnerBranch: contract_PartnerBranch,
      PartnerIban: contract_PartnerIban,
      PartnerCurrency: contract_PartnerCurrency,
      PartnerPerson: contract_PartnerPerson,
      PartnerEmail: contract_PartnerEmail,
      PartnerPhone: contract_PartnerPhone,
      PartnerRole: contract_PartnerRole,
      EntityAddress: contract_EntityAddress,
      EntityStreet: contract_EntityStreet,
      EntityCity: contract_EntityCity,
      EntityCounty: contract_EntityCounty,
      EntityCountry: contract_EntityCountry,
      EntityBranch: contract_EntityBranch,
      EntityIban: contract_EntityIban,
      EntityCurrency: contract_EntityCurrency,
      EntityPerson: contract_EntityPerson,
      EntityEmail: contract_EntityEmail,
      EntityPhone: contract_EntityPhone,
      EntityRole: contract_EntityRole,
      Type: contract_Type,
      Item: contract_Item,
      Currency: contract_Currency,
      Frequency: contract_Frequency,
      MeasuringUnit: contract_MeasuringUnit,
      PaymentType: contract_PaymentType,
      TotalContractValue: contract_TotalContractValue.toString(),
      PaymentRemarks: contract_Remarks,
    };

    let replacedString: string = originalString;
    for (const key in replacements) {
      if (Object.prototype.hasOwnProperty.call(replacements, key)) {
        replacedString = replacedString.replace(key, replacements[key]);
      }
    }
    return replacedString;
  }

  @Cron(CronExpression.EVERY_10_HOURS)
  //@Cron(CronExpression.EVERY_30_SECONDS)
  // @Cron(CronExpression.EVERY_5_SECONDS)
  async handleCron() {
    const allcontracts = await this.findAllContracts();

    interface ContractsForAlert {
      id: number;
      number: string;
      start: Date;
      end: Date;
      sign: Date;
      completion: Date;
      partner: string;
      entity: string;
      partner_email: string;
      persons_email: string;
      remarks: string;
    }

    const contractsforNotification: ContractsForAlert[] = [];

    const mailerService = new MailerService();

    const emailSettings = await this.getAlertById(1);

    const nrofdays = emailSettings.nrofdays;
    const isActive = emailSettings.isActive;

    if (isActive == true) {
      if (allcontracts.length > 0) {
        const countCtr = allcontracts.length;
        const today = new Date();
        for (let i = 0; i < countCtr; i++) {
          // console.log(result[i].id, result[i].number, result[i].start, result[i].end, result[i].sign, result[i].completion, result[i].partner.name, result[i].entity.name)
          const countPers = allcontracts[i].partner.Persons.length;

          if (allcontracts[i].completion == null) {
            const currentDate: Date = new Date();
            currentDate.setDate(currentDate.getDate() + 1);
            allcontracts[i].completion = currentDate;
          }
          if (
            this.differenceInDays(allcontracts[i].completion, today) == nrofdays
          ) {
            for (let j = 0; j < countPers; j++) {
              {
                const obj: ContractsForAlert = {
                  id: allcontracts[i].id,
                  number: allcontracts[i].number,
                  start: allcontracts[i].start,
                  end: allcontracts[i].end,
                  sign: allcontracts[i].sign,
                  completion: allcontracts[i].completion,
                  partner: allcontracts[i].partner.name,
                  entity: allcontracts[i].entity.name,
                  partner_email: allcontracts[i].partner.email,
                  persons_email: allcontracts[i].partner.Persons[j].email,
                  remarks: allcontracts[i].remarks,
                };
                contractsforNotification.push(obj);
              }
            }
          }
        }

        for (let j = 0; j < contractsforNotification.length; j++) {
          const originalString: string = emailSettings.text;
          const contractId: number = contractsforNotification[j].id;
          const originalDate = new Date(
            contractsforNotification[j].start.toString(),
          );

          const day = originalDate.getDate().toString().padStart(2, '0'); // Get the day and pad with leading zero if needed
          const month = (originalDate.getMonth() + 1)
            .toString()
            .padStart(2, '0'); // Get the month (January is 0, so we add 1) and pad with leading zero if needed
          const year = originalDate.getFullYear(); // Get the full year

          const formattedDateStart = `${day}.${month}.${year}`;

          const originalDateEnd = new Date(
            contractsforNotification[j].end.toString(),
          );

          const day1 = originalDateEnd.getDate().toString().padStart(2, '0'); // Get the day and pad with leading zero if needed
          const month1 = (originalDateEnd.getMonth() + 1)
            .toString()
            .padStart(2, '0'); // Get the month (January is 0, so we add 1) and pad with leading zero if needed
          const year1 = originalDateEnd.getFullYear(); // Get the full year

          const formattedDateEnd = `${day1}.${month1}.${year1}`;

          const replacements = await this.replacePlaceholders(
            contractsforNotification[j].id,
            emailSettings.text,
          );

          const to = contractsforNotification[j].partner_email;
          const bcc = contractsforNotification[j].persons_email;
          const subject = emailSettings.subject;
          +' ' + contractsforNotification[j].number.toString();
          const text = replacements;
          const html = replacements;
          const attachments = [];
          const allEmails = 'to: ' + to + ' bcc:' + bcc;

          const toAddInAlertsHistory = {
            alertId: 1,
            alertContent: html,
            sentTo: allEmails,
            contractId: contractId,
            criteria: 'Inchis la data',
            param: 'completion',
            nrofdays: nrofdays,
            //    bcc: bcc,
            //    subject: subject,
            //    end: originalDateEnd,
            //    dif: dif
            //    nrofdays: nrofdays
          };

          const res = await this.prisma.alertsHistory.create({
            data: toAddInAlertsHistory,
          });

          mailerService
            .sendMail(
              to.toString(),
              bcc.toString(),
              subject,
              text,
              html,
              attachments,
            )
            .then(() => console.log('Email sent successfully.'))
            .catch((error) => console.error('Error sending email:', error));
        }
      }
    }
  }

  // expirare contracte
  // @Cron(CronExpression.EVERY_30_SECONDS)
  @Cron(CronExpression.EVERY_DAY_AT_10AM)
  async handleCronExpired() {
    const allcontracts = await this.findAllContracts();

    interface ContractsForAlert {
      id: number;
      number: string;
      start: Date;
      end: Date;
      sign: Date;
      completion: Date;
      partner: string;
      entity: string;
      partner_email: string;
      persons_email: string;
      remarks: string;
      dif: number;
    }

    interface AlertsHistory {
      alertId: number;
      alertContent: string;
      sentTo: string;
      contractId: number;
      criteria: string;
      param: string;
      nrofdays: number;
    }
    // console.log("se ruleaza")
    const contractsforNotification: ContractsForAlert[] = [];

    const mailerService = new MailerService();

    const emailSettings = await this.getAlertById(2);

    const nrofdays = emailSettings.nrofdays;
    const isActive = emailSettings.isActive;

    if (isActive == true) {
      if (allcontracts.length > 0) {
        const countCtr = allcontracts.length;
        const today = new Date();
        for (let i = 0; i < countCtr; i++) {
          const countPers = allcontracts[i].partner.Persons.length;

          if (
            this.differenceInDays(allcontracts[i].end, today) ==
            -1 * nrofdays
          ) {
            // console.log("cond nr zile", this.differenceInDays(allcontracts[i].end, today))
            for (let j = 0; j < countPers; j++) {
              {
                const obj: ContractsForAlert = {
                  id: allcontracts[i].id,
                  number: allcontracts[i].number,
                  start: allcontracts[i].start,
                  end: allcontracts[i].end,
                  sign: allcontracts[i].sign,
                  completion: allcontracts[i].completion,
                  partner: allcontracts[i].partner.name,
                  entity: allcontracts[i].entity.name,
                  partner_email: allcontracts[i].partner.email,
                  persons_email: allcontracts[i].partner.Persons[j].email,
                  remarks: allcontracts[i].remarks,
                  dif: this.differenceInDays(allcontracts[i].end, today),
                };
                contractsforNotification.push(obj);
              }
            }
          }
        }

        for (let j = 0; j < contractsforNotification.length; j++) {
          // const originalString: string = emailSettings.text;
          const contractId: number = contractsforNotification[j].id;

          const originalDate = new Date(
            contractsforNotification[j].start.toString(),
          );

          const day = originalDate.getDate().toString().padStart(2, '0'); // Get the day and pad with leading zero if needed
          const month = (originalDate.getMonth() + 1)
            .toString()
            .padStart(2, '0'); // Get the month (January is 0, so we add 1) and pad with leading zero if needed
          const year = originalDate.getFullYear(); // Get the full year

          const formattedDateStart = `${day}.${month}.${year}`;

          const originalDateEnd = new Date(
            contractsforNotification[j].end.toString(),
          );

          const day1 = originalDateEnd.getDate().toString().padStart(2, '0'); // Get the day and pad with leading zero if needed
          const month1 = (originalDateEnd.getMonth() + 1)
            .toString()
            .padStart(2, '0'); // Get the month (January is 0, so we add 1) and pad with leading zero if needed
          const year1 = originalDateEnd.getFullYear(); // Get the full year

          const formattedDateEnd = `${day1}.${month1}.${year1}`;
          const replacements = await this.replacePlaceholders(
            contractsforNotification[j].id,
            emailSettings.text,
          );

          const to = contractsforNotification[j].partner_email;
          const bcc = contractsforNotification[j].persons_email;
          const subject =
            emailSettings.subject +
            ' ' +
            contractsforNotification[j].number.toString();
          const text = replacements;
          const html = replacements;
          const attachments = [];
          const dif = contractsforNotification[j].dif;
          const allEmails = 'to: ' + to + ' bcc:' + bcc;

          const toAddInAlertsHistory = {
            alertId: 2,
            alertContent: html,
            sentTo: allEmails,
            contractId: contractId,
            criteria: 'Data Final',
            param: 'end',
            nrofdays: nrofdays,
          };

          const res = await this.prisma.alertsHistory.create({
            data: toAddInAlertsHistory,
          });
          mailerService
            .sendMail(
              to.toString(),
              bcc.toString(),
              subject,
              text,
              html,
              attachments,
            )
            .then(() => console.log('Email sent successfully.'))
            .catch((error) => console.error('Error sending email:', error));
        }
      }
    }

    // contractsforNotification = [];
  }

  //reminder contract task alerts
  //@Cron(CronExpression.EVERY_30_SECONDS)
  @Cron(CronExpression.EVERY_DAY_AT_10AM)
  async handleCronTaskReminder() {
    const res = await this.prisma.contractTasks.findMany({
      where: {
        AND: [
          {
            statusId: {
              in: [1],
            },
          },
          {
            statusWFId: {
              in: [1, 2],
            },
          },
        ],
      },
      include: {
        assigned: {
          select: {
            email: true,
          },
        },
      },
    });

    const current_date = new Date();
    const emailSettings = await this.getAlertById(3);

    const day = current_date.getDate().toString().padStart(2, '0'); // Get the day and pad with leading zero if needed
    const month = (current_date.getMonth() + 1).toString().padStart(2, '0'); // Get the month (January is 0, so we add 1) and pad with leading zero if needed
    const year = current_date.getFullYear(); // Get the full year

    const formattedCurrent_date = `${day}.${month}.${year}`;
    const mailerService = new MailerService();

    const taskForNotification = [];

    for (let i = 0; i < res.length; i++) {
      const originalDate = new Date(res[i].due.toString());

      const day = originalDate.getDate().toString().padStart(2, '0'); // Get the day and pad with leading zero if needed
      const month = (originalDate.getMonth() + 1).toString().padStart(2, '0'); // Get the month (January is 0, so we add 1) and pad with leading zero if needed
      const year = originalDate.getFullYear(); // Get the full year

      const formattedDateStart = `${day}.${month}.${year}`;

      if (formattedDateStart == formattedCurrent_date) {
        taskForNotification.push(res[i]);
      }
    }

    for (let j = 0; j < taskForNotification.length; j++) {
      const selected_contract = await this.findContractById(
        taskForNotification[j].contractId,
      );

      const contract_Number = selected_contract?.number;
      const contract_Partner = selected_contract?.partner.name;
      const contract_Entity = selected_contract?.entity.name;

      const createdAt = this.formatDate(taskForNotification[j].createdAt);

      const url = `<b><a href="http://localhost:5500/uikit/editcontract/ctr?Id=${taskForNotification[j].contractId}&idxp=6">Link Task</a></b>
            `;
      const text = `Va informam ca trebuie sa finalizati task-ul cu numele <b>${taskForNotification[j].taskName}</b>
            din data de <b>${createdAt}</b> 
            pentru contractul cu numarul <b>${contract_Number}</b>, la partenerul <b>${contract_Partner}</b>, entitatea <b>${contract_Entity}</b>.
            ${url}.

            ${taskForNotification[j].notes}
            `;

      const to = taskForNotification[j].assigned.email;
      const bcc = taskForNotification[j].assigned.email;
      const subject =
        emailSettings.subject + ' ' + taskForNotification[j].taskName;
      // const text = emailSettings.text + ' ' + url + ' ' + taskForNotification[j].notes;
      // const html = emailSettings.text + ' ' + url + ' ' + taskForNotification[j].notes;
      const html = text;
      const attachments = [];

      // console.log(to, bcc, subject, text, html, url)

      // const res = await this.prisma.alertsHistory.create({ data: toAddInAlertsHistory });
      mailerService
        .sendMail(
          to.toString(),
          bcc.toString(),
          subject,
          text,
          html,
          attachments,
        )
        .then(() => console.log('Email sent successfully.'))
        .catch((error) => console.error('Error sending email:', error));
    }

    // console.log(taskForNotification, "notifications")
  }
}
function parseString(data: any, arg1: (err: any, result: any) => void) {
  throw new Error('Function not implemented.');
}
