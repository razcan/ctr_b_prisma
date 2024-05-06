-- AlterTable
ALTER TABLE "Contracts" ADD COLUMN     "locationId" INTEGER;

-- CreateTable
CREATE TABLE "Location" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "Location_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Location_name_key" ON "Location"("name");

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "Location"("id") ON DELETE SET NULL ON UPDATE CASCADE;
