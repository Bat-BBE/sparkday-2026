import { SignJWT, jwtVerify } from "jose";

const encoder = new TextEncoder();

function mustGetSecret(): Uint8Array {
  const secret = process.env.AUTH_SECRET;
  if (!secret) throw new Error("AUTH_SECRET is not set");
  return encoder.encode(secret);
}

export type AuthTokenPayload = {
  sub: string;
  email: string;
};

export async function signAccessToken(payload: AuthTokenPayload): Promise<string> {
  return await new SignJWT({ email: payload.email })
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(payload.sub)
    .setIssuedAt()
    .setExpirationTime("30d")
    .sign(mustGetSecret());
}

export async function verifyAccessToken(token: string): Promise<AuthTokenPayload> {
  const { payload } = await jwtVerify(token, mustGetSecret());
  const sub = typeof payload.sub === "string" ? payload.sub : undefined;
  const email = typeof payload.email === "string" ? payload.email : undefined;
  if (!sub || !email) throw new Error("Invalid token payload");
  return { sub, email };
}

