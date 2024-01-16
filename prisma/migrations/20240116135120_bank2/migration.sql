/*
  Warnings:

  - You are about to drop the column `Bank` on the `Banks` table. All the data in the column will be lost.
  - You are about to drop the column `Branch` on the `Banks` table. All the data in the column will be lost.
  - You are about to drop the column `Currency` on the `Banks` table. All the data in the column will be lost.
  - You are about to drop the column `IBAN` on the `Banks` table. All the data in the column will be lost.
  - You are about to drop the column `Status` on the `Banks` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "Banks" DROP COLUMN "Bank",
DROP COLUMN "Branch",
DROP COLUMN "Currency",
DROP COLUMN "IBAN",
DROP COLUMN "Status",
ADD COLUMN     "bank" TEXT,
ADD COLUMN     "branch" TEXT,
ADD COLUMN     "currency" TEXT,
ADD COLUMN     "iban" TEXT,
ADD COLUMN     "status" TEXT;
