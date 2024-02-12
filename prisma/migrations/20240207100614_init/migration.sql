-- AlterTable
ALTER TABLE "Contracts" ADD COLUMN     "contractContentId" INTEGER;

-- CreateTable
CREATE TABLE "ContractContent" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "content" TEXT NOT NULL,

    CONSTRAINT "ContractContent_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_contractContentId_fkey" FOREIGN KEY ("contractContentId") REFERENCES "ContractContent"("id") ON DELETE SET NULL ON UPDATE CASCADE;
