extends Node

var map_size = Vector2(64,128)
var level_camera_offset = Vector2(0,-100)
var current_camera_offset = Vector2(0,-100)
var tile_size = 16

var drops_per_tile := 1
var current_hand_slot = 1
var player_money = 0
var shop_item_amount = 1

var bomb_radius = 1 #in tiles
var usable_items = ["bomb",""]
var oncoming_scene: NodePath

var ladder_atlas_position = Vector2i(13,1)

var player_stats = {
	"mining_speed": 2.0, #2.0 def
	"mining_fortune": 1 #1 def
}

func drop_amount():
	return int(drops_per_tile * player_stats["mining_fortune"])

var tile_weights = {
	"rock": 1.0,
	"coal": 0.085,
	"iron": 0.03,
	"gold": 0.02,
	"diamond": 0.01,
	"uranium": 0.0005,
	"bomb": 0.002
}

var scenes = {
	"level":   "res://scenes/world.tscn",
	"cave":    "res://scenes/mine.tscn",
	"menu":    "res://scenes/main_menu.tscn",
	"upgrade": "res://scenes/upgrade_shop.tscn",
	"loading": "res://scenes/loading_screen.tscn"
}

var tiles = {
	"rock": Vector2(0,1),
	"coal": Vector2(0,2),
	"iron": Vector2(0,3),
	"gold": Vector2(0,4),
	"diamond": Vector2(0,5),
	"uranium": Vector2(0,6),
	"bomb": Vector2(0,7),
	"barrier": Vector2(0,8)
}

var tile_icons = {
	"rock": load("res://sprites/rock_resource.png"),
	"coal": load("res://sprites/coal_resource.png"),
	"iron": load("res://sprites/iron_resource.png"),
	"gold": load("res://sprites/gold_resource.png"),
	"diamond": load("res://sprites/diamond_resource.png"),
	"uranium": load("res://sprites/uranium_resource.png"),
	"bomb": load("res://sprites/bomb_icon.png")
}

var item_resources = {
	"rock": preload("res://resources/rock.tres"),
	"coal": preload("res://resources/coal.tres"),
	"iron": preload("res://resources/iron.tres"),
	"gold": preload("res://resources/gold.tres"),
	"diamond": preload("res://resources/diamond.tres"),
	"uranium": preload("res://resources/uranium.tres"),
	"bomb": preload("res://resources/bomb.tres")
}

var item_value = {
	"rock": 2,
	"coal": 5,
	"iron": 8,
	"gold": 15,
	"diamond": 25,
	"uranium": 100,
	"bomb": 20
}
