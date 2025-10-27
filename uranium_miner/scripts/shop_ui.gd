extends Control

@export var player: CharacterBody2D

@onready var slot_to_sell: Label = $NinePatchRect/BoxContainer/SellContainer/NinePatchRect/SlotToSell

func _ready() -> void:
	pass

func _on_sell_button_pressed() -> void:
	var money_gained = player.inventory.sell_slot()
	if money_gained:
		slot_to_sell.text = "+" + str(money_gained) + "$"
