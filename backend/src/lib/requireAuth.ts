import type { Request, Response, NextFunction } from "express";
import { verifyAccessToken } from "./auth";

export type AuthedRequest = Request & { userId: string };

export async function requireAuth(req: Request, res: Response, next: NextFunction) {
  const auth = req.header("authorization") ?? "";
  const token = auth.startsWith("Bearer ") ? auth.slice("Bearer ".length) : "";
  if (!token) return res.status(401).json({ error: "UNAUTHORIZED", messageMn: "Нэвтэрч байж үргэлжлүүлнэ үү." });

  try {
    const payload = await verifyAccessToken(token);
    (req as AuthedRequest).userId = payload.sub;
    return next();
  } catch {
    return res.status(401).json({ error: "UNAUTHORIZED", messageMn: "Нэвтрэлт хүчингүй байна. Дахин нэвтэрнэ үү." });
  }
}

