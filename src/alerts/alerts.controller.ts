import { Controller, Get, Post, Body, Patch, Param, Delete, SetMetadata, Logger } from '@nestjs/common';
import { PrismaService } from 'src/prisma.service';
// import { v4 as uuidv4 } from 'uuid';
import { MailerService } from './mailer.service'
import { Cron, CronExpression } from '@nestjs/schedule';
import { ContractsController } from '../contracts/contracts.controller'
import { Injectable } from '@nestjs/common';

@Controller('alerts')
export class AlertsController {
    constructor(
        private prisma: PrismaService,
        private contracts: ContractsController
    ) { }


    @Get('alerts')
    async getAlerts() {
        const alerts = await this.prisma.alerts.findMany()
        // this.sendMail();
        return alerts;
    }

    // @Cron('05 * * * * *')
    // handleCron() {
    //     this.sendMail()
    //     console.log('Executing scheduled task at', new Date().toLocaleString());
    // }
    private readonly logger = new Logger();

    differenceInDays(date1: Date, date2: Date): number {
        const oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds
        const diffInTime = date2.getTime() - date1.getTime();
        return Math.round(diffInTime / oneDay);
    }

    // Real-time example


    @Cron(CronExpression.EVERY_30_SECONDS)
    handleCron() {
        this.logger.debug('Called every 30 sec');

        const allcontracts = this.contracts.findAllContracts()

        interface ContractsForAlert {
            id: Number,
            number: String,
            start: Date,
            end: Date,
            sign: Date,
            completion: Date,
            partner: String,
            entity: String
        }

        const contractsforNotification: ContractsForAlert[] = [];

        allcontracts.then(result => {
            const countCtr = result.length
            const today = new Date();
            for (let i = 0; i < countCtr; i++) {
                //compare dates.
                console.log(result[i].id, result[i].number, result[i].start, result[i].end, result[i].sign, result[i].completion, result[i].partner.name, result[i].entity.name)

                console.log("nr zile dif: ", this.differenceInDays(result[i].end, today));

                if (this.differenceInDays(result[i].end, today) >= 30) {
                    const obj: ContractsForAlert = {
                        id: result[i].id,
                        number: result[i].number,
                        start: result[i].start,
                        end: result[i].end,
                        sign: result[i].sign,
                        completion: result[i].completion,
                        partner: result[i].partner.name,
                        entity: result[i].entity.name
                    }
                    contractsforNotification.push(obj)
                }
            }
            console.log(contractsforNotification);
        }).catch(error => {
            console.error(error);
        });

        //treb luate toate ctr si data curenta, si pt fiecare ctr care are data fin mai mica de 30, se trimite email - treb luate din ctr si valorile pentru placeholdere
    }

    @Post('alerts')
    async sendMail(): Promise<void> {
        const mailerService = new MailerService();

        const dateTime = new Date();
        const dateAsString = dateTime.toLocaleDateString();

        const to = 'razvan.mustata@gmail.com';
        const bcc = ''
        const subject = 'A new order has been added';
        const text = "";
        const html = `<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(0, 102, 204);">@@NumarContract</span> din data de 
        <span style="color: rgb(0, 102, 204);">@@DataContract</span> la partenerul <span style="color: rgb(0, 102, 204);">@@Partener</span>. 
        Acest contract a fost in vigoare in compania 
        <span style="color: rgb(0, 102, 204);">@@Entitate</span> si reprezinta <span style="color: rgb(0, 102, 204);">@@ScurtaDescriere</span>.</h2>`
        const attachments = [
            //   {   // binary buffer as an attachment
            //     filename: 'text.txt',
            //     content:  'hello world!'
            // },
            // {   // file on disk as an attachment
            //   filename: 'git.txt',
            //   path: '/Users/razvanmustata/Projects/coins/coins-backend/git.txt' // stream this file
            // },
        ]

        mailerService.sendMail(to, bcc, subject, text, html, attachments)
            .then(() => console.log('Email sent successfully.'))
            .catch(error => console.error('Error sending email:', error));
    }

}
