
import {WorkFlowTaskSettings} from '../../workFlowTaskSettings/entities/workFlowTaskSettings.entity'
import {User} from '../../user/entities/user.entity'


export class WorkFlowTaskSettingsUsers {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
workflowSettings?: WorkFlowTaskSettings ;
workflowTaskSettingsId: number ;
user?: User  | null;
userId: number  | null;
approvalOrderNumber: number ;
}
