import {
  Abi,
  createPublicClient,
  createWalletClient,
  getContract,
  http,
} from "viem";
import { holesky } from "viem/chains";
import { privateKeyToAccount } from "viem/accounts";

require("dotenv").config();
const fs = require("fs");
const path = require("path");

export const ORACLE = "0x86968d4987a0feed1f6e8cff560afca755a931cb";

export const oracleCoreABI = JSON.parse(
  fs.readFileSync(path.resolve(__dirname, "../abis/OracleCore.json"), "utf8")
);

export const publicClient = createPublicClient({
  chain: holesky,
  transport: http(process.env.HOLESKY_RPC),
});

export const walletClient = createWalletClient({
  transport: http(process.env.HOLESKY_RPC),
  chain: holesky,
  account: privateKeyToAccount(process.env.OP_PK as `0x${string}`),
});

export const oracle = getContract({
  address: ORACLE,
  abi: oracleCoreABI as Abi,
  client: walletClient,
});
