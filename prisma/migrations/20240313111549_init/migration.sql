-- AlterTable
ALTER TABLE "Contracts" ADD COLUMN     "userId" INTEGER;

-- AddForeignKey
ALTER TABLE "Contracts" ADD CONSTRAINT "Contracts_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
