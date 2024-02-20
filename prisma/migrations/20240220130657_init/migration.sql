-- AlterTable
ALTER TABLE "ContractFinancialDetail" ADD COLUMN     "active" BOOLEAN NOT NULL DEFAULT true;

-- AlterTable
ALTER TABLE "ContractFinancialDetailSchedule" ADD COLUMN     "active" BOOLEAN NOT NULL DEFAULT true;
