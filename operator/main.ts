import {
  Abi,
  createPublicClient,
  createWalletClient,
  getContract,
  http,
  stringToHex,
} from "viem";
import { anvil } from "viem/chains";

import { privateKeyToAccount } from "viem/accounts";

require("dotenv").config();
const fs = require("fs");
const path = require("path");

const oracleCoreABI = JSON.parse(
  fs.readFileSync(path.resolve(__dirname, "../abis/OracleCore.json"), "utf8")
);

const publicClient = createPublicClient({
  chain: anvil,
  transport: http(),
});

const walletClient = createWalletClient({
  chain: anvil,
  transport: http(),
  account: privateKeyToAccount(
    "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
  ),
});

const oracle = getContract({
  address: "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707",
  abi: oracleCoreABI as Abi,
  client: walletClient,
});

export const requestEvent = async () => {
  await oracle.write.request([
    "test",
    stringToHex("This is Test event"),
    walletClient.account.address,
  ]);

  console.log("Request!! ");
};

const getEvent = (name: string) => {
  const event = oracleCoreABI.find((item: any) => item.name === name);
  return event;
};

const watchProposeEvent = async () => {
  console.log("Start watching propose event ...");

  publicClient.watchEvent({
    pollingInterval: 1_000,
    address: "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707",
    // event: parseAbiItem(
    //   "event RequestEvent(bytes32 indexed id, address indexed creator, bytes requestContent, uint256 time)"
    // ),
    poll: true,
    onLogs: (logs) => {
      console.log("RequestEvent logs:");
      console.log(logs);
    },
    onError: (error) => {
      console.error(error);
    },
  });
};

async function main() {
  await watchProposeEvent();
}

main();
