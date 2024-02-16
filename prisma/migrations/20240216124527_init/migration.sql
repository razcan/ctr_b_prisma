-- DropForeignKey
ALTER TABLE "ContractAttachments" DROP CONSTRAINT "ContractAttachments_contractId_fkey";

-- AlterTable
ALTER TABLE "ContractAttachments" ALTER COLUMN "contractId" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "ContractAttachments" ADD CONSTRAINT "ContractAttachments_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES "Contracts"("id") ON DELETE SET NULL ON UPDATE CASCADE;
