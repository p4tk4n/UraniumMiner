extends Node2D

@onready var loading_bar: TextureProgressBar = $CanvasLayer/LoadingBar

var progress = []
var scene_name
var scene_load_status = 0.0
var can_load = false
var load_speed = 200.0

func _ready() -> void:
	scene_name = global.oncoming_scene
	ResourceLoader.load_threaded_request(scene_name)
	
static func map(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	return (value - from_min) * (to_max - to_min) / (from_max - from_min) + to_min

func _process(delta: float) -> void:
	scene_load_status = ResourceLoader.load_threaded_get_status(scene_name,progress)
	loading_bar.value += load_speed * delta
	
	if loading_bar.value >= 100:
		can_load = true
	
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED and can_load:
		var newScene = ResourceLoader.load_threaded_get(scene_name)
		get_tree().change_scene_to_packed(newScene)
