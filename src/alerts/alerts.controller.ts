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

    @Cron(CronExpression.EVERY_30_SECONDS)
    handleCron() {
        this.logger.debug('Called every 30 sec');

        const allcontracts = this.contracts.findAllContracts()

        allcontracts.then(result => {
            console.log(result);
        }).catch(error => {
            console.error(error);
        });

        //treb luate toate ctr si data curenta, si pt fiecare ctr care are data fin mai mica de 30, se trimite email
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
