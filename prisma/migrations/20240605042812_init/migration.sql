-- CreateTable
CREATE TABLE "ExchangeRatesBNR" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "date" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "name" TEXT NOT NULL,
    "multiplier" TEXT NOT NULL,

    CONSTRAINT "ExchangeRatesBNR_pkey" PRIMARY KEY ("id")
);
