extends Node

@export_group("Settings")
@onready var player: AudioStreamPlayer = $PlayerSFX
@onready var item: AudioStreamPlayer = $ItemSFX
@onready var environment: AudioStreamPlayer = $EnvironmentSFX
@export var audio_bus: StringName = "SFX"
@export var player_polyphony: int = 4
@export var item_polyphony: int = 10
@export var environment_polyphony: int = 4

@export_group("Cat Sounds", "cat")
@export var cat_jump: AudioStream
@export var cat_pounce: AudioStream
@export var cat_fall: AudioStream
@export var cat_walk: AudioStream
@export var cat_meow: AudioStream

@export_group("Bottle Sounds", "bottle")
@export var bottle_clink: AudioStream
@export var bottle_fall: AudioStream
@export var bottle_shatter: AudioStream

@export_group("Book Sounds", "book")
@export var book_fly: AudioStream
@export var book_break: AudioStream
@export var book_fall: AudioStream


func _ready() -> void:
	player.bus = audio_bus
	item.bus = audio_bus
	environment.bus = audio_bus
	player.max_polyphony = player_polyphony
	item.max_polyphony = item_polyphony
	environment.max_polyphony = environment_polyphony


func stop():
	player.stop()
	item.stop()
	environment.stop()

func play_cat_sfx(sfx: AudioStream, pitch_min: float = 0.8, pitch_max: float = 1.2, volume_db: float = 0.0, skip_ahead : float = 0.0):
	if player.stream != sfx:
		player.pitch_scale = 1
		player.set_stream(sfx)
	player.pitch_scale *= randf_range(pitch_min, pitch_max)
	if player.pitch_scale > pitch_max:
		player.pitch_scale = pitch_max
	elif player.pitch_scale < pitch_min:
		player.pitch_scale = pitch_min
	player.volume_db = volume_db
	player.play(skip_ahead)

func play_item_sfx(sfx: AudioStream, pitch_min: float = 0.8, pitch_max: float = 1.2, volume_db: float = 0.0, skip_ahead : float = 0.0):
	if item.stream != sfx:
		item.pitch_scale = 1
		item.set_stream(sfx)
	item.pitch_scale *= randf_range(pitch_min, pitch_max)
	if item.pitch_scale > pitch_max:
		item.pitch_scale = pitch_max
	elif item.pitch_scale < pitch_min:
		item.pitch_scale = pitch_min
	item.volume_db = volume_db
	item.play(skip_ahead)


func play_environmental_sfx(sfx: AudioStream, pitch_min: float = 0.8, pitch_max: float = 1.2, volume_db: float = 0.0, skip_ahead : float = 0.0):
	if environment.stream != sfx:
		environment.pitch_scale = 1
		environment.set_stream(sfx)
	environment.pitch_scale *= randf_range(pitch_min, pitch_max)
	if environment.pitch_scale > pitch_max:
		environment.pitch_scale = pitch_max
	elif environment.pitch_scale < pitch_min:
		environment.pitch_scale = pitch_min
	environment.volume_db = volume_db
	environment.play(skip_ahead)
