import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { requireAuth, type AuthedRequest } from "../lib/requireAuth";

export const accountsRouter = Router();

const createSchema = z.object({
  name: z.string().min(1),
  type: z.enum(["CASH", "BANK", "CARD", "SAVINGS"]).optional(),
  currency: z.string().min(1).optional(),
  balance: z.number().int().optional(),
});

accountsRouter.get("/", requireAuth, async (req, res) => {
  const userId = (req as AuthedRequest).userId;
  const items = await prisma.account.findMany({
    where: { userId },
    orderBy: { createdAt: "desc" },
  });
  return res.json({ items });
});

accountsRouter.post("/", requireAuth, async (req, res) => {
  const userId = (req as AuthedRequest).userId;
  const parsed = createSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      error: "INVALID_INPUT",
      messageMn: "Оруулсан мэдээллээ шалгана уу.",
      details: parsed.error.flatten(),
    });
  }
  const { name, type, currency, balance } = parsed.data;
  const item = await prisma.account.create({
    data: {
      userId,
      name,
      type: type as any,
      currency: currency ?? "MNT",
      balance: balance ?? 0,
    },
  });
  return res.status(201).json({ item });
});

