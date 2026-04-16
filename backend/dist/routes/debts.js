"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.debtsRouter = void 0;
const express_1 = require("express");
const zod_1 = require("zod");
const prisma_1 = require("../lib/prisma");
const requireAuth_1 = require("../lib/requireAuth");
exports.debtsRouter = (0, express_1.Router)();
const createSchema = zod_1.z.object({
    kind: zod_1.z.enum(["LOAN", "RECEIVABLE"]),
    counterparty: zod_1.z.string().min(1),
    amount: zod_1.z.number().int().positive(),
    dueDate: zod_1.z.string().datetime().optional(),
    note: zod_1.z.string().min(1).optional(),
});
exports.debtsRouter.get("/", requireAuth_1.requireAuth, async (req, res) => {
    const userId = req.userId;
    const status = req.query.status ?? "OPEN";
    const items = await prisma_1.prisma.debt.findMany({
        where: { userId, status: status === "CLOSED" ? "CLOSED" : "OPEN" },
        orderBy: { updatedAt: "desc" },
    });
    return res.json({ items });
});
exports.debtsRouter.post("/", requireAuth_1.requireAuth, async (req, res) => {
    const userId = req.userId;
    const parsed = createSchema.safeParse(req.body);
    if (!parsed.success) {
        return res.status(400).json({
            error: "INVALID_INPUT",
            messageMn: "Оруулсан мэдээллээ шалгана уу.",
            details: parsed.error.flatten(),
        });
    }
    const { kind, counterparty, amount, dueDate, note } = parsed.data;
    const item = await prisma_1.prisma.debt.create({
        data: {
            userId,
            kind: kind,
            counterparty,
            amount,
            dueDate: dueDate ? new Date(dueDate) : null,
            note,
        },
    });
    return res.status(201).json({ item });
});
