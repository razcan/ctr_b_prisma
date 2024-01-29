/*
  Warnings:

  - You are about to drop the column `status` on the `Contracts` table. All the data in the column will be lost.
  - You are about to drop the column `type` on the `Contracts` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "Contracts" DROP COLUMN "status",
DROP COLUMN "type",
ADD COLUMN     "statusId" INTEGER,
ADD COLUMN     "typeId" INTEGER DEFAULT 1;

-- CreateTable
CREATE TABLE "ContractType" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "ContractType_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContractStatus" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "ContractStatus_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ContractType_name_key" ON "ContractType"("name");

-- CreateIndex
CREATE UNIQUE INDEX "ContractStatus_name_key" ON "ContractStatus"("name");

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES "ContractType"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_statusId_fkey" FOREIGN KEY ("statusId") REFERENCES "ContractStatus"("id") ON DELETE SET NULL ON UPDATE CASCADE;
