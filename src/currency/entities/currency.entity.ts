
import {ContractItems} from '../../contractItems/entities/contractItems.entity'
import {ContractFinancialDetailSchedule} from '../../contractFinancialDetailSchedule/entities/contractFinancialDetailSchedule.entity'
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'
import {Invoice} from '../../invoice/entities/invoice.entity'
import {PartnersBanksExtraRates} from '../../partnersBanksExtraRates/entities/partnersBanksExtraRates.entity'
import {Transactions} from '../../transactions/entities/transactions.entity'
import {TransactionDetail} from '../../transactionDetail/entities/transactionDetail.entity'
import {TransactionDetailEvents} from '../../transactionDetailEvents/entities/transactionDetailEvents.entity'


export class Currency {
  id: number ;
code: string ;
name: string ;
ContractItems?: ContractItems[] ;
ContractFinancialDetailSchedule?: ContractFinancialDetailSchedule[] ;
item?: ContractFinancialDetail[] ;
guarantee?: ContractFinancialDetail[] ;
goodexecution?: ContractFinancialDetail[] ;
Invoice?: Invoice[] ;
PartnersBanksExtraRates?: PartnersBanksExtraRates[] ;
Transactions?: Transactions[] ;
TransactionDetail?: TransactionDetail[] ;
TransactionDetailEvents?: TransactionDetailEvents[] ;
}
