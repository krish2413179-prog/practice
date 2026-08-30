// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract CrowdSale {
    error NotOwner();
    error ZeroDeposit();
    error NotWhitelisted();
    error InvalidTier();
    error ExceedsTierCap(uint256 maxAllowed, uint256 currentTotal);

    address public owner;

    // Tier caps in wei
    uint256 public constant TIER_1_CAP = 5 ether;
    uint256 public constant TIER_2_CAP = 2 ether;
    uint256 public constant TIER_3_CAP = 0.5 ether;

    struct Detail {
        uint256 tier;
        uint256 amount;
    }

    mapping(address => Detail) public details;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    function whitelist(address _user, uint256 _tier) external onlyOwner {
        if (_tier > 3) revert InvalidTier();
        details[_user].tier = _tier;
    }

    function getTierCap(uint256 _tier) public pure returns (uint256) {
        if (_tier == 1) return TIER_1_CAP;
        if (_tier == 2) return TIER_2_CAP;
        if (_tier == 3) return TIER_3_CAP;
        return 0;
    }

    function register() external payable {
        if (msg.value == 0) revert ZeroDeposit();

        Detail storage userDetail = details[msg.sender];

        if (userDetail.tier == 0) revert NotWhitelisted();

        uint256 maxCap = getTierCap(userDetail.tier);
        uint256 newTotal = userDetail.amount + msg.value;

        if (newTotal > maxCap) revert ExceedsTierCap(maxCap, newTotal);

        // Accumulate deposit amount
        userDetail.amount = newTotal;
    }
}