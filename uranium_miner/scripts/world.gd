extends Node2D

@onready var cave_entrance: Area2D = $CaveEntrance
@onready var tutorial_sign: Area2D = $TutorialSign
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
	global.current_camera_offset = global.level_camera_offset
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
		pause_menu.visible = true
		get_tree().paused = true
			
func enter_upgrade_shop():
	SceneChanger.switch_scene(global.scenes["upgrade"])

func enter_cave():
	SceneChanger.switch_scene(global.scenes["cave"])

func _on_cave_entrance_area_entered(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		can_enter_mine = true
		SignalBus.show_interact_bubble.emit()

func _on_cave_entrance_area_exited(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		can_enter_mine = false
		SignalBus.hide_interact_bubble.emit()
	
func _on_tutorial_sign_area_entered(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		SignalBus.show_interact_bubble.emit()
		can_read_sign = true

func _on_tutorial_sign_area_exited(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		SignalBus.hide_interact_bubble.emit()
		can_read_sign = false
		tutorial.hide()

func _on_trader_sign_area_entered(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		can_trade = true
		SignalBus.show_interact_bubble.emit()

func _on_trader_sign_area_exited(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		can_trade = false
		SignalBus.hide_interact_bubble.emit()
		shop_ui.visible = false

func _on_resume_pressed() -> void:
	pause_menu.hide()
	get_tree().paused = false

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	SceneChanger.switch_scene(global.scenes["menu"])
	
func _on_upgrade_shop_entrance_area_entered(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		can_enter_upgrade_shop = true
		SignalBus.show_interact_bubble.emit()

func _on_upgrade_shop_entrance_area_exited(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		can_enter_upgrade_shop = false
		SignalBus.hide_interact_bubble.emit()
