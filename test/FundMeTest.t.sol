// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address SHOAIB = makeAddr("SHOAIB");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(SHOAIB, STARTING_BALANCE);
    }

    function testMinUscIsFiveDollars() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log("Owner: ", fundMe.I_OWNER());
        console.log("Msg Sender: ", msg.sender);
        assertEq(fundMe.I_OWNER(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        console.log("Version: ", version);
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // hey, the next line of code should revert!
        fundMe.fund(); // sending 0 eth value which is less than the minimum 5 USD
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(SHOAIB); // next tx will be sent by SHOAIB address
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(SHOAIB);
        assertEq(amountFunded, SEND_VALUE);
    }
}
