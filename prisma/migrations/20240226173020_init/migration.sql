-- DropForeignKey
ALTER TABLE "ContractFinancialDetail" DROP CONSTRAINT "ContractFinancialDetail_contractItemId_fkey";

-- AddForeignKey
ALTER TABLE "ContractFinancialDetail" ADD CONSTRAINT "ContractFinancialDetail_contractItemId_fkey" FOREIGN KEY ("contractItemId") REFERENCES "ContractItems"("id") ON DELETE CASCADE ON UPDATE CASCADE;
