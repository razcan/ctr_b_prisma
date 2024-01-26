/*
  Warnings:

  - You are about to drop the column `entity` on the `Contracts` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "Contracts" DROP COLUMN "entity",
ADD COLUMN     "entityId" INTEGER,
ADD COLUMN     "entityaddressId" INTEGER,
ADD COLUMN     "entitybankId" INTEGER,
ADD COLUMN     "entitypersonsId" INTEGER,
ADD COLUMN     "parentId" INTEGER,
ADD COLUMN     "partneraddressId" INTEGER,
ADD COLUMN     "partnerbankId" INTEGER,
ADD COLUMN     "partnerpersonsId" INTEGER;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_entityId_fkey" FOREIGN KEY ("entityId") REFERENCES "Partners"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_partnerpersonsId_fkey" FOREIGN KEY ("partnerpersonsId") REFERENCES "Persons"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_entitypersonsId_fkey" FOREIGN KEY ("entitypersonsId") REFERENCES "Persons"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_entityaddressId_fkey" FOREIGN KEY ("entityaddressId") REFERENCES "Address"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_partneraddressId_fkey" FOREIGN KEY ("partneraddressId") REFERENCES "Address"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_entitybankId_fkey" FOREIGN KEY ("entitybankId") REFERENCES "Banks"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_partnerbankId_fkey" FOREIGN KEY ("partnerbankId") REFERENCES "Banks"("id") ON DELETE SET NULL ON UPDATE CASCADE;
