/*
  Warnings:

  - You are about to drop the column `currencyid` on the `ContractFinancialDetail` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "ContractFinancialDetail" DROP CONSTRAINT "ContractFinancialDetail_currencyid_fkey";

-- AlterTable
ALTER TABLE "ContractFinancialDetail" DROP COLUMN "currencyid",
ADD COLUMN     "currencyId" INTEGER;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_currencyId_fkey" FOREIGN KEY ("currencyId") REFERENCES "Currency"("id") ON DELETE SET NULL ON UPDATE CASCADE;
