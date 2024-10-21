
import {Item} from '../../item/entities/item.entity'
import {Currency} from '../../currency/entities/currency.entity'
import {MeasuringUnit} from '../../measuringUnit/entities/measuringUnit.entity'
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'
import {Invoice} from '../../invoice/entities/invoice.entity'


export class ContractFinancialDetailSchedule {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
item?: Item  | null;
itemid: number  | null;
currency?: Currency  | null;
currencyid: number  | null;
date: Date ;
measuringUnit?: MeasuringUnit  | null;
measuringUnitid: number  | null;
billingQtty: number ;
totalContractValue: number ;
billingValue: number ;
isInvoiced: boolean ;
isPayed: boolean ;
active: boolean ;
financial?: ContractFinancialDetail  | null;
contractfinancialItemId: number  | null;
Invoice?: Invoice[] ;
}
