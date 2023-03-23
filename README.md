[![Mentioned in Awesome Foundry](https://awesome.re/mentioned-badge-flat.svg)](https://github.com/crisgarner/awesome-foundry)
# Foundry + Hardhat Diamonds

This codebase contains a minimal extension to the [Diamonds](https://github.com/ethereum/EIPs/issues/2535) standard, to allow for Diamond upgrades to be rolled-backed.
The repository was genarated from this [template](https://github.com/Timidan/Foundry-Hardhat-Diamonds).

## Installation

- Clone this repo
- Install dependencies

```bash
$ yarn && forge update
```

### Compile
- To compile contracts, run:
```bash
$ npx hardhat compile
```

## Deployment

### Hardhat
```bash
$ npx hardhat run scripts/deploy.js
```

### Foundry
- To test, run:
```bash
$ forge test
```

`Note`: A lot of improvements are still needed so contributions are welcome!!

Bonus: The [DiamondLoupefacet](contracts/facets/DiamondLoupeFacet.sol) uses an updated [LibDiamond](contracts/libraries//LibDiamond.sol) which utilises solidity custom errors to make debugging easier especially when upgrading diamonds. Take it for a spin!!

Need some more clarity? message me [on twitter](https://twitter.com/Timidan_x), Or join the [EIP-2535 Diamonds Discord server](https://discord.gg/kQewPw2)
