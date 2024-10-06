
import {Contracts} from '../../contracts/entities/contracts.entity'
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'
import {Transactions} from '../../transactions/entities/transactions.entity'


export class PaymentType {
  id: number ;
name: string ;
contractId?: Contracts[] ;
ContractFinancialDetail?: ContractFinancialDetail[] ;
Transactions?: Transactions[] ;
}
