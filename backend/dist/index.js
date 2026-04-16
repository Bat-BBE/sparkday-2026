"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const auth_1 = require("./routes/auth");
const accounts_1 = require("./routes/accounts");
const transactions_1 = require("./routes/transactions");
const debts_1 = require("./routes/debts");
const app = (0, express_1.default)();
const corsOptions = {
    origin: (_origin, cb) => cb(null, true), // allow all origins (dev)
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: false,
    optionsSuccessStatus: 204,
};
app.use((0, cors_1.default)(corsOptions));
// Express v5 doesn't accept "*" here; use a regex to match all paths.
app.options(/.*/, (0, cors_1.default)(corsOptions));
app.use(express_1.default.json({ limit: "1mb" }));
app.get("/health", (_req, res) => res.json({ ok: true }));
app.use("/auth", auth_1.authRouter);
app.use("/accounts", accounts_1.accountsRouter);
app.use("/transactions", transactions_1.transactionsRouter);
app.use("/debts", debts_1.debtsRouter);
const port = Number(process.env.PORT ?? 4000);
app.listen(port, () => {
    // eslint-disable-next-line no-console
    console.log(`zban backend listening on :${port}`);
});
