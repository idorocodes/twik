

# Twik – Web3 Crowdfunding Protocol on Sui

**Description:**
Twik is a simple Web3 crowdfunding platform on Sui. Creators launch campaigns, donors contribute funds, and creators withdraw once the funding goal is reached. All transactions are on-chain, safe, and trackable.


## Features

* **Create Campaigns** – Launch a crowdfunding campaign with a funding goal.
* **Donate** – Contributors send SUI to campaigns.
* **Withdraw** – Creators withdraw funds once the goal is reached.
* **Check Status** – Anyone can query whether a campaign is Active, Funded, or Closed.


## Objects & Structure

### 1. `Campaign`

Holds the campaign details and collected funds.

**Fields:**

* `id: u64` – Unique campaign identifier
* `name: vector<u8>` – Campaign title
* `description: vector<u8>` – Campaign description
* `creator: address` – Creator’s address
* `target_amount: u64` – Funding goal
* `collected_amount: u64` – Total donated
* `contributors: vector<address>` – List of donor addresses
* `status: u8` – 0 = Active, 1 = Funded, 2 = Closed

### 2. `WithdrawCap`

Capability object allowing only the creator to withdraw funds.

**Fields:**

* `campaign_id: u64` – Links to the Campaign object
* `owner: address` – Owner of the capability


## Functions

1. **create_campaign(creator, name, description, target_amount, id)**

   * Creates a new campaign and a `WithdrawCap` for the creator

2. **donate(donor, campaign, amount)**

   * Add a donor and increment collected amount
   * Auto-update status to Funded if goal reached

3. **withdraw(creator, campaign, cap)**

   * Transfer funds to creator if goal is reached
   * Close campaign and destroy `WithdrawCap`

4. **check_status(campaign)**

   * Returns `Active`, `Funded`, or `Closed`


## Quick Start 

1. Deploy `Campaign` and `WithdrawCap` via `create_campaign`.
2. Donate to the campaign with `donate`.
3. Check status anytime with `check_status`.
4. Creator withdraws with `withdraw` once funded.


## Example

**Campaign:**

* Name: `Save Developers from vibecoders`
* Description: `Contribte to arrest people who sit and tell an ai agent to build a full app/website from scratch, without making any misakes.`
* Target: `11000 SUI`

**Flow:**

1. Idorocodes creates Save developers from vibecoders campaign
2. Rex donates 200 SUI
3. Amos donates 300 SUI
4. Idorocodes withdraws once 11000 SUI is reached
