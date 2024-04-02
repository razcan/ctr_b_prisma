
import {WorkFlowTaskSettings} from '../../workFlowTaskSettings/entities/workFlowTaskSettings.entity'


export class ContractTasksReminders {
  id: number ;
name: string ;
days: number ;
WorkFlowTaskSettings?: WorkFlowTaskSettings[] ;
}
