-- DropForeignKey
ALTER TABLE "Address" DROP CONSTRAINT "Address_partnerId_fkey";

-- DropForeignKey
ALTER TABLE "Banks" DROP CONSTRAINT "Banks_partnerId_fkey";

-- DropForeignKey
ALTER TABLE "Persons" DROP CONSTRAINT "Persons_partnerId_fkey";

-- AddForeignKey
ALTER TABLE "Persons" ADD CONSTRAINT "Persons_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partners"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Address" ADD CONSTRAINT "Address_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partners"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Banks" ADD CONSTRAINT "Banks_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partners"("id") ON DELETE CASCADE ON UPDATE CASCADE;
