
import {WorkFlow} from '../../workFlow/entities/workFlow.entity'
import {WorkFlowTaskSettingsUsers} from '../../workFlowTaskSettingsUsers/entities/workFlowTaskSettingsUsers.entity'
import {ContractTasksReminders} from '../../contractTasksReminders/entities/contractTasksReminders.entity'
import {ContractTasksPriority} from '../../contractTasksPriority/entities/contractTasksPriority.entity'
import {WorkFlowContractTasks} from '../../workFlowContractTasks/entities/workFlowContractTasks.entity'


export class WorkFlowTaskSettings {
  id: number ;
updateadAt: Date ;
createdAt: Date ;
workflow?: WorkFlow ;
workflowId: number ;
approvedByAll: boolean ;
approvalTypeInParallel: boolean ;
approvalOrder: number ;
WorkFlowTaskSettingsUsers?: WorkFlowTaskSettingsUsers[] ;
taskName: string ;
taskDueDate: Date ;
taskNotes: string ;
taskSendNotifications: boolean ;
taskSendReminders: boolean ;
taskReminder?: ContractTasksReminders ;
taskReminderId: number ;
taskPriority?: ContractTasksPriority ;
taskPriorityId: number ;
WorkFlowContractTasks?: WorkFlowContractTasks[] ;
}
