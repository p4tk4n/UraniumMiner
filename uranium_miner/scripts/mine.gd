extends Node2D

@onready var player_scene = preload("res://scenes/player.tscn")
@onready var mine_tilemap: TileMapLayer = $MineTilemap
@onready var level_tilemap: TileMapLayer = $Level
@onready var cave_light: PointLight2D = $CaveLight
@onready var return_sign: Area2D = $ReturnSign
@onready var pause_menu: CanvasLayer = $PauseMenu

var player
var tile_type
var can_return

var pickaxe_deco_atlas_pos = Vector2i(0,1)
var lantern_deco_atlas_pos = Vector2i(5,1)
var lantern_deco_world_pos = Vector2(68,-2)
var pickaxe_deco_world_pos = Vector2(68,-1)
var barrier_bloc_atlas_pos = Vector2(0,0)

var entrance_pos = Vector2(pickaxe_deco_world_pos.x - 1, pickaxe_deco_world_pos.y)

func _ready() -> void:
	self.name = "mine"
	global.current_camera_offset = Vector2.ZERO
	generate_mine_map()
	mine_tilemap.name = "cave"
	return_sign.name = "return_sign"
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		pause_menu.visible = not pause_menu.visible
		get_tree().paused = pause_menu.visible
		if pause_menu.visible: SignalBus.hide_cutout.emit() 
		else: SignalBus.show_cutout.emit()
		
	if Input.is_action_just_pressed("player_interact") and can_return:
		SceneChanger.switch_scene(global.scenes["level"])
		
func spawn_player(spawn_position):
	player = player_scene.instantiate()
	player.global_position = spawn_position * 16
	player.camera_offset_y = 0.0
	player.tilemap = mine_tilemap
	add_child(player)

func generate_mine_map():
	for y in range(0,global.map_size.y+1):
		for x in range(-1,global.map_size.x+1):
			var depth = float(y) / global.map_size.y #percent
			var depth_increase = pow(depth, 0.5)
			var chance = randf() * (1.0 - depth_increase * 0.8)
			if chance < global.tile_weights["uranium"]:
				tile_type = global.tiles.get("uranium")
			elif chance < global.tile_weights["diamond"]:
				tile_type = global.tiles.get("diamond")
			elif chance < global.tile_weights.get("gold"):
				tile_type = global.tiles.get("gold")
			elif chance < global.tile_weights["bomb"]:
				tile_type = global.tiles.get("bomb")
			elif chance < global.tile_weights["iron"]:
				tile_type = global.tiles.get("iron")
			elif chance < global.tile_weights["coal"]:
				tile_type = global.tiles.get("coal")
			elif chance < global.tile_weights["rock"]:
				tile_type = global.tiles.get("rock")
			
			if x < 0 or x == global.map_size.x or y > global.map_size.y or (y < 0 and (x < 0 or x == global.map_size.x)):
				tile_type = null
				level_tilemap.set_cell(Vector2(x,y),0,barrier_bloc_atlas_pos)
			
			if x < 0 and y == 0:
				for i in range(5):
					tile_type = null
					level_tilemap.set_cell(Vector2(x,y-i),0,barrier_bloc_atlas_pos)
			
			if tile_type:
				mine_tilemap.set_cell(Vector2i(x,y),0,tile_type)

	var map_start = entrance_pos
	
	cave_light.global_position = mine_tilemap.map_to_local(lantern_deco_world_pos)
	return_sign.global_position = mine_tilemap.map_to_local(pickaxe_deco_world_pos)
	level_tilemap.set_cell(Vector2i(68,-2),0,lantern_deco_atlas_pos)
	level_tilemap.set_cell(Vector2i(68,-1),0,pickaxe_deco_atlas_pos)
	spawn_player(map_start) # spawne hraca ked je na to ready mapa

func _on_return_sign_area_entered(area: Area2D) -> void:
	can_return = true
	player.show_interact_bubble()

func _on_return_sign_area_exited(area: Area2D) -> void:
	can_return = false
	player.hide_interact_bubble()
	
func _on_lobby_button_pressed() -> void:
	get_tree().paused = false
	SceneChanger.switch_scene(global.scenes["level"])
	
func _on_resume_button_pressed() -> void:
	SignalBus.show_cutout.emit()
	get_tree().paused = false
	pause_menu.visible = false
	
	
func _on_entrance_button_pressed() -> void:
	SignalBus.show_cutout.emit()
	player.position = entrance_pos * global.tile_size
	pause_menu.visible = false
	get_tree().paused = false
	
