-- CreateTable
CREATE TABLE "ContractTasksStatus" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "ContractTasksStatus_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ContractTasksStatus_name_key" ON "ContractTasksStatus"("name");
