//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract NFTStakingFactory {
    struct ProtocolDetails {
        string Name;
        string Description;
        address owner;
    }

    mapping(address => ProtocolDetails) addressList;

    constructor() public {}

    /// @notice function to add a new contract supporting the configuration
    function createNewProtocolSupport(
        address _targetInteractionContract,
        string calldata Name,
        string calldata Description,
        address owner
    ) public {
        ProtocolDetails memory protocol = ProtocolDetails(
            Name,
            Description,
            owner
        );
        addressList[_targetInteractionContract] = protocol;
    }

    /// @notice update protocol details
    function updateProtocolDeatails(
        address _targetInteractionContract,
        string calldata Name,
        string calldata Description,
        address owner
    ) public {
        require(
            addressList[_targetInteractionContract].owner == msg.sender,
            "Not the owner of the contract"
        );
        ProtocolDetails storage protocol = addressList[
            _targetInteractionContract
        ];
        protocol.owner = owner;
        protocol.Name = Name;
        protocol.Description = Description;
    }
}
