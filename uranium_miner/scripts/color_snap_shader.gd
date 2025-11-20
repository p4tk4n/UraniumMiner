extends Control

@onready var color_rect: ColorRect = %ColorRect
@export var palette: Texture2D

func _ready() -> void:
	var material = color_rect.material as ShaderMaterial
	material.set_shader_parameter("palette", palette)
	color_rect.visible = true
