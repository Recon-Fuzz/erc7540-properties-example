## ERC7540 Properties Example

This repo is meant to serve as an illustrative example of how to implement the [erc7540-reusable-properties](https://github.com/Recon-Fuzz/erc7540-reusable-properties/tree/main?tab=readme-ov-file) repo developed by the Centrifuge and Recon teams to automatically test properties related to [ERC7540 vault](https://eips.ethereum.org/EIPS/eip-7540) implementations with fuzz testing. 

The ERC7540 vault implementation used here is taken from the [liquidity-pools](https://github.com/centrifuge/liquidity-pools/tree/main) repo developed by the Centrifuge team, with some modifications made for simplicity.

## Usage

The repo is setup for fuzzing with Echidna and Medusa in property `testingMode`. 

To run Echidna use the following command:

```
echidna . --contract CryticTester --config echidna.yaml
```

To run Medusa use the following command:

```
medusa fuzz
```