/*
  Warnings:

  - You are about to drop the column `progress` on the `ContractTasks` table. All the data in the column will be lost.
  - You are about to drop the column `statusDate` on the `ContractTasks` table. All the data in the column will be lost.
  - Added the required column `rejected_reason` to the `ContractTasks` table without a default value. This is not possible if the table is not empty.
  - Added the required column `taskPriorityId` to the `ContractTasks` table without a default value. This is not possible if the table is not empty.
  - Added the required column `type` to the `ContractTasks` table without a default value. This is not possible if the table is not empty.
  - Added the required column `uuid` to the `ContractTasks` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ContractTasks" DROP COLUMN "progress",
DROP COLUMN "statusDate",
ADD COLUMN     "rejected_reason" TEXT NOT NULL,
ADD COLUMN     "taskPriorityId" INTEGER NOT NULL,
ADD COLUMN     "type" TEXT NOT NULL,
ADD COLUMN     "uuid" TEXT NOT NULL;

-- AddForeignKey
ALTER TABLE "ContractTasks" ADD CONSTRAINT "ContractTasks_taskPriorityId_fkey" FOREIGN KEY ("taskPriorityId") REFERENCES "ContractTasksPriority"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
