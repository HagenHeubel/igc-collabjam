@tool
extends Path2D

@export_range(0, 100, 1.0) var speed : float = 80
@export_range(0, 1, 0.01) var start_percent : float = 0.0
@export var spawn_moving_backwards : bool = false
@export var pause_at_ends : float = 1.0

@onready var path_follow_2d: PathFollow2D = $PathFollow2D
@onready var book: AnimatableBody2D = $Book

enum {FORWARD, AT_END, BACKWARD, AT_BEGINNING}
var current_movement : int = FORWARD
var moving : bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	path_follow_2d.progress_ratio = start_percent
	book.global_position = path_follow_2d.global_position
	book.target_position = book.global_position
	if not spawn_moving_backwards:
		current_movement = FORWARD
	else:
		current_movement = BACKWARD

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		path_follow_2d.progress_ratio = start_percent
		book.global_position = path_follow_2d.global_position
		return
	match current_movement:
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
	book.target_position = path_follow_2d.global_position

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
