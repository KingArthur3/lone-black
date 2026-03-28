extends Logic
class_name AsteroidFieldLogic
## Manages dynamic asteroid spawning and cleanup around the player.

@export var asteroid_scene: PackedScene
@export var asteroid_spawn_distance := 2000.0
@export var asteroid_despawn_distance := 2500.0
@export var grid_cell_size := 200

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

	var asteroid_count = randi_range(2, 8) if randi_range(0, 10) == 0 else 0
	var min_distance_between_asteroids := 64.0
	var max_attempts := 10

	for _i in asteroid_count:
		var success := false
		var attempt := 0

		while not success and attempt < max_attempts:
			var offset = Vector2(randf_range(0, grid_cell_size), randf_range(0, grid_cell_size))
			var spawn_pos = zone_pos + offset

			var too_close := false
			for existing in asteroids_in_zone:
				if existing.global_position.distance_to(spawn_pos) < min_distance_between_asteroids:
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
	active_asteroids.append_array(asteroids_in_zone)


func cleanup_distant_asteroids(player_pos: Vector2) -> void:
	var zones_to_remove: Array[Vector2i] = []

	for zone in asteroid_zones.keys():
		var zone_pos = zone_to_world(zone)
		if player_pos.distance_to(zone_pos) > asteroid_despawn_distance:
			for asteroid in active_asteroids:
				if is_instance_valid(asteroid) and asteroid.global_position.distance_to(zone_pos) < grid_cell_size:
					asteroid.queue_free()
			zones_to_remove.append(zone)

	for zone in zones_to_remove:
		asteroid_zones.erase(zone)
