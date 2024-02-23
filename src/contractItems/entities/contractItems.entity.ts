
import {Contracts} from '../../contracts/entities/contracts.entity'
import {Item} from '../../item/entities/item.entity'
import {BillingFrequency} from '../../billingFrequency/entities/billingFrequency.entity'
import {Currency} from '../../currency/entities/currency.entity'
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'


export class ContractItems {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
contract?: Contracts  | null;
contractId: number  | null;
item?: Item  | null;
itemid: number  | null;
frequency?: BillingFrequency  | null;
billingFrequencyid: number  | null;
currency?: Currency  | null;
currencyid: number  | null;
currencyValue: number ;
active: boolean ;
ContractFinancialDetail?: ContractFinancialDetail[] ;
}
