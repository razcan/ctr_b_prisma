-- CreateTable
CREATE TABLE "ForgotPass" (
    "id" SERIAL NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "email" TEXT NOT NULL,
    "actual_password" TEXT NOT NULL,
    "old_password" TEXT NOT NULL,
    "uuid" TEXT NOT NULL,
    "userId" INTEGER NOT NULL,

    CONSTRAINT "ForgotPass_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "ForgotPass" ADD CONSTRAINT "ForgotPass_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
