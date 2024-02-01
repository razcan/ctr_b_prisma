/*
  Warnings:

  - You are about to drop the column `dbname` on the `ContractAttachments` table. All the data in the column will be lost.
  - You are about to drop the column `destination` on the `ContractAttachments` table. All the data in the column will be lost.
  - You are about to drop the column `name` on the `ContractAttachments` table. All the data in the column will be lost.
  - Added the required column `encoding` to the `ContractAttachments` table without a default value. This is not possible if the table is not empty.
  - Added the required column `fieldname` to the `ContractAttachments` table without a default value. This is not possible if the table is not empty.
  - Added the required column `filename` to the `ContractAttachments` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ContractAttachments" DROP COLUMN "dbname",
DROP COLUMN "destination",
DROP COLUMN "name",
ADD COLUMN     "encoding" TEXT NOT NULL,
ADD COLUMN     "fieldname" TEXT NOT NULL,
ADD COLUMN     "filename" TEXT NOT NULL;
