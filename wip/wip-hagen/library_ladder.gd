@tool
extends Node2D

@export_group("References")
@export var spritesheet :CompressedTexture2D
@export var handle :Node2D
@export var rungs :Array[Node2D]
@export var ladder_mid_parts :Array[Node2D]
@export var ladder_top :Node2D
@export var ladder_bottom :Node2D
@export var rail_mid_parts :Array[Node2D]
@export var rail_left :Node2D
@export var rail_right :Node2D
@export_category("Ladder Construction")
@export var height_factor :float=1.0 :
	get: 
		return height_factor
	set(value):
		update_ladder_size(value)
		height_factor = value
@export var rung_density :int=2##Rungs per ladder "tile"
@export_range(0.0,1.0) var handle_position :float=0.2 :
	get: 
		return handle_position
	set(value):
		handle_position = value
		update_handle_position()
@export_category("Rail and Movement")
@export var rail_length_factor :float=1.0
@export_range(0.0,1.0) var ladder_position :float=1.0 



func _get_configuration_warnings() -> PackedStringArray:
	var warnings :PackedStringArray=[]
	if !spritesheet:
		warnings.append("No spritesheet referenced in export variables!")
	return warnings


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func update_handle_position():
	handle.global_position.y = lerpf(ladder_bottom.global_position.y,ladder_top.global_position.y,handle_position) 


func update_ladder_size(new_size:float):
	var tile_number_change = (new_size as int) - (height_factor as int)
	if tile_number_change>0: #new tiles have to be added
		for i in range(tile_number_change):
			pass
	elif tile_number_change<0:
		pass


func update_rail_length():
	pass
