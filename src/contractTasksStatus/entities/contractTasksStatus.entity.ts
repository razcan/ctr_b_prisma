
import {ContractTasks} from '../../contractTasks/entities/contractTasks.entity'
import {WorkFlowContractTasks} from '../../workFlowContractTasks/entities/workFlowContractTasks.entity'


export class ContractTasksStatus {
  id: number ;
name: string ;
ContractTasks?: ContractTasks[] ;
WorkFlowContractTasks?: WorkFlowContractTasks[] ;
}
