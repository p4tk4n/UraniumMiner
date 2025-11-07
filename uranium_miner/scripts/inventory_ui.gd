extends Control

@onready var inv: Inventory = preload("res://resources/inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
@onready var highlight: Sprite2D = $NinePatchRect/GridContainer/Highlight

var is_open = true

func _ready() -> void:
	inv.update.connect(update_slots)
	#close()
	update_slots()
	move_highlight()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("player_inventory"):
		if is_open:
			close()
		else:
			open()
			
	if Input.is_action_just_pressed("slot_up") and global.current_hand_slot < slots.size()-1:
		global.current_hand_slot += 1
		move_highlight()
		
	elif Input.is_action_just_pressed("slot_down") and global.current_hand_slot > 1:
		global.current_hand_slot -= 1
		move_highlight()
	
	for i in range(inv.slots.size()):
		if Input.is_action_just_pressed("slot_"+str(i+1)):
			global.current_hand_slot = i+1
			move_highlight()
			
func move_highlight():
	print(global.current_hand_slot)
	highlight.position = Vector2((global.current_hand_slot * 36)-20,16)
	
func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])
		
func close():
	visible = false
	is_open = false
	
func open():
	visible = true
	is_open = true
	
