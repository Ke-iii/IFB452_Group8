// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// Interface to retrieve batch data from FarmersBatchRegistration
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

contract ExportArrivalLogistics {
    address public owner;
    IFarmersBatchRegistration public farmerContract;

    constructor(address _farmerContractAddress) {
        owner = msg.sender;
        farmerContract = IFarmersBatchRegistration(_farmerContractAddress);
    }

    modifier onlyExporter() {
        require(msg.sender == owner, "Only verified exporter can log arrival");
        _;
    }

    // Struct to hold arrival details
    struct Arrival {
        uint256 batchId;
        string transportType;
        string originPort;
        string departureDate;
        string arrivalDate;
        string arrivalLocation;
        bool delayed;
        bool logged;
    }

    // Mapping batchId => Arrival info
    mapping(uint256 => Arrival) public arrivals;

    // Event emitted when arrival is logged
    event ArrivalLogged(
        uint256 batchId,
        string transportType,
        string originPort,
        string departureDate,
        string arrivalDate,
        string arrivalLocation,
        bool delayed,
        address exporter
    );

    /// @notice Log the arrival details of a coffee export batch
    function logArrival(
        uint256 _batchId,
        string memory _transportType,
        string memory _originPort,
        string memory _departureDate,
        string memory _arrivalDate,
        string memory _arrivalLocation,
        bool _delayed
    ) public onlyExporter {
        require(!arrivals[_batchId].logged, "Arrival already logged");
        require(_isValidBatchId(_batchId), "Batch ID not found in farmer contract");

        arrivals[_batchId] = Arrival({
            batchId: _batchId,
            transportType: _transportType,
            originPort: _originPort,
            departureDate: _departureDate,
            arrivalDate: _arrivalDate,
            arrivalLocation: _arrivalLocation,
            delayed: _delayed,
            logged: true
        });

        emit ArrivalLogged(
            _batchId,
            _transportType,
            _originPort,
            _departureDate,
            _arrivalDate,
            _arrivalLocation,
            _delayed,
            msg.sender
        );
    }

    /// @notice Get arrival log for a specific batch
    function getArrival(uint256 _batchId) public view returns (Arrival memory) {
        return arrivals[_batchId];
    }

    /// @dev Verifies that a batchId exists in the farmer registry
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