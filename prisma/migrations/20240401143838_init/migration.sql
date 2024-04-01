/*
  Warnings:

  - Changed the type of `ruleFilterValue` on the `WorkFlowRules` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.

*/
-- AlterTable
ALTER TABLE "WorkFlowRules" DROP COLUMN "ruleFilterValue",
ADD COLUMN     "ruleFilterValue" INTEGER NOT NULL,
ALTER COLUMN "ruleFilterName" SET DATA TYPE TEXT;
