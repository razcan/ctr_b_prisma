-- AlterTable
ALTER TABLE "Contracts" ADD COLUMN     "contractAttachmentsId" INTEGER;

-- CreateTable
CREATE TABLE "ContractAttachments" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "name" TEXT NOT NULL,
    "size" INTEGER NOT NULL,
    "lastModifiedDate" TIMESTAMP(3),
    "dbname" TEXT,
    "path" TEXT,
    "destination" TEXT,
    "mimetype" TEXT,
    "originalname" TEXT,

    CONSTRAINT "ContractAttachments_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_contractAttachmentsId_fkey" FOREIGN KEY ("contractAttachmentsId") REFERENCES "ContractAttachments"("id") ON DELETE SET NULL ON UPDATE CASCADE;
