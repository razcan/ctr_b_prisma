-- AlterTable
ALTER TABLE "Contracts" ADD COLUMN     "automaticRenewal" BOOLEAN NOT NULL DEFAULT false,
ALTER COLUMN "parentId" SET DEFAULT 0;
