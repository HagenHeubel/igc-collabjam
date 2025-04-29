extends RigidBody2D
class_name FlyingBook

#@export var use_sprite_for_size :bool= false ##[b]FALSE: [/b]Collision is used for setting height and width variables[br][b]TRUE:  [/b]Uses sprite instead
#@export var sprite :Node2D
@export var speed :float= 400.0
@export var target_bookshelf_after :float= 20.0
@export var height :float=0.0
@export var width :float=0.0

@onready var ray_cast: RayCast2D = $RayCast2D

var target_bookshelf :MagicBookshelf
var target_location :Vector2=Vector2.ZERO
var previous_bookshelf :MagicBookshelf

var room :TowerRoom
var has_been_flying_for:float=0.0
var default_collision_layer:int=0
var default_collision_mask:int=0

var can_continue:=true

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
			node.scale *= scale
	scale.x = 1.0
	scale.y = 1.0
	default_collision_layer = collision_layer
	default_collision_mask = collision_mask
	find_bookshelf.call_deferred()
	target_location = global_position
	
	room = get_room_node(get_parent())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target_bookshelf:
		has_been_flying_for += delta
		if has_been_flying_for >= target_bookshelf_after:
			target_location = target_bookshelf.global_position
			can_continue = true
		else:
			can_continue = false
			if global_position.distance_squared_to(target_location)<3600.0:
				find_random_spot()
		
		var direction :Vector2= global_position.direction_to(target_location)
		if global_position.distance_squared_to(GlobalVars.player.global_position)<30000.0:
			if global_position.distance_squared_to(GlobalVars.player.global_position)<18000.0:
				direction -= global_position.direction_to(GlobalVars.player.global_position)
			direction -= global_position.direction_to(GlobalVars.player.global_position)
			direction = direction.normalized()
		
		apply_force(direction*speed*mass)
		
		


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
	has_been_flying_for = 0.0
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


func find_random_spot():
	target_location = room.camera_target.global_position
	target_location.x += randf_range(-400.,400.)
	target_location.y += randf_range(-150.,150.)
	
	#print("current target position: ", target_location)
	ray_cast.global_position = global_position
	ray_cast.target_position = ray_cast.to_local(target_location)*1.2
	ray_cast.force_raycast_update()
	#print(ray_cast.get_collider())
	if ray_cast.is_colliding():
		#print(ray_cast.get_collision_point())
		target_location = ray_cast.get_collision_point().lerp(global_position,0.4)
		#print("target after raycast: ", target_location)
		


func get_room_node(parent:Node2D)->TowerRoom:
	if parent is TowerRoom:
		return parent
	else:
		return get_room_node(parent.get_parent())


func calculate_size():
	for node in get_children(true):
		if node is CollisionShape2D:
			width = node.shape.get_rect().size.x
			height = node.shape.get_rect().size.y
			print(height," | ",width)
