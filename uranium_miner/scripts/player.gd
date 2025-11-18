extends CharacterBody2D

@onready var camera: Camera2D = $Camera2D
@onready var mining_raycast: RayCast2D = $MiningRaycast
@onready var line_2d: Line2D = $Line2D
@onready var mining_delay_timer: Timer = $MiningDelayTimer
@onready var particle_scene = preload("res://scenes/block_breaking_particles.tscn")
@onready var bomb_scene = preload("res://scenes/bomb.tscn")
@onready var interact_bubble: Sprite2D = $InteractBubble
@onready var inventory_ui: Control = $CanvasLayer/InventoryUI
@onready var money_label: Label = $CanvasLayer/PlayerHUD/NinePatchRect/MoneyLabel
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var player_hitbox: Area2D = $PlayerHitbox
@onready var player_animations: AnimationPlayer = $PlayerAnimations
@onready var tooltip: Control = $CanvasLayer/Tooltip
@onready var anim_effects: AnimatedSprite2D = $AnimEffects
@onready var walk_trail: CPUParticles2D = $PlayerSprite/WalkTrail
@onready var vignette_rect: ColorRect = $CanvasLayer/VignetteRect

@export var tilemap: TileMapLayer
@export var mining_direction := Vector2.ZERO
@export var inventory: Inventory

var normal_speed := 210.0
var airborne_speed := normal_speed * 1.3

var gravity := 42.0
var jump_velocity: float = 450.0
var climb_velocity: float = 250.0
var direction
var camera_offset_y = global.level_camera_offset
var can_mine := true
var can_jump := true

var is_mining := false
var current_mining_tile = Vector2i(-1, -1)
var mining_progress := 0.0
var mining_time_req = global.player_stats["mining_speed"]
var last_mining_dir := Vector2.ZERO

var can_interact = false
var max_sin_val: float = 1.0
var bubble_sin_value: float = 0.0
var bubble_speed: float = 4.0
var bubble_amplitude: float = 5.0
var was_airborne: bool

const CRACK_STAGES = 9  
const BLOCK_TYPES = 5  

var current_touched_tile
var ladder_atlas_pos = global.ladder_atlas_position
var can_climb: bool = false

func _ready() -> void:
	if get_tree().current_scene.name == "mine":
		vignette_rect.visible = true
	else:
		vignette_rect.visible = false
		
	inventory.update.connect(inventory_ui.update_slots)
	money_label.text = str(global.player_money) + "$"
	tooltip.visible = false
	
	#vignette_rect.visible = false
	
	player_sprite.flip_h = true
	
	SignalBus.show_interact_bubble.connect(show_interact_bubble)
	SignalBus.hide_interact_bubble.connect(hide_interact_bubble)
	SignalBus.show_cutout.connect(show_cutout)
	SignalBus.hide_cutout.connect(hide_cutout)
	
	change_cutout_size()
	
func show_cutout():
	tween_cutout(150.0, 0.1)
func hide_cutout():
	tween_cutout(210.0, 0.1)
func tween_cutout(new_size, duration):
	var mat = vignette_rect.material as ShaderMaterial
	var tween = create_tween()
	
	var current_cutout = mat.get_shader_parameter("cutout_size")
	
	tween.tween_method(
		func(value): mat.set_shader_parameter("cutout_size", value),
		current_cutout, new_size, duration
	)
func show_tooltip(text):
	tooltip.visible = true
	tooltip.show_text(text)
	await tooltip.finished_printing
	await get_tree().create_timer(1.0).timeout
	tooltip.visible = false
func show_interact_bubble():
	can_interact = true
	interact_bubble.visible = true
func hide_interact_bubble():
	can_interact = false
	interact_bubble.visible = false
func change_cutout_size():
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_set_cutout_size, global.default_cutout_size, global.max_cutout_size, global.delta_cutout_size + randf_range(-1.0,1.5))
	tween.tween_method(_set_cutout_size, global.max_cutout_size, global.default_cutout_size, global.delta_cutout_size + randf_range(-1.0,1.5))
	
func _set_cutout_size(val: float):
	var cutout_material = vignette_rect.material as ShaderMaterial
	cutout_material.set_shader_parameter("fade_width", val)
	
func _physics_process(delta: float) -> void:
	if get_tree().paused: return
	direction = Input.get_axis("player_left","player_right")
	
	if not is_on_floor():
		velocity.y += gravity
		was_airborne = true
	
	if velocity.x and is_on_floor():
		walk_trail.emitting = true 
	else:
		walk_trail.emitting = false
	
	if velocity.y > 0:
		anim_effects.visible = true
		anim_effects.play("big_fall")
	
	if is_on_floor():
		velocity.x = direction * normal_speed
		if was_airborne:
			show_fall_effect()
			was_airborne = false
	elif can_climb:
		velocity.x = direction * normal_speed
	else:
		velocity.x = direction * airborne_speed
		
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y -= jump_velocity
	
	if Input.is_action_pressed("player_jump") and can_climb:
		velocity.y = -climb_velocity
	
	if direction < 0:
		player_sprite.flip_h = true
	elif direction > 0:
		player_sprite.flip_h = false
	
	if direction > 0:
		if is_mining:
			player_animations.play("mining")
		else:
			player_animations.play("idle")
		
	elif direction < 0:
		if is_mining:
			player_animations.play("mining")
		else:
			player_animations.play("idle")
	
	elif is_mining:
		player_animations.play("mining")
	
	move_and_slide()

func _process(delta: float) -> void:
	handle_mining_input()
	mining_raycast.target_position = mining_direction * 20.0
	if is_mining:
		update_mining(delta)
	
	interact_bubble.visible = can_interact
	
	if bubble_sin_value > PI:
		bubble_sin_value = -PI
	
	if interact_bubble.visible:
		interact_bubble.global_position.y += sin(bubble_sin_value) * bubble_amplitude * delta
		bubble_sin_value += bubble_speed * delta
		
	money_label.text = str(global.player_money) + "$"
	if tilemap:
		current_touched_tile = tilemap.get_cell_atlas_coords(tilemap.local_to_map(self.position))
		if current_touched_tile == ladder_atlas_pos:
			can_climb = true
		else:
			can_climb = false
	
	if Input.is_action_just_pressed("use_item") and inventory.slots[global.current_hand_slot - 1].item:
		if inventory.slots[global.current_hand_slot - 1].item.is_usable:
			if inventory.slots[global.current_hand_slot - 1].quantity > 1:
				inventory.slots[global.current_hand_slot - 1].quantity -= 1
			else:
				inventory.slots[global.current_hand_slot - 1].item = null
			inventory.update.emit()
			spawn_bomb()

func show_fall_effect():
	anim_effects.visible = true
	anim_effects.play("landing")
	await anim_effects.animation_finished
	anim_effects.visible = false
	
func spawn_bomb():
	var bomb_instance: Bomb = bomb_scene.instantiate()
	bomb_instance.global_position = tilemap.map_to_local(tilemap.local_to_map(global_position))
	bomb_instance.tilemap = tilemap
	bomb_instance.player_inventory = inventory
	get_parent().add_child(bomb_instance)
	
func start_mining(direction):
	if not tilemap.name == "cave":
		return
		
	var player_tile_pos = tilemap.local_to_map(global_position)
	var target_tile = player_tile_pos + Vector2i(round(direction.x), round(direction.y))

	if target_tile != current_mining_tile:
		stop_mining()
		current_mining_tile = target_tile
		
		var atlas_coords = tilemap.get_cell_atlas_coords(target_tile)
		var source_id = tilemap.get_cell_source_id(target_tile)
		
		if source_id != -1 and atlas_coords.y > 0:
			is_mining = true
			mining_progress = 0.0
			#show_mining_effect(target_tile, true)
		else:
			is_mining = false
			current_mining_tile = Vector2i(-1, -1)
	else:
		if !is_mining:
			is_mining = true

func stop_mining():
	if is_mining:
		is_mining = false
		mining_progress = 0.0

func update_mining(delta):
	if !is_mining:
		return
	
	# Update mining progress
	mining_progress += delta
	
	# Update tile cracking visual
	update_tile_cracking()
	
	# Visual feedback
	update_mining_visuals()
	
	# Check if block is broken
	if mining_progress >= mining_time_req:
		break_current_tile()
		stop_mining()

func update_tile_cracking():
	var progress_ratio = mining_progress / mining_time_req
	var crack_stage = int(progress_ratio * CRACK_STAGES)
	
	# Get current tile data to preserve block type (row)
	var current_atlas_coords = tilemap.get_cell_atlas_coords(current_mining_tile)
	var source_id = tilemap.get_cell_source_id(current_mining_tile)
	
	if source_id != -1:
		# Update to the appropriate crack stage
		# Column 0 = no crack, Column 1-9 = crack stages
		var new_crack_column = min(crack_stage + 1, CRACK_STAGES)  # +1 because column 0 is no crack
		var new_atlas_coords = Vector2i(new_crack_column, current_atlas_coords.y)
		
		tilemap.set_cell(current_mining_tile, source_id, new_atlas_coords)

func update_mining_visuals():
	var progress_ratio = mining_progress / mining_time_req
	
	# Visual feedback - change line color based on progress
	line_2d.default_color = Color(1.0, 1.0 - progress_ratio, 0.0)  # Yellow to Red
	
	var crack_stage = int(progress_ratio * CRACK_STAGES) + 1

func break_current_tile():
	var atlas_coords = tilemap.get_cell_atlas_coords(current_mining_tile)
	var source_id = tilemap.get_cell_source_id(current_mining_tile)
	var block_type = atlas_coords.y
	
	var tile_name = global.tiles.find_key(Vector2(0,block_type))
	if source_id != -1:
		tilemap.set_cell(current_mining_tile, -1)
		spawn_break_effect(current_mining_tile, block_type)
		var item = global.item_resources[tile_name]
		item.item_name = tile_name
		item.quantity = global.drop_amount()
		item.texture = global.tile_icons[tile_name]
		if block_type == 7:
			item.is_usable = true
		inventory.insert(item,false)
		
func spawn_break_effect(tile_pos: Vector2i, block_type: int):
	var world_pos = tilemap.map_to_local(tile_pos)
	
	var particles = particle_scene.instantiate()
	get_parent().add_child(particles)
	particles.position = tilemap.map_to_local(tile_pos)
	particles.emitting = true
	
func show_mining_effect(tile_pos: Vector2i, show: bool):
	if show:
		# Make the mining line visible
		line_2d.visible = true
		line_2d.default_color = Color.YELLOW
	else:
		# Hide or reset the mining line
		line_2d.visible = false
		line_2d.default_color = Color.WHITE	

func handle_mining_input():
	var new_mining_direction = Vector2.ZERO
	
	# Check directional inputs
	if Input.is_action_pressed("player_right"):
		new_mining_direction.x += 1
	if Input.is_action_pressed("player_left"):
		new_mining_direction.x -= 1
	if Input.is_action_pressed("player_down"):
		new_mining_direction.y += 1
	if Input.is_action_pressed("player_up"):
		new_mining_direction.y -= 1
	
	# Normalize if diagonal (optional)
	if new_mining_direction.length() > 0:
		new_mining_direction = new_mining_direction.normalized()
	
	# Check if mining direction changed or stopped
	if new_mining_direction != last_mining_dir || new_mining_direction == Vector2.ZERO:
		stop_mining()
	
	# Start new mining if direction is pressed
	if new_mining_direction != Vector2.ZERO:
		last_mining_dir = new_mining_direction
		mining_direction = new_mining_direction
		start_mining(mining_direction)

func _on_mining_delay_timer_timeout() -> void:
	#can_mine = true
	pass
