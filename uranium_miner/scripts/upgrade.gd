extends Panel

enum UpgradeType {
	MINING_SPEED,
	MINING_FORTUNE,
	BOMB_SHOP,
	BOMB_RADIUS_SHOP
}

@export var upgrade_icon: Texture2D
@export var upgrade_type: UpgradeType
@export var upgrade_cost: float
@export var cost_multiplier: float
@onready var texture_rect: TextureRect = $BoxContainer/TextureRect
@onready var cost_label: Label = $BoxContainer/CostLabel
@onready var purchase_button: Button = $BoxContainer/PurchaseButton

var upgrade_name 

func _ready() -> void:
	if texture_rect and upgrade_icon:
		texture_rect.texture = upgrade_icon
	if cost_label and upgrade_cost:
		cost_label.text = str(upgrade_cost) + "$"
	if purchase_button and upgrade_type:
		upgrade_name = name_string(UpgradeType.keys().get(upgrade_type)) 
		purchase_button.text = upgrade_name
		
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
