extends Control

@onready var inv: Inventory = preload("res://resources/inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
@onready var highlight: Sprite2D = $NinePatchRect/GridContainer/Highlight

var is_open = true

func _ready() -> void:
	inv.update.connect(update_slots)
	SignalBus.squish_slot.connect(_on_squish_slot)
	#close()
	update_slots()
	move_highlight()

func _on_squish_slot(slot_index: int):
	if slot_index >= 0 and slot_index < slots.size():
		var slot_container = slots[slot_index]
		squish(slot_container)

func squish(obj):
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(obj.item_display, "scale", Vector2(2.5,1.5),0.1)
	tween.tween_property(obj.item_display, "scale", Vector2(1.8,2.2),0.1).set_delay(0.1)
	tween.tween_property(obj.item_display, "scale", Vector2(2.0,2.0),0.1).set_delay(0.2)
	
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
	
