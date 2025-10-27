extends Control

@onready var nine_patch_rect: NinePatchRect = $MarginContainer/NinePatchRect
@onready var time_per_letter: Timer = $TimePerLetter
@onready var tooltip_text_label: Label = $MarginContainer/NinePatchRect/BoxContainer/TooltipText
@onready var margin_container: MarginContainer = $MarginContainer

func _ready() -> void:
	time_per_letter.wait_time = 0.2
	letter_by_letter("Hello stranger, welcome to the cave! ")

func clear_field():
	tooltip_text_label.text = ""

func letter_by_letter(text):
	clear_field()
	margin_container.size = tooltip_text_label.size
	nine_patch_rect.size = tooltip_text_label.size
	for letter in text:
		tooltip_text_label.text += letter
		if letter != " ":
			time_per_letter.start()
			await time_per_letter.timeout
