@tool
extends Area2D
class_name MagicBookshelf

#TODO make sorting work if collision shape isn't on the same global position as bookshelf
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
@export_group("References (Automatic)")
@export var bookshelf_shape :RectangleShape2D
@export var bookshelf_collision :CollisionShape2D

var max_book_slots :int= 0
@export var book_slots :Array[FlyingBook]
var current_book_count :int=0

@onready var timer :Timer= $BookLeavingTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		if (get_parent()==get_viewport()):
			return
		if !bookshelf_shape:
			var new_collision_shape = CollisionShape2D.new()
			bookshelf_collision = new_collision_shape
			add_child(bookshelf_collision)
			#new_collision_shape.owner = self
			if get_parent().owner:
				bookshelf_collision.owner = get_parent().owner
			else:
				bookshelf_collision.owner = get_parent()
			print("Creating shape for bookshelf: ", bookshelf_collision)
			bookshelf_collision.shape = RectangleShape2D.new()
		bookshelf_shape = bookshelf_collision.shape
	timer.wait_time = book_interval
	max_book_slots = bookshelf_shape.size.x/book_width
	update_book_management()
	#for i in range(max_book_slots):
		#book_slots.append(null)


func _on_book_leaving_timer_timeout() -> void:
	if randf() <= book_chance:
		for book:FlyingBook in book_slots:
			if book:
				print("one book is leaving")
				return


func can_store_book(book:FlyingBook)->bool:
	return (book.width <= get_remaining_space()) and (book.height <= bookshelf_shape.size.y)


func _on_child_entered_tree(node: Node) -> void:
	if node is FlyingBook:
		if !can_store_book(node):
			push_warning("Assigned book ", node, " doesn't fit into shelf ", self)
			return
		await get_tree().process_frame
		set_book_size(node)
		node.global_position = get_position_of_best_slot(node)
		sort_book_into_shelf(node)
		print(get_position_of_best_slot(node))
func _on_child_exiting_tree(node: Node) -> void:
	if node is FlyingBook:
		remove_book_from_shelf(node)


func sort_book_into_shelf(new_book:FlyingBook):
	var start_range :float= bookshelf_collision.position.x - (bookshelf_shape.size.x*0.5)
	# If no other books exist yet, just put it in on the left
	if book_slots.is_empty():
		book_slots.append(new_book)
		new_book.position.x = start_range+(new_book.width*0.5)
		new_book.position.y = bookshelf_collision.position.y + (bookshelf_shape.size.y*0.5) - (new_book.height*0.5)
		return
	# If other books exist, check for the largest open space
	var max_space:float=0.0
	var position:float=0.0
	var slot:int=0
	#ERROR books are being pushed too far for some reason
	#ERROR the space freed up by the books isn't additive because only one book moves at a time (all the books between the latest book and the inserted book need to move)
	for i in range(book_slots.size()):
		print("checking book ",book_slots[i], " at index ", i)
		print("starting loop with start_range ",start_range, " and max_space ", max_space)
		if i == 0:
			max_space = abs(start_range - (book_slots[i].position.x-(book_slots[i].width*0.5)))
			position = start_range
			start_range = book_slots[i].position.x+(book_slots[i].width*0.5)
		else: #not first element
			if max_space < (book_slots[i].position.x-(book_slots[i].width*0.5)-start_range):
				max_space = book_slots[i].position.x-(book_slots[i].width*0.5)-start_range
				position = start_range
				slot = i
			start_range = book_slots[i].position.x+(book_slots[i].width*0.5)
		if max_space >= new_book.width:
			break
		if i == (book_slots.size()-1): # check behind last element too
			print("checking space after last book")
			print((0.5*bookshelf_shape.size.x-start_range))
			if max_space < (0.5*bookshelf_shape.size.x-start_range):
				max_space = 0.5*bookshelf_shape.size.x-start_range
				position = start_range
				slot = -1
	print("Max space found: ", max_space)
	var index = 1
	var opened_space :float= 0.0
	while(max_space < new_book.width):
		var j = slot + index
		var sn = signi(index)
		if (j>0) and (j<(book_slots.size()-1)):
			opened_space += abs(book_slots[j].position.x - book_slots[j+sn].position.x) - (book_slots[j].width*0.5) - (book_slots[j+sn].position.x)
			book_slots[j].position.x += sn*(abs(book_slots[j].position.x - book_slots[j+sn].position.x) - (book_slots[j].width*0.5) - (book_slots[j+sn].position.x))
		elif j==0:
			opened_space -= (-bookshelf_shape.size.x*0.5 - (book_slots[0].position.x - book_slots[j].width*0.5))
			book_slots[0].position.x += -bookshelf_shape.size.x*0.5 - (book_slots[0].position.x - book_slots[0].width*0.5)
		elif j==(book_slots.size()-1):
			opened_space += bookshelf_shape.size.x*0.5 - (book_slots[j].position.x + book_slots[j].width*0.5)
			book_slots[j].position.x += bookshelf_shape.size.x*0.5 - (book_slots[j].position.x + book_slots[j].width*0.5)
		index = Math.increment_int_alternating(index)
		
		if (max_space+opened_space) >= new_book.width:
			break
		if index > book_slots.size():
			push_error("Book sorting algorithm got trapped in an endless loop -> safety break activated")
			break
	
	new_book.position.y = bookshelf_collision.position.y + (bookshelf_shape.size.y*0.5) - (new_book.height*0.5)
	new_book.position.x = position+(new_book.width*0.5)
	if slot >= 0:
		book_slots.insert(slot,new_book)
	else:
		book_slots.append(new_book)

func remove_book_from_shelf(book:FlyingBook):
	book_slots.erase(book)

func get_position_of_best_slot(book:FlyingBook)->Vector2:
	var vec_out = bookshelf_collision.global_position
	return vec_out


func get_remaining_space()->float:
	var output:float=bookshelf_shape.size.x
	for book :FlyingBook in book_slots:
		output -= book.width
	return output


func update_book_management():
	book_slots.clear()
	for node:Node in get_children():
		if node is FlyingBook:
			book_slots.append(node)


func set_book_size(book:FlyingBook):
	if (book.width<1.0) or (book.height<1.0):
		for node in book.get_children(true):
			if node is CollisionShape2D:
				book.width = node.shape.get_rect().size.x
				book.height = node.shape.get_rect().size.y
