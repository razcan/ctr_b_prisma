
import {ContractWFStatus} from '../../contractWFStatus/entities/contractWFStatus.entity'
import {ContractStatus} from '../../contractStatus/entities/contractStatus.entity'
import {WorkFlowTaskSettings} from '../../workFlowTaskSettings/entities/workFlowTaskSettings.entity'


export class WorkFlowXContracts {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
contractId: number  | null;
wfstatus?: ContractWFStatus  | null;
wfstatusId: number  | null;
ctrstatus?: ContractStatus ;
ctrstatusId: number ;
workflowSettings?: WorkFlowTaskSettings ;
workflowTaskSettingsId: number ;
}
