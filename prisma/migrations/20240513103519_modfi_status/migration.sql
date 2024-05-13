-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_statusWFId_fkey";

-- AlterTable
ALTER TABLE "Contracts" ALTER COLUMN "statusWFId" DROP NOT NULL;

-- AlterTable
ALTER TABLE "ContractsAudit" ALTER COLUMN "statusId" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_statusWFId_fkey" FOREIGN KEY ("statusWFId") REFERENCES "ContractWFStatus"("id") ON DELETE SET NULL ON UPDATE CASCADE;
