"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.signAccessToken = signAccessToken;
exports.verifyAccessToken = verifyAccessToken;
const jose_1 = require("jose");
const encoder = new TextEncoder();
function mustGetSecret() {
    const secret = process.env.AUTH_SECRET;
    if (!secret)
        throw new Error("AUTH_SECRET is not set");
    return encoder.encode(secret);
}
async function signAccessToken(payload) {
    return await new jose_1.SignJWT({ email: payload.email })
        .setProtectedHeader({ alg: "HS256" })
        .setSubject(payload.sub)
        .setIssuedAt()
        .setExpirationTime("30d")
        .sign(mustGetSecret());
}
async function verifyAccessToken(token) {
    const { payload } = await (0, jose_1.jwtVerify)(token, mustGetSecret());
    const sub = typeof payload.sub === "string" ? payload.sub : undefined;
    const email = typeof payload.email === "string" ? payload.email : undefined;
    if (!sub || !email)
        throw new Error("Invalid token payload");
    return { sub, email };
}
