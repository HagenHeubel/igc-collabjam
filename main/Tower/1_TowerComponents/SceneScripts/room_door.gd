@tool
class_name RoomDoor
extends Node2D

@export_range(1.0, 500.0, 1.0) var door_size: float = 96
@export_enum("NULL", "⇆", "⇅") var door_direction : int = 0:
	set(val):
		door_direction = val
		if is_node_ready():
			set_door_direction(door_direction)
		else:
			await ready
			set_door_direction(door_direction)
@export var orange_room: TowerRoom
@export var green_room: TowerRoom

@onready var orange_area: RoomDoorArea = %Orange
@onready var green_area: RoomDoorArea = %Green
@onready var door_collision_shape: CollisionShape2D = %DoorShape
@onready var door_collision_shape_2: CollisionShape2D = %DoorShape2

func _ready() -> void:
	var shape : RectangleShape2D = RectangleShape2D.new()
	door_collision_shape.shape = shape
	door_collision_shape_2.shape = shape
	set_door_direction(door_direction)
	set_door_size(door_size)
	if Engine.is_editor_hint():
		return
	if not orange_room or not green_room:
		printerr("Door", name, " is missing at least one connection to a valid room")
		queue_free()
		return
	green_area.set_target_room(green_room)
	orange_area.set_target_room(orange_room)
	green_room.adjacent_rooms.append(orange_room)
	orange_room.adjacent_rooms.append(green_room)

func set_door_size(size: float) -> void:
	if door_direction == 1:
		door_collision_shape.shape.size.y = door_size
		door_collision_shape.shape.size.x = 32
	elif door_direction == 2:
		door_collision_shape.shape.size.x = door_size
		door_collision_shape.shape.size.y = 32
	door_size = size

func set_door_direction(type : int) -> void:
	if door_direction == 2:
		orange_area.position = Vector2(0, -16)
		green_area.position  = Vector2(0,  16)
		door_collision_shape.shape.size.y = 32
		door_collision_shape.shape.size.x = door_size
	elif door_direction == 1:
		orange_area.position = Vector2(-16, 0)
		green_area.position  = Vector2( 16, 0)
		door_collision_shape.shape.size.y = door_size
		door_collision_shape.shape.size.x = 32
