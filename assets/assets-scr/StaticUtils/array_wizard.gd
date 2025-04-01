class_name ArrayWizard
extends RefCounted # array_wizard.gd

## Useful Utility Script that provides handy Array related functions
## By utilizing static functions, all scripts can theoretically call on the ArrayWizard in the
## same way they would an autoload or a globalscript.

## Find sum of integers in an Array
static func sum(values: Array[int]) -> int:
	var result: int = 0

	for value in values:
		result += value

	return result

## Fund sum of floats in an Array
static func sum_floats(values: Array[float]) -> float:
	var result: float = 0.0

	for value in values:
		result += value

	return result


## Flatten any array with n dimensions recursively
static func flatten(array: Array[Variant]):
	var result := []

	for i in array.size():
		if typeof(array[i]) >= TYPE_ARRAY:
			result.append_array(flatten(array[i]))
		else:
			result.append(array[i])

	return result

## Creates a new Array using random values from the target array.
## To use call the target array, amount of values to pick, and if duplicates are allowed
static func pick_random_values(array: Array[Variant], items_to_pick: int = 1, duplicates: bool = true) -> Array[Variant]:
	var result := []
	var target = flatten(array.duplicate())
	target.shuffle()

	items_to_pick = min(target.size(), items_to_pick)

	for i in range(items_to_pick):
		var item = target.pick_random()
		result.append(item)

		if not duplicates:
			target.erase(item)

	return result

## As it says, eliminates duplicate values from the target array
static func remove_duplicates(array: Array[Variant]) -> Array[Variant]:
	var cleaned_array := []

	for element in array:
		if not cleaned_array.has(element):
			cleaned_array.append(element)

	return cleaned_array

## Should eliminate all nulls, False, and "falsy" values
static func remove_falsy_values(array: Array[Variant]) -> Array[Variant]:
	var cleaned_array := []

	for element in array:
		if element:
			cleaned_array.append(element)

	return cleaned_array

## Looks for the middle-most element based on the Array's current ordering.
static func middle_element(array: Array[Variant]):
	if array.size() > 2:
		return array[floor(array.size() / 2.0)]

	return null


## To detect if a contains elements of b
static func intersects(a: Array[Variant], b: Array[Variant]) -> bool:
	for e: Variant in a:
		if b.has(e):
			return true

	return false

## Returns common elements between Arrays A and B
static func intersected_elements(a: Array[Variant], b: Array[Variant]) -> Array[Variant]:
	if intersects(a, b):
		return a.filter(func(element): return element in b)

	return []
