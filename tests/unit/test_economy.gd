extends TestCase
## Coins, purchases and the satchel upgrade (GameState economy).

var satchel_upgrade: UpgradeData


func before_each() -> void:
	GameState.new_game()
	satchel_upgrade = GameDB.upgrade(&"expanded_satchel")


func after_each() -> void:
	GameState.new_game()


func test_earning_adds_coins_and_tracks_the_total() -> void:
	assert_true(GameState.earn(12))
	assert_true(GameState.earn(5))
	assert_eq(GameState.coins, 17)
	assert_eq(GameState.stats.coins_earned, 17)


func test_non_positive_earnings_are_rejected() -> void:
	assert_false(GameState.earn(0))
	assert_false(GameState.earn(-5))
	assert_eq(GameState.coins, 0)


func test_spending_more_than_owned_fails_without_changes() -> void:
	GameState.earn(10)
	assert_false(GameState.spend(11))
	assert_eq(GameState.coins, 10)
	assert_true(GameState.spend(10))
	assert_eq(GameState.coins, 0)


func test_buying_the_satchel_charges_once_and_expands_capacity() -> void:
	GameState.earn(satchel_upgrade.cost + 7)
	assert_true(GameState.buy_upgrade(satchel_upgrade))
	assert_eq(GameState.coins, 7)
	assert_true(GameState.owns_upgrade(&"expanded_satchel"))
	assert_eq(GameState.satchel.capacity, GameState.BASE_SATCHEL_CAPACITY + satchel_upgrade.satchel_bonus)
	assert_false(GameState.buy_upgrade(satchel_upgrade), "cannot buy twice")
	assert_eq(GameState.coins, 7, "no second charge")


func test_buying_without_enough_coins_changes_nothing() -> void:
	GameState.earn(satchel_upgrade.cost - 1)
	assert_false(GameState.buy_upgrade(satchel_upgrade))
	assert_eq(GameState.coins, satchel_upgrade.cost - 1)
	assert_false(GameState.owns_upgrade(&"expanded_satchel"))
	assert_eq(GameState.satchel.capacity, GameState.BASE_SATCHEL_CAPACITY)


func test_coins_always_equal_earned_minus_spent() -> void:
	GameState.earn(40)
	GameState.spend(15)
	GameState.spend(100)
	GameState.earn(3)
	assert_eq(GameState.coins, GameState.stats.coins_earned - GameState.stats.coins_spent)


func test_new_game_resets_coins_upgrades_and_opening_state() -> void:
	GameState.earn(200)
	GameState.buy_upgrade(satchel_upgrade)
	GameState.set_tavern_open(true)
	GameState.new_game()
	assert_eq(GameState.coins, 0)
	assert_false(GameState.owns_upgrade(&"expanded_satchel"))
	assert_eq(GameState.satchel.capacity, GameState.BASE_SATCHEL_CAPACITY)
	assert_false(GameState.tavern_open)


func test_the_upgrade_is_affordable_within_a_short_session() -> void:
	# design constraint: a handful of served dishes, not a grind
	assert_true(satchel_upgrade.cost <= 80, "cost %d" % satchel_upgrade.cost)
	assert_true(satchel_upgrade.satchel_bonus >= 6, "bonus %d must be noticeable" % satchel_upgrade.satchel_bonus)
