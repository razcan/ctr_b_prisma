-- CreateTable
CREATE TABLE "temp_cashflow" (
    "tip" TEXT NOT NULL,
    "billingvalue" DOUBLE PRECISION NOT NULL,
    "month_number" DOUBLE PRECISION NOT NULL,

    CONSTRAINT "temp_cashflow_pkey" PRIMARY KEY ("tip","billingvalue","month_number")
);

-- CreateTable
CREATE TABLE "ContractTasksPriority" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "ContractTasksPriority_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContractTasksReminders" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "value" INTEGER NOT NULL,

    CONSTRAINT "ContractTasksReminders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WorkFlow" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "wfName" TEXT NOT NULL,
    "wfDescription" TEXT NOT NULL,
    "status" BOOLEAN NOT NULL,

    CONSTRAINT "WorkFlow_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WorkFlowRules" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "workflowId" INTEGER NOT NULL,
    "ruleFilterName" TEXT NOT NULL,
    "ruleFilterValue" TEXT NOT NULL,

    CONSTRAINT "WorkFlowRules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WorkFlowTaskSettings" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "workflowId" INTEGER NOT NULL,
    "approvedByAll" BOOLEAN NOT NULL,
    "approvalTypeInParallel" BOOLEAN NOT NULL,
    "approvalOrder" INTEGER NOT NULL,
    "taskName" TEXT NOT NULL,
    "taskDueDate" TIMESTAMP(3) NOT NULL,
    "taskNotes" TEXT NOT NULL,
    "taskSendNotifications" BOOLEAN NOT NULL,
    "taskSendReminders" BOOLEAN NOT NULL,
    "taskReminderId" INTEGER NOT NULL,
    "taskPriorityId" INTEGER NOT NULL,

    CONSTRAINT "WorkFlowTaskSettings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WorkFlowTaskSettingsUsers" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "workflowTaskSettingsId" INTEGER NOT NULL,
    "userId" INTEGER NOT NULL,
    "approvalOrderNumber" INTEGER NOT NULL,

    CONSTRAINT "WorkFlowTaskSettingsUsers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WorkFlowRejectActions" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "workflowId" INTEGER NOT NULL,
    "sendNotificationsToAllApprovers" BOOLEAN NOT NULL,
    "sendNotificationsToContractResponsible" BOOLEAN NOT NULL,

    CONSTRAINT "WorkFlowRejectActions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WorkFlowContractTasks" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "contractId" INTEGER,
    "statusId" INTEGER NOT NULL,
    "requestorId" INTEGER NOT NULL,
    "assignedId" INTEGER NOT NULL,
    "workflowTaskSettingsId" INTEGER NOT NULL,

    CONSTRAINT "WorkFlowContractTasks_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ContractTasksPriority_name_key" ON "ContractTasksPriority"("name");

-- CreateIndex
CREATE UNIQUE INDEX "ContractTasksReminders_name_key" ON "ContractTasksReminders"("name");

-- AddForeignKey
ALTER TABLE "WorkFlowRules" ADD CONSTRAINT "WorkFlowRules_workflowId_fkey" FOREIGN KEY ("workflowId") REFERENCES "WorkFlow"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowTaskSettings" ADD CONSTRAINT "WorkFlowTaskSettings_workflowId_fkey" FOREIGN KEY ("workflowId") REFERENCES "WorkFlow"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowTaskSettings" ADD CONSTRAINT "WorkFlowTaskSettings_taskReminderId_fkey" FOREIGN KEY ("taskReminderId") REFERENCES "ContractTasksReminders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowTaskSettings" ADD CONSTRAINT "WorkFlowTaskSettings_taskPriorityId_fkey" FOREIGN KEY ("taskPriorityId") REFERENCES "ContractTasksPriority"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowTaskSettingsUsers" ADD CONSTRAINT "WorkFlowTaskSettingsUsers_workflowTaskSettingsId_fkey" FOREIGN KEY ("workflowTaskSettingsId") REFERENCES "WorkFlowTaskSettings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowTaskSettingsUsers" ADD CONSTRAINT "WorkFlowTaskSettingsUsers_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowRejectActions" ADD CONSTRAINT "WorkFlowRejectActions_workflowId_fkey" FOREIGN KEY ("workflowId") REFERENCES "WorkFlow"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowContractTasks" ADD CONSTRAINT "WorkFlowContractTasks_statusId_fkey" FOREIGN KEY ("statusId") REFERENCES "ContractTasksStatus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowContractTasks" ADD CONSTRAINT "WorkFlowContractTasks_requestorId_fkey" FOREIGN KEY ("requestorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowContractTasks" ADD CONSTRAINT "WorkFlowContractTasks_assignedId_fkey" FOREIGN KEY ("assignedId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowContractTasks" ADD CONSTRAINT "WorkFlowContractTasks_workflowTaskSettingsId_fkey" FOREIGN KEY ("workflowTaskSettingsId") REFERENCES "WorkFlowTaskSettings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
