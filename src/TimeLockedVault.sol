// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

contract VaultLock{
    error Depositzero();
    error PastTime();
    error NoDeposit();
    error NoMaturity();

    struct Vault{
        uint amount;
        uint time;
    }
    mapping(address => Vault) public vaults;




    function deposit(uint _time) public payable  {
        if(msg.value==0 ) revert Depositzero();
        if(_time==0) revert PastTime();
        
    vaults[msg.sender].amount += msg.value;
    if (vaults[msg.sender].time > block.timestamp) {
    vaults[msg.sender].time += _time * 1 days;
} else {
    vaults[msg.sender].time = block.timestamp + (_time * 1 days);
}

        
    
    }

    function withdraw() public returns (bool){
        if (block.timestamp<= vaults[msg.sender].time ) revert NoMaturity();
        if(vaults[msg.sender].amount ==0 ) revert NoDeposit ();
        uint amountToWithdraw = vaults[msg.sender].amount;
        vaults[msg.sender].amount = 0 ;
        vaults[msg.sender].time = 0;

        (bool success,) = msg.sender.call{value: amountToWithdraw}("");
        require(success,"Transfer failed");
return true;
    }


}