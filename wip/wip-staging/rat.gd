extends Node2D

@onready var alert_icon: Sprite2D = $AlertIcon
@onready var alert_range: Area2D = $AlertRange
@onready var capture_range: Area2D = $CaptureRange
@onready var screen_exit_despawner: ScreenExitDespawner = $ScreenExitDespawner

@export var is_catchable: bool = true
@export var WANDER_SPEED: float = 50.0
@export var RUN_SPEED: float = 500.0
@export var WANDER_DISTANCE: float = 400.0 # in pixels
@export var MAX_LEFT: float
@export var MAX_RIGHT: float
@export_enum("Left", "Right") var DIRECTION_TO_EXIT: int = 1 ## 0 for left, 1 for right

var just_alerted : bool = false
var is_alert: bool = false
var start_pos: Vector2
var target_pos: Vector2 
var move_dir: int = 1

func _ready() -> void:
	start_pos = global_position
	screen_exit_despawner.screen_exited.connect(_on_screen_exited)
	alert_range.body_entered.connect(_on_alerted)
	alert_range.body_exited.connect(_on_unalerted)
	capture_range.body_entered.connect(_on_capture)
	alert_icon.hide()

func _on_screen_exited() -> void:
	if is_alert:
		queue_free()

func _on_alerted(body: Node2D):
	if body.is_in_group("Player"):
		if not is_alert:
			trigger_alert_hop()
		is_alert = true
		print("Alerted!")
		alert_icon.show()

func trigger_alert_hop() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_method(_alert_hop, 0.0, 1.0, 0.2)

func _alert_hop(t : float) -> void:
	global_position.y = start_pos.y + 100 * t * (t - 1)

func _on_unalerted(body: Node2D):
	if body.is_in_group("Player"):
		await get_tree().create_timer(4.0).timeout
		is_alert = false
		alert_icon.hide()
		await get_tree().create_timer(2.0).timeout
		if is_alert:
			return
		else:
			print("Rat Escaped!!")
			self.queue_free()

func _on_capture(body: Node2D):
	if body.is_in_group("Player"):
		if is_catchable:
			##TODO Add winning stuff
			print("YOU CAUGHT THE RAT GOOD JORB!!")
			self.queue_free()
		else:
			print("Why is the rat so slippery??")

func _physics_process(delta: float) -> void:
	if is_alert:
		run_away(delta)
	else:
		wander(delta)

func wander(delta: float):
	var arrived: bool = (move_dir > 0 and global_position.x >= target_pos.x) or (move_dir < 0 and global_position.x <= target_pos.x)
	if arrived:
		choose_new_wander_target()
	global_position.x += move_dir * WANDER_SPEED * delta
	global_position.x = clamp(global_position.x, start_pos.x - WANDER_DISTANCE, start_pos.x + WANDER_DISTANCE)

func choose_new_wander_target():
	# Determine Distance first, then direction
	var distance: float = randf_range(WANDER_DISTANCE * 0.2, WANDER_DISTANCE)
	move_dir = 1 if randf() > 0.5 else -1 # 50/50 left or right
	target_pos.x = global_position.x + (distance * move_dir)
	target_pos.x = clamp(target_pos.x, MAX_LEFT + start_pos.x, MAX_RIGHT + start_pos.x)

func run_away(delta: float):
	if DIRECTION_TO_EXIT == 0:
		global_position.x -= RUN_SPEED * delta
	else:
		global_position.x += RUN_SPEED * delta
