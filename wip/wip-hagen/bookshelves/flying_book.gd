extends RigidBody2D
class_name FlyingBook

#@export var use_sprite_for_size :bool= false ##[b]FALSE: [/b]Collision is used for setting height and width variables[br][b]TRUE:  [/b]Uses sprite instead
#@export var sprite :Node2D
@export var speed :float= 4000.0
@export var height :float=0.0
@export var width :float=0.0
var target_bookshelf :MagicBookshelf
var previous_bookshelf :MagicBookshelf
var default_collision_layer:int=0
var default_collision_mask:int=0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in get_children(true):
		if node is CollisionShape2D:
			print("setting collision shape size, scale: ",scale)
			var new_shape :RectangleShape2D= RectangleShape2D.new()
			new_shape.size = node.shape.get_rect().size*scale
			node.shape = new_shape
			width = node.shape.size.x
			height = node.shape.size.y
			print(height," | ",width)
		else:
			node.scale = scale
	scale.x = 1.0
	scale.y = 1.0
	default_collision_layer = collision_layer
	default_collision_mask = collision_mask
	find_bookshelf.call_deferred()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target_bookshelf:
		var direction :Vector2= target_bookshelf.position-position
		direction = direction.normalized()
		apply_force(direction*speed)


func enter_bookshelf(shelf:MagicBookshelf):
	collision_layer = 0
	collision_mask = 0
	reparent(shelf)
	freeze = true
	rotation = 0
	target_bookshelf = null


func leave_bookshelf(shelf:MagicBookshelf):
	collision_layer = default_collision_layer
	collision_mask = default_collision_mask
	reparent(shelf.get_parent())
	freeze = false
	previous_bookshelf = shelf
	find_bookshelf()


func find_bookshelf():
	var possible_bookshelves :Array[Node]
	for element in get_tree().get_nodes_in_group(&"Magic Bookshelf"):
		if element is MagicBookshelf:
			if element.can_store_book(self) and (element.bookshelf_shape.size.y >= height) and (element != previous_bookshelf):
				possible_bookshelves.append(element)
	if !possible_bookshelves.is_empty():
		target_bookshelf = possible_bookshelves.pick_random()
		if target_bookshelf.position.distance_to(position) < 40:
			target_bookshelf._on_body_entered(self)
	else:
		await get_tree().create_timer(1.0).timeout
		find_bookshelf()




func calculate_size():
	for node in get_children(true):
		if node is CollisionShape2D:
			width = node.shape.get_rect().size.x
			height = node.shape.get_rect().size.y
			print(height," | ",width)
