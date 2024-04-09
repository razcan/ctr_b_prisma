
import {ContractTasks} from '../../contractTasks/entities/contractTasks.entity'
import {WorkFlowContractTasks} from '../../workFlowContractTasks/entities/workFlowContractTasks.entity'
import {WorkFlowXContracts} from '../../workFlowXContracts/entities/workFlowXContracts.entity'


export class ContractTasksStatus {
  id: number ;
name: string ;
Desription: string ;
ContractTasks?: ContractTasks[] ;
WorkFlowContractTasks?: WorkFlowContractTasks[] ;
WorkFlowXContracts?: WorkFlowXContracts[] ;
}
