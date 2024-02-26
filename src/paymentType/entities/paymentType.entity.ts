
import {Contracts} from '../../contracts/entities/contracts.entity'
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'


export class PaymentType {
  id: number ;
name: string ;
contractId?: Contracts[] ;
ContractFinancialDetail?: ContractFinancialDetail[] ;
}
