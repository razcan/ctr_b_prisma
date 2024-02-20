
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'


export class ContractFinancialDetailSchedule {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
itemid: number ;
currencyid: number ;
date: Date ;
measuringUnitid: number ;
billingQtty: number ;
totalContractValue: number ;
billingValue: number ;
isInvoiced: boolean ;
isPayed: boolean ;
active: boolean ;
financial?: ContractFinancialDetail  | null;
contractfinancialItemId: number  | null;
}
