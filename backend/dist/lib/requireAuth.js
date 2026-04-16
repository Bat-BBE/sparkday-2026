"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAuth = requireAuth;
const auth_1 = require("./auth");
async function requireAuth(req, res, next) {
    const auth = req.header("authorization") ?? "";
    const token = auth.startsWith("Bearer ") ? auth.slice("Bearer ".length) : "";
    if (!token)
        return res.status(401).json({ error: "UNAUTHORIZED", messageMn: "Нэвтэрч байж үргэлжлүүлнэ үү." });
    try {
        const payload = await (0, auth_1.verifyAccessToken)(token);
        req.userId = payload.sub;
        return next();
    }
    catch {
        return res.status(401).json({ error: "UNAUTHORIZED", messageMn: "Нэвтрэлт хүчингүй байна. Дахин нэвтэрнэ үү." });
    }
}
