/*
  Warnings:

  - You are about to drop the column `departament` on the `Contracts` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "Contracts" DROP COLUMN "departament",
ADD COLUMN     "departmentId" INTEGER DEFAULT 1;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "Department"("id") ON DELETE SET NULL ON UPDATE CASCADE;
