
import {ContractTasksStatus} from '../../contractTasksStatus/entities/contractTasksStatus.entity'
import {User} from '../../user/entities/user.entity'


export class ContractTasks {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
taskName: string ;
contractId: number  | null;
progress: number ;
status?: ContractTasksStatus  | null;
statusId: number  | null;
statusDate: Date ;
requestor?: User  | null;
requestorId: number  | null;
assigned?: User  | null;
assignedId: number  | null;
due: Date ;
notes: string ;
}
