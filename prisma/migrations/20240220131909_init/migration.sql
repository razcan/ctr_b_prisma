-- AlterTable
ALTER TABLE "ContractFinancialDetailSchedule" ADD COLUMN     "contractfinancialItemId" INTEGER;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetailSchedule" ADD CONSTRAINT "ContractFinancialDetailSchedule_contractfinancialItemId_fkey" FOREIGN KEY ("contractfinancialItemId") REFERENCES "ContractFinancialDetail"("id") ON DELETE SET NULL ON UPDATE CASCADE;
