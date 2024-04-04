import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from 'src/prisma.service';

@Injectable()
export class ContractsService {
  constructor(
    private prisma: PrismaService
  ) { }

  async findContractsAvailableWf(
    departmentId?: any[], categoryId?: any[],
    cashflowId?: any[], costcenterId?: any[]) {

    // const contractsQuery: any = {};

    // // Conditionally include the where clause based on whether costcenterId is provided
    // if (costcenterId) {
    //   contractsQuery.where = {
    //     costcenterId: {
    //       in: costcenterId
    //     }
    //   };
    // }

    // if (departmentId) {
    //   contractsQuery.where = {
    //     departmentId: {
    //       in: departmentId
    //     }
    //   };
    // }

    // if (cashflowId) {
    //   contractsQuery.where = {
    //     cashflowId: {
    //       in: cashflowId
    //     }
    //   };
    // }

    // if (categoryId) {
    //   contractsQuery.where = {
    //     categoryId: {
    //       in: categoryId
    //     }
    //   };
    // }

    // const contracts = await this.prisma.contracts.findMany(contractsQuery);

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


  @Cron(CronExpression.EVERY_10_SECONDS)
  async Parser(): Promise<any> {


    const all_wf = await this.prisma.workFlowRules.findMany({
      where: {
        workflow: {
          status: true
        }
      },
      include: {
        workflow: {
          select: {
            status: true
          }
        }
      }
    });
    console.log("iupi", all_wf)
  }

  // @Cron('0 */30 9-11 * * *')
  // @Cron(CronExpression.EVERY_10_SECONDS)
  async WFParser(): Promise<any> {


    const all_wf = await this.prisma.workFlowRules.findMany({
      where: {
        workflow: {
          status: true
        }
      },
      include: {
        workflow: {
          select: {
            status: true
          }
        }
      }
    }
    );

    // const all_dep_filters = await this.prisma.workFlowRules.findMany({
    //   where: {
    //     ruleFilterSource: "costcenters",
    //     workflow: {
    //       status: true
    //     }
    //   },
    //   include: {
    //     workflow: {
    //       select: {
    //         status: true
    //       }
    //     }
    //   }
    // });

    interface rule {
      workflowId?: number,
      departments?: number[],
      categories?: number[],
      cashflows?: number[],
      costcenters?: number[]
    }

    const resultwf = [];

    all_wf.map((wf) => {
      const add = wf.workflowId
      resultwf.push(add)
    })

    const uniqueWf = [...new Set(resultwf)];

    // const uniqueWfSet = new Set(resultwf.map(item => JSON.stringify(item)));
    // const uniqueWf = Array.from(uniqueWfSet).map(item => JSON.parse(item));

    console.log(uniqueWf)


    // all_dep_filters.map(dep => {
    //   workflowId,
    // })
    // ruleFilterValue.map
    // console.log(all_dep_filters)

    // all_dep_filters.map((rules) => {
    //   const add: rule = {
    //     workflowId: rules.workflowId,
    //     departments: rules.ruleFilterValue
    //   }
    //   result.push(add)
    // })

    // console.log(all_filters)

    // const all_dep_data_filters = await this.prisma.workFlowRules.findMany({
    //   where: {
    //     ruleFilterSource: "departments"
    //   }
    // })

    // const all_departments = [];
    // all_dep_data_filters.map((dep) => {
    //   const add = { workflowId: dep.workflowId, ruleFilterSource: "departments", ruleFilterValue: dep.ruleFilterValue }
    //   all_departments.push(add)
    // })
    // const all_unique_dep_data_filters = [...new Set(all_departments)];
    // console.log(all_unique_dep_data_filters)


    // const all_categ_data_filters = await this.prisma.workFlowRules.findMany({
    //   where: {
    //     ruleFilterSource: "categories"
    //   }
    // })

    // const all_categories = [];
    // all_categ_data_filters.map((dep) => {
    //   const add = { workflowId: dep.workflowId, ruleFilterSource: "categories", ruleFilterValue: dep.ruleFilterValue }
    //   all_categories.push(add)
    // })
    // const all_unique_categ_data_filters = [...new Set(all_categories)];



    // const all_cc_data_filters = await this.prisma.workFlowRules.findMany({
    //   where: {
    //     ruleFilterSource: "costcenters"
    //   }
    // })

    // const all_costcenter = [];
    // all_cc_data_filters.map((dep) => {
    //   const add = { workflowId: dep.workflowId, ruleFilterSource: "costcenters", ruleFilterValue: dep.ruleFilterValue }
    //   all_costcenter.push(add)

    // })
    // const all_unique_cc_data_filters = [...new Set(all_costcenter)];

    // const all_cf_data_filters = await this.prisma.workFlowRules.findMany({
    //   where: {
    //     ruleFilterSource: "cashflows"
    //   }
    // })

    // const all_cashflow = [];
    // all_cf_data_filters.map((dep) => {
    //   const add = { workflowId: dep.workflowId, ruleFilterSource: "cashflows", ruleFilterValue: dep.ruleFilterValue }
    //   all_cashflow.push(add)

    // })
    // const all_unique_cf_data_filters = [...new Set(all_cashflow)];



    // console.log(
    //   all_unique_dep_data_filters, all_unique_categ_data_filters,
    //   all_unique_cf_data_filters, all_unique_cc_data_filters)



    // const available_ctr = await this.findContractsAvailableWf(
    //   all_unique_dep_data_filters, all_unique_categ_data_filters,
    //   all_unique_cf_data_filters, all_unique_cc_data_filters);

    // console.log(available_ctr)


    // Call with departmentIdValue, cashflowIdValue, and costcenterIdValue
    // await findContractsAvailableWf(departmentIdValue, undefined, cashflowIdValue, costcenterIdValue);
    // await findContractsAvailableWf(departmentIdValue, categoryIdValue, cashflowIdValue, costcenterIdValue);


    // const actualContract = await this.findContractById(1)
    // console.log(actualContract)


    // WorkFlowContractTasks 
    //     name                   String
    // text                   String
    // contractId             Int ?
    //     status                 ContractTasksStatus ? @relation(fields: [statusId], references: [id])
    // statusId               Int
    // requestor              User ? @relation("requestorwf", fields: [requestorId], references: [id])
    // requestorId            Int
    // assigned               User ? @relation("assignedwf", fields: [assignedId], references: [id])
    // assignedId             Int
    // workflowSettings       WorkFlowTaskSettings @relation(fields: [workflowTaskSettingsId], references: [id])
    // workflowTaskSettingsId Int
    // uuid                   String
    // approvalOrderNumber    Int
    // duedates               DateTime
    // taskPriority           ContractTasksPriority @relation(fields: [taskPriorityId], references: [id])
    // taskPriorityId         Int
    // reminders              DateTime


  }

}
