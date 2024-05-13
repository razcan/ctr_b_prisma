
import {ContractWFStatus} from '../../contractWFStatus/entities/contractWFStatus.entity'
import {User} from '../../user/entities/user.entity'
import {WorkFlowTaskSettings} from '../../workFlowTaskSettings/entities/workFlowTaskSettings.entity'
import {ContractTasksPriority} from '../../contractTasksPriority/entities/contractTasksPriority.entity'


export class WorkFlowContractTasks {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
name: string ;
text: string ;
contractId: number  | null;
status?: ContractWFStatus  | null;
statusId: number  | null;
requestor?: User  | null;
requestorId: number  | null;
assigned?: User  | null;
assignedId: number  | null;
workflowSettings?: WorkFlowTaskSettings ;
workflowTaskSettingsId: number ;
uuid: string ;
approvalOrderNumber: number ;
duedates: Date ;
taskPriority?: ContractTasksPriority ;
taskPriorityId: number ;
reminders: Date ;
}
