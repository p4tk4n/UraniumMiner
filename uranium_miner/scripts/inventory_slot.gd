extends Panel

@onready var item_display: Sprite2D = $ItemDisplay
@onready var item_quantity: Label = $Label

func update(slot: InventorySlot):
	if slot:
		if not slot.item:
			item_display.visible = false
			item_quantity.visible = false
		else:
			item_display.visible = true
			item_quantity.visible = true
			item_display.texture = slot.item.texture	
			item_quantity.text = str(slot.quantity)
