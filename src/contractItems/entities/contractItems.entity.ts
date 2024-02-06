
import {Contracts} from '../../contracts/entities/contracts.entity'
import {ContractFinancialDetail} from '../../contractFinancialDetail/entities/contractFinancialDetail.entity'


export class ContractItems {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
contract?: Contracts ;
contractId: number ;
itemid: number ;
active: boolean ;
ContractFinancialDetail?: ContractFinancialDetail[] ;
}
