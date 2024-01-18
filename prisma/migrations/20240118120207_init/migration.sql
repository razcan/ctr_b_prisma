/*
  Warnings:

  - Changed the type of `legalrepresent` on the `Persons` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.

*/
-- AlterTable
ALTER TABLE "Persons" DROP COLUMN "legalrepresent",
ADD COLUMN     "legalrepresent" BOOLEAN NOT NULL,
ALTER COLUMN "role" SET DATA TYPE TEXT;
