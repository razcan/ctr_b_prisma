-- AlterTable
ALTER TABLE "Invoice" ADD COLUMN     "contractFinancialScheduleId" INTEGER,
ADD COLUMN     "contractId" INTEGER,
ADD COLUMN     "contractfinancialItemId" INTEGER;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES "Contracts"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_contractfinancialItemId_fkey" FOREIGN KEY ("contractfinancialItemId") REFERENCES "ContractFinancialDetail"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_contractFinancialScheduleId_fkey" FOREIGN KEY ("contractFinancialScheduleId") REFERENCES "ContractFinancialDetailSchedule"("id") ON DELETE SET NULL ON UPDATE CASCADE;
