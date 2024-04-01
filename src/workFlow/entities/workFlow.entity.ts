
import {WorkFlowRules} from '../../workFlowRules/entities/workFlowRules.entity'
import {WorkFlowTaskSettings} from '../../workFlowTaskSettings/entities/workFlowTaskSettings.entity'
import {WorkFlowRejectActions} from '../../workFlowRejectActions/entities/workFlowRejectActions.entity'


export class WorkFlow {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
wfName: string ;
wfDescription: string ;
status: boolean ;
WorkFlowRules?: WorkFlowRules[] ;
WorkFlowTaskSettings?: WorkFlowTaskSettings[] ;
WorkFlowRejectActions?: WorkFlowRejectActions[] ;
}
