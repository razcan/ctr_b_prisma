/*
  Warnings:

  - A unique constraint covering the columns `[uuid]` on the table `ForgotPass` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "ForgotPass_uuid_key" ON "ForgotPass"("uuid");
