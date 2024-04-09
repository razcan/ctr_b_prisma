import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from 'src/prisma.service';
import { Prisma } from '@prisma/client';
import { MailerService } from '../alerts/mailer.service'
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


  @Cron(CronExpression.EVERY_MINUTE)
  // @Cron(CronExpression.EVERY_10_MINUTES)
  async wfactiverules() {

    const result1: Array<{
      workflowid?: number,
      costcenters?: string[],
      departments?: string[],
      cashflows?: string[],
      categories?: string[],

    }> = await this.prisma.$queryRaw(
      Prisma.sql`SELECT * FROM public.active_wf_rulesok()`
    )

    // await this.findContractsAvailableWf(departmentIdValue, categoryIdValue, cashflowIdValue, costcenterIdValue);

    // const test = await this.findContractsAvailableWf([1, 2], [1, 3], [1, 4], [1, 2, 4]);

    //alerta in cazul in care un ctr intra pe mai multe fluxuri ?
    //p2 pregatire/inserare taskuri utilizatori workflowcontracttasks
    //update contract status in  id =2 - asteapta aprobarea si inserat in WorkFlowXContracts cu status id 2
    //contract task status = In curs = id =1 
    //trebuie lista separata pt wf sau se poate folosi lista de la taskuri ? putem fol aceeasi lista.

    const final_res = result1.map(res => {
      if (res.costcenters.length === 0) {
        res = { ...res, costcenters: undefined };
      }
      if (res.departments.length === 0) {
        res = { ...res, departments: undefined };
      }
      if (res.cashflows.length === 0) {
        res = { ...res, cashflows: undefined };
      }
      if (res.categories.length === 0) {
        res = { ...res, categories: undefined };
      }
      return res;
    });

    const contracts_fin = [];
    let externalArray = [];

    const promises = final_res.map(async (rule, index) => {
      const x = await this.findContractsAvailableWf(rule.departments, rule.categories, rule.cashflows, rule.costcenters);
      const adds = x.map(async contract => ({
        contractId: contract.id,
        ctrstatusId: 2,
        wfstatusId: 1,
        workflowTaskSettingsId: 0,
        // index,
        workflowid: rule.workflowid
      }));
      return adds;
    });


    Promise.all(promises)
      .then(async contractArrays => {
        const contracts_fin = contractArrays.flat();
        const mappedResults = contracts_fin.map(async (contract) => {
          const result = await this.prisma.workFlowTaskSettings.findFirst({
            select: {
              id: true
            },
            where: {
              workflowId: (await contract).workflowid
            },
          });
          (await contract).workflowTaskSettingsId = result.id

          return contract;
        });

        // If you need to wait for all the mapped results to resolve:
        const finalResults = await Promise.all(mappedResults);
        externalArray = finalResults;
        // console.log(externalArray, "externalArray inside")
        return finalResults;
      }).then(async fin => {
        // console.log("externalArray outside", externalArray)
        const uniqueValues = Array.from(new Set(externalArray));
        // console.log(uniqueValues, "uniqueValues", uniqueValues.length);
        // console.log(externalArray.length, "dim array")
        for (let i = 0; i < uniqueValues.length; i++) {
          //daca  exista combinatia(contractId,workflowTaskSettingsId), nu se face insert
          const y = await this.prisma.workFlowXContracts.findFirst({
            where: {
              contractId: uniqueValues[i].contractId,
              workflowTaskSettingsId: uniqueValues[i].workflowTaskSettingsId
            }
          })
          if (y) {
            // console.log("exista");
          }
          else {
            //daca nu exista combinatia(contractId,workflowTaskSettingsId), se face insert
            // console.log("nu exista, se face insert");
            const x = await this.prisma.workFlowXContracts.create({
              data:
              {
                contractId: uniqueValues[i].contractId,
                wfstatusId: uniqueValues[i].wfstatusId,
                ctrstatusId: uniqueValues[i].ctrstatusId,
                workflowTaskSettingsId: uniqueValues[i].workflowTaskSettingsId,
              }
            })
            const result1 = await this.prisma.$queryRaw(
              Prisma.sql`SELECT remove_duplicates_from_table2()`
            )
            // return result1;

          }
        }
      })
      .catch(error => {
        console.error('Error occurred:', error);
      });


    return contracts_fin;
  }



  @Cron(CronExpression.EVERY_5_SECONDS)
  // @Cron(CronExpression.EVERY_30_SECONDS)
  async generateContractTasks() {
    const result: [any] = await this.prisma.$queryRaw(
      Prisma.sql`select * from public.contractTaskToBeGeneratedok()`
    )
    const mailerService = new MailerService();

    result.map(async (task) => {
      const data = {
        contractId: task.contractid,
        statusId: task.statusid,
        requestorId: task.requestorid,
        assignedId: task.assignedid,
        workflowTaskSettingsId: task.workflowtasksettingsid,
        approvalOrderNumber: task.approvalordernumber,
        duedates: task.calculatedduedate,
        name: task.taskname,
        reminders: task.calculatedreminderdate,
        taskPriorityId: task.priorityid,
        text: task.tasknotes,
        uuid: task.uuid
      }

      const result = await this.prisma.workFlowContractTasks.create({
        data,
      });

      const remove_duplicates = await this.prisma.$queryRaw(
        Prisma.sql`SELECT remove_duplicates_from_task()`
      )

      // const to = contractsforNotification[j].partner_email;
      // const bcc = contractsforNotification[j].persons_email;
      // const subject = emailSettings.subject + ' ' + contractsforNotification[j].number.toString();
      // const text = replacedString;
      // const html = replacedString;
      // const attachments = [];
      // const allEmails = 'to: ' + to + ' bcc:' + bcc;

      // mailerService.sendMail(to.toString(), bcc.toString(), subject, text, html, attachments)
      //   .then(() => console.log('Email sent successfully.'))
      //   .catch(error => console.error('Error sending email:', error));

      console.log(result);
    })

    //trebuie modificata starea ctr si a statusului dupa insert in tabela de x astfel incat sa nu se mai genereze inca odata.
    //trebuie apelat endpoint pentru schimbare text fiecare task pe ctrid
    // cand se populeaza tabela de x trebuie modificata starea ctr.

  }


}