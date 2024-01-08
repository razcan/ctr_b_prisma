-- CreateTable
CREATE TABLE "Contracte" (
    "id" SERIAL NOT NULL,
    "nr" TEXT NOT NULL,
    "client" TEXT,

    CONSTRAINT "Contracte_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Contracte_nr_key" ON "Contracte"("nr");
