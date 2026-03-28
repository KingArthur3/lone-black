extends Node2D

# --- CONFIGURABLE ---
@export var asteroid_scene: PackedScene
@export var player: NodePath
@export var asteroid_spawn_distance := 2000.0
@export var asteroid_despawn_distance := 2500.0
@export var grid_cell_size := 200

@onready var info_text : Label = $"Player/PlayerCamera/UI/InfoText"

# --- INTERNAL ---
var player_node: Node2D
var asteroid_zones = {}
var active_asteroids = []

# Game state
var game_started := false  # becomes true once player moves

func _ready():
	player_node = get_node(player)

func _process(delta):
	if not player_node:
		if not info_text.visible:
			info_text.text = "Press R to restart"
			info_text.visible = true
		return

	var player_pos = player_node.global_position
	var current_zone = world_to_zone(player_pos)

	# --- Always run this ---
	# Asteroid spawning logic
	var zone_radius = ceil(asteroid_spawn_distance / grid_cell_size)
	for x in range(current_zone.x - zone_radius, current_zone.x + zone_radius + 1):
		for y in range(current_zone.y - zone_radius, current_zone.y + zone_radius + 1):
			var zone = Vector2(x, y)
			var zone_world_pos = zone_to_world(zone)
			if player_pos.distance_to(zone_world_pos) < asteroid_spawn_distance:
				if not asteroid_zones.has(zone):
					spawn_asteroids_in_zone(zone)
	cleanup_distant_asteroids(player_pos)

	# --- Wait for input before starting the game ---
	if not game_started:
		if Input.is_action_just_pressed("thrust"):
			start_game()

func start_game():
	game_started = true
	info_text.visible = false

func _input(event):
	if event.is_action_pressed("quit"):
		get_tree().quit()
	elif event.is_action_pressed("fullscreen"):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
	elif event.is_action_pressed("restart"):
		call_deferred("restart_game")

func restart_game():
	var scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(scene_path)

# --- Helpers ---
func world_to_zone(pos: Vector2) -> Vector2:
	return Vector2(floor(pos.x / grid_cell_size), floor(pos.y / grid_cell_size))

func zone_to_world(zone: Vector2) -> Vector2:
	return zone * grid_cell_size

func spawn_asteroids_in_zone(zone: Vector2):
	var zone_pos = zone_to_world(zone)
	var asteroids_in_zone = []

	var asteroid_count = randi_range(2, 8) if randi_range(0, 10) == 0 else 0
	var min_distance_between_asteroids := 64.0
	var max_attempts := 10

	for i in asteroid_count:
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
				add_child(asteroid)
				asteroids_in_zone.append(asteroid)
				success = true

			attempt += 1

	asteroid_zones[zone] = true
	active_asteroids.append_array(asteroids_in_zone)

func cleanup_distant_asteroids(player_pos: Vector2):
	var zones_to_remove = []

	for zone in asteroid_zones.keys():
		var zone_pos = zone_to_world(zone)
		if player_pos.distance_to(zone_pos) > asteroid_despawn_distance:
			for asteroid in active_asteroids:
				if is_instance_valid(asteroid) and asteroid.global_position.distance_to(zone_pos) < grid_cell_size:
					asteroid.queue_free()
			zones_to_remove.append(zone)

	for zone in zones_to_remove:
		asteroid_zones.erase(zone)
