import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from 'src/prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class AlertService {
    constructor(private prisma: PrismaService) { }

    async findContractsAvailableWf(
        departmentId?: any[], categoryId?: any[],
        cashflowId?: any[], costcenterId?: any[]) {

        const where: any = {};

        if (costcenterId) {
            where.costcenterId = { in: costcenterId };
        }

        if (departmentId) {
            where.departmentId = { in: departmentId };
        }

        if (cashflowId) {
            where.cashflowId = { in: cashflowId };
        }

        if (categoryId) {
            where.categoryId = { in: categoryId };
        }

        const contracts = await this.prisma.contracts.findMany({
            where: where
        });


        return contracts;
    }


    // @Cron(CronExpression.EVERY_5_SECONDS)
    async wfactiverules() {

        const result1 = await this.prisma.$queryRaw(
            Prisma.sql`SELECT * FROM public.active_wf_rulesok()`
        )

        // await this.findContractsAvailableWf(departmentIdValue, categoryIdValue, cashflowIdValue, costcenterIdValue);

        // const test = await this.findContractsAvailableWf([1, 2], [1, 3], [1, 4], [1, 2, 4]);

        const test = await this.findContractsAvailableWf([1, 2], [1, 3], [2], undefined);



        console.log("test", test)
        // console.log(result1);
        return result1;
    }

}
