// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// imports
    import {Script} from "forge-std/Script.sol";
    import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
    import {LinkToken} from "../test/mocks/LinkToken.sol";

// contracts
contract HelperConfig is Script {

// Structure
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator; 
        bytes32 gasLane;
        uint64 subscriptionId; 
        uint32 callBackGasLimit;
        address link;
    }

// global declaration
    NetworkConfig public activeNetworkConfig;

// Constructor
    constructor(){
        if (block.chainid == 11155111 ){
            activeNetworkConfig = getSepoliaEthConfig();
        }else {
            activeNetworkConfig = gtOrCreateAnvilConfig();
        }
    }

// functions
    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0,
            callBackGasLimit: 500000,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    function gtOrCreateAnvilConfig() public returns(NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoordinator != address(0)){
            return activeNetworkConfig;
        }

        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;

        vm.startBroadcast();
            VRFCoordinatorV2Mock vrfCoordinatorV2Mock = new VRFCoordinatorV2Mock(baseFee,gasPriceLink);
            LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();

        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorV2Mock),
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0,
            callBackGasLimit: 500000,
            link: address(linkToken)
        });
    }
}