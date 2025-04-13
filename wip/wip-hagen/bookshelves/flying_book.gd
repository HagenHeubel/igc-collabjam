extends RigidBody2D
class_name FlyingBook

#@export var use_sprite_for_size :bool= false ##[b]FALSE: [/b]Collision is used for setting height and width variables[br][b]TRUE:  [/b]Uses sprite instead
#@export var sprite :Node2D
@export var height :float=0.0
@export var width :float=0.0
var target_bookshelf :MagicBookshelf

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	calculate_size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_flying():
	pass


func find_bookshelf():
	var possible_bookshelves :Array[Node]
	for element in get_tree().get_nodes_in_group(&"Magic Bookshelf"):
		if element is MagicBookshelf:
			if element.can_store_book() and (element.bookshelf_shape.size.y >= height):
				possible_bookshelves.append(element)
	target_bookshelf = possible_bookshelves.pick_random()


func enter_bookshelf():
	pass


func calculate_size():
	for node in get_children():
		if node is CollisionShape2D:
			width = node.shape.get_rect().size.x
			height = node.shape.get_rect().size.y
			print(height," | ",width)
