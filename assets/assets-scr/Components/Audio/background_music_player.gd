class_name BackgroundMusicPlayer
extends AudioStreamPlayer # background_music_player.tscn
# Presets many AudioStreamPlayer properties
func _ready()->void:
	autoplay = true
	max_polyphony = 1
	bus = "Music"
	process_mode = PROCESS_MODE_ALWAYS
