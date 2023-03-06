# Stake DAO Contract - Documentation

This is the documentation for the task assigned for writing a staking smart contract and a DAO structure for voting on staking period and reward etc.

## Important Methods

- stake

  Let's the user stake their tokens (see StakeToken.sol).

- withdraw

  Let's a staker withdraw their staked tokens upon completion of the staking period and claiming their rewards.

- claimReward

  Let's a staker claim their rewards without withdrawing their stake for future rewards.

- userStake

  Getter function for viewing the amount of staked tokens for a particular staker.

- voteUp

  Function to vote in 'favor" by a staker if a proposal is currently running.

- voteDown

  Function to vote in "denial" by a staker if a proposal is currently running.

- startProposalToChangeStakingPeriod

  The "Owner" of the DAO can invoke this function to start a proposal to change the staking period. The stakers will vote on the proposal in Favor or Denial.

- endProposalToChangeStakingPeriod

  Function to end the ongoing proposal to change staking period. This will calculate the voting result and take the appropriate action based on votes.

- startProposalToChangeRewardRate

  The "Owner" of the DAO can invoke this function to start a proposal to change the reward rate for staking the tokens. The stakers will vote on the proposal in Favor or Denial.

- endProposalToChangeRewardRate

  Function to end the ongoing proposal to change reward rate. This will calculate the voting result and take the appropriate action based on votes.

## Testing

To test the StakeDAO contract, go to Remix IDE and import the contract from address `0xa8247bF0E819C63f4CAeE280Ab23F6d943a6B54f` and call the `stake` method. Before calling the main contract, you must issue tokens from the `StakingToken` contract and approve the
`StakeDAO` contract to spend the tokens.
