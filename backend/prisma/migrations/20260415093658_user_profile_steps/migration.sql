-- AlterTable
ALTER TABLE "User" ADD COLUMN     "ageRange" TEXT,
ADD COLUMN     "gender" TEXT,
ADD COLUMN     "hasLoan" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "hasSavings" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "profileImageBase64" TEXT;
