#@tool
extends Area2D
class_name PopupArea2D

@export var auto_setup: bool = true
@export var bbcode_enabled: bool = true
@export var container: Container
@export var lifetime: float = 3.0 # seconds after leaving area that the container disappears

@onready var timer: Timer = $Timer


func _ready() -> void:
	if auto_setup:
		monitorable = false
		# Setup to only detect the player
		set_collision_layer_value(1, false)
		set_collision_mask_value(3, true)

	
	
	container.hide()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	timer.timeout.connect(_on_timer_timeout)
	
	
func _on_body_entered(body: PhysicsBody2D) -> void:
	timer.stop()
	container.show()

func _on_body_exited(body: PhysicsBody2D) -> void:
	timer.start(lifetime)
	
func _on_timer_timeout() -> void:
	container.hide()
