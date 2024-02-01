/*
  Warnings:

  - You are about to drop the column `lastModifiedDate` on the `ContractAttachments` table. All the data in the column will be lost.
  - Added the required column `destination` to the `ContractAttachments` table without a default value. This is not possible if the table is not empty.
  - Made the column `path` on table `ContractAttachments` required. This step will fail if there are existing NULL values in that column.
  - Made the column `mimetype` on table `ContractAttachments` required. This step will fail if there are existing NULL values in that column.
  - Made the column `originalname` on table `ContractAttachments` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "ContractAttachments" DROP COLUMN "lastModifiedDate",
ADD COLUMN     "destination" TEXT NOT NULL,
ALTER COLUMN "path" SET NOT NULL,
ALTER COLUMN "mimetype" SET NOT NULL,
ALTER COLUMN "originalname" SET NOT NULL;
