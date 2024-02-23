
import {ContractItems} from '../../contractItems/entities/contractItems.entity'
import {ContractFinancialDetailSchedule} from '../../contractFinancialDetailSchedule/entities/contractFinancialDetailSchedule.entity'


export class ContractFinancialDetail {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
itemid: number  | null;
totalContractValue: number ;
currencyid: number ;
currencyValue: number ;
currencyPercent: number  | null;
billingDay: number ;
billingQtty: number ;
billingFrequencyid: number  | null;
measuringUnitid: number  | null;
paymentTypeid: number  | null;
billingPenaltyPercent: number ;
billingDueDays: number ;
remarks: string  | null;
guaranteeLetter: boolean  | null;
guaranteeLetterCurrencyid: number  | null;
guaranteeLetterDate: Date  | null;
guaranteeLetterValue: number  | null;
active: boolean  | null;
items?: ContractItems  | null;
contractItemId: number  | null;
ContractFinancialDetailSchedule?: ContractFinancialDetailSchedule[] ;
}
