extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var boom_timer: Timer = $BoomTimer
@onready var bomb_sprite: Sprite2D = $BombSprite
@onready var explosion: Sprite2D = $explosion
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

var player_inventory
var tilemap
var shader_material: ShaderMaterial

func _ready() -> void:
	explosion.visible = false
	scale_explosion()
	
	collision_shape_2d.shape.radius = global.tile_size * global.bomb_radius
	boom_timer.start(2.0)

func scale_explosion():
	var original_size = explosion.texture.get_size()
	var original_polomer = max(original_size.x, original_size.y) / 2
	
	var scale_coeff = (global.bomb_radius * global.tile_size) / original_polomer
	explosion.scale = Vector2(1+scale_coeff,1+scale_coeff)
	explosion.position = Vector2(0,0)
	
func _process(delta):
	if boom_timer.time_left > 0:
		update_whitening_effect()

func destroy_tiles_in_radius():
	if not tilemap:
		push_error("TileMap not found!")
		return
	
	var bomb_center = global_position
	var bomb_radius = collision_shape_2d.shape.radius
	
	# Convert world position to tile coordinates
	var center_tile = tilemap.local_to_map(bomb_center)
	var radius_in_tiles = ceil(bomb_radius / global.tile_size)
	
	# Calculate the bounding box in tile coordinates
	var top_left = center_tile - Vector2i(radius_in_tiles, radius_in_tiles)
	var bottom_right = center_tile + Vector2i(radius_in_tiles, radius_in_tiles)
	
	# Iterate through all tiles in the bounding box
	for x in range(top_left.x, bottom_right.x + 1):
		for y in range(top_left.y, bottom_right.y + 1):
			var tile_pos = Vector2i(x, y)
			var tile_world_pos = tilemap.map_to_local(tile_pos)
			
			# Check if tile exists and is within the actual circle radius
			if tilemap.get_cell_source_id(tile_pos) != -1:
				var distance = bomb_center.distance_to(tile_world_pos)
				if distance <= bomb_radius:
					destroy_tile(tile_pos)

func destroy_tile(tile_pos: Vector2i):
	var atlas_coords = tilemap.get_cell_atlas_coords(tile_pos)
	var source_id = tilemap.get_cell_source_id(tile_pos)
	
	if source_id != -1:
		# Get tile name for item dropping
		var tile_name = global.tiles.find_key(Vector2(0, atlas_coords.y))
		
		# Remove the tile
		tilemap.set_cell(tile_pos, -1)
		if tile_name and player_inventory:
			var item = global.item_resources[tile_name]
			item.item_name = tile_name
			item.quantity = global.drop_amount()
			item.texture = global.tile_icons[tile_name]
			if atlas_coords.y == 7:
				item.is_usable = true
			player_inventory.insert(item)	
					
func update_whitening_effect():
	var time_remaining = boom_timer.time_left
	var total_time = boom_timer.wait_time
	var progress = 1.0 - (time_remaining / total_time)
	
	# Set the shader uniform
	bomb_sprite.material.set_shader_parameter("whiteness", progress)

func blow():
	explosion.visible = true
	animation_player.play("explode")
	cpu_particles_2d.emitting = true
	bomb_sprite.material.set_shader_parameter("whiteness", 1.5)
	await get_tree().create_timer(0.1).timeout
	destroy_tiles_in_radius()
	await animation_player.animation_finished
	explosion.visible = false
	queue_free()

func _on_boom_timer_timeout() -> void:
	blow()
