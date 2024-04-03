
import {ContractTasksStatus} from '../../contractTasksStatus/entities/contractTasksStatus.entity'
import {ContractStatus} from '../../contractStatus/entities/contractStatus.entity'
import {WorkFlowTaskSettings} from '../../workFlowTaskSettings/entities/workFlowTaskSettings.entity'


export class WorkFlowXContracts {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
contractId: number  | null;
wfstatus?: ContractTasksStatus  | null;
wfstatusId: number  | null;
ctrstatus?: ContractStatus ;
ctrstatusId: number ;
workflowSettings?: WorkFlowTaskSettings ;
workflowTaskSettingsId: number ;
}
