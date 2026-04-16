"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.authRouter = void 0;
const express_1 = require("express");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const zod_1 = require("zod");
const prisma_1 = require("../lib/prisma");
const auth_1 = require("../lib/auth");
exports.authRouter = (0, express_1.Router)();
function error(res, status, code, messageMn, details) {
    return res.status(status).json({ error: code, messageMn, details });
}
const signupSchema = zod_1.z.object({
    fullName: zod_1.z.string().min(2),
    email: zod_1.z.string().email(),
    password: zod_1.z.string().min(6),
    ageRange: zod_1.z.string().min(1).optional(),
    gender: zod_1.z.string().min(1).optional(),
    hasLoan: zod_1.z.boolean().optional(),
    hasSavings: zod_1.z.boolean().optional(),
    profileImageBase64: zod_1.z.string().min(1).optional(),
    incomeSources: zod_1.z.array(zod_1.z.string()).max(10).default([]),
    expenseSources: zod_1.z.array(zod_1.z.string()).max(10).default([]),
    customIncomeSources: zod_1.z.array(zod_1.z.string()).max(20).default([]),
    customExpenseSources: zod_1.z.array(zod_1.z.string()).max(20).default([]),
    theme: zod_1.z.enum(["violet", "emerald", "amber", "sky", "rose"]).default("violet"),
});
const loginSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    password: zod_1.z.string().min(6),
});
exports.authRouter.post("/signup", async (req, res) => {
    const parsed = signupSchema.safeParse(req.body);
    if (!parsed.success)
        return error(res, 400, "INVALID_INPUT", "Оруулсан мэдээллээ шалгана уу.", parsed.error.flatten());
    const { fullName, email, password, ageRange, gender, hasLoan, hasSavings, profileImageBase64, incomeSources, expenseSources, customIncomeSources, customExpenseSources, theme, } = parsed.data;
    const existing = await prisma_1.prisma.user.findUnique({ where: { email } });
    if (existing)
        return error(res, 409, "EMAIL_EXISTS", "Энэ и-мэйлээр бүртгэл аль хэдийн үүссэн байна.");
    const passwordHash = await bcryptjs_1.default.hash(password, 10);
    const user = await prisma_1.prisma.user.create({
        data: {
            fullName,
            email,
            passwordHash,
            ageRange,
            gender,
            hasLoan: hasLoan ?? false,
            hasSavings: hasSavings ?? false,
            profileImageBase64,
            incomeSources,
            expenseSources,
            customIncomeSources,
            customExpenseSources,
            theme,
        },
        select: { id: true, fullName: true, email: true, theme: true },
    });
    const token = await (0, auth_1.signAccessToken)({ sub: user.id, email: user.email });
    return res.status(201).json({ token, user });
});
exports.authRouter.post("/login", async (req, res) => {
    const parsed = loginSchema.safeParse(req.body);
    if (!parsed.success)
        return error(res, 400, "INVALID_INPUT", "И-мэйл болон нууц үгээ зөв оруулна уу.", parsed.error.flatten());
    const { email, password } = parsed.data;
    const user = await prisma_1.prisma.user.findUnique({ where: { email } });
    if (!user)
        return error(res, 404, "EMAIL_NOT_FOUND", "Бүртгэлгүй байна. Бүртгүүлэх үү?");
    const ok = await bcryptjs_1.default.compare(password, user.passwordHash);
    if (!ok)
        return error(res, 401, "WRONG_PASSWORD", "Нууц үг буруу байна.");
    const token = await (0, auth_1.signAccessToken)({ sub: user.id, email: user.email });
    return res.json({
        token,
        user: { id: user.id, fullName: user.fullName, email: user.email, theme: user.theme },
    });
});
exports.authRouter.get("/me", async (req, res) => {
    const auth = req.header("authorization") ?? "";
    const token = auth.startsWith("Bearer ") ? auth.slice("Bearer ".length) : "";
    if (!token)
        return error(res, 401, "UNAUTHORIZED", "Нэвтэрч байж үргэлжлүүлнэ үү.");
    try {
        const payload = await (0, auth_1.verifyAccessToken)(token);
        const user = await prisma_1.prisma.user.findUnique({
            where: { id: payload.sub },
            select: {
                id: true,
                fullName: true,
                email: true,
                theme: true,
                ageRange: true,
                gender: true,
                hasLoan: true,
                hasSavings: true,
                profileImageBase64: true,
                incomeSources: true,
                expenseSources: true,
                customIncomeSources: true,
                customExpenseSources: true,
            },
        });
        if (!user)
            return error(res, 401, "UNAUTHORIZED", "Нэвтрэлт хүчингүй байна. Дахин нэвтэрнэ үү.");
        return res.json({ user });
    }
    catch {
        return error(res, 401, "UNAUTHORIZED", "Нэвтрэлт хүчингүй байна. Дахин нэвтэрнэ үү.");
    }
});
