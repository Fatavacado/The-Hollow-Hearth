class_name TestCase
extends Node
## Base class for headless tests. Subclasses define `test_*` methods (sync or async).
## The runner adds each case to the scene tree, so integration tests may instance scenes
## and `await` frames. Assertions record failures instead of aborting the test.

var failures: PackedStringArray = []
var current_test: StringName = &""


func before_each() -> void:
	pass


func after_each() -> void:
	pass


func run_test(method_name: StringName) -> void:
	current_test = method_name
	await before_each()
	if failures.is_empty():
		await call(method_name)
	await after_each()


func fail(message: String) -> void:
	failures.append(message)


func assert_true(condition: bool, message: String = "") -> void:
	if not condition:
		fail("expected true. %s" % message)


func assert_false(condition: bool, message: String = "") -> void:
	if condition:
		fail("expected false. %s" % message)


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if not _same(actual, expected):
		fail("expected <%s> but got <%s>. %s" % [str(expected), str(actual), message])


func assert_ne(actual: Variant, unexpected: Variant, message: String = "") -> void:
	if _same(actual, unexpected):
		fail("did not expect <%s>. %s" % [str(unexpected), message])


func assert_null(value: Variant, message: String = "") -> void:
	if value != null:
		fail("expected null but got <%s>. %s" % [str(value), message])


func assert_not_null(value: Variant, message: String = "") -> void:
	if value == null:
		fail("expected a value but got null. %s" % message)


func assert_almost_eq(actual: float, expected: float, tolerance: float, message: String = "") -> void:
	if absf(actual - expected) > tolerance:
		fail("expected %s ± %s but got %s. %s" % [expected, tolerance, actual, message])


func wait_frames(count: int) -> void:
	for i in count:
		await get_tree().process_frame


func wait_physics_frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame


## Real-time wait. Headless frames are uncapped, so time-based effects (tweens) need this.
func wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _same(a: Variant, b: Variant) -> bool:
	# Numeric values compare by value regardless of int/float; everything else must match type.
	var numeric := [TYPE_INT, TYPE_FLOAT]
	if typeof(a) in numeric and typeof(b) in numeric:
		return is_equal_approx(float(a), float(b))
	if typeof(a) != typeof(b):
		# StringName and String are interchangeable for test purposes.
		if typeof(a) in [TYPE_STRING, TYPE_STRING_NAME] and typeof(b) in [TYPE_STRING, TYPE_STRING_NAME]:
			return String(a) == String(b)
		return false
	return a == b
