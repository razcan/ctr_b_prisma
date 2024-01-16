-- CreateTable
CREATE TABLE "Address" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "addressName" TEXT NOT NULL,
    "addressType" TEXT NOT NULL,
    "Country" TEXT NOT NULL,
    "County" TEXT NOT NULL,
    "City" TEXT NOT NULL,
    "Street" TEXT NOT NULL,
    "Number" TEXT NOT NULL,
    "postalCode" TEXT NOT NULL,
    "Status" TEXT NOT NULL,
    "Default" TEXT NOT NULL,
    "aggregate" TEXT NOT NULL,
    "completeAddress" TEXT NOT NULL,
    "partnerId" INTEGER NOT NULL,

    CONSTRAINT "Address_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "Address" ADD CONSTRAINT "Address_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partners"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
