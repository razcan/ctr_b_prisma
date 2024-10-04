import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from 'src/prisma.service';
import { Prisma } from '@prisma/client';
import { MailerService } from '../alerts/mailer.service';
import { access } from 'fs';
import { v4 as uuidv4 } from 'uuid';
import { exec } from 'child_process';

@Injectable()
export class ContractsService {
  constructor(private prisma: PrismaService) {}

  // @Cron(CronExpression.EVERY_5_SECONDS)
  async Parser(): Promise<any> {
    const all_wf = await this.prisma.workFlowRules.findMany({
      where: {
        workflow: {
          status: true,
        },
      },
      include: {
        workflow: true,
      },
    });

    const resultwf = [];

    all_wf.map((wf) => {
      const add = wf.workflowId;
      resultwf.push(add);
    });

    const uniqueWf = [...new Set(resultwf)];
    //un array cu wf-urile unice active
    // console.log(uniqueWf)

    function getDistinctElements(array: any[]): any[] {
      return array.filter((element, index, self) => {
        return (
          index ===
          self.findIndex(
            (t) =>
              t[0] === element[0] && t[1] === element[1] && t[2] === element[2],
          )
        );
      });
    }

    interface rule {
      workflowId?: number;
      departments?: number[];
      categories?: number[];
      cashflows?: number[];
      costcenters?: number[];
    }

    const x = [];

    uniqueWf.map((wfid) => {
      x.push(wfid);
    });

    const xxx: any[] = [];
    for (let i = 0; i < x.length; i++) {
      const all_categ_data_filters = await this.prisma.workFlowRules.findMany({
        where: {
          workflowId: x[i],
          ruleFilterSource: 'categories',
        },
      });

      const all_cc_data_filters = await this.prisma.workFlowRules.findMany({
        where: {
          workflowId: x[i],
          ruleFilterSource: 'costcenters',
        },
      });

      const all_cf_data_filters = await this.prisma.workFlowRules.findMany({
        where: {
          workflowId: x[i],
          ruleFilterSource: 'cashflows',
        },
      });

      const all_dep_data_filters = await this.prisma.workFlowRules.findMany({
        where: {
          workflowId: x[i],
          ruleFilterSource: 'departments',
        },
      });

      const all_categories = [];
      all_categ_data_filters.map((dep) => {
        const add = dep.ruleFilterValue;
        all_categories.push(x[i], 'categories', add);
      });
      const all_unique_categ_data_filters = [...new Set(all_categories)];

      const all_costcenter = [];
      all_cc_data_filters.map((dep) => {
        const add = dep.ruleFilterValue;
        all_costcenter.push(x[i], 'costcenters', add);
      });
      const all_unique_cc_data_filters = [...new Set(all_costcenter)];

      const all_cashflow = [];
      all_cf_data_filters.map((dep) => {
        const add = dep.ruleFilterValue;
        all_cashflow.push(x[i], 'cashflows', add);
      });
      const all_unique_cf_data_filters = [...new Set(all_cashflow)];

      const all_departments = [];
      all_dep_data_filters.map((dep) => {
        const add = dep.ruleFilterValue;
        all_departments.push(x[i], 'departments', add);
      });
      const all_unique_dep_data_filters = [...new Set(all_departments)];

      xxx.push(
        ...xxx,
        all_unique_categ_data_filters,
        all_unique_cc_data_filters,
        all_unique_cf_data_filters,
        all_unique_dep_data_filters,
      );
    }

    const distinctElements = getDistinctElements(xxx);
    console.log(distinctElements);

    return distinctElements;
  }

  async findContractsAvailableWf(
    departmentId?: any[],
    categoryId?: any[],
    cashflowId?: any[],
    costcenterId?: any[],
  ) {
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

    where.statusWFId = { in: [2] }; //Asteapta aprobarea

    where.statusId = { in: [2] }; //Activ
    //the selected contracts, it will be choosen only by the combination between the upper to states

    // console.log(where, "where")

    const contracts = await this.prisma.contracts.findMany({
      where: where,
    });

    // console.log(contracts, "contracte regula")

    return contracts;
  }

  @Cron(CronExpression.EVERY_DAY_AT_10AM)
  async runScript(): Promise<void> {
    // Command to run your bash script
    const command =
      'sh /Users/razvanmustata/Projects/contracts/backend/bck_db/run_backup.sh';
    // backend / bck_db / run_backup.sh
    // Execute the bash script
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error executing bash script: ${error.message}`);
        return;
      }
      if (stderr) {
        console.error(`Error output from bash script: ${stderr}`);
        return;
      }
      console.log(`Output from bash script: ${stdout}`);
    });
  }

  @Cron(CronExpression.EVERY_MINUTE)
  // @Cron(CronExpression.EVERY_10_MINUTES)
  async wfactiverules() {
    const result1: Array<{
      workflowid?: number;
      costcenters?: string[];
      departments?: string[];
      cashflows?: string[];
      categories?: string[];
    }> = await this.prisma.$queryRaw(
      Prisma.sql`SELECT * FROM public.active_wf_rulesok99()`,
    );

    // await this.findContractsAvailableWf(departmentIdValue, categoryIdValue, cashflowIdValue, costcenterIdValue);

    // const test = await this.findContractsAvailableWf([1, 2], [1, 3], [1, 4], [1, 2, 4]);

    //alerta in cazul in care un ctr intra pe mai multe fluxuri ?
    //p2 pregatire/inserare taskuri utilizatori workflowcontracttasks
    //update contract status in  id =2 - asteapta aprobarea si inserat in WorkFlowXContracts cu status id 2
    //contract task status = In curs = id =1
    //trebuie lista separata pt wf sau se poate folosi lista de la taskuri ? putem fol aceeasi lista.

    const final_res = result1.map((res) => {
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
      const x = await this.findContractsAvailableWf(
        rule.departments,
        rule.categories,
        rule.cashflows,
        rule.costcenters,
      );
      // console.log(x, "contracte")
      const adds = x.map(async (contract) => ({
        contractId: contract.id,
        ctrstatusId: 2,
        wfstatusId: 1,
        workflowTaskSettingsId: 0,
        // index,
        workflowid: rule.workflowid,
      }));
      return adds;
    });

    Promise.all(promises)
      .then(async (contractArrays) => {
        const contracts_fin = contractArrays.flat();
        const mappedResults = contracts_fin.map(async (contract) => {
          const result = await this.prisma.workFlowTaskSettings.findFirst({
            select: {
              id: true,
            },
            where: {
              workflowId: (await contract).workflowid,
            },
          });
          (await contract).workflowTaskSettingsId = result.id;

          return contract;
        });

        // If you need to wait for all the mapped results to resolve:
        const finalResults = await Promise.all(mappedResults);
        externalArray = finalResults;
        // console.log(externalArray, "externalArray inside")
        return finalResults;
      })
      .then(async (fin) => {
        // console.log("externalArray outside", externalArray)
        const uniqueValues = Array.from(new Set(externalArray));
        // console.log(uniqueValues, "uniqueValues", uniqueValues.length);
        // console.log(externalArray.length, "dim array")
        for (let i = 0; i < uniqueValues.length; i++) {
          //daca  exista combinatia(contractId,workflowTaskSettingsId), nu se face insert
          const y = await this.prisma.workFlowXContracts.findFirst({
            where: {
              contractId: uniqueValues[i].contractId,
              workflowTaskSettingsId: uniqueValues[i].workflowTaskSettingsId,
            },
          });
          if (y) {
            // console.log("exista");
          } else {
            //daca nu exista combinatia(contractId,workflowTaskSettingsId), se face insert
            // console.log("nu exista, se face insert");
            const x = await this.prisma.workFlowXContracts.create({
              data: {
                contractId: uniqueValues[i].contractId,
                wfstatusId: uniqueValues[i].wfstatusId,
                ctrstatusId: uniqueValues[i].ctrstatusId,
                workflowTaskSettingsId: uniqueValues[i].workflowTaskSettingsId,
              },
            });
            const result1 = await this.prisma.$queryRaw(
              Prisma.sql`SELECT remove_duplicates_from_table2()`,
            );
            // return result1;
          }
        }
      })
      .catch((error) => {
        console.error('Error occurred:', error);
      });

    return contracts_fin;
  }

  async getSimplifyUsersById(userId: any): Promise<any> {
    const users = await this.prisma.user.findUnique({
      where: {
        id: parseInt(userId),
      },
      select: {
        id: true,
        name: true,
        email: true,
        status: true,
      },
    });
    return users;
  }

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

  // contracts.ContractItems[0].ContractFinancialDetail;

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

  async nextTasks(contractId: number) {
    const nextTasks: [any] = await this.prisma.$queryRaw(
      Prisma.sql`select * from public.contracttasktobegeneratedsecv(${contractId}::int4)`,
    );
    // return nextTasks;
  }

  @Cron(CronExpression.EVERY_5_SECONDS)
  // @Cron(CronExpression.EVERY_10_MINUTES)
  // @Cron(CronExpression.EVERY_10_HOURS)
  async generateSecventialContractTasks() {
    //se iau toate ctr active(ctr in stare Activ si statusWf Asteapta aprobarea) pt fluxuri Active
    const result: any[] = await this.prisma.$queryRaw(
      Prisma.sql`SELECT * FROM cttobegeneratedsecv();`,
    );
    // console.log(result)
    const res_array = [];

    await Promise.all(
      result.map(async (task) => {
        //se ia urmatorul task(supa order number) care nu este in stare Aprobat
        const nextTask = await this.prisma.$queryRaw(
          Prisma.sql`select * from public.contracttasktobegeneratedsecv3(${task.contractid}::int4)`,
        );
        res_array.push(nextTask);
      }),
    );

    const flattenedArray = res_array.flat();

    const distinctArray = [...new Set(flattenedArray)];

    const uniqueContractIds = new Set();

    // Filter the array to keep only distinct elements based on contractid
    const distinctElements = distinctArray.filter((obj) => {
      if (uniqueContractIds.has(obj.contractid)) {
        return false; // Duplicate, skip
      }
      uniqueContractIds.add(obj.contractid);
      return true; // Unique, keep
    });

    // for (let i = 0; i < distinctElements.length; i++) {
    //   console.log(distinctElements[i].contractid, "distinctElements")
    // }

    distinctElements.map(async (task) => {
      const textReplaced = await this.replacePlaceholders(
        task.contractid,
        task.tasknotes,
      );

      const uuid = uuidv4();

      const nextTask = {
        contractId: task.contractid,
        statusId: 2, //Asteapta aprobarea
        requestorId: task.requestorid,
        assignedId: task.assignedid,
        workflowTaskSettingsId: task.workflowtasksettingsid,
        approvalOrderNumber: task.approvalordernumber,
        duedates: task.calculatedduedate,
        name: task.taskname,
        reminders: task.calculatedreminderdate,
        taskPriorityId: task.priorityid,
        text: task.tasknotes,
        uuid: uuid,
      };

      const ctrTask = {
        taskName: task.taskname,
        contractId: task.contractid,
        statusId: 4, //Anulat
        statusWFId: 2, //Asteapta aprobarea
        requestorId: task.requestorid,
        assignedId: task.assignedid,
        due: task.calculatedduedate,
        notes: textReplaced,
        uuid: uuid,
        type: 'approval_task',
        taskPriorityId: task.priorityid,
        rejected_reason: '',
      };

      const check = await this.prisma.workFlowContractTasks.findFirst({
        where: {
          contractId: task.contractid,
          approvalOrderNumber: task.approvalordernumber,
          workflowTaskSettingsId: task.workflowTaskSettingsId,
        },
      });

      // console.log(check.contractId, task.contractid, "aiciiiii")

      if (!check) {
        const rez = await this.prisma.workFlowContractTasks.create({
          data: nextTask,
        });

        const rezCtrTask = await this.prisma.contractTasks.create({
          data: ctrTask,
        });

        // console.log(rez, rezCtrTask)
        const mailerService = new MailerService();

        const user_assigned_email = await this.getSimplifyUsersById(
          task.assignedid,
        );
        const link = `http://localhost:3000/uikit/workflowstask/${nextTask.uuid}`;
        const inputDate = new Date(task.calculatedduedate);
        const options: Intl.DateTimeFormatOptions = {
          year: 'numeric',
          month: 'long',
          day: 'numeric',
        };
        const localDate = inputDate.toLocaleDateString('ro-RO', options);

        // const to = user_assigned_email.email;
        const to = 'razvan.mustata@gmail.com';

        const approve_link = `http://localhost:3000/contracts/approveTask/${nextTask.uuid}`;
        const reject_link = `http://localhost:3000/contracts/rejectTask/${nextTask.uuid}`;
        // const bcc = user_assigned_email.email;
        const bcc = 'razvan.mustata@nirogroup.ro';
        const subject = task.taskname;
        const text = task.tasknotes;
        const html = `<!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Email Template</title>
        <style>
            /* Button styles */
            .button {
                display: inline-block;
                padding: 10px 20px;
                background-color: #007bff;
                color: #ffffff;
                text-decoration: none;
                border-radius: 5px;
            }
            /* Button hover effect */
            .button:hover {
                background-color: #0056b3;
            }
              .button_approve {
                      display: inline-block;
                      padding: 10px 20px;
                      background-color: #007bff;
                      color: #ffffff;
                      text-decoration: none;
                      border-radius: 5px;
                  }
              .button_reject {
                      display: inline-block;
                      padding: 10px 20px;
                      background-color: #FF0000;
                      color: #ffffff;
                      text-decoration: none;
                      border-radius: 5px;
                  }
        </style>
        </head>
        <body>

          <p>${textReplaced}</p>

            <p> Acest task trebuie aprobat pana la data: <b>${localDate}</b> </p>
            <p> Acest task are prioritatea:  <b>${task.priorityname}</b></p>

            <table border="0" cellpadding="0" cellspacing="0">
                <tr>
                    <td>
                        <a href=${approve_link} class="button_approve">Aproba</a>
                    </td>
                    <td style="padding-left: 10px;">
                        <a href=${reject_link} class="button_reject">Respinge</a>
                    </td>
                </tr>
            </table>
        </body>
        </html>`;

        const attachments = [];
        const allEmails = 'to: ' + to + ' bcc:' + bcc;

        // console.log(to.toString(), bcc.toString(), subject, text, html, attachments)
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
    });
  }

  @Cron(CronExpression.EVERY_10_MINUTES)
  @Cron(CronExpression.EVERY_10_HOURS)
  @Cron(CronExpression.EVERY_5_SECONDS)
  async generateParalelContractTasks() {
    //get all contracts with satateId=1
    const result: [any] = await this.prisma.$queryRaw(
      Prisma.sql`select * from public.contractTaskToBeGeneratedok()`,
    );
    const mailerService = new MailerService();

    result.map(async (task) => {
      //replace placeholders
      const textReplaced = await this.replacePlaceholders(
        task.contractid,
        task.tasknotes,
      );

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
        text: textReplaced,
        uuid: task.uuid,
      };

      if (task.approvaltypeinparallel) {
        // update contract status
        const ctr_status = await this.prisma.contracts.update({
          where: {
            id: task.contractid,
          },
          data: {
            statusId: 2,
            //Asteapta aprobarea
          },
        });

        const result = await this.prisma.workFlowContractTasks.create({
          data,
        });
      }

      //send notification emails
      const user_assigned_email = await this.getSimplifyUsersById(
        task.assignedid,
      );
      const link = `http://localhost:3000/uikit/workflowstask/${task.uuid}`;
      const inputDate = new Date(task.calculatedduedate);
      const options: Intl.DateTimeFormatOptions = {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
      };
      const localDate = inputDate.toLocaleDateString('ro-RO', options);

      // const to = user_assigned_email.email;
      const to = 'razvan.mustata@gmail.com';

      const approve_link = `http://localhost:3000/contracts/approveTask/${task.uuid}`;
      const reject_link = `http://localhost:3000/contracts/rejectTask/${task.uuid}`;
      // const bcc = user_assigned_email.email;
      const bcc = 'razvan.mustata@nirogroup.ro';
      const subject = task.taskname;
      const text = task.tasknotes;
      const html = `<!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Email Template</title>
        <style>
            /* Button styles */
            .button {
                display: inline-block;
                padding: 10px 20px;
                background-color: #007bff;
                color: #ffffff;
                text-decoration: none;
                border-radius: 5px;
            }
            /* Button hover effect */
            .button:hover {
                background-color: #0056b3;
            }
              .button_approve {
                      display: inline-block;
                      padding: 10px 20px;
                      background-color: #007bff;
                      color: #ffffff;
                      text-decoration: none;
                      border-radius: 5px;
                  }
              .button_reject {
                      display: inline-block;
                      padding: 10px 20px;
                      background-color: #FF0000;
                      color: #ffffff;
                      text-decoration: none;
                      border-radius: 5px;
                  }
        </style>
        </head>
        <body>

          <p>Va rugam sa luati decizia daca aprobati contractul.</p>
            <p>${textReplaced}</p>

            <p> Acest task trebuie aprobat pana la data: <b>${localDate}</b> </p>
            <p> Acest task are prioritatea:  <b>${task.priorityname}</b></p>

            <table border="0" cellpadding="0" cellspacing="0">
                <tr>
                    <td>
                        <a href=${approve_link} class="button_approve">Aproba</a>
                    </td>
                    <td style="padding-left: 10px;">
                        <a href=${reject_link} class="button_reject">Respinge</a>
                    </td>
                </tr>
            </table>
        </body>
        </html>`;

      const attachments = [];
      const allEmails = 'to: ' + to + ' bcc:' + bcc;

      // console.log(to.toString(), bcc.toString(), subject, text, html, attachments)
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

      // console.log(result);
    });

    //trebuie modificata starea ctr si a statusului dupa insert in tabela de x astfel incat sa nu se mai genereze inca odata.
    //trebuie apelat endpoint pentru schimbare text fiecare task pe ctrid
    // cand se populeaza tabela de x trebuie modificata starea ctr.
  }
}
