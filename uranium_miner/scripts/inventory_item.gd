class_name InventoryItem
extends Resource

@export var item_name: String = ""
@export var texture: Texture2D
@export var quantity: int

var is_usable: bool:
	get:
		return item_name in global.usable_items if global else false
	
