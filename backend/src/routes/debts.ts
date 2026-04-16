import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { requireAuth, type AuthedRequest } from "../lib/requireAuth";

export const debtsRouter = Router();

const createSchema = z.object({
  kind: z.enum(["LOAN", "RECEIVABLE"]),
  counterparty: z.string().min(1),
  amount: z.number().int().positive(),
  dueDate: z.string().datetime().optional(),
  note: z.string().min(1).optional(),
});

debtsRouter.get("/", requireAuth, async (req, res) => {
  const userId = (req as AuthedRequest).userId;
  const status = (req.query.status as string | undefined) ?? "OPEN";
  const items = await prisma.debt.findMany({
    where: { userId, status: status === "CLOSED" ? "CLOSED" : "OPEN" },
    orderBy: { updatedAt: "desc" },
  });
  return res.json({ items });
});

debtsRouter.post("/", requireAuth, async (req, res) => {
  const userId = (req as AuthedRequest).userId;
  const parsed = createSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      error: "INVALID_INPUT",
      messageMn: "Оруулсан мэдээллээ шалгана уу.",
      details: parsed.error.flatten(),
    });
  }

  const { kind, counterparty, amount, dueDate, note } = parsed.data;
  const item = await prisma.debt.create({
    data: {
      userId,
      kind: kind as any,
      counterparty,
      amount,
      dueDate: dueDate ? new Date(dueDate) : null,
      note,
    },
  });
  return res.status(201).json({ item });
});

