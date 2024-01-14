-- AlterTable
ALTER TABLE "Contracts" ADD COLUMN     "cashflow" TEXT NOT NULL DEFAULT 'default',
ADD COLUMN     "costcenter" TEXT NOT NULL DEFAULT 'default',
ADD COLUMN     "departament" TEXT NOT NULL DEFAULT 'default',
ADD COLUMN     "entity" TEXT NOT NULL DEFAULT 'default',
ADD COLUMN     "item" TEXT NOT NULL DEFAULT 'default';

-- CreateTable
CREATE TABLE "Item" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "Item_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CostCenter" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "CostCenter_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Entity" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "Entity_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Item_name_key" ON "Item"("name");

-- CreateIndex
CREATE UNIQUE INDEX "CostCenter_name_key" ON "CostCenter"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Entity_name_key" ON "Entity"("name");
