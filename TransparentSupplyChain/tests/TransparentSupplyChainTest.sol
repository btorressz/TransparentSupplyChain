// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../contracts/TransparentSupplyChain.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract TransparentSupplyChainTest {
    TransparentSupplyChain public supplyChain;
    address public account0 = address(this);
    address public account1 = address(0x123); // Farmer
    address public account2 = address(0x456); // Distributor
    address public account3 = address(0x789); // New owner

    constructor() {
        // Deploy the TransparentSupplyChain contract
        supplyChain = new TransparentSupplyChain();

        // Grant roles to accounts
        supplyChain.grantRole(supplyChain.FARMER_ROLE(), account1);
        supplyChain.grantRole(supplyChain.DISTRIBUTOR_ROLE(), account2);
    }

    function testAdminSetup() public {
        // Check if the admin role is set correctly
        require(supplyChain.hasRole(supplyChain.DEFAULT_ADMIN_ROLE(), account0), "Admin role should be granted to account0");
    }

    function testAddProduct() public {
        // Add a product
        supplyChain.addProduct("Apple", "USA", true, true);

        // Verify the product details
        (
            string memory name,
            string memory origin,
            uint256 timestamp,
            bool organicCertified,
            bool fairTradeCertified,
            address currentOwner
        ) = supplyChain.getProduct(0);

        require(keccak256(bytes(name)) == keccak256(bytes("Apple")), "Product name should be 'Apple'");
        require(keccak256(bytes(origin)) == keccak256(bytes("USA")), "Product origin should be 'USA'");
        require(organicCertified == true, "Product should be organic certified");
        require(fairTradeCertified == true, "Product should be fair-trade certified");
        require(currentOwner == account1, "Product owner should be account1");
    }

    function testAddCheckpoint() public {
        // Add a checkpoint
        supplyChain.addCheckpoint(0, "Warehouse", "Stored in warehouse");

        // Verify the checkpoint details
        TransparentSupplyChain.Checkpoint[] memory checkpoints = supplyChain.getCheckpoints(0);
        require(checkpoints.length == 1, "There should be one checkpoint");
        require(keccak256(bytes(checkpoints[0].location)) == keccak256(bytes("Warehouse")), "Checkpoint location should be 'Warehouse'");
        require(keccak256(bytes(checkpoints[0].description)) == keccak256(bytes("Stored in warehouse")), "Checkpoint description should be 'Stored in warehouse'");
    }

    function testTransferProduct() public {
        // Transfer product ownership
        supplyChain.transferProduct(0, account3);

        // Verify the product details
        (
            ,
            ,
            ,
            ,
            ,
            address currentOwner
        ) = supplyChain.getProduct(0);

        require(currentOwner == account3, "Product owner should be account3");
    }

    function testCheckpointAfterTransfer() public {
        // Add a checkpoint after the transfer
        supplyChain.addCheckpoint(0, "Retail Store", "Available for sale");

        // Verify the checkpoint details
        TransparentSupplyChain.Checkpoint[] memory checkpoints = supplyChain.getCheckpoints(0);
        require(checkpoints.length == 2, "There should be two checkpoints");
        require(keccak256(bytes(checkpoints[1].location)) == keccak256(bytes("Retail Store")), "Checkpoint location should be 'Retail Store'");
        require(keccak256(bytes(checkpoints[1].description)) == keccak256(bytes("Available for sale")), "Checkpoint description should be 'Available for sale'");
    }
}
