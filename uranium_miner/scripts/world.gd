extends Node2D

@onready var cave_entrance: Area2D = $CaveEntrance
@onready var tutorial_sign: Area2D = $TutorialSign
@onready var loading_screen = load("res://scenes/loading_screen.tscn")
@onready var main_menu_scene = load("res://scenes/main_menu.tscn")
@onready var player: CharacterBody2D = $Player
@onready var tutorial: Sprite2D = $Tutorial
@onready var trader_sign: Area2D = $TraderSign
@onready var shop_ui: Control = $ShopUI
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var level: TileMapLayer = $Level

var can_enter_mine = false
var can_read_sign = false
var can_trade = false
var can_enter_upgrade_shop = false

func _ready() -> void:
	player.camera_offset_y = -150.0
	shop_ui.visible = false
	player.tilemap = level
	level.name = "level"
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("player_interact"):
		if can_enter_mine:
			enter_cave()
		elif can_read_sign:
			tutorial.visible = not tutorial.visible
		elif can_trade:
			shop_ui.visible = not shop_ui.visible
		elif can_enter_upgrade_shop:
			enter_upgrade_shop()
		
		
	if Input.is_action_just_pressed("ui_cancel"):
		pause_menu.show()
		get_tree().paused = true
	
func switch_scenes(scene):
	get_tree().change_scene_to_packed(scene)

func enter_upgrade_shop():
	global.oncoming_scene = "res://scenes/upgrade_shop.tscn"
	switch_scenes(loading_screen)

func enter_cave():
	global.oncoming_scene = "res://scenes/mine.tscn"
	switch_scenes(loading_screen)

func _on_cave_entrance_area_entered(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		can_enter_mine = true
		player.show_interact_bubble()
		
func _on_cave_entrance_area_exited(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		can_enter_mine = false
		player.hide_interact_bubble()
	
func _on_tutorial_sign_area_entered(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		player.show_interact_bubble()
		can_read_sign = true

func _on_tutorial_sign_area_exited(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		player.hide_interact_bubble()
		can_read_sign = false
		tutorial.hide()

func _on_trader_sign_area_entered(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		can_trade = true
		player.show_interact_bubble()

func _on_trader_sign_area_exited(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		can_trade = false
		player.hide_interact_bubble()
		shop_ui.visible = false

func _on_resume_pressed() -> void:
	pause_menu.hide()
	get_tree().paused = false

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	switch_scenes(main_menu_scene)
	
func _on_upgrade_shop_entrance_area_entered(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		can_enter_upgrade_shop = true
		player.show_interact_bubble()

func _on_upgrade_shop_entrance_area_exited(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		can_enter_upgrade_shop = false
		player.hide_interact_bubble()
