/*
  Warnings:

  - You are about to drop the column `contractFinancialItemId` on the `ContractFinancialDetailSchedule` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "ContractFinancialDetailSchedule" DROP CONSTRAINT "ContractFinancialDetailSchedule_contractFinancialItemId_fkey";

-- AlterTable
ALTER TABLE "ContractFinancialDetailSchedule" DROP COLUMN "contractFinancialItemId";
