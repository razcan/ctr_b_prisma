/*
  Warnings:

  - The `Status` column on the `Address` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `Default` column on the `Address` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `aggregate` column on the `Address` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- AlterTable
ALTER TABLE "Address" DROP COLUMN "Status",
ADD COLUMN     "Status" BOOLEAN,
DROP COLUMN "Default",
ADD COLUMN     "Default" BOOLEAN,
DROP COLUMN "aggregate",
ADD COLUMN     "aggregate" BOOLEAN;
