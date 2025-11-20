class_name Inventory
extends Resource

signal update
signal slot_updated(slot_index: int)

@export var slots: Array[InventorySlot]

func sell_slot():
	var sold_items = slots[global.current_hand_slot-1]
	if sold_items and sold_items.item:
		var sold_for = sold_items.quantity * global.item_value[sold_items.item.item_name]
		global.player_money += sold_for
		clear_slot()
		return sold_for
		
func clear_slot():
	slots[global.current_hand_slot-1].quantity = 0
	slots[global.current_hand_slot-1].item = null
	update.emit()

func insert(item: InventoryItem,is_from_shop=false):
	var updated_slot_index = -1
	
	# First, try to find existing slots with the same item
	var existing_slots = slots.filter(func(slot): 
		return slot.item == item
	)
	
	if not existing_slots.is_empty():
		if not is_from_shop:
			existing_slots[0].quantity += item.quantity
		else:
			existing_slots[0].quantity += global.shop_item_amount
		updated_slot_index = slots.find(existing_slots[0])
		update.emit()
		SignalBus.squish_slot.emit(updated_slot_index)
		return
	
	# If no existing slots, find completely empty slots
	var empty_slots = slots.filter(func(slot): 
		return slot.item == null
	)
	
	if not empty_slots.is_empty():
		empty_slots[0].item = item
		if not is_from_shop:
			empty_slots[0].quantity += item.quantity
		else:
			empty_slots[0].quantity += global.shop_item_amount
		updated_slot_index = slots.find(empty_slots[0])
		update.emit()
		SignalBus.squish_slot.emit(updated_slot_index)
		return
