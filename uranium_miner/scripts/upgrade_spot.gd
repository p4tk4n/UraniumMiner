extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cost_label: Label = $Control/NinePatchRect/CostLabel
@onready var upgrade_name_label: Label = $Control/NinePatchRect2/UpgradeName
@onready var control: Control = $Control

enum UpgradeType {
	MINING_SPEED,
	MINING_FORTUNE,
	BOMB_SHOP,
	BOMB_RADIUS_SHOP
}

@export var player: CharacterBody2D
@export var upgrade_texture: Texture2D
@export var upgrades_value: UpgradeType
@export var cost: int
@export var upgrade_power: float

var show_cost
var upgrade_name: String
var current_level: int = 0
var formated_name
var sell_type = "upgrade"

var max_sin_val: float = 1.0
var control_sin_value: float = 0.0
var control_speed: float = 4.0
var control_amplitude: float = 5.0

func _ready() -> void:
	name = UpgradeType.keys().get(upgrades_value)
	
	if name == "BOMB_SHOP" or name == "BOMB_RADIUS_SHOP":
		sell_type = "item"
	
	sprite_2d.texture = upgrade_texture
	cost_label.text = str(cost) + "$"
	formated_name = name_string(name)
	if sell_type == "upgrade" or name == "BOMB_RADIUS_SHOP":
		upgrade_name_label.text = formated_name + " " + str(current_level)
	else:
		upgrade_name_label.text = formated_name
		
	control.visible = false
	
func name_string(string):
	var name_arr = string.split("_")
	name_arr.insert(1," ")
	name_arr[0] = name_arr[0].to_lower()
	name_arr[2] = name_arr[2].to_lower()
	name_arr[0][0] = name_arr[0][0].to_upper()
	name_arr[2][0] = name_arr[2][0].to_upper()
	var cut_off_arr = []
	cut_off_arr.append(name_arr[0])
	cut_off_arr.append(name_arr[1])
	cut_off_arr.append(name_arr[2])
	var temp_name = "".join(cut_off_arr)
	return temp_name
		
func _process(delta: float) -> void:
	if show_cost:
		control.visible = true
	else:
		control.visible = false
	
	if control_sin_value > PI:
		control_sin_value = -PI
	
	if control.visible:
		control.global_position.y += sin(control_sin_value) * control_amplitude * delta
		control_sin_value += control_speed * delta
	
func add_item_to_player(item_name):
	var item = global.item_resources[item_name]
	item.item_name = item_name
	item.quantity = 1
	item.texture = global.tile_icons[item_name]
	if item_name == "bomb":
		item.is_usable = true
	player.inventory.insert(item,true)

func buy():
	if sell_type == "upgrade":
		current_level += 1
		global.player_stats[name.to_lower()] += upgrade_power
		global.player_money -= cost
		cost *= 1.2
		cost_label.text = str(cost) + "$"
		upgrade_name_label.text = formated_name + " " + str(current_level)
	else:
		if name == "BOMB_SHOP":
			global.player_money -= cost
			add_item_to_player("bomb")
		if name == "BOMB_RADIUS_SHOP":
			current_level += 1
			global.bomb_radius += 0.5
			global.player_money -= cost
			cost *= 1.3
			cost_label.text = str(cost) + "$"
			upgrade_name_label.text = formated_name + " " + str(current_level)
			
