/*
  Warnings:

  - Added the required column `eqvTotalAmount` to the `Invoice` table without a default value. This is not possible if the table is not empty.
  - Added the required column `eqvTotalPayment` to the `Invoice` table without a default value. This is not possible if the table is not empty.
  - Added the required column `eqvVatAmount` to the `Invoice` table without a default value. This is not possible if the table is not empty.
  - Added the required column `serialNumber` to the `Invoice` table without a default value. This is not possible if the table is not empty.
  - Added the required column `seriesId` to the `Invoice` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Invoice" ADD COLUMN     "eqvTotalAmount" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "eqvTotalPayment" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "eqvVatAmount" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "serialNumber" TEXT NOT NULL,
ADD COLUMN     "seriesId" INTEGER NOT NULL;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_seriesId_fkey" FOREIGN KEY ("seriesId") REFERENCES "DocumentSeries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
