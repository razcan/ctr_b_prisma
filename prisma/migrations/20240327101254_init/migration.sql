/*
  Warnings:

  - You are about to drop the `ContractsDetails` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Entity` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropTable
DROP TABLE "ContractsDetails";

-- DropTable
DROP TABLE "Entity";

-- CreateTable
CREATE TABLE "ContractDynamicFields" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "contractId" INTEGER NOT NULL,
    "dffInt1" INTEGER,
    "dffInt2" INTEGER,
    "dffInt3" INTEGER,
    "dffInt4" INTEGER,
    "dffString1" TEXT,
    "dffString2" TEXT,
    "dffString3" TEXT,
    "dffString4" TEXT,
    "dffDate1" TIMESTAMP(3),
    "dffDate2" TIMESTAMP(3),

    CONSTRAINT "ContractDynamicFields_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DynamicFields" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "fieldname" TEXT NOT NULL,
    "fieldlabel" TEXT NOT NULL,
    "fieldorder" INTEGER,

    CONSTRAINT "DynamicFields_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "ContractDynamicFields" ADD CONSTRAINT "ContractDynamicFields_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES "Contracts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
