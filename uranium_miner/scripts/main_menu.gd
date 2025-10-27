extends Control

var cave_path = global.scenes["level"]
var loading_screen = global.scenes["loading"]

func switch_scenes(scene):
	get_tree().change_scene_to_file(scene)

func _on_lobby_button_pressed() -> void:
	call_deferred("switch_scenes",loading_screen)
	global.oncoming_scene = cave_path

func _on_quit_button_pressed() -> void:
	get_tree().quit()
