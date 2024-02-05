-- CreateTable
CREATE TABLE "BillingFrequency" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "BillingFrequency_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "BillingFrequency_name_key" ON "BillingFrequency"("name");
