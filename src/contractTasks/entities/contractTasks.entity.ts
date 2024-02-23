
import {ContractTasksStatus} from '../../contractTasksStatus/entities/contractTasksStatus.entity'
import {Persons} from '../../persons/entities/persons.entity'


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
requestor?: Persons  | null;
requestorId: number  | null;
assigned?: Persons  | null;
assignedId: number  | null;
due: Date ;
notes: string ;
}
