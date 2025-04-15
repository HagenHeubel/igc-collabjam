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
@export var leaving_interval :float= 5.0 ##Seconds between each check for if a book can leave
@export_range(0.0,1.0,0.1) var leaving_chance :float= 0.5 ##Chance that a book will leave on an otherwise successful check
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
	timer.wait_time = leaving_interval+randf()
	timer.timeout.connect(_on_book_leaving_timer_timeout)
	max_book_slots = bookshelf_shape.size.x/book_width
	update_book_management()
	#for i in range(max_book_slots):
		#book_slots.append(null)


func _on_book_leaving_timer_timeout() -> void:
	if book_slots.is_empty():
		return
	if randf() <= leaving_chance:
		var book :FlyingBook= book_slots.pick_random()
		remove_book_from_shelf(book)


func can_store_book(book:FlyingBook)->bool:
	return (book.width <= get_remaining_space()) and (book.height <= bookshelf_shape.size.y)


func _on_child_entered_tree(node: Node) -> void:
	if node is FlyingBook:
		if !can_store_book(node):
			push_warning("Assigned book ", node, " doesn't fit into shelf ", self)
			return
		await get_tree().process_frame
		set_book_size(node)
		sort_book_into_shelf(node)
func _on_child_exiting_tree(node: Node) -> void:
	if node is FlyingBook:
		if Engine.is_editor_hint():
			remove_book_from_shelf(node)


func sort_book_into_shelf(new_book:FlyingBook):
	# If no other books exist yet, just put it in on the left
	if book_slots.is_empty():
		book_slots.append(new_book)
		print(new_book)
		print(bookshelf_collision)
		new_book.position.x = bookshelf_collision.position.x - (bookshelf_shape.size.x*0.5) +(new_book.width*0.5)
		new_book.position.y = bookshelf_collision.position.y + (bookshelf_shape.size.y*0.5) - (new_book.height*0.5)
		return
	# If other books exist, check for the largest open space
	var max_space:float=0.0
	var slot:int=0
	for i in range(book_slots.size()):
		print("checking book ",book_slots[i], " at index ", i)
		if i == 0:
			max_space = get_book_distance_to_left(0)
			slot = 0
		if max_space < get_book_distance_to_right(i):
			max_space = get_book_distance_to_right(i)
			slot = i+1
		if max_space >= new_book.width:
			break
	
	print("Max space found: ", max_space)
	
	var index = 0
	var opened_space :float= 0.0
	while(max_space < new_book.width):
		var j = slot + index
		var sn = signi(index)
		if (j>=0) and (j<book_slots.size()):
			if sn >= 0: #right
				opened_space += get_book_distance_to_right(j)
				var move_by :float= get_book_distance_to_right(j)
				for i in range(abs(index+1)):
					print("moving ",book_slots[slot+i].name, " to the right")
					book_slots[slot+i].position.x += move_by
			else:
				opened_space += get_book_distance_to_left(j)
				var move_by :float= get_book_distance_to_left(j)
				for i in range(abs(index)):
					print("moving ",book_slots[slot-i-1].name, " to the left")
					book_slots[slot-i-1].position.x -= move_by
		
		index = Math.increment_int_alternating(index)
		
		if (max_space+opened_space) >= new_book.width:
			break
		if index > (book_slots.size()*2):
			push_error("Book sorting algorithm got trapped in an endless loop -> safety break activated")
			break
	
	if slot < book_slots.size():
		new_book.position.x = get_book_edge(slot,-1) -(new_book.width*0.5)
		book_slots.insert(slot,new_book)
	else:
		new_book.position.x = get_book_edge(slot-1,1) +(new_book.width*0.5)
		book_slots.append(new_book)
	new_book.position.y = bookshelf_collision.position.y + (bookshelf_shape.size.y*0.5) - (new_book.height*0.5)


func remove_book_from_shelf(book:FlyingBook):
	book_slots.erase(book)
	if !Engine.is_editor_hint():
		book.leave_bookshelf.call_deferred(self)


##Returns positive float representing the distance to the left-next book or edge of the bookshelf
func get_book_distance_to_left(i:int)->float:
	var distance :float= 0
	if i == 0:
		distance = -bookshelf_shape.size.x*0.5 - get_book_edge(i,-1)
	else:
		distance = get_book_edge(i-1,1) - get_book_edge(i,-1)
	return distance*-1
##Returns positive float representing the distance to the right-next book or edge of the bookshelf
func get_book_distance_to_right(i:int)->float:
	var distance :float= 0
	if i == (book_slots.size()-1):
		distance = bookshelf_shape.size.x*0.5 - get_book_edge(i,1)
	else:
		distance = get_book_edge(i+1,-1) - get_book_edge(i,1)
	return distance


##Get left (-1) or right (1) edge of the book at index i
func get_book_edge(i:int,left_right:int):
	return book_slots[i].position.x + (book_slots[i].width*0.5*left_right)



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
				book.width = node.shape.get_rect().size.x * book.scale.x
				book.height = node.shape.get_rect().size.y * book.scale.y


func _on_body_entered(body: Node2D) -> void:
	if body is FlyingBook:
		if body.target_bookshelf != self:
			return
		if !can_store_book(body):
			body.find_bookshelf()
			return
		body.enter_bookshelf.call_deferred(self)
