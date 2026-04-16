import { Router } from "express";
import bcrypt from "bcryptjs";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { signAccessToken, verifyAccessToken } from "../lib/auth";

export const authRouter = Router();

function error(
  res: any,
  status: number,
  code: string,
  messageMn: string,
  details?: unknown,
) {
  return res.status(status).json({ error: code, messageMn, details });
}

const signupSchema = z.object({
  fullName: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(6),
  ageRange: z.string().min(1).optional(),
  gender: z.string().min(1).optional(),
  hasLoan: z.boolean().optional(),
  hasSavings: z.boolean().optional(),
  profileImageBase64: z.string().min(1).optional(),
  incomeSources: z.array(z.string()).max(10).default([]),
  expenseSources: z.array(z.string()).max(10).default([]),
  customIncomeSources: z.array(z.string()).max(20).default([]),
  customExpenseSources: z.array(z.string()).max(20).default([]),
  theme: z
    .enum(["violet", "emerald", "amber", "sky", "rose"])
    .default("violet"),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

authRouter.post("/signup", async (req, res) => {
  const parsed = signupSchema.safeParse(req.body);
  if (!parsed.success)
    return error(
      res,
      400,
      "INVALID_INPUT",
      "Оруулсан мэдээллээ шалгана уу.",
      parsed.error.flatten(),
    );

  const {
    fullName,
    email,
    password,
    ageRange,
    gender,
    hasLoan,
    hasSavings,
    profileImageBase64,
    incomeSources,
    expenseSources,
    customIncomeSources,
    customExpenseSources,
    theme,
  } = parsed.data;

  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing)
    return error(
      res,
      409,
      "EMAIL_EXISTS",
      "Энэ и-мэйлээр бүртгэл аль хэдийн үүссэн байна.",
    );

  const passwordHash = await bcrypt.hash(password, 10);
  const user = await prisma.user.create({
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

  const token = await signAccessToken({ sub: user.id, email: user.email });
  return res.status(201).json({ token, user });
});

authRouter.post("/login", async (req, res) => {
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success)
    return error(
      res,
      400,
      "INVALID_INPUT",
      "И-мэйл болон нууц үгээ зөв оруулна уу.",
      parsed.error.flatten(),
    );

  const { email, password } = parsed.data;
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user)
    return error(
      res,
      404,
      "EMAIL_NOT_FOUND",
      "Бүртгэлгүй байна. Бүртгүүлнэ үү?",
    );

  const ok = await bcrypt.compare(password, user.passwordHash);
  if (!ok) return error(res, 401, "WRONG_PASSWORD", "Нууц үг буруу байна.");

  const token = await signAccessToken({ sub: user.id, email: user.email });
  return res.json({
    token,
    user: {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      theme: user.theme,
    },
  });
});

authRouter.get("/me", async (req, res) => {
  const auth = req.header("authorization") ?? "";
  const token = auth.startsWith("Bearer ") ? auth.slice("Bearer ".length) : "";
  if (!token)
    return error(res, 401, "UNAUTHORIZED", "Нэвтэрч байж үргэлжлүүлнэ үү.");

  try {
    const payload = await verifyAccessToken(token);
    const user = await prisma.user.findUnique({
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
      return error(
        res,
        401,
        "UNAUTHORIZED",
        "Нэвтрэлт хүчингүй байна. Дахин нэвтэрнэ үү.",
      );
    return res.json({ user });
  } catch {
    return error(
      res,
      401,
      "UNAUTHORIZED",
      "Нэвтрэлт хүчингүй байна. Дахин нэвтэрнэ үү.",
    );
  }
});
