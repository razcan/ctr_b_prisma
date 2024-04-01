/*
  Warnings:

  - Changed the type of `ruleFilterName` on the `WorkFlowRules` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.

*/
-- AlterTable
ALTER TABLE "WorkFlowRules" DROP COLUMN "ruleFilterName",
ADD COLUMN     "ruleFilterName" INTEGER NOT NULL;
