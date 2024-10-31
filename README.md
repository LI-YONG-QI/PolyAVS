# PolyAVS

![](https://i.imgur.com/RSZXbwd.png)

PolyAVS is an oracle specifically designed for prediction markets. It leverages the shared security of AVS, providing a transparent and censorship-resistant mechanism to ensure the accuracy of each event. To maintain sufficient decentralization, PolyAVS offers a dispute mechanism, allowing those with concerns about the results to challenge them. Operators who provide incorrect results will have a certain amount of tokens confiscated.

## Architecture

![](https://i.imgur.com/lT3sedb.png)

## Event Flow

![](https://i.imgur.com/geSVGkk.png)

Here is the complete process from request to settlement of the event (without dispute).or

In the above diagram, except for the operator who needs to register in Eigenlayer in advance, the **Requestor / Proposer / Settler could be anyone.**

## Dispute Flow

![](https://i.imgur.com/KYDRcTn.png)

If anyone is not agreed with the operator’s verification result, he can request a dispute for re-verification of the result and the stake assets will serve as collateral. The steps in the diagram continue from the previous diagram.

There will be two possible outcomes here

1. If disputer is wrong, then the disputer's staked assets will be confiscated.
2. If operators is wrong, then the assets delegated to operator will be confiscated

# Deployments

- Holesky
  - OracleCore: [0x86968D4987a0FEed1F6e8CfF560AFcA755A931cB](https://holesky.etherscan.io/tx/0xeffb589e01db7d0261eed3990e61b214bb94cc8da04ae3379d11e929964e6f7f#eventlog)
  - ECDSAStakeRegistry: [0xc7a3659e894c95d70f9a8ec95127e56c12032878](https://holesky.etherscan.io/address/0xc7a3659e894c95d70f9a8ec95127e56c12032878)

# How to start?

# Contracts

0. Check current path in contracts

```sh
cd contracts
```

1. Build contracts

```sh
forge build
```

2. Test contracts

```sh
forge test
```

# Operator

0. Check current path in project root

1. Install dependencies

```sh
pnpm install
```

2. Run operator to monitor event

```sh
ts-node ./operator/main.ts
```
