-- CreateTable
CREATE TABLE "Alerts" (
    "id" SERIAL NOT NULL,
    "updateadAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "itemid" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL,
    "subject" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "internal_emails" TEXT NOT NULL,
    "nrofdays" INTEGER NOT NULL,
    "param" TEXT NOT NULL,
    "isActivePartner" BOOLEAN NOT NULL,
    "isActivePerson" BOOLEAN NOT NULL,

    CONSTRAINT "Alerts_pkey" PRIMARY KEY ("id")
);
