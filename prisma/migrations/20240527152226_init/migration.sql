-- AlterTable
ALTER TABLE "ContractFinancialDetail" ADD COLUMN     "vatId" INTEGER;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_vatId_fkey" FOREIGN KEY ("vatId") REFERENCES "VatQuota"("id") ON DELETE SET NULL ON UPDATE CASCADE;
