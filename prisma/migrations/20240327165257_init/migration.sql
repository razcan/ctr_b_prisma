/*
  Warnings:

  - A unique constraint covering the columns `[fieldname]` on the table `DynamicFields` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[fieldorder]` on the table `DynamicFields` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `fieldtype` to the `DynamicFields` table without a default value. This is not possible if the table is not empty.
  - Made the column `fieldorder` on table `DynamicFields` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "DynamicFields" ADD COLUMN     "fieldtype" TEXT NOT NULL,
ALTER COLUMN "fieldorder" SET NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "DynamicFields_fieldname_key" ON "DynamicFields"("fieldname");

-- CreateIndex
CREATE UNIQUE INDEX "DynamicFields_fieldorder_key" ON "DynamicFields"("fieldorder");
