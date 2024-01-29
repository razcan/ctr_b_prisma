/*
  Warnings:

  - You are about to drop the column `cashflowId` on the `Contracts` table. All the data in the column will be lost.
  - You are about to drop the column `categoryId` on the `Contracts` table. All the data in the column will be lost.
  - You are about to drop the column `costcenterId` on the `Contracts` table. All the data in the column will be lost.
  - You are about to drop the column `departmentId` on the `Contracts` table. All the data in the column will be lost.
  - You are about to drop the column `itemId` on the `Contracts` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_cashflowId_fkey";

-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_categoryId_fkey";

-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_costcenterId_fkey";

-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_departmentId_fkey";

-- DropForeignKey
ALTER TABLE "Contracts" DROP CONSTRAINT "Contracts_itemId_fkey";

-- AlterTable
ALTER TABLE "Contracts" DROP COLUMN "cashflowId",
DROP COLUMN "categoryId",
DROP COLUMN "costcenterId",
DROP COLUMN "departmentId",
DROP COLUMN "itemId",
ADD COLUMN     "cashflow" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "category" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "costcenter" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "departament" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "item" INTEGER NOT NULL DEFAULT 0,
ALTER COLUMN "partnersId" DROP DEFAULT,
ALTER COLUMN "entityId" DROP DEFAULT,
ALTER COLUMN "entityaddressId" DROP DEFAULT,
ALTER COLUMN "entitybankId" DROP DEFAULT,
ALTER COLUMN "entitypersonsId" DROP DEFAULT,
ALTER COLUMN "parentId" SET DEFAULT 0,
ALTER COLUMN "partneraddressId" DROP DEFAULT,
ALTER COLUMN "partnerbankId" DROP DEFAULT,
ALTER COLUMN "partnerpersonsId" DROP DEFAULT;
