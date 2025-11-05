extends Node2D

@onready var shop_tilemap: TileMapLayer = $ShopTilemap
@onready var player: CharacterBody2D = $Player
@onready var loading_screen = global.scenes["loading"]
@onready var pause_menu: CanvasLayer = $PauseMenu

var can_enter_level: bool = false
var can_buy_upgrade: bool = false
var current_upgrade
var previous_upgrade

func _ready() -> void:
	shop_tilemap.name = "shop"
	player.tilemap = shop_tilemap
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("player_interact"):
		if can_enter_level:
			enter_level()
		if can_buy_upgrade:
			if global.player_money >= current_upgrade.cost:
				current_upgrade.buy()
		
	if Input.is_action_just_pressed("ui_cancel"):
		pause_menu.show()
		get_tree().paused = true
		
	if player.player_hitbox.get_overlapping_areas().size() > 0:
		if player.player_hitbox.get_overlapping_areas().get(0).owner.is_in_group("upgrade"):
			previous_upgrade = current_upgrade
			current_upgrade = player.player_hitbox.get_overlapping_areas().get(0).owner
			
			if current_upgrade != previous_upgrade and previous_upgrade:
				previous_upgrade.show_cost = false
				
			current_upgrade.show_cost = true
			can_buy_upgrade = true
			SignalBus.show_interact_bubble.emit()
	else:
		if current_upgrade:
			current_upgrade.show_cost = false
		can_buy_upgrade = false
		SignalBus.hide_interact_bubble.emit()
		
func enter_level():
	SceneChanger.switch_scene(global.scenes["level"])
	
func _on_level_entrance_area_entered(area: Area2D) -> void:
	can_enter_level = true
	SignalBus.show_interact_bubble.emit()

func _on_level_entrance_area_exited(area: Area2D) -> void:
	can_enter_level = false
	SignalBus.hide_interact_bubble.emit()

func _on_resume_pressed() -> void:
	pause_menu.hide()
	get_tree().paused = false

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	SceneChanger.switch_scene(global.scenes["menu"])
