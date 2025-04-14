extends Node
class_name Level


signal level_won
signal level_lost

var level_state : LevelState


func _ready():
	level_state = GameState.get_level_state(scene_file_path)
	#%ColorPickerButton.color = level_state.color
	#%BackgroundColor.color = level_state.color


# Example of how to update the save state
#func _on_color_picker_button_color_changed(color):
	#%BackgroundColor.color = color
	#level_state.color = color
	#GlobalState.save()
