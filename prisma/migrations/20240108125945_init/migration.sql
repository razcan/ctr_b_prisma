-- CreateTable
CREATE TABLE "Contracts" (
    "id" SERIAL NOT NULL,
    "number" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "partner" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "start" TIMESTAMP(3) NOT NULL,
    "end" TIMESTAMP(3) NOT NULL,
    "sign" TIMESTAMP(3) NOT NULL,
    "completion" TIMESTAMP(3) NOT NULL,
    "remarks" TEXT NOT NULL,

    CONSTRAINT "Contracts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContractsDetails" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "itemid" INTEGER NOT NULL,
    "contractId" INTEGER NOT NULL,

    CONSTRAINT "ContractsDetails_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Contracts_number_key" ON "Contracts"("number");

-- CreateIndex
CREATE UNIQUE INDEX "ContractsDetails_name_key" ON "ContractsDetails"("name");

-- AddForeignKey
ALTER TABLE "ContractsDetails" ADD CONSTRAINT "ContractsDetails_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES "Contracts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
