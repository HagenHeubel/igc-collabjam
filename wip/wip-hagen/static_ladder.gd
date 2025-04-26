@tool
extends Node2D

@export_group("References")
@export var spritesheet :CompressedTexture2D
@export var rungs :Array[Node2D]
@export var ladder_mid_parts :Array[Node2D]
@export var ladder_top :Node2D
@export var ladder_bottom :Node2D
@export_category("Ladder Construction")
@export_range(1.0,10.0) var height_factor :float=1.0 :
	get: 
		return height_factor
	set(value):
		height_factor = value
		update_ladder_size()
@export var step_distance :float=96.0: ##distance between steps
	get: 
		return step_distance
	set(value):
		step_distance = maxf(value,16)
		update_ladder_rungs()
@export var top_margin :float=96.0: ##distance between steps
	get: 
		return top_margin
	set(value):
		top_margin = value
		update_ladder_rungs()
@export var bottom_margin :float=96.0: ##distance between steps
	get: 
		return bottom_margin
	set(value):
		bottom_margin = value
		update_ladder_rungs()
#@export var grow_upwards :bool=true:
	#get: 
		#return grow_upwards
	#set(value):
		#grow_upwards = value
		#update_ladder_size()
@export var manual_step_placement :bool= false ##Turns off step-placement function. To edit the steps yourself, enable "editable children" (please don't delete the original LadderRung node though)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings :PackedStringArray=[]
	if !spritesheet:
		warnings.append("No spritesheet referenced in export variables!")
	return warnings


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_ladder_size()


func update_ladder_size():
	if ladder_mid_parts.is_empty():
		return
	var tile_number_change = (height_factor as int) - ladder_mid_parts.size()
	var new_scale :float= 1 + (height_factor-(height_factor as int))/ladder_mid_parts.size()
	
	for i in range(height_factor as int):
		if i >= ladder_mid_parts.size():
			#Add new ladder pieces
			var new_piece:Node = ladder_mid_parts[0].duplicate()
			ladder_mid_parts.append(new_piece)
			ladder_mid_parts[0].get_parent().add_child(new_piece)
			new_piece.owner = self
			new_piece.name = "LadderMiddle"+str(i+1)
		#Update all ladder pieces
		ladder_mid_parts[i].position.y = -192 - (128*new_scale*i) - (64*(new_scale-1))
		ladder_mid_parts[i].scale.y = new_scale
	
	if tile_number_change<0: #remove unnecessary ladder parts again
		for i in range(abs(tile_number_change)):
			var old_piece :Node2D= ladder_mid_parts.pop_back()
			old_piece.queue_free()
	
	ladder_top.position.y = -320 - (128*new_scale*(ladder_mid_parts.size()-1)) - (128*(new_scale-1))
	ladder_mid_parts[0].position.y = -192 - (64*(new_scale-1))
	
	update_ladder_rungs()


func update_ladder_rungs():
	if rungs.is_empty() or manual_step_placement:
		return
	rungs[0].position.y = -bottom_margin#/rung_density
	
	var ladder_piece_scale :float= 1 + (height_factor-(height_factor as int))/(ladder_mid_parts.size() as float)
	var needed_amount:int= (ladder_mid_parts.size()*128.0*ladder_piece_scale+step_distance + 256 - top_margin - top_margin)/step_distance
	needed_amount = maxi(needed_amount, 1)
	var space_between:float=step_distance
	
	if needed_amount<rungs.size(): #remove unnecessary ladder parts again
		for i in range(rungs.size()-needed_amount):
			var old_piece :Node2D= rungs.pop_back()
			old_piece.queue_free()
	
	
	for i in range(needed_amount):
		if i >= rungs.size():
			#Add new ladder pieces
			var new_piece:Node = rungs[0].duplicate()
			rungs.append(new_piece)
			rungs[0].get_parent().add_child(new_piece)
			new_piece.owner = self
			new_piece.get_child(0).owner = self
			new_piece.name = "LadderRung"+str(i+1)
		
		rungs[i].position.y = -space_between * i + rungs[0].position.y
