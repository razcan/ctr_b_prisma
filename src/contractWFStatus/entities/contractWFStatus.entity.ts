
import {WorkFlowContractTasks} from '../../workFlowContractTasks/entities/workFlowContractTasks.entity'
import {WorkFlowXContracts} from '../../workFlowXContracts/entities/workFlowXContracts.entity'
import {Contracts} from '../../contracts/entities/contracts.entity'


export class ContractWFStatus {
  id: number ;
name: string ;
Desription: string ;
WorkFlowContractTasks?: WorkFlowContractTasks[] ;
WorkFlowXContracts?: WorkFlowXContracts[] ;
ContractId?: Contracts[] ;
}
