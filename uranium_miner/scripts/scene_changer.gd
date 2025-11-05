extends Node

var loading_screen = "res://scenes/loading_screen.tscn"

func switch_scene(path_to_use):
	global.oncoming_scene = path_to_use
	call_deferred("switcher",loading_screen)

func switcher(scene):
	get_tree().change_scene_to_file(scene)
