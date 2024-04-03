
import {Contracts} from '../../contracts/entities/contracts.entity'
import {WorkFlowXContracts} from '../../workFlowXContracts/entities/workFlowXContracts.entity'


export class ContractStatus {
  id: number ;
name: string ;
contractId?: Contracts[] ;
WorkFlowXContracts?: WorkFlowXContracts[] ;
}
