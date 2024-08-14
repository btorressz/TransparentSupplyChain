// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title TransparentSupplyChain
 * @dev This contract tracks the journey of agricultural products from farm to table, ensuring transparency and authenticity of organic and fair-trade certifications.
 */
contract TransparentSupplyChain is AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant FARMER_ROLE = keccak256("FARMER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant RETAILER_ROLE = keccak256("RETAILER_ROLE");

    // Struct to represent a product
    struct Product {
        string name;
        string origin;
        uint256 timestamp;
        bool organicCertified;
        bool fairTradeCertified;
        address currentOwner;
    }

    // Struct to represent a checkpoint in the product's journey
    struct Checkpoint {
        string location;
        string description;
        uint256 timestamp;
    }

    // Mapping to store products and their respective checkpoints
    mapping(uint256 => Product) private products;
    mapping(uint256 => Checkpoint[]) private productCheckpoints;

    // Counter to generate unique product IDs
    Counters.Counter private productIdCounter;

    // Events for tracking product creation, updates, and transfers
    event ProductCreated(uint256 productId, string name, string origin, address owner);
    event CheckpointAdded(uint256 productId, string location, string description);
    event ProductTransferred(uint256 productId, address from, address to);

    /**
     * @dev Initializes the contract by setting up roles.
     */
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(FARMER_ROLE, msg.sender);
        _grantRole(DISTRIBUTOR_ROLE, msg.sender);
        _grantRole(RETAILER_ROLE, msg.sender);
    }

    /**
     * @notice Adds a new product to the supply chain.
     * @param _name The name of the product.
     * @param _origin The origin of the product.
     * @param _organicCertified Boolean indicating if the product is organically certified.
     * @param _fairTradeCertified Boolean indicating if the product is fair-trade certified.
     */
    function addProduct(
        string memory _name,
        string memory _origin,
        bool _organicCertified,
        bool _fairTradeCertified
    ) external onlyRole(FARMER_ROLE) {
        uint256 productId = productIdCounter.current();
        products[productId] = Product({
            name: _name,
            origin: _origin,
            timestamp: block.timestamp,
            organicCertified: _organicCertified,
            fairTradeCertified: _fairTradeCertified,
            currentOwner: msg.sender
        });
        productIdCounter.increment();

        emit ProductCreated(productId, _name, _origin, msg.sender);
    }

    /**
     * @notice Adds a checkpoint to a product's journey.
     * @param _productId The ID of the product.
     * @param _location The location of the checkpoint.
     * @param _description A description of the checkpoint.
     */
    function addCheckpoint(
        uint256 _productId,
        string memory _location,
        string memory _description
    ) external onlyRole(DISTRIBUTOR_ROLE) {
        require(_productId < productIdCounter.current(), "Product does not exist.");

        Checkpoint memory newCheckpoint = Checkpoint({
            location: _location,
            description: _description,
            timestamp: block.timestamp
        });
        productCheckpoints[_productId].push(newCheckpoint);

        emit CheckpointAdded(_productId, _location, _description);
    }

    /**
     * @notice Transfers ownership of a product to another address.
     * @param _productId The ID of the product.
     * @param _to The address to transfer the product to.
     */
    function transferProduct(uint256 _productId, address _to) external {
        require(_productId < productIdCounter.current(), "Product does not exist.");
        require(products[_productId].currentOwner == msg.sender, "Only the current owner can transfer the product.");

        address previousOwner = products[_productId].currentOwner;
        products[_productId].currentOwner = _to;

        emit ProductTransferred(_productId, previousOwner, _to);
    }

    /**
     * @notice Retrieves product details by ID.
     * @param _productId The ID of the product.
     * @return name The name of the product.
     * @return origin The origin of the product.
     * @return timestamp The timestamp of the product's addition.
     * @return organicCertified Whether the product is organically certified.
     * @return fairTradeCertified Whether the product is fair-trade certified.
     * @return currentOwner The current owner of the product.
     */
    function getProduct(uint256 _productId)
        external
        view
        returns (
            string memory name,
            string memory origin,
            uint256 timestamp,
            bool organicCertified,
            bool fairTradeCertified,
            address currentOwner
        )
    {
        require(_productId < productIdCounter.current(), "Product does not exist.");
        Product memory product = products[_productId];
        return (
            product.name,
            product.origin,
            product.timestamp,
            product.organicCertified,
            product.fairTradeCertified,
            product.currentOwner
        );
    }

    /**
     * @notice Retrieves checkpoints for a product by ID.
     * @param _productId The ID of the product.
     * @return checkpoints Array of checkpoints.
     */
    function getCheckpoints(uint256 _productId)
        external
        view
        returns (Checkpoint[] memory checkpoints)
    {
        require(_productId < productIdCounter.current(), "Product does not exist.");
        return productCheckpoints[_productId];
    }
}
