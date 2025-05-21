// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFarmersBatchRegistration {
    function getBatchCount() external view returns (uint256);
    function getBatch(uint256 index) external view returns (
        uint256,
        string memory,
        string memory,
        string memory,
        string memory,
        string memory,
        string memory
    );
}

contract ExportDepartureLogistics {
    address public owner;
    IFarmersBatchRegistration public farmerContract;

    constructor(address _farmerContractAddress) {
        owner = msg.sender;
        farmerContract = IFarmersBatchRegistration(_farmerContractAddress);
    }

    modifier onlyExporter() {
        require(msg.sender == owner, "Only verified exporter can log departure");
        _;
    }

    struct Departure {
        uint256 batchId;
        string transportType;
        string originPort;
        string departureDate;
        bool logged;
    }

    mapping(uint256 => Departure) public departures;

    event DepartureLogged(
        uint256 batchId,
        string transportType,
        string originPort,
        string departureDate,
        address exporter
    );

    function logDeparture(
        uint256 _batchId,
        string memory _transportType,
        string memory _originPort,
        string memory _departureDate
    ) public onlyExporter {
        require(!departures[_batchId].logged, "Departure already logged");
        require(_isValidBatchId(_batchId), "Batch ID not found in farmer contract");

        departures[_batchId] = Departure({
            batchId: _batchId,
            transportType: _transportType,
            originPort: _originPort,
            departureDate: _departureDate,
            logged: true
        });

        emit DepartureLogged(_batchId, _transportType, _originPort, _departureDate, msg.sender);
    }

    function getDeparture(uint256 _batchId) public view returns (Departure memory) {
        return departures[_batchId];
    }

    function _isValidBatchId(uint256 _batchId) internal view returns (bool) {
        uint256 count = farmerContract.getBatchCount();
        for (uint256 i = 0; i < count; i++) {
            (uint256 id,,,,,,) = farmerContract.getBatch(i);
            if (id == _batchId) {
                return true;
            }
        }
        return false;
    }
}