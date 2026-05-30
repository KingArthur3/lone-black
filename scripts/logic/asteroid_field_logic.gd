extends Logic
class_name AsteroidFieldLogic
## Manages dynamic asteroid spawning and cleanup around the player.

@export var asteroid_scene: PackedScene
@export var asteroid_spawn_distance := 2000.0
@export var asteroid_despawn_distance := 2500.0
@export var grid_cell_size := 350 # Increased default to 350 for better spacing

var asteroid_zones: Dictionary = {}
var active_asteroids: Array[Node2D] = []


func update_field(player_pos: Vector2) -> void:
	var current_zone = world_to_zone(player_pos)
	var zone_radius := int(ceil(asteroid_spawn_distance / grid_cell_size))

	for x in range(current_zone.x - zone_radius, current_zone.x + zone_radius + 1):
		for y in range(current_zone.y - zone_radius, current_zone.y + zone_radius + 1):
			var zone := Vector2i(x, y)
			var zone_world_pos = zone_to_world(zone)
			if player_pos.distance_to(zone_world_pos) < asteroid_spawn_distance and not asteroid_zones.has(zone):
				spawn_asteroids_in_zone(zone)

	cleanup_distant_asteroids(player_pos)


func world_to_zone(pos: Vector2) -> Vector2i:
	return Vector2i(floor(pos.x / grid_cell_size), floor(pos.y / grid_cell_size))


func zone_to_world(zone: Vector2i) -> Vector2:
	return Vector2(zone) * grid_cell_size


func spawn_asteroids_in_zone(zone: Vector2i) -> void:
	if asteroid_scene == null:
		return

	var zone_pos = zone_to_world(zone)
	var asteroids_in_zone: Array[Node2D] = []

	# Determine zone density type
	var rand_val = randf()
	var asteroid_count := 0
	
	# Minimum distance between asteroids (scales based on density to avoid overlapping)
	# Large asteroids can have a radius up to 40px, so 40+40=80px + margin is required
	var min_dist := 110.0 

	if rand_val < 0.35:
		# 35% chance: Empty space (Void Zone) - for fast boosting and breathing room
		asteroid_count = 0
	elif rand_val < 0.75:
		# 40% chance: Scattered / Lone Asteroids (1-2 asteroids per zone)
		asteroid_count = randi_range(1, 2)
		min_dist = 130.0 # Keep them well-separated
	elif rand_val < 0.95:
		# 20% chance: Medium Cluster (3-5 asteroids)
		asteroid_count = randi_range(3, 5)
		min_dist = 95.0
	else:
		# 5% chance: Dense Asteroid Belt (6-9 asteroids) - forms a natural maze
		asteroid_count = randi_range(6, 9)
		min_dist = 75.0

	var max_attempts := 20

	for _i in asteroid_count:
		var success := false
		var attempt := 0

		while not success and attempt < max_attempts:
			var offset = Vector2(randf_range(0, grid_cell_size), randf_range(0, grid_cell_size))
			var spawn_pos = zone_pos + offset

			var too_close := false
			
			# Check against already spawned asteroids in this zone
			for existing in asteroids_in_zone:
				if is_instance_valid(existing) and existing.global_position.distance_to(spawn_pos) < min_dist:
					too_close = true
					break
			
			# Check against active asteroids in neighboring zones to prevent edge overlaps
			if not too_close:
				for existing in active_asteroids:
					if is_instance_valid(existing) and existing.global_position.distance_to(spawn_pos) < min_dist:
						too_close = true
						break

			if not too_close:
				var asteroid = asteroid_scene.instantiate() as Node2D
				asteroid.global_position = spawn_pos
				
				var world_root: Node = Helpers.game if is_instance_valid(Helpers.game) else get_tree().current_scene
				world_root.add_child(asteroid)
				asteroids_in_zone.append(asteroid)
				success = true

			attempt += 1

	asteroid_zones[zone] = true
	
	# Append only valid instances to the active list
	for ast in asteroids_in_zone:
		if is_instance_valid(ast):
			active_asteroids.append(ast)


func cleanup_distant_asteroids(player_pos: Vector2) -> void:
	var zones_to_remove: Array[Vector2i] = []

	# Despawn asteroids in far-away zones
	for zone in asteroid_zones.keys():
		var zone_pos = zone_to_world(zone)
		if player_pos.distance_to(zone_pos) > asteroid_despawn_distance:
			for asteroid in active_asteroids:
				# Use a buffer multiplier (1.5) to capture all asteroids belonging to the cell
				if is_instance_valid(asteroid) and asteroid.global_position.distance_to(zone_pos) < grid_cell_size * 1.5:
					asteroid.queue_free()
			zones_to_remove.append(zone)

	for zone in zones_to_remove:
		asteroid_zones.erase(zone)
		
	# Clean up freed/null references from the active_asteroids array to prevent memory growth
	var clean_active: Array[Node2D] = []
	for asteroid in active_asteroids:
		if is_instance_valid(asteroid):
			clean_active.append(asteroid)
	active_asteroids = clean_active
