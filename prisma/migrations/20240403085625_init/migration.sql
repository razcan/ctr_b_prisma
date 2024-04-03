/*
  Warnings:

  - Added the required column `approvalOrderNumber` to the `WorkFlowContractTasks` table without a default value. This is not possible if the table is not empty.
  - Added the required column `duedates` to the `WorkFlowContractTasks` table without a default value. This is not possible if the table is not empty.
  - Added the required column `name` to the `WorkFlowContractTasks` table without a default value. This is not possible if the table is not empty.
  - Added the required column `reminders` to the `WorkFlowContractTasks` table without a default value. This is not possible if the table is not empty.
  - Added the required column `taskPriorityId` to the `WorkFlowContractTasks` table without a default value. This is not possible if the table is not empty.
  - Added the required column `text` to the `WorkFlowContractTasks` table without a default value. This is not possible if the table is not empty.
  - Added the required column `uuid` to the `WorkFlowContractTasks` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "WorkFlowContractTasks" ADD COLUMN     "approvalOrderNumber" INTEGER NOT NULL,
ADD COLUMN     "duedates" TIMESTAMP(3) NOT NULL,
ADD COLUMN     "name" TEXT NOT NULL,
ADD COLUMN     "reminders" TIMESTAMP(3) NOT NULL,
ADD COLUMN     "taskPriorityId" INTEGER NOT NULL,
ADD COLUMN     "text" TEXT NOT NULL,
ADD COLUMN     "uuid" TEXT NOT NULL;

-- CreateTable
CREATE TABLE "WorkFlowXContracts" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "contractId" INTEGER,
    "wfstatusId" INTEGER NOT NULL,
    "ctrstatusId" INTEGER NOT NULL,
    "workflowTaskSettingsId" INTEGER NOT NULL,

    CONSTRAINT "WorkFlowXContracts_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "WorkFlowContractTasks" ADD CONSTRAINT "WorkFlowContractTasks_taskPriorityId_fkey" FOREIGN KEY ("taskPriorityId") REFERENCES "ContractTasksPriority"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowXContracts" ADD CONSTRAINT "WorkFlowXContracts_wfstatusId_fkey" FOREIGN KEY ("wfstatusId") REFERENCES "ContractTasksStatus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowXContracts" ADD CONSTRAINT "WorkFlowXContracts_ctrstatusId_fkey" FOREIGN KEY ("ctrstatusId") REFERENCES "ContractStatus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkFlowXContracts" ADD CONSTRAINT "WorkFlowXContracts_workflowTaskSettingsId_fkey" FOREIGN KEY ("workflowTaskSettingsId") REFERENCES "WorkFlowTaskSettings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
