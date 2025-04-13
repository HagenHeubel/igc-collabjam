@tool
extends Area2D
class_name MagicBookshelf

#TODO If the books have collision, a book should check if something is in the way when it tries to slide out.
#TODO If something is in the way we can choose a toggle for either to just wait for X seconds and try again or immediately try another book (until all books have been tried at which point we break the loop, we don't want infinite while loops)
#TODO The animations are controllable
#TODO You can pause it
#TODO somewhere to insert either an animation or other code between choosing a book and it starting to move (so we can create the effect of it sliding out/in)
#DONE Only one book sliding at a time
#TODO Some options of different methods of choosing which book to slide also where to slide it
#TODO Books should be able to have different sizes (on the same shelf)
#DONE Customizable timing between a book completing it's shuffle and the next one starting

@export var book_width :float=10.0 ##Maximum width per book in pixels - used to determine amount of book slots
@export_group("Book Leaving Checks")
@export var book_interval :float= 5.0 ##Seconds between each check for if a book can leave
@export_range(0.0,1.0,0.1) var book_chance :float= 0.5 ##Chance that a book will leave on an otherwise successful check
@export var bookshelf_shape :RectangleShape2D

var max_book_slots :int= 0
var remaining_space :float= 0.0
var book_slots :Array[FlyingBook]
var current_book_count :int=0

@onready var timer :Timer= $BookLeavingTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Engine.is_editor_hint():
		timer.wait_time = book_interval
		remaining_space = bookshelf_shape.size.x
		max_book_slots = bookshelf_shape.size.x/book_width
		#for i in range(max_book_slots):
			#book_slots.append(null)
		return
	if (get_parent()==get_viewport()):
		return
	if !bookshelf_shape:
		var new_collision_shape = CollisionShape2D.new()
		add_child(new_collision_shape)
		#new_collision_shape.owner = self
		if get_parent().owner:
			new_collision_shape.owner = get_parent().owner
		else:
			new_collision_shape.owner = get_parent()
		print("Creating shape for bookshelf: ", new_collision_shape)
		new_collision_shape.shape = RectangleShape2D.new()
		bookshelf_shape = new_collision_shape.shape


func _on_book_leaving_timer_timeout() -> void:
	if randf() <= book_chance:
		for book:FlyingBook in book_slots:
			if book:
				print("one book is leaving")
				return

func can_store_book(book:FlyingBook)->bool:
	return (book.width <= remaining_space) and (book.height <= bookshelf_shape.size.y)


func _on_child_entered_tree(node: Node) -> void:
	if node is FlyingBook:
		if !can_store_book(node):
			push_warning("Assigned book ", node, " doesn't fit into shelf ", self)
