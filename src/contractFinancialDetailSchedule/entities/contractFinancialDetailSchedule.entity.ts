
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'


export class ContractFinancialDetailSchedule {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
itemid: number ;
date: Date ;
measuringUnitid: number ;
billingQtty: number ;
totalContractValue: number ;
billingValue: number ;
guaranteeLetterCurrencyid: number ;
isInvoiced: boolean ;
isPayed: boolean ;
contractfinancial?: ContractFinancialDetail ;
contractFinancialItemId: number ;
}
