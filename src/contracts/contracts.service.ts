import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from 'src/prisma.service';

@Injectable()
export class ContractsService {
  constructor(
    private prisma: PrismaService
  ) { }

  async findContractsAvailableWf(
    departmentId?: any[], categoryId?: any,
    cashflowId?: any, costcenterId?: any) {

    const contractsQuery: any = {};

    // Conditionally include departament based on whether departmentId is provided
    // if (departmentId) {
    //   contractsQuery.include.departament = {
    //     where: {
    //       id: departmentId
    //     }
    //   };
    // }

    // // Conditionally include cashflow based on whether cashflowId is provided
    // if (cashflowId) {
    //   contractsQuery.include.cashflow = {
    //     where: {
    //       id: cashflowId
    //     }
    //   };
    // }


    // Conditionally include the where clause based on whether costcenterId is provided
    if (costcenterId) {
      contractsQuery.where = {
        costcenterId: costcenterId
      };
    }

    if (departmentId) {
      contractsQuery.where = {
        departmentId: {
          in: departmentId
        }
      };
    }

    if (cashflowId) {
      contractsQuery.where = {
        cashflowId: cashflowId
      };
    }

    if (categoryId) {
      contractsQuery.where = {
        categoryId: categoryId
      };
    }

    const contracts = await this.prisma.contracts.findMany(contractsQuery);


    return contracts;
  }

  // @Cron('0 */30 9-11 * * *')
  @Cron(CronExpression.EVERY_10_SECONDS)
  async WFParser(): Promise<any> {
    console.log("WFParser");

    // Call with all parameters
    const available_ctr = await this.findContractsAvailableWf([1, 2], undefined, undefined, undefined);
    // const okctr = available_ctr.map(
    //   (av) => {
    //     console.log("x", av.departmentId)
    //     // av.departament.id != null 
    //   }
    // )

    // Call with departmentIdValue, cashflowIdValue, and costcenterIdValue
    // await findContractsAvailableWf(departmentIdValue, undefined, cashflowIdValue, costcenterIdValue);
    // await findContractsAvailableWf(departmentIdValue, categoryIdValue, cashflowIdValue, costcenterIdValue);


    console.log(available_ctr)

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
