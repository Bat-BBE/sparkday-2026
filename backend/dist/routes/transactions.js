"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.transactionsRouter = void 0;
const express_1 = require("express");
const zod_1 = require("zod");
const prisma_1 = require("../lib/prisma");
const requireAuth_1 = require("../lib/requireAuth");
exports.transactionsRouter = (0, express_1.Router)();
const createSchema = zod_1.z.object({
    accountId: zod_1.z.string().min(1),
    type: zod_1.z.enum(["INCOME", "EXPENSE", "TRANSFER"]),
    amount: zod_1.z.number().int().positive(),
    category: zod_1.z.string().min(1).optional(),
    note: zod_1.z.string().min(1).optional(),
    occurredAt: zod_1.z.string().datetime().optional(),
});
exports.transactionsRouter.get("/", requireAuth_1.requireAuth, async (req, res) => {
    const userId = req.userId;
    const limit = Math.min(Number(req.query.limit ?? 50) || 50, 200);
    const items = await prisma_1.prisma.transaction.findMany({
        where: { userId },
        orderBy: { occurredAt: "desc" },
        take: limit,
        include: { account: true },
    });
    return res.json({ items });
});
exports.transactionsRouter.post("/", requireAuth_1.requireAuth, async (req, res) => {
    const userId = req.userId;
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
    const acc = await prisma_1.prisma.account.findFirst({ where: { id: accountId, userId } });
    if (!acc) {
        return res.status(404).json({ error: "NOT_FOUND", messageMn: "Данс олдсонгүй." });
    }
    const item = await prisma_1.prisma.$transaction(async (tx) => {
        const created = await tx.transaction.create({
            data: {
                userId,
                accountId,
                type: type,
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
