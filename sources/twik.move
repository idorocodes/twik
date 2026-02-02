module twik::twik;

use std::string::String;
use sui::balance::{Self, Balance};
use sui::coin::{Self, Coin};
use sui::sui::SUI;
use sui::transfer:: public_transfer;
use sui::transfer;

const EInvalidOwner: u64 = 3;
const EInvalidAmount: u64 = 2;
const ETargetReached :u64 = 5;

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

public  entry  fun create_campaign(
    name: String,
    description: String,
    target_amount: u64,
    ctx: &mut TxContext,
) {
    let campaign_object = Campaign {
        id: object::new(ctx),
        name,
        description,
        campaign_pool: balance::zero(),
        creator: tx_context::sender(ctx),
        target_amount,
        collected_amount: 0,
        contributors: vector[],
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
    let contribution_part = coin::split(contribution, amount, ctx); 
    assert!(campaign.collected_amount < campaign.target_amount, ETargetReached);

    balance::join(&mut campaign.campaign_pool, coin::into_balance(contribution_part));
    campaign.collected_amount = campaign.collected_amount + amount;

    let contributor = tx_context::sender(ctx);
    vector::push_back(&mut campaign.contributors, contributor);
}

public entry fun withdraw(_: &mut WithdrawCap, campaign: &mut Campaign, ctx: &mut TxContext) {

    assert!(tx_context::sender(ctx) == campaign.creator, EInvalidOwner);

    let campaign_funds = campaign.campaign_pool.value();

    let coin = coin::take(&mut campaign.campaign_pool, campaign_funds, ctx);

    public_transfer(coin, campaign.creator);
}
