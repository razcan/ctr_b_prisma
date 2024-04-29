/*
  Warnings:

  - You are about to drop the column `approvalTypeInParallel` on the `WorkFlowTaskSettings` table. All the data in the column will be lost.
  - You are about to drop the column `approvedByAll` on the `WorkFlowTaskSettings` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "WorkFlowTaskSettings" DROP COLUMN "approvalTypeInParallel",
DROP COLUMN "approvedByAll";
