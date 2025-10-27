extends Node2D

@onready var player_scene = preload("res://scenes/player.tscn")
@onready var mine_tilemap: TileMapLayer = $MineTilemap
@onready var level_tilemap: TileMapLayer = $Level
@onready var cave_light: PointLight2D = $CaveLight
@onready var cave_light_timer: Timer = $CaveLightTimer
@onready var return_sign: Area2D = $ReturnSign
@onready var pause_menu: CanvasLayer = $PauseMenu

var cave_path = "res://scenes/world.tscn"
var main_menu_path = "res://scenes/main_menu.tscn"

var player
var tile_type
var can_return

var pickaxe_deco_atlas_pos = Vector2i(0,1)
var lantern_deco_atlas_pos = Vector2i(5,1)

func _ready() -> void:
	generate_mine_map()
	cave_light_timer.start(randf_range(0.5,1))
	mine_tilemap.name = "cave"
	return_sign.name = "return_sign"
	
func switch_scenes(scene):
	get_tree().change_scene_to_file(scene)
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		pause_menu.visible = true
		get_tree().paused = true
		
	if Input.is_action_just_pressed("player_interact") and can_return:
		call_deferred("switch_scenes",cave_path)
		
func spawn_player(map_mid):
	player = player_scene.instantiate()
	player.global_position = map_mid * 16
	player.camera_offset_y = 0.0
	player.tilemap = mine_tilemap
	add_child(player)

func generate_mine_map():
	for y in range(global.map_size.y):
		for x in range(global.map_size.x):
			var chance = randf()
			if chance < global.tile_weights["rock"]:
				tile_type = global.tiles.get("rock")
			if chance < global.tile_weights["coal"]:
				tile_type = global.tiles.get("coal")
			if chance < global.tile_weights["iron"]:
				tile_type = global.tiles.get("iron")
			if chance < global.tile_weights.get("gold"):
				tile_type = global.tiles.get("gold")
			if chance < global.tile_weights["diamond"]:
				tile_type = global.tiles.get("diamond")
			if chance < global.tile_weights["bomb"]:
				tile_type = global.tiles.get("bomb")
			if chance < global.tile_weights["uranium"]:
				tile_type = global.tiles.get("uranium")
				print("!!!is uranium!!!")
			
			mine_tilemap.set_cell(Vector2i(x,y),0,tile_type)

	var map_mid = Vector2(global.map_size.x/2,global.map_size.y/2)	
	for y in range(map_mid.y-2,map_mid.y+2):
		for x in range(map_mid.x-2,map_mid.x+2):
			mine_tilemap.erase_cell(Vector2i(x,y))
			if x == map_mid.x and y == map_mid.y + 1:
				level_tilemap.set_cell(Vector2i(x,y),0,pickaxe_deco_atlas_pos)
			if x == map_mid.x and y == map_mid.y:
				level_tilemap.set_cell(Vector2i(x,y),0,lantern_deco_atlas_pos)
				cave_light.global_position = mine_tilemap.map_to_local(Vector2(x,y))
				return_sign.global_position = mine_tilemap.map_to_local(Vector2(x,y))
				
	spawn_player(map_mid)
	
func _on_cave_light_timer_timeout() -> void:
	cave_light.energy = randf_range(1.5,2.0)
	cave_light_timer.start(randf_range(0.5,1))

func _on_return_sign_area_entered(area: Area2D) -> void:
	can_return = true
	player.show_interact_bubble()

func _on_return_sign_area_exited(area: Area2D) -> void:
	can_return = false
	player.hide_interact_bubble()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	switch_scenes(main_menu_path)
	
func _on_lobby_button_pressed() -> void:
	get_tree().paused = false
	switch_scenes(cave_path)
	
func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false
