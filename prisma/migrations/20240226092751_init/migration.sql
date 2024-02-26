-- AlterTable
ALTER TABLE "ContractFinancialDetailSchedule" ALTER COLUMN "itemid" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "ContractFinancialDetailSchedule" ADD CONSTRAINT "ContractFinancialDetailSchedule_itemid_fkey" FOREIGN KEY ("itemid") REFERENCES "Item"("id") ON DELETE SET NULL ON UPDATE CASCADE;
