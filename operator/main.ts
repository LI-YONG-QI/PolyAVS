import { oracleCoreABI, publicClient, ORACLE } from "./config";
require("dotenv").config();

const getEvent = (name: string) => {
  const event = oracleCoreABI.find((item: any) => item.name === name);
  return event;
};

const verifyEvent = async () => {
  // await oracle.write.verifyProposed([
  //   "Test Event Title",
  //   stringToHex("What day is today?"),
  //   walletClient.account.address,
  // ]);

  console.log("Verify!! ");
};
const watchProposeEvent = async () => {
  console.log("Start watching proposed event ...");

  publicClient.watchEvent({
    pollingInterval: 1_000,
    address: ORACLE,
    event: getEvent("ProposeEvent"),
    poll: true,
    onLogs: async (logs) => {
      console.log("ProposeEvent logs:", logs);
      await verifyEvent();
    },
    onError: (error) => {
      console.error(error);
    },
  });
};

async function main() {
  console.log(getEvent("ProposeEvent"));
  await watchProposeEvent();
}

main();
