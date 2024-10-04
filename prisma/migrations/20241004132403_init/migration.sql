-- AlterTable
ALTER TABLE "Contracts" ADD COLUMN     "additionalTypeId" INTEGER;

-- CreateTable
CREATE TABLE "additionalActType" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "name" TEXT NOT NULL,

    CONSTRAINT "additionalActType_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_additionalTypeId_fkey" FOREIGN KEY ("additionalTypeId") REFERENCES "additionalActType"("id") ON DELETE SET NULL ON UPDATE CASCADE;
