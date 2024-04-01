
import {ContractTasksStatus} from '../../contractTasksStatus/entities/contractTasksStatus.entity'
import {User} from '../../user/entities/user.entity'
import {WorkFlowTaskSettings} from '../../workFlowTaskSettings/entities/workFlowTaskSettings.entity'


export class WorkFlowContractTasks {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
contractId: number  | null;
status?: ContractTasksStatus  | null;
statusId: number  | null;
requestor?: User  | null;
requestorId: number  | null;
assigned?: User  | null;
assignedId: number  | null;
workflowSettings?: WorkFlowTaskSettings ;
workflowTaskSettingsId: number ;
}
