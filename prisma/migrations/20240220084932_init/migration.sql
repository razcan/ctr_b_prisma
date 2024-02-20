-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_typeId_fkey";

-- AlterTable
ALTER TABLE "ContractType" ADD COLUMN     "contractId" INTEGER;

-- AddForeignKey
ALTER TABLE "ContractType" ADD CONSTRAINT "ContractType_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES "Contracts"("id") ON DELETE SET NULL ON UPDATE CASCADE;
