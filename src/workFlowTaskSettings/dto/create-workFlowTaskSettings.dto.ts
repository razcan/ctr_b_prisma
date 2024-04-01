





export class CreateWorkFlowTaskSettingsDto {
  approvedByAll: boolean;
approvalTypeInParallel: boolean;
approvalOrder: number;
taskName: string;
taskDueDate: Date;
taskNotes: string;
taskSendNotifications: boolean;
taskSendReminders: boolean;
}
