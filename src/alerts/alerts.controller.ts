import { Controller, Get, Post, Body, Patch, Param, Delete, SetMetadata, Logger } from '@nestjs/common';
import { PrismaService } from 'src/prisma.service';
// import { v4 as uuidv4 } from 'uuid';
import { MailerService } from './mailer.service'
import { Cron, CronExpression } from '@nestjs/schedule';
import { ContractsController } from '../contracts/contracts.controller'
import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { async } from 'rxjs';

@Controller('alerts')
export class AlertsController {
    constructor(
        private prisma: PrismaService,
        private contracts: ContractsController
    ) { }


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

    @Cron(CronExpression.EVERY_10_MINUTES)
    PopulateAlertContractsCron() {

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
                                datetoBeSent: alertDay

                            },
                        })

                    if (alertExist !== null) {
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

    //EVERY_DAY_AT_10AM
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
                    if (this.differenceInDays(result[i].end, today) >= nrofdays)
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
                // console.log(contractsforNotification);


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
