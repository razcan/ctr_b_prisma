
import {WorkFlowTaskSettings} from '../../workFlowTaskSettings/entities/workFlowTaskSettings.entity'
import {WorkFlowContractTasks} from '../../workFlowContractTasks/entities/workFlowContractTasks.entity'
import {ContractTasks} from '../../contractTasks/entities/contractTasks.entity'


export class ContractTasksPriority {
  id: number ;
name: string ;
WorkFlowTaskSettings?: WorkFlowTaskSettings[] ;
WorkFlowContractTasks?: WorkFlowContractTasks[] ;
ContractTasks?: ContractTasks[] ;
}
