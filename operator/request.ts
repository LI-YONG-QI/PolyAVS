import { create } from "domain";
import { walletClient, oracle } from "./config";
import { stringToHex } from "viem";

const requestEvent = async () => {
  await oracle.write.request([
    "Test Event Title",
    stringToHex("What day is today?"),
    walletClient.account.address,
  ]);

  console.log("Request!! ");
};

const proposeEvent = async () => {
  await oracle.write.request([
    {
      title: "Test Event Title",
      request: {
        content: stringToHex("What day is today?"),
        creator: walletClient.account.address,
        createAt: 1730362944,
      },
      propose: {
        content: stringToHex(""),
        creator: walletClient.account.address,
        createAt: 1730362944,
      },
      status: 0,
    },
    stringToHex("Thursday"),
    walletClient.account.address,
  ]);

  console.log("Request!! ");
};

async function main() {
  //await requestEvent();
  await proposeEvent();
}

main();
