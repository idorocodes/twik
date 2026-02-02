#[test_only]
module twik::twik_tests {
    use std::unit_test::assert_eq;
    use sui::test_scenario;
    use sui::coin;
    use sui::sui::SUI;

    use twik::twik;

    // Helper: mint some SUI for testing
    #[test_only]
    fun mint_sui(ts: &mut test_scenario::Scenario, amount: u64): coin::Coin<SUI> {
        coin::mint_for_testing<SUI>(amount, ts.ctx())
    }

    #[test]
    fun test_create_and_contribute_and_withdraw() {
        // Start a multi‑tx scenario with a mock address
        let addr = @0xA;
        let mut scenario = test_scenairo::begin(addr);

        // === Tx 1: create campaign ===
        {
            twik::create_campaign(
                b"Test".to_string(),
                b"Desc".to_string(),
                10_000_000, // target
                scenario.ctx(),
            );
        };

        // Get the created objects from the sender
        let (mut campaign, mut cap) =
            scenario.take_from_sender<twik::Campaign, twik::WithdrawCap>();

        // === Tx 2: contribute ===
        scenario.next_tx(addr);
        {
            let coin = mint_sui(&mut scenario, 2_000_000);
            twik::contribute(&mut campaign, coin, scenario.ctx());
        };

        // Check collected_amount updated
        assert_eq!(campaign.collected_amount, 2_000_000);

        // === Tx 3: withdraw ===
        scenario.next_tx(addr);
        {
            twik::withdraw(&mut cap, &mut campaign, scenario.ctx());
        };

        // End scenario (required cleanup)
        scenario.end();
    }
}