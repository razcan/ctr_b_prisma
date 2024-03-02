-- DropForeignKey
ALTER TABLE "Role_User" DROP CONSTRAINT "Role_User_roleId_fkey";

-- DropForeignKey
ALTER TABLE "Role_User" DROP CONSTRAINT "Role_User_userId_fkey";

-- AddForeignKey
ALTER TABLE "Role_User" ADD CONSTRAINT "Role_User_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Role_User" ADD CONSTRAINT "Role_User_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "Role"("id") ON DELETE CASCADE ON UPDATE CASCADE;
