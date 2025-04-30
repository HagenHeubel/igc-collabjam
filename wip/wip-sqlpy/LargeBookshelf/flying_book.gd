@tool
extends Path2D

@export var book_color : Color = Color.WHITE
@export_range(0.0, 3.0, .001) var book_scale : float = 0.3
@export var book_texture : Texture2D
@export var book_gold : Texture2D
@export var update : bool = false:
	set(val):
		if is_node_ready():
			_ready()
@export_range(0, 300, 0.01) var speed : float = 80:
	set(val):
		speed = val
		length = curve.get_baked_length()
		time = length / speed

@export var time : float:
	set(val):
		time = val
		length = curve.get_baked_length()
		if abs((length / speed) / time - 1.0) > 0.04:
			speed = length / time

@export_range(0, 1, 0.01) var start_percent : float = 0.0
@export var spawn_pause : float = 0.0
@export var spawn_moving_backwards : bool = false
@export var pause_at_ends : float = 1.0

@onready var light_occluder_rect: LightOccluderRect = $Book/LightOccluderRect
@onready var collision_shape_2d: CollisionShape2D = $Book/CollisionShape2D
@onready var path_follow_2d: PathFollow2D = $PathFollow2D
@onready var book: AnimatableBody2D = $Book
@onready var sprite_2d: Sprite2D = $Book/Sprite2D
@onready var gold: Sprite2D = $Book/Gold

enum {FORWARD, AT_END, BACKWARD, AT_BEGINNING}
var length : float
var current_movement : int = -1
var moving : bool = false
var currently_spawning : bool = true
var spawn_started : bool = false

func _ready() -> void:

	light_occluder_rect.scale = Vector2.ONE * book_scale
	collision_shape_2d.scale = Vector2.ONE * book_scale
	sprite_2d.scale = Vector2.ONE * book_scale
	gold.scale = Vector2.ONE * book_scale
	sprite_2d.modulate = book_color
	sprite_2d.texture = book_texture
	gold.texture = book_gold
	collision_shape_2d.shape.size = gold.texture.get_size() - Vector2.ONE * 30
	if Engine.is_editor_hint():
		return
	
	path_follow_2d.progress_ratio = start_percent
	book.global_position = path_follow_2d.global_position
	book.target_position = book.global_position

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		path_follow_2d.progress_ratio = start_percent
		book.global_position = path_follow_2d.global_position
		return
		
	match current_movement:
		-1:
			process_spawning(delta)
		FORWARD:
			progress_forward(delta)
			moving = true
		AT_END:
			await_end_pause()
		BACKWARD:
			progress_backward(delta)
			moving = true
		AT_BEGINNING:
			await_end_pause()
			
	sprite_2d.modulate = book_color
	book.target_position = path_follow_2d.global_position

func process_spawning(delta) -> void:
	if currently_spawning:
		if not spawn_started:
			spawn_started = true
			await get_tree().create_timer(spawn_pause).timeout
			currently_spawning = false
	else:
		if not spawn_moving_backwards:
			current_movement = FORWARD
		else:
			current_movement = BACKWARD

func await_end_pause() -> void:
	if moving:
		moving = false
		await get_tree().create_timer(pause_at_ends).timeout
		progress_movement()

func progress_backward(delta : float) -> void:
	var start_progress : float = path_follow_2d.progress_ratio
	path_follow_2d.progress -= delta * speed
	if path_follow_2d.progress_ratio > start_progress:
		path_follow_2d.progress_ratio = 0.0
		progress_movement()

func progress_forward(delta : float) -> void:
	var start_progress : float = path_follow_2d.progress_ratio
	path_follow_2d.progress += delta * speed
	if path_follow_2d.progress_ratio < start_progress:
		path_follow_2d.progress_ratio = 1.0
		progress_movement()

func progress_movement() -> void:
	match current_movement:
		FORWARD:
			current_movement = AT_END
		AT_END:
			current_movement = BACKWARD
		BACKWARD:
			current_movement = AT_BEGINNING
		AT_BEGINNING:
			current_movement = FORWARD
