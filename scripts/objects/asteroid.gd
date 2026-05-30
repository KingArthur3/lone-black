extends RigidBody2D
class_name Asteroid

@export var min_scale := 0.5
@export var max_scale := 2.5
@export var base_mass := 5.0  # Mass at scale = 1.0

# Procedural generation settings
@export var radius := 16.0
@export var roughness := 4.5
@export var curve_steps := 6   # Subdivision steps per corner curve

# Visual shading settings
@export var base_color := Color("2e2e33ff")
@export var light_direction := Vector2(-1.0, -1.0).normalized()
@export var light_intensity := 0.35

var _quads := []
var _quad_colors := []
var _inner_polygon := PackedVector2Array()
var _inner_color := Color()
var scale_factor := 1.0

# Destruction settings for small asteroids
var is_small := false
var health := 3
@export var explosion_scene : PackedScene = preload("res://scenes/objects/explosions/explosion_asteroid.tscn")

# Cache variables for specular edge highlight drawing
var _num_points := 0
var _outer_curves := []
var _inner_vertices := PackedVector2Array()
var _outer_vertices := PackedVector2Array()
var _quad_centers := []

func _ready() -> void:
	# Setup random size & mass
	rotation_degrees = randf_range(0.0, 360.0)
	scale_factor = randf_range(min_scale, max_scale)
	var custom_mass: float = base_mass * pow(scale_factor, 2)
	set_mass(custom_mass)
	
	# Determine if this is a small asteroid (around the player's scale, e.g. scale <= 1.1)
	is_small = (scale_factor <= 0.9)
	
	# Enable contact monitoring for collision detection if it's small
	if is_small:
		contact_monitor = true
		max_contacts_reported = 4
		body_entered.connect(_on_body_entered)
	
	# Generate procedural shape
	generate_asteroid_shape()

# Evaluates a quadratic Bezier curve to round the corner at current_pt
func get_corner_curve(prev_pt: Vector2, current_pt: Vector2, next_pt: Vector2, steps: int) -> PackedVector2Array:
	var start_pt = prev_pt.lerp(current_pt, 0.5)
	var control_pt = current_pt
	var end_pt = current_pt.lerp(next_pt, 0.5)
	
	var curve = PackedVector2Array()
	for step in range(steps + 1):
		var t = float(step) / float(steps)
		var omt = 1.0 - t
		var pt = omt * omt * start_pt + 2.0 * omt * t * control_pt + t * t * end_pt
		curve.append(pt)
	return curve

func generate_asteroid_shape() -> void:
	# Choose a random even number of boundary points (6, 8, 10, or 12)
	_num_points = randi_range(3, 6) * 2
	_outer_vertices = PackedVector2Array()
	_inner_vertices = PackedVector2Array()
	
	# Combined low-frequency wave amplitudes for organic, non-circular silhouettes
	var wave2_amp = randf_range(0.22, 0.38) * radius  # 2-lobed wave (elongates/makes peanut shaped)
	var wave3_amp = randf_range(0.12, 0.22) * radius  # 3-lobed wave (adds triangular character)
	
	# Randomize phases so the shapes point in different directions
	var phase2 = randf_range(0.0, 2.0 * PI)
	var phase3 = randf_range(0.0, 2.0 * PI)
	
	for i in range(_num_points):
		var angle = i * (2.0 * PI / _num_points) + randf_range(-0.05, 0.05)
		
		# Smooth low-frequency wave modulations
		var wave2 = cos(angle * 2.0 + phase2) * wave2_amp
		var wave3 = cos(angle * 3.0 + phase3) * wave3_amp
		
		# Low high-frequency roughness offset to keep it organic but prevent pointy spikes
		var offset = randf_range(-1.2, 1.2)
		var r_outer = radius + wave2 + wave3 + offset
		
		# Clamp radius to a minimum safe threshold to avoid self-intersection
		r_outer = max(r_outer, radius * 0.4)
		
		# Generate outer vertex
		var outer_pt = Vector2(cos(angle) * r_outer, sin(angle) * r_outer)
		_outer_vertices.append(outer_pt)
		
		# Generate inner vertex with slanted angle and varying radius
		var angle_inner = angle + randf_range(-0.16, 0.16) # Tilts the partition edges!
		var r_inner = r_outer * randf_range(0.45, 0.53)
		var inner_pt = Vector2(cos(angle_inner) * r_inner, sin(angle_inner) * r_inner)
		_inner_vertices.append(inner_pt)
		
	# Generate Bezier curves for all corners
	_outer_curves.clear()
	var inner_curves = []
	
	for i in range(_num_points):
		var prev_i = (i - 1 + _num_points) % _num_points
		var next_i = (i + 1) % _num_points
		
		var outer_curve = get_corner_curve(_outer_vertices[prev_i], _outer_vertices[i], _outer_vertices[next_i], curve_steps)
		var inner_curve = get_corner_curve(_inner_vertices[prev_i], _inner_vertices[i], _inner_vertices[next_i], curve_steps)
		
		_outer_curves.append(outer_curve)
		inner_curves.append(inner_curve)
		
	# Construct smooth outer boundary for physics collider
	var outer_boundary = PackedVector2Array()
	for i in range(_num_points):
		var curve = _outer_curves[i]
		for idx in range(curve.size() - 1):
			outer_boundary.append(curve[idx])
			
	# Apply collision polygon and scale it
	if has_node("CollisionPolygon2D"):
		var col_poly = $CollisionPolygon2D
		col_poly.polygon = outer_boundary
		col_poly.scale = Vector2.ONE * scale_factor
		
	# Construct smooth inner boundary for the single inner core polygon
	var inner_boundary = PackedVector2Array()
	for i in range(_num_points):
		var curve = inner_curves[i]
		for idx in range(curve.size() - 1):
			inner_boundary.append(curve[idx])
			
	_inner_polygon = inner_boundary
	_inner_color = base_color
	
	_quads.clear()
	_quad_colors.clear()
	_quad_centers.clear()
	
	# Generate N outer facets (each facet is a curved quad surrounding corner i)
	for i in range(_num_points):
		var facet = PackedVector2Array()
		# 1. Outer curve (forward)
		var outer_curve = _outer_curves[i]
		for pt in outer_curve:
			facet.append(pt)
		# 2. Inner curve (backward)
		var inner_curve = inner_curves[i]
		for idx in range(inner_curve.size() - 1, -1, -1):
			facet.append(inner_curve[idx])
			
		_quads.append(facet)
		
	# Compute colors and centers for all outer facets
	for quad in _quads:
		# Estimate center of the curved facet for lighting direction
		var sum = Vector2.ZERO
		for pt in quad:
			sum += pt
		var quad_center = sum / quad.size()
		_quad_centers.append(quad_center)
		
		var direction = quad_center.normalized()
		
		# Shading multiplier based on alignment to light source
		var dot = direction.dot(-light_direction) # range [-1, 1]
		var color_mult = 1.0 + dot * light_intensity
		
		var shade = Color(
			clamp(base_color.r * color_mult, 0.0, 1.0),
			clamp(base_color.g * color_mult, 0.0, 1.0),
			clamp(base_color.b * color_mult, 0.0, 1.0),
			1.0
		)
		_quad_colors.append(shade)
		
	queue_redraw()

func _draw() -> void:
	if _quads.is_empty() or _inner_polygon.is_empty():
		return
		
	# Scale the drawn coordinates to match the CollisionPolygon2D scale
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * scale_factor)
	
	# Draw the single inner core polygon
	draw_polygon(_inner_polygon, PackedColorArray([_inner_color]))
	
	# Draw all flat-shaded outer curved quads
	for i in range(_quads.size()):
		draw_polygon(_quads[i], PackedColorArray([_quad_colors[i]]))

func _on_body_entered(body: Node) -> void:
	if not is_small:
		return
		
	if body is Player:
		# Ramming destruction depends on relative velocity (sufficient impact speed)
		var relative_velocity = body.linear_velocity - linear_velocity
		var impact_speed = relative_velocity.length()
		
		# Base required speed is 60.0, scaled with the size of the asteroid
		if impact_speed >= 10.0 * scale_factor:
			destroy()
	elif body is Bullet:
		health -= 1
		if health <= 0:
			destroy()

func destroy() -> void:
	if explosion_scene:
		var explosion = explosion_scene.instantiate() as CPUParticles2D
		explosion.global_position = global_position
		
		# Scale the explosion size dynamically based on scale factor
		if "size" in explosion:
			explosion.size = explosion.size * scale_factor
			
		get_tree().current_scene.add_child(explosion)
		
	queue_free()
