/*
  Warnings:

  - You are about to drop the column `advancePercent` on the `ContractFinancialDetail` table. All the data in the column will be lost.
  - You are about to drop the column `currencyId` on the `ContractFinancialDetail` table. All the data in the column will be lost.
  - You are about to drop the column `goodexecutionLetter` on the `ContractFinancialDetail` table. All the data in the column will be lost.
  - You are about to drop the column `goodexecutionLetterBankId` on the `ContractFinancialDetail` table. All the data in the column will be lost.
  - You are about to drop the column `goodexecutionLetterCurrencyId` on the `ContractFinancialDetail` table. All the data in the column will be lost.
  - You are about to drop the column `goodexecutionLetterDate` on the `ContractFinancialDetail` table. All the data in the column will be lost.
  - You are about to drop the column `goodexecutionLetterInfo` on the `ContractFinancialDetail` table. All the data in the column will be lost.
  - You are about to drop the column `goodexecutionLetterValue` on the `ContractFinancialDetail` table. All the data in the column will be lost.
  - You are about to drop the column `guaranteeLetterBankId` on the `ContractFinancialDetail` table. All the data in the column will be lost.
  - You are about to drop the column `guaranteeLetterInfo` on the `ContractFinancialDetail` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "ContractFinancialDetail" DROP CONSTRAINT "ContractFinancialDetail_goodexecutionLetterBankId_fkey";

-- DropForeignKey
ALTER TABLE "ContractFinancialDetail" DROP CONSTRAINT "ContractFinancialDetail_goodexecutionLetterCurrencyId_fkey";

-- DropForeignKey
ALTER TABLE "ContractFinancialDetail" DROP CONSTRAINT "ContractFinancialDetail_guaranteeLetterBankId_fkey";

-- AlterTable
ALTER TABLE "ContractFinancialDetail" DROP COLUMN "advancePercent",
DROP COLUMN "currencyId",
DROP COLUMN "goodexecutionLetter",
DROP COLUMN "goodexecutionLetterBankId",
DROP COLUMN "goodexecutionLetterCurrencyId",
DROP COLUMN "goodexecutionLetterDate",
DROP COLUMN "goodexecutionLetterInfo",
DROP COLUMN "goodexecutionLetterValue",
DROP COLUMN "guaranteeLetterBankId",
DROP COLUMN "guaranteeLetterInfo",
ADD COLUMN     "currencyid" INTEGER;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_currencyid_fkey" FOREIGN KEY ("currencyid") REFERENCES "Currency"("id") ON DELETE SET NULL ON UPDATE CASCADE;
