-- CreateTable
CREATE TABLE "VatQuota" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "VatCode" TEXT NOT NULL,
    "VATDescription" TEXT NOT NULL,
    "VATPercent" INTEGER NOT NULL,
    "VATType" INTEGER NOT NULL,
    "AccVATPercent" INTEGER NOT NULL,

    CONSTRAINT "VatQuota_pkey" PRIMARY KEY ("id")
);
