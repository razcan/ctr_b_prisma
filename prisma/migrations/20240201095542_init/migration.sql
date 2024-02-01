/*
  Warnings:

  - You are about to drop the column `contractAttachmentsId` on the `Contracts` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_contractAttachmentsId_fkey";

-- AlterTable
ALTER TABLE "Contracts" DROP COLUMN "contractAttachmentsId";
