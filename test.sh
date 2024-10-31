#! /bin/sh

# Restake
cast send --private-key ab791cf20f47ab8ae366597ff94c629a7c121aa1df6cb41476d3ebc45a0231ed --rpc-url https://holesky.infura.io/v3/311142eea537485aabe9b15954cb5960 0xdfB5f6CE42aAA7830E94ECFCcAd411beF4d4D5b6 " depositIntoStrategy(address,address,uint256)" 0x80528D6e9A2BAbFc766965E0E26d5aB08D9CFaF9 0x94373a4919B3240D86eA41593D5eBa789FEF3848 2000000000000000000

# Delegate
forge script script/Delegate.s.sol --rpc-url https://holesky.infura.io/v3/311142eea537485aabe9b15954cb5960 --private-key ab791cf20f47ab8ae366597ff94c629a7c121aa1df6cb41476d3ebc45a0231ed