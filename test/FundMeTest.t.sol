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

    modifier Funded() {
        vm.prank(SHOAIB);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

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
        console.log("Owner: ", fundMe.getOwner());
        console.log("Msg Sender: ", msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
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

    function testAddsFunderToArrayOfFunders() public Funded {
        address funder = fundMe.getFunder(0);
        address expected = SHOAIB;
        assertEq(funder, expected);
    }

    function testOnlyOwnerCanWithdraw() public Funded {
        vm.prank(SHOAIB);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public Funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public Funded {
        // Arrange

        // why there uint160?
        // we are using uint160 because addresses in Ethereum are 160 bits long,
        // and we want to create multiple unique addresses for our funders.
        // By using uint160, we can easily generate a range of addresses by incrementing the value,
        // ensuring that each funder has a distinct address to interact with the FundMe contract.
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // we will start from 1 because 0 is already used by SHOAIB in the Funded modifier

        // `hoaz` setups the next tx to be from a new address and gives that address some ether
        // `hoax` is a combination of `prank` and `deal`
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }
}
