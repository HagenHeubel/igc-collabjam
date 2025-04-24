class_name ShuffleBookshelf
extends Node2D

@export_group("Shuffle Parameters", "shuffle")
@export_range(0.0, 20.0, 0.1) var shuffle_wait_min : float = 0.0
@export_range(0.0, 20.0, 0.1) var shuffle_wait_max : float = 0.0
@export_enum("Random", "<-", "->") var shuffle_type : String = "Random"
var books_in_shelf : Array[ShuffleBook] = []
var slot_positions : Array[float] = []
var is_book_moving : bool = false
var last_slot_slotted : int = -1
signal start_shuffle

func _ready() -> void:
	start_shuffle.connect(attempt_shuffle_start)
	_init_child_books()
	_recalculate_slot_positions()
	_set_init_book_positions()
	attempt_shuffle_start()

func attempt_shuffle_start() -> void:
	if not is_book_moving:
		var book_nr : int = -1
		var slot_nr : int = -1
		while book_nr == slot_nr:
			var shuffle : Vector2i = get_shuffle_target()
			book_nr = shuffle.x
			slot_nr = shuffle.y
			if book_nr == last_slot_slotted:
				book_nr = slot_nr
		last_slot_slotted = slot_nr
		move_book_to_slot(book_nr, slot_nr)
		is_book_moving = true

func get_shuffle_target() -> Vector2i:
	var res : Vector2i = Vector2i.ZERO
	match shuffle_type:
		"<-":
			# Random book that's not in first slot
			# Random slot before chosen book
			res.x = randi_range(1, books_in_shelf.size() - 1)
			res.y = randi_range(0, res.x - 1)
		"->":
			# Random book that's not last slot
			# Random slot after chosen book
			res.x = randi_range(0, books_in_shelf.size() - 2)
			res.y = randi_range(res.x + 1, books_in_shelf.size() - 1)
		"_":
			# Random book and random slot
			res.x = randi_range(0, books_in_shelf.size() - 1)
			res.y = randi_range(0, books_in_shelf.size() - 1)
	return res

func move_book_to_slot(book_nr : int, slot : int) -> void:
	var move_book : ShuffleBook = books_in_shelf.pop_at(book_nr)
	move_child(move_book, -1)
	books_in_shelf.insert(slot, move_book)
	_recalculate_slot_positions()
	
	move_book.unslot()
	await move_book.unslotted
	for i : int in range(books_in_shelf.size()):
		var book : ShuffleBook = books_in_shelf[i]
		if book == move_book:
			book.slide_delay = 0.0
		else:
			book.slide_delay = (slot_positions.size() - abs(slot - i) + randf()) * 0.2
		book.target_position = slot_positions[i]
		book.slide_to_target_position(40.0)
	await move_book.arrived_at_target
	move_book.reslot()
	await move_book.reslotted
	if is_book_moving:
		start_book_shuffle_timer()

func start_book_shuffle_timer() -> void:
	is_book_moving = false
	var time : float = randf_range(shuffle_wait_min, shuffle_wait_max)
	await get_tree().create_timer(time).timeout
	attempt_shuffle_start()
	
func _recalculate_slot_positions() -> void:
	slot_positions.clear()
	var current_pos : float = 0
	for book : ShuffleBook in books_in_shelf:
		slot_positions.append(current_pos)
		current_pos += book.width

func _init_child_books() -> void:
	for child in get_children():
		if child is ShuffleBook:
			print(child)
			books_in_shelf.append(child)
	books_in_shelf.sort_custom(_sort_position)

func _sort_position(a : ShuffleBook, b : ShuffleBook) -> bool:
	return a.global_position.x < b.global_position.x

func _set_init_book_positions() -> void:
	for i : int in range(books_in_shelf.size()):
		var book : ShuffleBook = books_in_shelf[i]
		book.global_position = global_position + Vector2.RIGHT * slot_positions[i]
