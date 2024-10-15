-- AlterTable
ALTER TABLE "Invoice" ADD COLUMN     "movement_type" INTEGER NOT NULL DEFAULT 1;

-- AlterTable
ALTER TABLE "Transactions" ADD COLUMN     "movement_type" INTEGER NOT NULL DEFAULT 1;
