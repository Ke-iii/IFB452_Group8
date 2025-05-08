// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract FarmersBatchRegistration {
    using Strings for uint256;
    
    address public owner;
    uint256 public batchIdCounter = 1; // Start from 1
    mapping(bytes32 => bool) public validCertifications;
    FarmerBatch[] public batches;

    struct FarmerBatch {
        uint256 batchId;
        string certification;
        string harvestDate;
        string location;
        string farmName;
        string practices;
        string exportCompany;
    }

    event BatchRegistered(
        uint256 indexed batchId,
        string certification,
        string harvestDate,
        string location,
        string farmName,
        string practices,
        string exportCompany
    );

    // only owner can access
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addCertification(string memory _certification) public onlyOwner {
        bytes32 certHash = keccak256(abi.encodePacked(_certification));
        validCertifications[certHash] = true;
    }

    function removeCertification(string memory _certification) public onlyOwner {
        bytes32 certHash = keccak256(abi.encodePacked(_certification));
        validCertifications[certHash] = false;
    }

    function registerBatch(
        string memory _certification,
        string memory _harvestDate,
        string memory _location,
        string memory _farmName,
        string memory _practices,
        string memory _exportCompany
    ) public {
        bytes32 certHash = keccak256(abi.encodePacked(_certification));
        require(validCertifications[certHash], "Invalid certification");

        uint256 newBatchId = batchIdCounter;
        batchIdCounter++;

        batches.push(FarmerBatch(
            newBatchId,
            _certification,
            _harvestDate,
            _location,
            _farmName,
            _practices,
            _exportCompany
        ));

        emit BatchRegistered(
            newBatchId,
            _certification,
            _harvestDate,
            _location,
            _farmName,
            _practices,
            _exportCompany
        );
    }

    function getBatchCount() public view returns (uint256) {
        return batches.length;
    }

    function getBatch(uint256 index) public view returns (
        uint256 batchId,
        string memory certification,
        string memory harvestDate,
        string memory location,
        string memory farmName,
        string memory practices,
        string memory exportCompany
    ) {
        require(index < batches.length, "Invalid index");
        FarmerBatch memory batch = batches[index];
        return (
            batch.batchId,
            batch.certification,
            batch.harvestDate,
            batch.location,
            batch.farmName,
            batch.practices,
            batch.exportCompany
        );
    }

}