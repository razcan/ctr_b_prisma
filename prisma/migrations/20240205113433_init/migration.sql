-- CreateTable
CREATE TABLE "MeasuringUnit" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "MeasuringUnit_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "MeasuringUnit_name_key" ON "MeasuringUnit"("name");
