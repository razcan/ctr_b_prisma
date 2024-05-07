-- AlterTable
ALTER TABLE "ContractFinancialDetail" ADD COLUMN     "advancePercent" DOUBLE PRECISION,
ADD COLUMN     "goodexecutionLetter" BOOLEAN,
ADD COLUMN     "goodexecutionLetterBankId" INTEGER,
ADD COLUMN     "goodexecutionLetterCurrencyId" INTEGER,
ADD COLUMN     "goodexecutionLetterDate" TIMESTAMP(3),
ADD COLUMN     "goodexecutionLetterInfo" TEXT,
ADD COLUMN     "goodexecutionLetterValue" DOUBLE PRECISION,
ADD COLUMN     "guaranteeLetterBankId" INTEGER,
ADD COLUMN     "guaranteeLetterInfo" TEXT;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_guaranteeLetterBankId_fkey" FOREIGN KEY ("guaranteeLetterBankId") REFERENCES "Bank"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_goodexecutionLetterCurrencyId_fkey" FOREIGN KEY ("goodexecutionLetterCurrencyId") REFERENCES "Currency"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_goodexecutionLetterBankId_fkey" FOREIGN KEY ("goodexecutionLetterBankId") REFERENCES "Bank"("id") ON DELETE CASCADE ON UPDATE CASCADE;
