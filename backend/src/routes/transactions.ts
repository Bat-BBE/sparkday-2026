import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { requireAuth, type AuthedRequest } from "../lib/requireAuth";

export const transactionsRouter = Router();

const createSchema = z.object({
  accountId: z.string().min(1),
  type: z.enum(["INCOME", "EXPENSE", "TRANSFER"]),
  amount: z.number().int().positive(),
  category: z.string().min(1).optional(),
  note: z.string().min(1).optional(),
  occurredAt: z.string().datetime().optional(),
});

transactionsRouter.get("/", requireAuth, async (req, res) => {
  const userId = (req as AuthedRequest).userId;
  const limit = Math.min(Number(req.query.limit ?? 50) || 50, 200);
  const items = await prisma.transaction.findMany({
    where: { userId },
    orderBy: { occurredAt: "desc" },
    take: limit,
    include: { account: true },
  });
  return res.json({ items });
});

transactionsRouter.post("/", requireAuth, async (req, res) => {
  const userId = (req as AuthedRequest).userId;
  const parsed = createSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      error: "INVALID_INPUT",
      messageMn: "Оруулсан мэдээллээ шалгана уу.",
      details: parsed.error.flatten(),
    });
  }
  const { accountId, type, amount, category, note, occurredAt } = parsed.data;

  // ensure account belongs to user
  const acc = await prisma.account.findFirst({ where: { id: accountId, userId } });
  if (!acc) {
    return res.status(404).json({ error: "NOT_FOUND", messageMn: "Данс олдсонгүй." });
  }

  const item = await prisma.$transaction(async (tx) => {
    const created = await tx.transaction.create({
      data: {
        userId,
        accountId,
        type: type as any,
        amount,
        category,
        note,
        occurredAt: occurredAt ? new Date(occurredAt) : new Date(),
      },
      include: { account: true },
    });

    // update account balance snapshot
    const delta = type === "INCOME" ? amount : type === "EXPENSE" ? -amount : 0;
    await tx.account.update({
      where: { id: accountId },
      data: { balance: { increment: delta } },
    });

    return created;
  });

  return res.status(201).json({ item });
});

