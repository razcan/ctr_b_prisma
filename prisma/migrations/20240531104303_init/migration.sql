/*
  Warnings:

  - You are about to drop the column `entityId` on the `PartnersBanksExtraRates` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "PartnersBanksExtraRates" DROP CONSTRAINT "PartnersBanksExtraRates_entityId_fkey";

-- AlterTable
ALTER TABLE "PartnersBanksExtraRates" DROP COLUMN "entityId";
