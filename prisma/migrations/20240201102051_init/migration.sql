-- AlterTable
ALTER TABLE "Contracts" ADD COLUMN     "contractAttachmentsId" INTEGER;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_contractAttachmentsId_fkey" FOREIGN KEY ("contractAttachmentsId") REFERENCES "ContractAttachments"("id") ON DELETE SET NULL ON UPDATE CASCADE;
