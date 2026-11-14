class_name Gathering
extends RefCounted
## Gather-node rules. A node's runtime state is a plain dictionary kept in GameState:
##   {}                                   untouched (full)
##   {"remaining": n, "depleted_at": t}   after a harvest; regrows to full `regrow_seconds` of
##                                        play time after it hit zero. Partially picked nodes keep
##                                        their remainder and do not regrow.


static func remaining(state: Dictionary, max_yield: int, regrow_seconds: float, now: float) -> int:
	if state.is_empty():
		return max_yield
	var left := int(state.get("remaining", max_yield))
	if left == 0 and now - float(state.get("depleted_at", now)) >= regrow_seconds:
		return max_yield
	return left


## Returns {"gathered": int, "state": Dictionary}. Items go into `satchel` as far as they fit.
static func harvest(state: Dictionary, max_yield: int, regrow_seconds: float, now: float,
		satchel: Inventory, item_id: StringName) -> Dictionary:
	var available := remaining(state, max_yield, regrow_seconds, now)
	if available == 0:
		return {"gathered": 0, "state": state}
	var gathered := satchel.add_up_to(item_id, available)
	if gathered == 0:
		return {"gathered": 0, "state": state}
	var left := available - gathered
	var new_state := {"remaining": left, "depleted_at": now if left == 0 else -1.0}
	return {"gathered": gathered, "state": new_state}
