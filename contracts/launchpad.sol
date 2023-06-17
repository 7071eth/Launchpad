// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract IDOContract {
    address contractAdd;
    struct Participant {
        uint256 depositedAmount;
        uint256 tokensClaimed;
        bool tokensClaimedFlag;
    }

    mapping(address => Participant)  participants;
    IERC20 public tokenContract;

    address payable owner;

    uint256 public totalIDOSupply;

    event Deposit(address indexed participant, uint256 usdtAmount, uint256 tokenAllocation);
    event ClaimTokens(address indexed participant, uint256 amount);

    constructor(address _tokenContractAddress, uint256 _totalIDOSupply) {
        contractAdd = address(this);
        tokenContract = IERC20(_tokenContractAddress);
        totalIDOSupply = _totalIDOSupply;
        
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");

        participants[msg.sender].depositedAmount += msg.value;
        participants[msg.sender].tokensClaimedFlag = false;

        emit Deposit(msg.sender, msg.value, calculateTokenAllocation(msg.value));
    }

     function idoBal() public view returns(uint256) {
        return(tokenContract.balanceOf(contractAdd));
    }

    function claimTokens() external {
        Participant storage participant = participants[msg.sender];
        require(participant.depositedAmount > 0, "No deposited amount found");
        require(!participant.tokensClaimedFlag, "Tokens already claimed");

        uint256 tokensToClaim = participant.tokensClaimed += calculateTokenAllocation(participant.depositedAmount);
        require(tokensToClaim > 0, "No tokens available for claim");

        participant.tokensClaimedFlag = true;
        participant.depositedAmount = 0;

        require(tokenContract.transfer(msg.sender, tokensToClaim), "Token transfer failed");

        emit ClaimTokens(msg.sender, tokensToClaim);
    }

    function calculateTokenAllocation(uint256 usdtAmount) public pure returns (uint256) {
        // Define your token allocation logic here
        // Example: For every 1 USDT, user receives 1 ERC20 token
        return usdtAmount;
    }

    function getParticipant(address participant) external view returns (uint256 depositedAmount, uint256 tokensClaimed, bool tokensClaimedFlag) {
        depositedAmount = participants[participant].depositedAmount;
        tokensClaimed = participants[participant].tokensClaimed;
        tokensClaimedFlag = participants[participant].tokensClaimedFlag;
    }

    function getTotalIDOSupply() external view returns (uint256) {
        return totalIDOSupply;
    }
}
