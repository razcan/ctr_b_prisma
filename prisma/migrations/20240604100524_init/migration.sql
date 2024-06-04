-- CreateTable
CREATE TABLE "DocumentSeries" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "entityId" INTEGER NOT NULL,
    "updatedByUserId" INTEGER NOT NULL,
    "documentTypeId" INTEGER NOT NULL,
    "series" TEXT NOT NULL,
    "start_number" INTEGER NOT NULL,
    "final_number" INTEGER NOT NULL,
    "last_number" INTEGER NOT NULL,
    "isActive" BOOLEAN NOT NULL,

    CONSTRAINT "DocumentSeries_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "DocumentSeries_series_key" ON "DocumentSeries"("series");
