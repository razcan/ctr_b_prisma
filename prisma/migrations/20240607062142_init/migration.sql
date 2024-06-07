/*
  Warnings:

  - You are about to drop the `Invoice` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "Invoice" DROP CONSTRAINT "Invoice_currencyId_fkey";

-- DropForeignKey
ALTER TABLE "Invoice" DROP CONSTRAINT "Invoice_entityId_fkey";

-- DropForeignKey
ALTER TABLE "Invoice" DROP CONSTRAINT "Invoice_entitybankId_fkey";

-- DropForeignKey
ALTER TABLE "Invoice" DROP CONSTRAINT "Invoice_partnerId_fkey";

-- DropForeignKey
ALTER TABLE "Invoice" DROP CONSTRAINT "Invoice_partneraddressId_fkey";

-- DropForeignKey
ALTER TABLE "Invoice" DROP CONSTRAINT "Invoice_seriesId_fkey";

-- DropForeignKey
ALTER TABLE "Invoice" DROP CONSTRAINT "Invoice_statusId_fkey";

-- DropForeignKey
ALTER TABLE "Invoice" DROP CONSTRAINT "Invoice_transactionTypeId_fkey";

-- DropForeignKey
ALTER TABLE "Invoice" DROP CONSTRAINT "Invoice_typeId_fkey";

-- DropForeignKey
ALTER TABLE "Invoice" DROP CONSTRAINT "Invoice_userId_fkey";

-- DropForeignKey
ALTER TABLE "InvoiceDetail" DROP CONSTRAINT "InvoiceDetail_invoiceId_fkey";

-- DropTable
DROP TABLE "Invoice";

-- CreateTable
CREATE TABLE "Invoice2" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "partnerId" INTEGER,
    "entityId" INTEGER,
    "number" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "duedate" TIMESTAMP(3) NOT NULL,
    "totalAmount" DOUBLE PRECISION NOT NULL,
    "vatAmount" DOUBLE PRECISION NOT NULL,
    "totalPayment" DOUBLE PRECISION NOT NULL,
    "typeId" INTEGER NOT NULL,
    "transactionTypeId" INTEGER NOT NULL,
    "statusId" INTEGER,
    "entitybankId" INTEGER,
    "partneraddressId" INTEGER,
    "currencyRate" DOUBLE PRECISION NOT NULL,
    "userId" INTEGER NOT NULL,
    "currencyId" INTEGER,
    "remarks" TEXT NOT NULL,
    "seriesId" INTEGER NOT NULL,
    "serialNumber" TEXT NOT NULL,
    "eqvTotalAmount" DOUBLE PRECISION NOT NULL,
    "eqvVatAmount" DOUBLE PRECISION NOT NULL,
    "eqvTotalPayment" DOUBLE PRECISION NOT NULL,
    "vatOnReceipt" BOOLEAN NOT NULL,

    CONSTRAINT "Invoice2_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "Invoice2" ADD CONSTRAINT "Invoice2_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partners"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice2" ADD CONSTRAINT "Invoice2_entityId_fkey" FOREIGN KEY ("entityId") REFERENCES "Partners"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice2" ADD CONSTRAINT "Invoice2_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES "InvoiceType"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice2" ADD CONSTRAINT "Invoice2_transactionTypeId_fkey" FOREIGN KEY ("transactionTypeId") REFERENCES "TransactionType"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice2" ADD CONSTRAINT "Invoice2_statusId_fkey" FOREIGN KEY ("statusId") REFERENCES "InvoiceStatus"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice2" ADD CONSTRAINT "Invoice2_entitybankId_fkey" FOREIGN KEY ("entitybankId") REFERENCES "Banks"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice2" ADD CONSTRAINT "Invoice2_partneraddressId_fkey" FOREIGN KEY ("partneraddressId") REFERENCES "Address"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice2" ADD CONSTRAINT "Invoice2_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice2" ADD CONSTRAINT "Invoice2_currencyId_fkey" FOREIGN KEY ("currencyId") REFERENCES "Currency"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice2" ADD CONSTRAINT "Invoice2_seriesId_fkey" FOREIGN KEY ("seriesId") REFERENCES "DocumentSeries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InvoiceDetail" ADD CONSTRAINT "InvoiceDetail_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "Invoice2"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
