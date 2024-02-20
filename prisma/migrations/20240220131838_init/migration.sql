/*
  Warnings:

  - You are about to drop the column `contractfinancialItemId` on the `ContractFinancialDetailSchedule` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "ContractFinancialDetailSchedule" DROP CONSTRAINT "ContractFinancialDetailSchedule_contractfinancialItemId_fkey";

-- AlterTable
ALTER TABLE "ContractFinancialDetailSchedule" DROP COLUMN "contractfinancialItemId";
