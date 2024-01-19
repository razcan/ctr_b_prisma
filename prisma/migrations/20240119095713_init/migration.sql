/*
  Warnings:

  - The `status` column on the `Banks` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- AlterTable
ALTER TABLE "Banks" DROP COLUMN "status",
ADD COLUMN     "status" BOOLEAN;
