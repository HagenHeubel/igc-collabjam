extends PointLight2D

var base_energy : float = 0.0
var base_scale : float = 0.0
var dim : float = 0.0
const MAX_DIM : float = 0.05
var noise_offset : float

const noise : FastNoiseLite = preload("res://wip/wip-sqlpy/assets/new_fast_noise_lite.tres")

func _ready() -> void:
	randomize()
	noise_offset = randf() * 3000.0
	SignalBus.tower_ready.connect(_on_tower_ready)

func _on_tower_ready() -> void:
	base_energy = energy
	base_scale = texture_scale

func _process(delta: float) -> void:
	if base_energy != 0.0 and base_scale != 0.0:
		noise_offset += delta * (25 + 75 * (1.0 - noise.get_noise_1d(Util.get_time_sec() - noise_offset) * (randf() * 0.1 + 0.9)))
		dim = remap(noise.get_noise_1d(noise_offset), 0.0, 1.0, 0, MAX_DIM)
		energy = base_energy * (1.0 - dim)
		texture_scale = base_scale * (1.0 - dim)
