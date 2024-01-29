/*
  Warnings:

  - The `category` column on the `Contracts` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `cashflow` column on the `Contracts` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `costcenter` column on the `Contracts` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `departament` column on the `Contracts` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `item` column on the `Contracts` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- AlterTable
ALTER TABLE "Contracts" DROP COLUMN "category",
ADD COLUMN     "category" INTEGER NOT NULL DEFAULT 0,
DROP COLUMN "cashflow",
ADD COLUMN     "cashflow" INTEGER NOT NULL DEFAULT 0,
DROP COLUMN "costcenter",
ADD COLUMN     "costcenter" INTEGER NOT NULL DEFAULT 0,
DROP COLUMN "departament",
ADD COLUMN     "departament" INTEGER NOT NULL DEFAULT 0,
DROP COLUMN "item",
ADD COLUMN     "item" INTEGER NOT NULL DEFAULT 0;
