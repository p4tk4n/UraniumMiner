extends PointLight2D

@onready var cave_light_timer: Timer = $CaveLightTimer

func _ready() -> void:
	cave_light_timer.start(randf_range(0.5,1))

func _on_cave_light_timer_timeout() -> void:
	energy = randf_range(1.5,2.0)
	cave_light_timer.start(randf_range(0.5,1))
	
