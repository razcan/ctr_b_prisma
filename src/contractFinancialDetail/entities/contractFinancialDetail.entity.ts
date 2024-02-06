
import {ContractItems} from '../../contractItems/entities/contractItems.entity'
import {ContractFinancialDetailSchedule} from '../../contractFinancialDetailSchedule/entities/contractFinancialDetailSchedule.entity'


export class ContractFinancialDetail {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
itemid: number ;
totalContractValue: number ;
currencyid: number ;
currencyValue: number ;
currencyPercent: number ;
billingDay: number ;
billingQtty: number ;
billingFrequencyid: number ;
measuringUnitid: number ;
paymentTypeid: number ;
billingPenaltyPercent: number ;
billingDueDays: number ;
remarks: string ;
guaranteeLetter: boolean ;
guaranteeLetterCurrencyid: number ;
guaranteeLetterDate: Date ;
guaranteeLetterValue: number ;
contractitems?: ContractItems ;
contractItemId: number ;
ContractFinancialDetailSchedule?: ContractFinancialDetailSchedule[] ;
}
