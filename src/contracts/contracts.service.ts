import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from 'src/prisma.service';
import { ContractFinancialDetail, ContractFinancialDetailSchedule, Contracts, Prisma } from '@prisma/client';

@Injectable()
export class ContractsService {
  constructor(private prisma: PrismaService) { }

  // @Cron(CronExpression.EVERY_5_SECONDS)
  // async Parser(): Promise<any> {

  //   const all_wf = await this.prisma.workFlowRules.findMany({
  //     where: {
  //       workflow: {
  //         status: true
  //       }
  //     },
  //     include: {
  //       workflow: true
  //     }
  //   });

  //   const resultwf = [];


  //   all_wf.map((wf) => {
  //     const add = wf.workflowId
  //     resultwf.push(add)
  //   })

  //   const uniqueWf = [...new Set(resultwf)];
  //   //un array cu wf-urile unice active
  //   // console.log(uniqueWf)

  //   function getDistinctElements(array: any[]): any[] {
  //     return array.filter((element, index, self) => {
  //       return index === self.findIndex((t) => (
  //         t[0] === element[0] && t[1] === element[1] && t[2] === element[2]
  //       ));
  //     });
  //   }


  //   interface rule {
  //     workflowId?: number,
  //     departments?: number[],
  //     categories?: number[],
  //     cashflows?: number[],
  //     costcenters?: number[]
  //   }

  //   const x = [];

  //   uniqueWf.map(
  //     (wfid) => {
  //       x.push(wfid)
  //     }
  //   )

  //   const xxx: any[] = []
  //   for (let i = 0; i < x.length; i++) {

  //     const all_categ_data_filters = await this.prisma.workFlowRules.findMany({
  //       where: {
  //         workflowId: x[i],
  //         ruleFilterSource: "categories"
  //       }
  //     })

  //     const all_cc_data_filters = await this.prisma.workFlowRules.findMany({
  //       where: {
  //         workflowId: x[i],
  //         ruleFilterSource: "costcenters"
  //       }
  //     })

  //     const all_cf_data_filters = await this.prisma.workFlowRules.findMany({
  //       where: {
  //         workflowId: x[i],
  //         ruleFilterSource: "cashflows"
  //       }
  //     })

  //     const all_dep_data_filters = await this.prisma.workFlowRules.findMany({
  //       where: {
  //         workflowId: x[i],
  //         ruleFilterSource: "departments"
  //       }
  //     })

  //     const all_categories = [];
  //     all_categ_data_filters.map((dep) => {
  //       const add = dep.ruleFilterValue
  //       all_categories.push(x[i], "categories", add)
  //     })
  //     const all_unique_categ_data_filters = [...new Set(all_categories)];

  //     const all_costcenter = [];
  //     all_cc_data_filters.map((dep) => {
  //       const add = dep.ruleFilterValue
  //       all_costcenter.push(x[i], "costcenters", add)
  //     })
  //     const all_unique_cc_data_filters = [...new Set(all_costcenter)];


  //     const all_cashflow = [];
  //     all_cf_data_filters.map((dep) => {
  //       const add = dep.ruleFilterValue
  //       all_cashflow.push(x[i], "cashflows", add)
  //     })
  //     const all_unique_cf_data_filters = [...new Set(all_cashflow)];

  //     const all_departments = [];
  //     all_dep_data_filters.map((dep) => {
  //       const add = dep.ruleFilterValue
  //       all_departments.push(x[i], "departments", add)
  //     })
  //     const all_unique_dep_data_filters = [...new Set(all_departments)];


  //     xxx.push(...xxx, all_unique_categ_data_filters, all_unique_cc_data_filters, all_unique_cf_data_filters, all_unique_dep_data_filters)

  //   }

  //   const distinctElements = getDistinctElements(xxx);
  //   console.log(distinctElements);

  //   return distinctElements;

  // }

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


  @Cron(CronExpression.EVERY_5_SECONDS)
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
