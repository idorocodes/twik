module twik::twik;

use std::string::String;
use sui::balance::{Self, Balance};
use sui::coin::{Self, Coin};
use sui::sui::SUI;
use sui::transfer::public_transfer;

const EInvalidOwner: u64 = 3;
const EInvalidAmount: u64 = 2;
const ETargetReached: u64 = 5;
const ETargetNotReached: u64 = 7;

const MIN_DONATION: u64 = 1_000_000; // 0.001 SUI

public struct Campaign has key, store {
    id: UID,
    name: String,
    description: String,
    creator: address,
    campaign_pool: Balance<SUI>,
    target_amount: u64,
    collected_amount: u64,
    contributors: vector<address>,
}

public struct WithdrawCap has key {
    id: UID,
    campaign_id: ID,
    owner: address,
}

public entry fun create_campaign(
    name: String,
    description: String,
    target_amount: u64,
    ctx: &mut TxContext,
) {
    assert!(target_amount >= MIN_DONATION, EInvalidAmount);
    let campaign_object = Campaign {
        id: object::new(ctx),
        name,
        description,
        campaign_pool: balance::zero(),
        creator: tx_context::sender(ctx),
        target_amount,
        collected_amount: 0,
        contributors: vector::empty(),
    };

    let withdraw_cap = WithdrawCap {
        id: object::new(ctx),
        campaign_id: object::id(&campaign_object),
        owner: tx_context::sender(ctx),
    };

    transfer::share_object(campaign_object);
    transfer::transfer(withdraw_cap, tx_context::sender(ctx))
}

public entry fun contribute(
    campaign: &mut Campaign,
    contribution: &mut Coin<SUI>,
    amount: u64,
    ctx: &mut TxContext,
) {
    assert!(amount >= MIN_DONATION, EInvalidAmount);

    assert!(campaign.collected_amount < campaign.target_amount, ETargetReached);

    assert!(campaign.collected_amount + amount <= campaign.target_amount, ETargetReached);
    let remaining_amount = campaign.target_amount - campaign.collected_amount;
    assert!(amount <= remaining_amount, EInvalidAmount);
    assert!(coin::value(contribution) >= amount, EInvalidAmount);

    let contribution_part = coin::split(contribution, amount, ctx);

    balance::join(&mut campaign.campaign_pool, coin::into_balance(contribution_part));
    campaign.collected_amount = campaign.collected_amount + amount;

    let contributor = tx_context::sender(ctx);

    let check_contributor = vector::contains(&campaign.contributors, &contributor);

    if (!check_contributor) {
        vector::push_back(&mut campaign.contributors, contributor);
    };
}

public entry fun withdraw(
    withdraw_cap: &mut WithdrawCap,
    campaign: &mut Campaign,
    ctx: &mut TxContext,
) {
    assert!(withdraw_cap.campaign_id == object::id(campaign), EInvalidOwner);
    assert!(withdraw_cap.owner == tx_context::sender(ctx), EInvalidOwner);
    assert!(tx_context::sender(ctx) == campaign.creator, EInvalidOwner);
    assert!(campaign.collected_amount == campaign.target_amount, ETargetNotReached);

    let campaign_funds = campaign.campaign_pool.value();

    let coin = coin::take(&mut campaign.campaign_pool, campaign_funds, ctx);

    public_transfer(coin, campaign.creator);
   
}

public entry fun delete_withdraw(withdraw_cap: WithdrawCap, ctx:&mut TxContext) {
     assert!(withdraw_cap.owner == tx_context::sender(ctx), EInvalidOwner);
    let WithdrawCap { id, ..} = withdraw_cap;
    object::delete(id);
}
