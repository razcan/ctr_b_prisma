/*
  Warnings:

  - A unique constraint covering the columns `[addressName]` on the table `Address` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[name]` on the table `Partners` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[fiscal_code]` on the table `Partners` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[commercial_reg]` on the table `Partners` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[name]` on the table `Persons` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[email]` on the table `Persons` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "Address_addressName_key" ON "Address"("addressName");

-- CreateIndex
CREATE UNIQUE INDEX "Partners_name_key" ON "Partners"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Partners_fiscal_code_key" ON "Partners"("fiscal_code");

-- CreateIndex
CREATE UNIQUE INDEX "Partners_commercial_reg_key" ON "Partners"("commercial_reg");

-- CreateIndex
CREATE UNIQUE INDEX "Persons_name_key" ON "Persons"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Persons_email_key" ON "Persons"("email");
