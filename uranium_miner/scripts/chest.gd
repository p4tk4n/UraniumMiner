extends Node2D

@export var fast_spin_time: float = 1.5
@export var slow_spin_time: float = 1.0

@onready var display_spot: Sprite2D = $Background/DisplaySpot
@onready var background: Panel = $Background
@onready var confetti_particle: CPUParticles2D = $ConfettiParticle

var can_open = false
var is_spinning: bool = false
var spin_timer: float = 0.0
var current_item_index: int = 0
var target_item_index: int
var item_change_speed: float = 0.0

var player

func _ready() -> void:
	background.hide()
	if display_spot and background:
		display_spot.position = background.size / 2
	
	if global.tile_icons.size() > 0:
		display_spot.texture = global.tile_icons[global.tile_icons.keys()[0]]
	
func open_chest():
	background.show()
	start_lottery()  # Start the lottery when chest opens

func start_lottery():
	if is_spinning:
		return
	
	is_spinning = true
	spin_timer = 0.0
	current_item_index = 0
	target_item_index = randi() % global.tile_icons.size()
	print("TARGET REWARD INDEX IS ", target_item_index)
	item_change_speed = 0.0  # Reset timer
	
	display_spot.scale = Vector2.ONE
	display_spot.modulate = Color.WHITE

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("player_interact"):
		if can_open:
			open_chest()
	
	# Lottery spinning logic
	if is_spinning:
		spin_timer += delta
		
		if spin_timer < fast_spin_time:
			# Fast spinning phase - change items rapidly
			change_item_fast(delta)
		elif spin_timer < fast_spin_time + slow_spin_time:
			# Slow down phase - gradually slow item changes
			change_item_slow(delta)
		else:
			# Finished - land on target
			land_on_target()

func change_item_fast(delta):
	var speed = lerp(0.05, 0.3, 0.1) 
	
	item_change_speed += delta
	if item_change_speed >= speed:
		item_change_speed = 0.0
		current_item_index = (current_item_index + 1) % global.tile_icons.size()
		display_spot.texture = global.tile_icons[global.tile_icons.keys()[current_item_index]]

func change_item_slow(delta):
	# Gradually slow down the item changes
	var slow_progress = (spin_timer - fast_spin_time) / slow_spin_time
	var speed = lerp(0.05, 0.3, slow_progress)  # Slower changes over time
	
	item_change_speed += delta
	if item_change_speed >= speed:
		item_change_speed = 0.0
		current_item_index = (current_item_index + 1) % global.tile_icons.size()
		display_spot.texture = global.tile_icons[global.tile_icons.keys()[current_item_index]]

func land_on_target():
	is_spinning = false
	display_spot.texture = global.tile_icons[global.tile_icons.keys()[target_item_index]]
	celebrate_win()

func celebrate_win():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Scale up
	tween.tween_property(display_spot, "scale", Vector2(1.3, 1.3), 0.3)
	
	# Change color to gold
	tween.tween_property(display_spot, "modulate", Color.GOLD, 0.3)
	
	# Bounce effect
	var original_y = display_spot.position.y
	tween.tween_property(display_spot, "position:y", original_y - 15, 0.15)
	tween.tween_property(display_spot, "position:y", original_y, 0.15).set_delay(0.15)
	
	#emit_confetti()
	
	display_spot.queue_redraw()
	
	move_item_to_player()

func emit_confetti():
	confetti_particle.emitting = true
	await confetti_particle.finished
	await get_tree().create_timer(0.1).timeout
	confetti_particle.queue_free()

func move_item_to_player():
	var tween = create_tween()
	var distance = display_spot.global_position.distance_to(player.global_position) / 5
	var duration = distance * 0.05
	
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(display_spot, "global_position", player.global_position, duration)
	await tween.finished
	
	var tile_name = global.tile_icons.keys()[target_item_index]
	var item = global.item_resources[tile_name]
	item.item_name = tile_name
	if tile_name != "bomb":
		item.quantity = (global.drop_amount() + randi_range(1,2)) * 5
	else:
		item.quantity = global.drop_amount() * 2
	item.texture = global.tile_icons[tile_name]
	if tile_name == "bomb":
		item.is_usable = true
		print("chest item is a BOMB")
	player.inventory.insert(item,false)
	
	queue_free()
	
func _on_interact_area_area_entered(area: Area2D) -> void:
	can_open = true
	SignalBus.show_interact_bubble.emit()
	player = area.owner
	
func _on_interact_area_area_exited(area: Area2D) -> void:
	can_open = false
	SignalBus.hide_interact_bubble.emit()
