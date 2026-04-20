import "dotenv/config";
import express from "express";
import cors from "cors";
import { authRouter } from "./routes/auth";
import { accountsRouter } from "./routes/accounts";
import { transactionsRouter } from "./routes/transactions";
import { debtsRouter } from "./routes/debts";

const app = express();
const corsOptions: cors.CorsOptions = {
  origin: (_origin, cb) => cb(null, true),
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: false,
  optionsSuccessStatus: 204,
};

app.use(cors(corsOptions));
app.options(/.*/, cors(corsOptions));
app.use(express.json({ limit: "20mb" }));

app.get("/health", (_req, res) => res.json({ ok: true }));
app.use("/auth", authRouter);
app.use("/accounts", accountsRouter);
app.use("/transactions", transactionsRouter);
app.use("/debts", debtsRouter);

const port = Number(process.env.PORT ?? 4000);
app.listen(port, () => {
  console.log(`zban backend listening on :${port}`);
});
