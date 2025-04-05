extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVars.player = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var force :Vector2 = Vector2.ZERO
	force.x = Input.get_axis("left", "right")
	apply_force(force*14000)
	
	if Input.is_action_just_pressed("jump"):
		apply_impulse(Vector2.UP*5000)
