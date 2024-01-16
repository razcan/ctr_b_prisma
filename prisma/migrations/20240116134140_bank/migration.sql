-- CreateTable
CREATE TABLE "Banks" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "Bank" TEXT,
    "Currency" TEXT,
    "Branch" TEXT,
    "IBAN" TEXT,
    "Status" TEXT,
    "partnerId" INTEGER NOT NULL,

    CONSTRAINT "Banks_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "Banks" ADD CONSTRAINT "Banks_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partners"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
