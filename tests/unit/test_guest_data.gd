extends TestCase
## Integrity of the two guest archetypes.


func test_slice_has_two_distinct_guest_archetypes() -> void:
	var guests := GameDB.guests()
	assert_eq(guests.size(), 2)
	assert_ne(guests[0].id, guests[1].id)
	assert_ne(guests[0].sprite_sheet, guests[1].sprite_sheet, "archetypes must look different")


func test_favourites_are_real_dishes() -> void:
	for guest in GameDB.guests():
		assert_false(guest.favorite_dishes.is_empty(), "%s has a favourite" % guest.id)
		for dish_id in guest.favorite_dishes:
			var dish := GameDB.item(dish_id)
			assert_not_null(dish, "%s favourite %s exists" % [guest.id, dish_id])
			if dish != null:
				assert_eq(dish.kind, ItemData.Kind.DISH)


func test_service_pacing_is_forgiving() -> void:
	for guest in GameDB.guests():
		assert_true(guest.patience_seconds >= 60.0, "%s waits at least a minute" % guest.id)
		assert_true(guest.tip > 0)
		assert_false(guest.display_name.is_empty())
		assert_false(guest.arrival_line.is_empty())
