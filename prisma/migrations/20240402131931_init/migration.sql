/*
  Warnings:

  - You are about to drop the column `value` on the `ContractTasksDueDates` table. All the data in the column will be lost.
  - You are about to drop the column `value` on the `ContractTasksReminders` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "ContractTasksDueDates" DROP COLUMN "value",
ADD COLUMN     "days" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "ContractTasksReminders" DROP COLUMN "value",
ADD COLUMN     "days" INTEGER NOT NULL DEFAULT 0;
