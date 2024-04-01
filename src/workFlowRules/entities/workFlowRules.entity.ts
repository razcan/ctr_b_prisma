
import {WorkFlow} from '../../workFlow/entities/workFlow.entity'


export class WorkFlowRules {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
workflow?: WorkFlow ;
workflowId: number ;
ruleFilterName: string ;
ruleFilterSource: string ;
ruleFilterValue: number ;
}
