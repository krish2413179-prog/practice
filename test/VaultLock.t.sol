pragma solidity 0.8.20;
import {Test, console} from "forge-std/Test.sol";
import {VaultLock} from "../src/TimeLockedVault.sol";

contract VaultLockTest is Test{
    VaultLock public vault;
    address public alice = address(0x1);
    address public bob = address(0x2);


    function setUp()  public  {
        vault = new VaultLock();
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function test_Deposit() public {
        vm.prank(alice);
        vault.deposit{value: 2 ether}(5);
        (uint256 amount, uint256 time) = vault.vaults(alice);
        assertEq(amount, 2 ether, "Amount locked should be 2 ETH");
        assertEq(time, block.timestamp + 5 days, "Unlock time should be 5 days out");

    }

    function test_RevertIf_WithdrawTooEarly() public {

        vm.prank(alice);
        vault.deposit{value:1 ether}(5);

        vm.warp(block.timestamp + 2 days);

        vm.expectRevert(VaultLock.NoMaturity.selector);
vm.prank(alice);

vault.withdraw();

    }
    function test_WithdrawAfterMaturity() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}(5);

        
        vm.warp(block.timestamp + 6 days);

       
        vm.prank(alice);
        vault.withdraw();

        
        (uint256 amount, ) = vault.vaults(alice);
        assertEq(amount, 0, "Vault balance should be reset");
    }

}