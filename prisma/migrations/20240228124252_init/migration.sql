-- CreateTable
CREATE TABLE "ContractTemplates" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "name" TEXT NOT NULL,
    "active" BOOLEAN NOT NULL,
    "contractTypeId" INTEGER,
    "notes" TEXT NOT NULL,

    CONSTRAINT "ContractTemplates_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "ContractTemplates" ADD CONSTRAINT "ContractTemplates_contractTypeId_fkey" FOREIGN KEY ("contractTypeId") REFERENCES "ContractType"("id") ON DELETE SET NULL ON UPDATE CASCADE;
