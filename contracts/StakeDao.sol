// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error Staking__TransferFailed();
error Withdraw__TransferFailed();
error Staking__NeedsMoreThanZero();

contract StakeDao is ReentrancyGuard, Ownable {
    event Vote_Cast(address voter, string voteType);

    IERC20 public STAKING_TOKEN;
    IERC20 public REWARD_TOKEN;

    string public daoName = "Stake Dao";
    uint256 public stakingPeriod = 604800;
    uint256 public rewardRate = 50;
    uint256 public totalStaked;
    uint256 public s_rewardPerTokenStored;
    uint256 public s_lastUpdateTime;
    bool public proposal = false;
    uint256 public votesInFavor;
    uint256 public votesInDenial;
    uint256 public proposedRewardRate = 0;
    uint256 public proposedStakingPeriod = 0;

    mapping(address => uint256) public stakeTime;
    mapping(address => uint256) public balance;
    mapping(address => uint256) public s_userRewardPerTokenPaid;
    mapping(address => uint256) public s_rewards;

    modifier updateReward(address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;

        _;
    }

    constructor(address st, address rt) {
        STAKING_TOKEN = IERC20(st);
        REWARD_TOKEN = IERC20(rt);
    }

    function earned(address account) public view returns (uint256) {
        uint256 currentBalance = balance[account];
        uint256 amountPaid = s_userRewardPerTokenPaid[account];
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 pastRewards = s_rewards[account];
        uint256 _earned = ((currentBalance *
            (currentRewardPerToken - amountPaid)) / 1e18) + pastRewards;

        return _earned;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return s_rewardPerTokenStored;
        } else {
            return
                s_rewardPerTokenStored +
                (((block.timestamp - s_lastUpdateTime) * rewardRate * 1e18) /
                    totalStaked);
        }
    }

    function stake(uint256 amount) external updateReward(msg.sender) {
        balance[msg.sender] += amount;
        totalStaked += amount;
        stakeTime[msg.sender] = block.timestamp;
        bool success = STAKING_TOKEN.transferFrom(
            msg.sender,
            address(this),
            amount
        );

        if (!success) {
            revert Staking__TransferFailed();
        }
    }

    function withdraw(uint256 amount) external updateReward(msg.sender) {
        require(
            (block.timestamp - stakeTime[msg.sender]) > stakingPeriod,
            "Staking period is not over yet."
        );
        balance[msg.sender] -= amount;
        totalStaked -= amount;
        bool success = STAKING_TOKEN.transfer(msg.sender, amount);
        if (!success) {
            revert Withdraw__TransferFailed();
        }
    }

    function claimReward() external updateReward(msg.sender) {
        require(
            (block.timestamp - stakeTime[msg.sender]) > stakingPeriod,
            "Staking period is not over yet."
        );
        uint256 reward = s_rewards[msg.sender];
        bool success = REWARD_TOKEN.transfer(msg.sender, reward);
        if (!success) {
            revert Staking__TransferFailed();
        }
    }

    function userStake(address account) public view returns (uint256) {
        return balance[account];
    }

    function voteUp() public {
        require(proposal == true, "Proposal Not Initiated!");
        require(balance[msg.sender] > 0);
        votesInFavor += 1;
        emit Vote_Cast(msg.sender, "In Favor");
    }

    function voteDown() public {
        require(proposal == true, "Proposal Not Initiated!");
        require(balance[msg.sender] > 0);
        votesInDenial -= 1;
        emit Vote_Cast(msg.sender, "In Denial");
    }

    function startProposalToChangeStakingPeriod(uint256 proposedstakingperiod)
        public
        onlyOwner
    {
        require(proposal == false, "Proposal Already In Progress!");
        proposal = true;
        proposedStakingPeriod = proposedstakingperiod;
    }

    function endProposalToChangeStakingPeriod()
        public
        onlyOwner
        returns (string memory)
    {
        require(proposal == true, "Proposal Not Initiated!");
        proposal = false;
        votesInFavor = 0;
        votesInDenial = 0;
        if (votesInFavor > votesInDenial) {
            stakingPeriod = proposedStakingPeriod;
            return "Proposal to change staking period passed!";
        } else {
            return "Proposal to change staking period denied!";
        }
    }

    function startProposalToChangeRewardRate(uint256 proposedrewardrate)
        public
        onlyOwner
    {
        require(proposal == false, "Proposal Already In Progress!");
        proposal = true;
        proposedRewardRate = proposedrewardrate;
    }

    function endProposalToChangeRewardRate()
        public
        onlyOwner
        returns (string memory)
    {
        require(proposal == true, "Proposal Not Initiated!");
        proposal = false;
        votesInFavor = 0;
        votesInDenial = 0;
        if (votesInFavor > votesInDenial) {
            rewardRate = proposedRewardRate;
            return "Proposal to change staking period passed!";
        } else {
            return "Proposal to change staking period denied!";
        }
    }
}
