// SPDX-License-Identifier: MIT // this tells the license we're using
pragma solidity ^0.8.20; // using solidity version 0.8.20

// this interface lets us read from the farmers contract
interface IFarmersBatchRegistration {
    function getBatchCount() external view returns (uint256); // gets the total number of batches
    function getBatch(uint256 index) external view returns ( // gets 1 batch's info by index
        uint256, // the batch id
        string memory, // certification
        string memory, // harvest date
        string memory, // location
        string memory, // farm name
        string memory, // practices
        string memory // export company
    );
}

// main contract that exporter uses to log info when coffee leaves the country
contract ExportDepartureLogistics {
    address public owner; // this is the address of the exporter (who deployed contract)
    IFarmersBatchRegistration public farmerContract; // link to the farmer contract so we can check batch ID

    constructor(address _farmerContractAddress) {
        owner = msg.sender; // whoever deploys this contract becomes the owner/exporter
        farmerContract = IFarmersBatchRegistration(_farmerContractAddress); // saves the farmer contract so we can read from it
    }

    // this makes sure only the exporter (owner) can call certain functions
    modifier onlyExporter() {
        require(msg.sender == owner, "Only verified exporter can log departure"); // stops other people from calling it
        _; // continues with the rest of the function if check passed
    }

    // this struct stores all the info about a departure
    struct Departure {
        uint256 batchId; // the id of the batch
        string transportType; // like 'sea' or 'air'
        string originPort; // where the coffee left from
        string departureDate; // date when it was shipped
        bool logged; // true if it was already logged
    }

    // a mapping that stores all the departures, matched by their batch id
    mapping(uint256 => Departure) public departures;

    // this is an event we emit to keep track when a departure is logged
    event DepartureLogged(
        uint256 batchId,
        string transportType,
        string originPort,
        string departureDate,
        address exporter
    );

    // main function the exporter calls to log when a batch departs
    function logDeparture(
        uint256 _batchId,
        string memory _transportType,
        string memory _originPort,
        string memory _departureDate
    ) public onlyExporter { // only the exporter can log this
        require(!departures[_batchId].logged, "Departure already logged"); // stops duplicate logging
        require(_isValidBatchId(_batchId), "Batch ID not found in farmer contract"); // checks the farmer contract to see if the batch is real

        // saves the info into the mapping
        departures[_batchId] = Departure({
            batchId: _batchId,
            transportType: _transportType,
            originPort: _originPort,
            departureDate: _departureDate,
            logged: true
        });

        // lets frontend or listener know that something was logged
        emit DepartureLogged(_batchId, _transportType, _originPort, _departureDate, msg.sender);
    }

    // lets anyone look up the departure info for a batch id
    function getDeparture(uint256 _batchId) public view returns (Departure memory) {
        return departures[_batchId];
    }

    // checks with the farmer contract if a batch id is valid
    function _isValidBatchId(uint256 _batchId) internal view returns (bool) {
        uint256 count = farmerContract.getBatchCount(); // how many batches there are
        for (uint256 i = 0; i < count; i++) { // loop through them all
            (uint256 id,,,,,,) = farmerContract.getBatch(i); // only need the batch id
            if (id == _batchId) { // if it matches
                return true; // it's valid
            }
        }
        return false; // not found, so invalid
    }
}
