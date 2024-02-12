/*
  Warnings:

  - Added the required column `currencyid` to the `ContractFinancialDetailSchedule` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ContractFinancialDetailSchedule" ADD COLUMN     "currencyid" INTEGER NOT NULL;
