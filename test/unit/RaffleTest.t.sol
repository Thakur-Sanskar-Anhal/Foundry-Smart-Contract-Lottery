// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// imports
    import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
    import {Raffle} from "../../src/Raffle.sol";
    import {Test, console} from "forge-std/Test.sol";
    import {HelperConfig} from  "../../script/HelperConfig.s.sol";

// contracts
contract RaffleTest is Test{

// events
    event EnteredRaffle(address indexed player);

// State variables
    Raffle raffle ;
    HelperConfig helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callBackGasLimit;
    address linkToken;
    
    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

// functions
    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        ( entranceFee,
         interval,
         vrfCoordinator,
         gasLane,
         subscriptionId,
         callBackGasLimit,
         linkToken
          ) = helperConfig.activeNetworkConfig();
         vm.deal(PLAYER, STARTING_USER_BALANCE);
    }

// tests
    function testRaffleInitializesInOpenState() public view {
        assert (raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

// enter Raffle test functions
    function testRaffleRevertsWhenYouDontPayEnouigh() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector);
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }

    function testEmitsEventsOnEntrance() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    function testCantEnterWhenRaffleIsCalculating() public{
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }
}