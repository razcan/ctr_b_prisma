/*
  Warnings:

  - You are about to drop the column `partner` on the `Contracts` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "Contracts" DROP COLUMN "partner",
ADD COLUMN     "partner_id" INTEGER NOT NULL DEFAULT 1;

-- CreateTable
CREATE TABLE "Partners" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "name" TEXT NOT NULL,
    "fiscal_code" TEXT NOT NULL,
    "commercial_reg" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "remarks" TEXT NOT NULL,
    "contractsId" INTEGER,

    CONSTRAINT "Partners_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Persons" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "name" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "legalrepresent" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    "partnerId" INTEGER NOT NULL,

    CONSTRAINT "Persons_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Partners_name_key" ON "Partners"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Partners_fiscal_code_key" ON "Partners"("fiscal_code");

-- CreateIndex
CREATE UNIQUE INDEX "Partners_commercial_reg_key" ON "Partners"("commercial_reg");

-- CreateIndex
CREATE UNIQUE INDEX "Partners_email_key" ON "Partners"("email");

-- CreateIndex
CREATE UNIQUE INDEX "Persons_name_key" ON "Persons"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Persons_phone_key" ON "Persons"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "Persons_email_key" ON "Persons"("email");

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_partner_id_fkey" FOREIGN KEY ("partner_id") REFERENCES "Partners"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Persons" ADD CONSTRAINT "Persons_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partners"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
