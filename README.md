# TransparentSupplyChain

## Overview

The `TransparentSupplyChain` project is a smart contract implemented in Solidity that tracks the journey of agricultural products from farm to table. This contract ensures transparency and authenticity of organic and fair-trade certifications by recording product details and checkpoints in the supply chain. The contract utilizes role-based access control to manage permissions for different entities in the supply chain.

## Features

- **Track Product Journey**: Records the journey of products from farm to table, including checkpoints at various stages.
- **Verify Certifications**: Ensures products are organic and fair-trade certified.
- **Role-Based Access Control**: Manages permissions for farmers, distributors, and retailers.
- **Data Integrity**: Ensures the authenticity of data through immutable records on the blockchain.

## Smart Contract Details

### Roles

- **Admin**: Manages roles and permissions.
- **Farmer**: Adds new products to the supply chain.
- **Distributor**: Adds checkpoints to the product journey.
- **Retailer**: Not used directly in this contract, but can be extended for retail operations.

### Structs

- **Product**
  - `name`: The name of the product.
  - `origin`: The origin of the product.
  - `timestamp`: The timestamp when the product was added.
  - `organicCertified`: Boolean indicating if the product is organically certified.
  - `fairTradeCertified`: Boolean indicating if the product is fair-trade certified.
  - `currentOwner`: The current owner of the product.

- **Checkpoint**
  - `location`: The location of the checkpoint.
  - `description`: A description of the checkpoint.
  - `timestamp`: The timestamp when the checkpoint was added.

### Events

- `ProductCreated(uint256 productId, string name, string origin, address owner)`
- `CheckpointAdded(uint256 productId, string location, string description)`
- `ProductTransferred(uint256 productId, address from, address to)`
