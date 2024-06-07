-- DropForeignKey
ALTER TABLE "Invoice" DROP CONSTRAINT "Invoice_seriesId_fkey";

-- DropForeignKey
ALTER TABLE "Invoice" DROP CONSTRAINT "Invoice_transactionTypeId_fkey";

-- DropForeignKey
ALTER TABLE "Invoice" DROP CONSTRAINT "Invoice_typeId_fkey";

-- AlterTable
ALTER TABLE "Invoice" ALTER COLUMN "typeId" DROP NOT NULL,
ALTER COLUMN "transactionTypeId" DROP NOT NULL,
ALTER COLUMN "seriesId" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES "InvoiceType"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_transactionTypeId_fkey" FOREIGN KEY ("transactionTypeId") REFERENCES "TransactionType"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_seriesId_fkey" FOREIGN KEY ("seriesId") REFERENCES "DocumentSeries"("id") ON DELETE SET NULL ON UPDATE CASCADE;
