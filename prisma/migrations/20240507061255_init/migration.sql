/*
  Warnings:

  - You are about to drop the column `totalContractValue` on the `ContractFinancialDetail` table. All the data in the column will be lost.
  - Added the required column `price` to the `ContractFinancialDetail` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ContractFinancialDetail" DROP COLUMN "totalContractValue",
ADD COLUMN     "advance" DOUBLE PRECISION,
ADD COLUMN     "goodexecutionLetter" BOOLEAN,
ADD COLUMN     "goodexecutionLetterBankId" INTEGER,
ADD COLUMN     "goodexecutionLetterCurrencyId" INTEGER,
ADD COLUMN     "goodexecutionLetterDate" TIMESTAMP(3),
ADD COLUMN     "goodexecutionLetterInfo" TEXT,
ADD COLUMN     "goodexecutionLetterValue" DOUBLE PRECISION,
ADD COLUMN     "guaranteeLetterBankId" INTEGER,
ADD COLUMN     "guaranteeLetterInfo" TEXT,
ADD COLUMN     "price" DOUBLE PRECISION NOT NULL;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_guaranteeLetterBankId_fkey" FOREIGN KEY ("guaranteeLetterBankId") REFERENCES "Bank"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_goodexecutionLetterCurrencyId_fkey" FOREIGN KEY ("goodexecutionLetterCurrencyId") REFERENCES "Currency"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_goodexecutionLetterBankId_fkey" FOREIGN KEY ("goodexecutionLetterBankId") REFERENCES "Bank"("id") ON DELETE CASCADE ON UPDATE CASCADE;
