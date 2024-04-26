/*
  Warnings:

  - Added the required column `approvalStepName` to the `WorkFlowTaskSettingsUsers` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "WorkFlowTaskSettingsUsers" ADD COLUMN     "approvalStepName" TEXT NOT NULL;
