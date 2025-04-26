@tool
extends VBoxContainer

@onready var margin_container: MarginContainer = $".."
@onready var buffer: Control = $Buffer
const SHELF_FLOOR = preload("res://wip/wip-sqlpy/scenes/shelf_floor.tscn")
const MIN_FLOOR_SPACE : float = 60
const FLOOR_HEIGHT : float = 12.0
var floors : Array[Node] = []


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	floors = get_children()
	floors.erase(buffer)

func _process(delta: float) -> void:
	create_shelf()

func create_shelf() -> void:
	if floors.size() > 0:
		if calculate_floor_height(floors.size()) > size.y - MIN_FLOOR_SPACE:
			var child : Node = floors.pop_front()
			child.queue_free()
	if calculate_floor_height(floors.size()) < size.y - MIN_FLOOR_SPACE:
		var child = SHELF_FLOOR.instantiate()
		add_child(child)
		child.owner = self
		floors.append(child)

func calculate_floor_height(num_floors : int) -> float:
	return num_floors * FLOOR_HEIGHT + (num_floors) * get_theme_constant("separation")
