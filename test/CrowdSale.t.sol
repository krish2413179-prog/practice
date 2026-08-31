// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {CrowdSale} from "../src/CrowdSale.sol";
import {MyToken} from "../src/MyToken.sol";

contract CrowdSaleTest is Test {
    CrowdSale public crowdsale;
    MyToken public token;

    address public owner;
    address public alice = address(0x1);
    address public bob = address(0x2);

    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10**18; // 1M Tokens
    uint256 public constant RATE = 1000;

    function setUp() public {
        owner = address(this);

        // 1. Deploy Crowdsale first
        // We pass address(0) temporarily or deploy Token first.
        // Option: Deploy Token minting to address(this), then transfer to Crowdsale.
        token = new MyToken(address(this), INITIAL_SUPPLY);

        // 2. Deploy CrowdSale contract with Token address
        crowdsale = new CrowdSale(address(token));

        // 3. Fund Crowdsale with total token supply
        token.transfer(address(crowdsale), INITIAL_SUPPLY);

        // 4. Fund test accounts with ETH
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }


    function test_InitialSetup() public view {
        assertEq(crowdsale.owner(), address(this), "Owner should be test contract");
        assertEq(address(crowdsale.token()), address(token), "Token address mismatch");
        assertEq(
            token.balanceOf(address(crowdsale)),
            INITIAL_SUPPLY,
            "Crowdsale should hold 1,000,000 DEVT tokens"
        );
    }


    function test_OwnerCanWhitelist() public {
        crowdsale.whitelist(alice, 1); // Tier 1 (VIP - 5 ETH Cap)

        (uint256 tier, ) = crowdsale.details(alice);
        assertEq(tier, 1, "Alice should be Tier 1");
    }

    function test_RevertIf_NonOwnerWhitelists() public {
        vm.prank(bob);
        vm.expectRevert(CrowdSale.NotOwner.selector);
        crowdsale.whitelist(alice, 1);
    }

    function test_RevertIf_InvalidTier() public {
        vm.expectRevert(CrowdSale.InvalidTier.selector);
        crowdsale.whitelist(alice, 4); // Max tier is 3
    }


    function test_BuyTokensSuccess() public {
        // Whitelist Alice as Tier 1 (5 ETH cap)
        crowdsale.whitelist(alice, 1);

        uint256 depositAmount = 2 ether;
        uint256 expectedTokens = depositAmount * RATE; // 2000 DEVT tokens (2000 * 10^18)

        // Alice registers with 2 ETH
        vm.prank(alice);
        crowdsale.register{value: depositAmount}();

        // A. Verify Alice's contract contribution state
        (, uint256 totalContributed) = crowdsale.details(alice);
        assertEq(totalContributed, depositAmount, "Alice contribution should be 2 ETH");

        // B. Verify Alice received the exact ERC-20 token payout
        assertEq(
            token.balanceOf(alice),
            expectedTokens,
            "Alice should have received 2000 DEVT tokens"
        );

        // C. Verify Crowdsale token vault decreased by exact payout
        assertEq(
            token.balanceOf(address(crowdsale)),
            INITIAL_SUPPLY - expectedTokens,
            "Crowdsale token balance should decrease by 2000 DEVT"
        );
    }

    function test_MultipleDepositsAccumulateTokensAndContribution() public {
        // Whitelist Alice as Tier 1 (5 ETH Cap)
        crowdsale.whitelist(alice, 1);

        // First deposit: 2 ETH -> 2000 DEVT
        vm.prank(alice);
        crowdsale.register{value: 2 ether}();

        // Second deposit: 3 ETH -> 3000 DEVT (Total: 5 ETH cap reached)
        vm.prank(alice);
        crowdsale.register{value: 3 ether}();

        // Check total accumulated tokens = 5000 DEVT
        assertEq(token.balanceOf(alice), 5000 * 10**18, "Alice should have 5000 DEVT");

        // Third deposit: 0.1 ETH -> Exceeds 5 ETH tier cap!
        vm.expectRevert(
            abi.encodeWithSelector(
                CrowdSale.ExceedsTierCap.selector,
                5 ether,    // Max Cap for Tier 1
                5.1 ether  // Attempted Total
            )
        );
        vm.prank(alice);
        crowdsale.register{value: 0.1 ether}();
    }


    function test_RevertIf_NotWhitelisted() public {
        // Bob is Tier 0 (Unwhitelisted)
        vm.expectRevert(CrowdSale.NotWhitelisted.selector);
        vm.prank(bob);
        crowdsale.register{value: 1 ether}();
    }

    function test_RevertIf_ZeroDeposit() public {
        crowdsale.whitelist(alice, 1);

        vm.expectRevert(CrowdSale.ZeroDeposit.selector);
        vm.prank(alice);
        crowdsale.register{value: 0}();
    }
}