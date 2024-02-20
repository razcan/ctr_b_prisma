-- AlterTable
ALTER TABLE "ContractFinancialDetail" ALTER COLUMN "contractItemId" DROP NOT NULL;

-- AlterTable
ALTER TABLE "ContractFinancialDetailSchedule" ADD COLUMN     "contractfinancialItemId" INTEGER;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_contractItemId_fkey" FOREIGN KEY ("contractItemId") REFERENCES "ContractItems"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetailSchedule" ADD CONSTRAINT "ContractFinancialDetailSchedule_contractfinancialItemId_fkey" FOREIGN KEY ("contractfinancialItemId") REFERENCES "ContractFinancialDetail"("id") ON DELETE SET NULL ON UPDATE CASCADE;
