-- AlterTable
ALTER TABLE "Partners" ADD COLUMN     "paymentTerm" INTEGER DEFAULT 10;

-- CreateTable
CREATE TABLE "PartnersBanksExtraRates" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "entityId" INTEGER NOT NULL,
    "partnersId" INTEGER,
    "currencyId" INTEGER,
    "percent" DOUBLE PRECISION,

    CONSTRAINT "PartnersBanksExtraRates_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "PartnersBanksExtraRates" ADD CONSTRAINT "PartnersBanksExtraRates_entityId_fkey" FOREIGN KEY ("entityId") REFERENCES "Partners"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PartnersBanksExtraRates" ADD CONSTRAINT "PartnersBanksExtraRates_partnersId_fkey" FOREIGN KEY ("partnersId") REFERENCES "Partners"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PartnersBanksExtraRates" ADD CONSTRAINT "PartnersBanksExtraRates_currencyId_fkey" FOREIGN KEY ("currencyId") REFERENCES "Currency"("id") ON DELETE SET NULL ON UPDATE CASCADE;
