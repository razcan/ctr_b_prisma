/*
  Warnings:

  - You are about to drop the column `taskDueDate` on the `WorkFlowTaskSettings` table. All the data in the column will be lost.
  - Added the required column `taskDueDateId` to the `WorkFlowTaskSettings` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "WorkFlowTaskSettings" DROP COLUMN "taskDueDate",
ADD COLUMN     "taskDueDateId" INTEGER NOT NULL;

-- CreateTable
CREATE TABLE "ContractTasksDueDates" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "value" INTEGER NOT NULL,

    CONSTRAINT "ContractTasksDueDates_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ContractTasksDueDates_name_key" ON "ContractTasksDueDates"("name");

-- AddForeignKey
ALTER TABLE "WorkFlowTaskSettings" ADD CONSTRAINT "WorkFlowTaskSettings_taskDueDateId_fkey" FOREIGN KEY ("taskDueDateId") REFERENCES "ContractTasksDueDates"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
