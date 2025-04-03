extends Node

enum TimeUnit {
	SECONDS,
	MILLISECONDS,
	MICROSECONDS
}


@onready var rng = RandomNumberGenerator.new()


const conversions_to_seconds: Dictionary = {
	TimeUnit.SECONDS: 1.0,
	TimeUnit.MILLISECONDS: 1_000.0,
	TimeUnit.MICROSECONDS: 1_000_000.0,
}
#region Timer/Timing Based Scripts
## Creates a timer in-script using seconds
## Example use: `await wait(15.5)` will set a timer for 15.5 seconds and wait for it to finish
func wait(seconds:float = 1.0):
	return get_tree().create_timer(seconds).timeout

## Delays a function until the end of the timer. Set deferred to true will result
## in the the call waiting until the end of frame, otherwise it will happen immediately.
## Example use `TimeTool.delay_func(print_text.bind("test"), 2.0)`
func delay_func(callable: Callable, seconds: float, deferred: bool = true):
	if callable.is_valid():
		await wait(seconds)

		if deferred:
			callable.call_deferred()
		else:
			callable.call()



func format_seconds(time: float, use_milliseconds: bool = false) -> String:
	var minutes := floori(time / 60)
	var seconds := fmod(time, 60)
	var milliseconds := fmod(time, 1) * 100

	var result: String = "%02d:%02d" % [minutes, seconds]

	if(use_milliseconds):
		result += ":%02d" % milliseconds


	return result


## Returns the amount of time passed since the engine started
func get_ticks(time_unit: TimeUnit = TimeUnit.SECONDS) -> float:
	match time_unit:
		TimeUnit.MICROSECONDS:
			return Time.get_ticks_usec()
		TimeUnit.MILLISECONDS:
			return Time.get_ticks_msec()
		TimeUnit.SECONDS:
			return get_ticks_seconds()
		_:
			return get_ticks_seconds()


## Returns the conversion of [method Time.get_ticks_usec] to seconds.
func get_ticks_seconds() -> float:
	return Time.get_ticks_usec() / conversions_to_seconds[TimeUnit.MICROSECONDS]


func convert_to_seconds(time: float, origin_unit: TimeUnit) -> float:
	return time / conversions_to_seconds[origin_unit]


func convert_to(time: float, origin_unit: TimeUnit, target_unit: TimeUnit) -> float:
	return convert_to_seconds(time, origin_unit) * conversions_to_seconds[target_unit]
#endregion


#region A collection of functions to imitate having a D&D dice bag
# 50% chance of returning true or false
func flip_coin() -> bool:
	return randf() > 0.5

# D&D-style dice roll, for example 3d6+2. Returns resulting roll value.
func roll_dice(num_dice:int = 1, num_sides:int = 6, modifier:int = 0) -> int:
	var result = modifier
	print("Rolling ", num_dice, "d", num_sides, " + ", modifier)
	for i in range(0, num_dice):
		result += rng.randi_range(1, num_sides)
	print("Result: ", result)
	return result

func force_roll(forced_result: int, fake_count: int, fake_sides: int, real_modifier: int = 0) -> int:
	var result: int = forced_result + real_modifier
	print("Rolling ", fake_count, "d", fake_sides, " + ", real_modifier)
	print("Result: ", result, " But to be fair we cheated")
	return result

# Roll one or more dice with advantage or disadvantage (if advantage is not true rolls are disadvantaged).
# Returns the highest (advantage) or lowest (disadvantage) value of all rolls.
func roll_dice_5e(num_sides:int = 20, advantage:bool = true, modifier:int = 0) -> int:
	var max_or_min_roll = 1
	var roll
	if advantage:
		for i in range (0, 2):
			roll = roll_dice(1, num_sides)
			if(roll > max_or_min_roll):
				max_or_min_roll = roll
			print("Rolling 2d", num_sides, "with Advantage. Taking the Higher Result")
	else:
		max_or_min_roll = num_sides
		for i in range (0, 2):
			roll = roll_dice(1, num_sides)
			if roll < max_or_min_roll:
				max_or_min_roll = roll
		print("Rolling 2d", num_sides, "with Disadvantage. Taking the Lower Result")
	print("Result: ", max_or_min_roll)
	return max_or_min_roll + modifier



func roll_1d4(modifier : int=0) -> int: return roll_dice(1,4,modifier)
func roll_1d6(modifier : int=0) -> int: return roll_dice(1,6,modifier)
func roll_1d8(modifier : int=0) -> int: return roll_dice(1,8,modifier)
func roll_1d10(modifier : int=0) -> int: return roll_dice(1,10,modifier)
func roll_1d12(modifier : int = 0) -> int: return roll_dice(1,12,modifier)
func roll_1d20(modifier : int=0) -> int: return roll_dice(1,20,modifier)
###
func roll_with_advantage(modifier: int = 0): return roll_dice_5e(20, true, modifier)
func roll_with_disadvantage(modifier: int = 0): return roll_dice_5e(20, false, modifier)

#endregion
