"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.accountsRouter = void 0;
const express_1 = require("express");
const zod_1 = require("zod");
const prisma_1 = require("../lib/prisma");
const requireAuth_1 = require("../lib/requireAuth");
exports.accountsRouter = (0, express_1.Router)();
const createSchema = zod_1.z.object({
    name: zod_1.z.string().min(1),
    type: zod_1.z.enum(["CASH", "BANK", "CARD", "SAVINGS"]).optional(),
    currency: zod_1.z.string().min(1).optional(),
    balance: zod_1.z.number().int().optional(),
});
exports.accountsRouter.get("/", requireAuth_1.requireAuth, async (req, res) => {
    const userId = req.userId;
    const items = await prisma_1.prisma.account.findMany({
        where: { userId },
        orderBy: { createdAt: "desc" },
    });
    return res.json({ items });
});
exports.accountsRouter.post("/", requireAuth_1.requireAuth, async (req, res) => {
    const userId = req.userId;
    const parsed = createSchema.safeParse(req.body);
    if (!parsed.success) {
        return res.status(400).json({
            error: "INVALID_INPUT",
            messageMn: "Оруулсан мэдээллээ шалгана уу.",
            details: parsed.error.flatten(),
        });
    }
    const { name, type, currency, balance } = parsed.data;
    const item = await prisma_1.prisma.account.create({
        data: {
            userId,
            name,
            type: type,
            currency: currency ?? "MNT",
            balance: balance ?? 0,
        },
    });
    return res.status(201).json({ item });
});
