
import {RoleUser} from '../../roleUser/entities/roleUser.entity'
import {Groups} from '../../groups/entities/groups.entity'
import {Contracts} from '../../contracts/entities/contracts.entity'
import {ContractTasks} from '../../contractTasks/entities/contractTasks.entity'
import {WorkFlowTaskSettingsUsers} from '../../workFlowTaskSettingsUsers/entities/workFlowTaskSettingsUsers.entity'
import {WorkFlowContractTasks} from '../../workFlowContractTasks/entities/workFlowContractTasks.entity'


export class User {
  id: number ;
updatedAt: Date ;
createdAt: Date ;
name: string ;
email: string ;
password: string ;
roles?: RoleUser[] ;
status: boolean ;
picture: string  | null;
User_Groups?: Groups[] ;
Contracts?: Contracts[] ;
AssignedTasks?: ContractTasks[] ;
RequestorTasks?: ContractTasks[] ;
WorkFlowTaskSettingsUsers?: WorkFlowTaskSettingsUsers[] ;
WorkFlowAssignedTasks?: WorkFlowContractTasks[] ;
WorkFlowRequestorTasks?: WorkFlowContractTasks[] ;
}
