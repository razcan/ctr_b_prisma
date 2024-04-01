/*
  Warnings:

  - Added the required column `ruleFilterSource` to the `WorkFlowRules` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "WorkFlowRules" ADD COLUMN     "ruleFilterSource" TEXT NOT NULL;
