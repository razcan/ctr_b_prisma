import { Controller, Get, Post, Body, Patch, Param, Delete, SetMetadata, Logger } from '@nestjs/common';
import { PrismaService } from 'src/prisma.service';
// import { v4 as uuidv4 } from 'uuid';
import { MailerService } from './mailer.service'
import { Cron, CronExpression } from '@nestjs/schedule';
import { ContractsController } from '../contracts/contracts.controller'
import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { async } from 'rxjs';
import BNR = require("bnr")
import { Interface } from 'readline';
import fetch from 'node-fetch';
import { parseString } from 'xml2js';

export interface CurrencyInterface {
    date: string;
    amount: number;
    name: string;
}

@Controller('alerts')
export class AlertsController {
    constructor(
        private prisma: PrismaService,
        private contracts: ContractsController
    ) { }


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
                const value = rate._;
                const toAdd: CurrencyInterface = {
                    date: atdate,
                    amount: value,
                    name: currency
                };
                currencyResult.push(toAdd);
            });
            console.log(currencyResult)
            return currencyResult;
        } catch (error) {
            console.error('Error fetching XML:', error);
            return null;
        }
    }

    @Get('bnr')
    async exampleUsage() {
        const exchangeRates = await this.fetchExchangeRates();
        return exchangeRates
    }



    @Cron('0 */30 9-11 * * *')
    getExchangeForEUR(): any {

        BNR.getRates(async (err, rates) => {
            console.log(err || rates);

            const res = rates

            interface currency_interface {
                date: string,
                amount: number,
                name: string,
                multiplier: number
            }

            const jsonArray = Object.values(rates);
            // console.log(jsonArray);
            const dateObject = new Date();
            const dateOnlyString = dateObject.toISOString().split("T")[0];
            const currency_result: currency_interface[] = []
            jsonArray.map(result => {
                const toAdd = {
                    date: dateOnlyString,
                    amount: result.amount,
                    name: result.name,
                    multiplier: result.multiplier
                }
                currency_result.push(toAdd)
            }

            )
            // const x = currency_result.findIndex((name) => name.name == "RON")
            // currency_result.splice(x, 1)

            currency_result.map((save) =>
                this.prisma.exchangeRates.create({
                    data: {
                        date: save.date,
                        amount: save.amount,
                        name: save.name,
                        multiplier: save.multiplier
                    }

                })
            )

            const ins = await this.prisma.exchangeRates.findFirst({
                where: {
                    date: dateOnlyString
                }
            })

            if (ins && ins.date !== undefined && ins.amount !== null) {
                // Property exists and has a non-null value
                console.log("we already have the foreign exchanges")
            } else {
                // Property does not exist or has a null value
                for (let i = 0; i < currency_result.length; i++) {
                    await this.prisma.exchangeRates.create({
                        data: {
                            date: currency_result[i].date,
                            amount: currency_result[i].amount,
                            name: currency_result[i].name,
                            multiplier: currency_result[i].multiplier
                        }

                    })
                }
            }


        })

        // The promise way
        // BNR.getRates().then(console.log)

        // let result = BNR.convert(1, "EUR", "RON", function (err, amount, output) {
        //     if (err) { return console.error(err); }
        //     console.log(`Result: ${amount}`);
        //     console.log(`${output.input.amount} ${output.input.currency} is ${output.output.amount} ${output.output.currency}`);
        // });
        // return result;
    }



    @Get('')
    async getAlerts() {
        const alerts = await this.prisma.alerts.findMany()
        // this.sendMail();
        return alerts;
    }




    @Get('byId/:id')
    async getAlertById(@Param('id') id: any) {
        const alerts = await this.prisma.alerts.findUnique({
            where: {
                id: parseInt(id),
            },
        }
        )
        return alerts;
    }

    @Get('contractId/:id')
    async getAlertsByContractId(@Param('id') id: any) {
        const alerts = await this.prisma.contractAlertSchedule.findMany({
            where: {
                contractId: parseInt(id),
            },
        }
        )
        return alerts;
    }

    @Patch('/:id')
    async UpdateAlert(@Body() data: Prisma.AlertsCreateInput, @Param('id') id: any): Promise<any> {
        const alert = await this.prisma.alerts.update({
            where: {
                id: parseInt(id),
            },
            data: data,
        })
        return alert;
    }

    differenceInDays(date1: Date, date2: Date): number {
        const oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds
        const diffInTime = date2.getTime() - date1.getTime();
        return Math.round(diffInTime / oneDay);
    }

    //sa se modifice starea ctr automat cand acestea expira si sa se trimita alerta

    @Cron(CronExpression.EVERY_10_MINUTES)
    PopulateAlertContractsCronId2() {

        const allcontracts = this.contracts.findAllContracts()

        const emailSettings = this.getAlertById(2)

        allcontracts.then(ctr => {
            emailSettings.then(async settings => {
                for (let i = 0; i < ctr.length; i++) {
                    let alertDay = new Date(ctr[i].end.getTime() - (settings.nrofdays * 24 * 60 * 60 * 1000));
                    //console.log(ctr[i].id, settings.id, settings.name, alertDay, settings.isActive, true, settings.subject, settings.nrofdays)
                    const alertExist = await this.prisma.contractAlertSchedule.findFirst(
                        {
                            where: {
                                contractId: ctr[i].id,
                                alertId: settings.id,
                                // datetoBeSent: alertDay
                            },
                        })

                    if (alertExist !== null) {
                        // await this.prisma.contractAlertSchedule.deleteMany({
                        //     where: {
                        //         contractId: ctr[i].id,
                        //         alertId: settings.id
                        //     },
                        // })
                        // console.log("Exist")
                    }
                    else {
                        console.log("To be inserted")
                        await this.prisma.contractAlertSchedule.create({
                            data:
                            {
                                contractId: ctr[i].id,
                                alertId: settings.id,
                                alertname: settings.name,
                                datetoBeSent: alertDay,
                                isActive: settings.isActive,
                                status: true,
                                subject: settings.subject,
                                nrofdays: settings.nrofdays

                            }
                        });
                    }
                }
            }
            )
        })

    }


    @Cron(CronExpression.EVERY_10_MINUTES)
    PopulateAlertContractsCronId1() {

        const allcontracts = this.contracts.findAllContracts()

        const emailSettings = this.getAlertById(1)

        allcontracts.then(ctr => {
            emailSettings.then(async settings => {
                for (let i = 0; i < ctr.length; i++) {
                    let alertDay = new Date(ctr[i].end.getTime() - (settings.nrofdays * 24 * 60 * 60 * 1000));
                    //console.log(ctr[i].id, settings.id, settings.name, alertDay, settings.isActive, true, settings.subject, settings.nrofdays)
                    const alertExist = await this.prisma.contractAlertSchedule.findFirst(
                        {
                            where: {
                                contractId: ctr[i].id,
                                alertId: settings.id,
                                // datetoBeSent: alertDay
                            },
                        })

                    if (alertExist !== null) {
                        // await this.prisma.contractAlertSchedule.deleteMany({
                        //     where: {
                        //         contractId: ctr[i].id,
                        //         alertId: settings.id
                        //     },
                        // })
                        // console.log("Exist")
                    }
                    else {
                        console.log("To be inserted")
                        await this.prisma.contractAlertSchedule.create({
                            data:
                            {
                                contractId: ctr[i].id,
                                alertId: settings.id,
                                alertname: settings.name,
                                datetoBeSent: alertDay,
                                isActive: settings.isActive,
                                status: true,
                                subject: settings.subject,
                                nrofdays: settings.nrofdays

                            }
                        });
                    }
                }
            }
            )
        })

    }

    //to be done : taskuri ce au au depasit termenul - o fereastra cu taskurile atasate - eventual un grafic de unde cu click - un badge langa user icon
    //odata ce a fost trimis o alerta sa nu se mai trimita si a doua oara
    //logare toate mesajele trimise
    //EVERY_DAY_AT_10AM
    //inchidere inainte de termen
    @Cron(CronExpression.EVERY_DAY_AT_10AM)
    handleCron() {
        const allcontracts = this.contracts.findAllContracts()
        interface ContractsForAlert {
            id: Number,
            number: String,
            start: Date,
            end: Date,
            sign: Date,
            completion: Date,
            partner: String,
            entity: String,
            partner_email: String,
            persons_email: String,
            remarks: String
        }

        const contractsforNotification: ContractsForAlert[] = [];

        const mailerService = new MailerService();

        const emailSettings = this.getAlertById(1)


        var nrofdays = 0;
        var isActive = false;
        emailSettings.then(result => {
            nrofdays = result.nrofdays;
            isActive = result.isActive
            // console.log("nrofdays", nrofdays, "isActive", isActive)
        })

        if (isActive = true) {
            allcontracts.then(result => {
                const countCtr = result.length
                const today = new Date();
                for (let i = 0; i < countCtr; i++) {
                    // console.log(result[i].id, result[i].number, result[i].start, result[i].end, result[i].sign, result[i].completion, result[i].partner.name, result[i].entity.name)
                    const countPers = result[i].partner.Persons.length;

                    if (result[i].completion == null) {
                        const currentDate: Date = new Date();
                        currentDate.setDate(currentDate.getDate() + 1);
                        result[i].completion = currentDate

                    }
                    if (this.differenceInDays(result[i].completion, today) >= nrofdays) {

                        for (let j = 0; j < countPers; j++) {
                            {
                                const obj: ContractsForAlert = {
                                    id: result[i].id,
                                    number: result[i].number,
                                    start: result[i].start,
                                    end: result[i].end,
                                    sign: result[i].sign,
                                    completion: result[i].completion,
                                    partner: result[i].partner.name,
                                    entity: result[i].entity.name,
                                    partner_email: result[i].partner.email,
                                    persons_email: result[i].partner.Persons[j].email,
                                    remarks: result[i].remarks
                                }
                                contractsforNotification.push(obj)
                            }
                        }
                    }

                }

                emailSettings.then(result => {

                    for (let j = 0; j < contractsforNotification.length; j++) {

                        const originalString: string = result.text;

                        const originalDate = new Date(contractsforNotification[j].start.toString());

                        const day = originalDate.getDate().toString().padStart(2, '0'); // Get the day and pad with leading zero if needed
                        const month = (originalDate.getMonth() + 1).toString().padStart(2, '0'); // Get the month (January is 0, so we add 1) and pad with leading zero if needed
                        const year = originalDate.getFullYear(); // Get the full year

                        const formattedDateStart = `${day}.${month}.${year}`;


                        const originalDateEnd = new Date(contractsforNotification[j].end.toString());

                        const day1 = originalDateEnd.getDate().toString().padStart(2, '0'); // Get the day and pad with leading zero if needed
                        const month1 = (originalDateEnd.getMonth() + 1).toString().padStart(2, '0'); // Get the month (January is 0, so we add 1) and pad with leading zero if needed
                        const year1 = originalDateEnd.getFullYear(); // Get the full year

                        const formattedDateEnd = `${day1}.${month1}.${year1}`;


                        const replacements: { [key: string]: string } = {
                            "@@NumarContract": contractsforNotification[j].number.toString(),
                            "@@DataContract": formattedDateStart,
                            "@@DataFinal": formattedDateEnd,
                            "@@Partener": contractsforNotification[j].partner?.toString(),
                            "@@Entitate": contractsforNotification[j].entity?.toString(),
                            "@@ScurtaDescriere": contractsforNotification[j].remarks?.toString()
                        };

                        let replacedString: string = originalString;
                        for (const key in replacements) {
                            if (Object.prototype.hasOwnProperty.call(replacements, key)) {
                                replacedString = replacedString.replace(key, replacements[key]);
                            }
                        }


                        const to = contractsforNotification[j].partner_email;
                        const bcc = contractsforNotification[j].persons_email;
                        const subject = result.subject + ' ' + contractsforNotification[j].number.toString();
                        const text = replacedString;
                        const html = replacedString;
                        const attachments = [];

                        mailerService.sendMail(to.toString(), bcc.toString(), subject, text, html, attachments)
                            .then(() => console.log('Email sent successfully.'))
                            .catch(error => console.error('Error sending email:', error));
                    }
                })

            }).catch(error => {
                console.error(error);
            });
        }
    }


    //expirare contracte
    @Cron(CronExpression.EVERY_30_SECONDS)
    // @Cron(CronExpression.EVERY_DAY_AT_10AM)
    handleCronExpired() {
        const allcontracts = this.contracts.findAllContracts()
        interface ContractsForAlert {
            id: Number,
            number: String,
            start: Date,
            end: Date,
            sign: Date,
            completion: Date,
            partner: String,
            entity: String,
            partner_email: String,
            persons_email: String,
            remarks: String
        }

        const contractsforNotification: ContractsForAlert[] = [];

        const mailerService = new MailerService();

        const emailSettings = this.getAlertById(2)


        var nrofdays = 0;
        var isActive = false;

        emailSettings.then(result => {
            nrofdays = result.nrofdays;
            isActive = result.isActive
            console.log("nrofdays", nrofdays, "isActive", isActive)
        })

        if (isActive = true) {
            allcontracts.then(result => {
                const countCtr = result.length
                const today = new Date();
                for (let i = 0; i < countCtr; i++) {
                    // console.log(result[i].id, result[i].number, result[i].start, result[i].end, result[i].sign, result[i].completion, result[i].partner.name, result[i].entity.name)
                    const countPers = result[i].partner.Persons.length;


                    if (this.differenceInDays(result[i].end, today) >= nrofdays) {

                        for (let j = 0; j < countPers; j++) {
                            {
                                const obj: ContractsForAlert = {
                                    id: result[i].id,
                                    number: result[i].number,
                                    start: result[i].start,
                                    end: result[i].end,
                                    sign: result[i].sign,
                                    completion: result[i].completion,
                                    partner: result[i].partner.name,
                                    entity: result[i].entity.name,
                                    partner_email: result[i].partner.email,
                                    persons_email: result[i].partner.Persons[j].email,
                                    remarks: result[i].remarks
                                }
                                contractsforNotification.push(obj)
                            }
                        }
                    }

                }

                emailSettings.then(result => {

                    for (let j = 0; j < contractsforNotification.length; j++) {

                        const originalString: string = result.text;

                        const originalDate = new Date(contractsforNotification[j].start.toString());

                        const day = originalDate.getDate().toString().padStart(2, '0'); // Get the day and pad with leading zero if needed
                        const month = (originalDate.getMonth() + 1).toString().padStart(2, '0'); // Get the month (January is 0, so we add 1) and pad with leading zero if needed
                        const year = originalDate.getFullYear(); // Get the full year

                        const formattedDateStart = `${day}.${month}.${year}`;


                        const originalDateEnd = new Date(contractsforNotification[j].end.toString());

                        const day1 = originalDateEnd.getDate().toString().padStart(2, '0'); // Get the day and pad with leading zero if needed
                        const month1 = (originalDateEnd.getMonth() + 1).toString().padStart(2, '0'); // Get the month (January is 0, so we add 1) and pad with leading zero if needed
                        const year1 = originalDateEnd.getFullYear(); // Get the full year

                        const formattedDateEnd = `${day1}.${month1}.${year1}`;


                        const replacements: { [key: string]: string } = {
                            "@@NumarContract": contractsforNotification[j].number.toString(),
                            "@@DataContract": formattedDateStart,
                            "@@DataFinal": formattedDateEnd,
                            "@@Partener": contractsforNotification[j].partner?.toString(),
                            "@@Entitate": contractsforNotification[j].entity?.toString(),
                            "@@ScurtaDescriere": contractsforNotification[j].remarks?.toString()
                        };

                        let replacedString: string = originalString;
                        for (const key in replacements) {
                            if (Object.prototype.hasOwnProperty.call(replacements, key)) {
                                replacedString = replacedString.replace(key, replacements[key]);
                            }
                        }


                        const to = contractsforNotification[j].partner_email;
                        const bcc = contractsforNotification[j].persons_email;
                        const subject = result.subject + ' ' + contractsforNotification[j].number.toString();
                        const text = replacedString;
                        const html = replacedString;
                        const attachments = [];

                        mailerService.sendMail(to.toString(), bcc.toString(), subject, text, html, attachments)
                            .then(() => console.log('Email sent successfully.'))
                            .catch(error => console.error('Error sending email:', error));
                    }
                })

            }).catch(error => {
                console.error(error);
            });
        }
    }


}
