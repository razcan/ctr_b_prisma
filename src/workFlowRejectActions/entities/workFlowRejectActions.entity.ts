
import {WorkFlow} from '../../workFlow/entities/workFlow.entity'


export class WorkFlowRejectActions {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
workflow?: WorkFlow ;
workflowId: number ;
sendNotificationsToAllApprovers: boolean ;
sendNotificationsToContractResponsible: boolean ;
}
