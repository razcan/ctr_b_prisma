
import {ContractTasksStatus} from '../../contractTasksStatus/entities/contractTasksStatus.entity'
import {User} from '../../user/entities/user.entity'
import {ContractTasksPriority} from '../../contractTasksPriority/entities/contractTasksPriority.entity'


export class ContractTasks {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
taskName: string ;
contractId: number  | null;
status?: ContractTasksStatus  | null;
statusId: number  | null;
requestor?: User  | null;
requestorId: number  | null;
assigned?: User  | null;
assignedId: number  | null;
due: Date ;
notes: string ;
uuid: string ;
type: string ;
rejected_reason: string ;
taskPriority?: ContractTasksPriority ;
taskPriorityId: number ;
}
