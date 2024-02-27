-- DropForeignKey
ALTER TABLE "ContractFinancialDetailSchedule" DROP CONSTRAINT "ContractFinancialDetailSchedule_contractfinancialItemId_fkey";

-- AddForeignKey
ALTER TABLE "ContractFinancialDetailSchedule" ADD CONSTRAINT "ContractFinancialDetailSchedule_contractfinancialItemId_fkey" FOREIGN KEY ("contractfinancialItemId") REFERENCES "ContractFinancialDetail"("id") ON DELETE CASCADE ON UPDATE CASCADE;
