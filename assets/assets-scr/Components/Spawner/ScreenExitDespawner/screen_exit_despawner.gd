
class_name ScreenExitDespawner
extends VisibleOnScreenNotifier2D # screen_exit_despawner.gd

# Attach this guy to any Node2D we'd like to be destroyed once it leaves the screen, -v

@onready var parent: Node2D = get_parent() ## Target Node2D to be despawned

func _ready() -> void:
	# screen_exited.connect(parent.queue_free)
	#NOTE Uncommented and added logic to parent so we can have it interact with alertness level
	#TBD Should any additional logic be added for this element of despawning?
	pass
