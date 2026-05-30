extends Component
class_name HealthComponent
## Health component
##
## Manages health of this object and destroys it
## if health reaches 0

@export var health : int:
	set(new_health):
		health = new_health
		if health_bar:
			health_bar.value = new_health if new_health >= 0 else 0
@export var health_bar_path : NodePath
@export var hit_sprite_frame : int = -1
@export var hit_sprite_duration : float = 0.1
@export var explosion_scene : PackedScene
@export var smoke_scene : PackedScene
@export var death_camera_shake_intensity : float = 10
@export var death_camera_shake_time_ms : int = 1000

@onready var health_bar : TextureProgressBar = get_node(health_bar_path) if health_bar_path else null
@onready var hit_sprite_duration_timer: Timer = $"HitSpriteDurationTimer"

func _ready() -> void:
	hit_sprite_duration_timer.wait_time = hit_sprite_duration
	if health_bar:
			health_bar.value = health

func _on_hit_sprite_duration_timer_timeout() -> void:
	sprite.frame = 0


var is_damaged : bool = false

func damage(amount : int = 1):
	is_damaged = true
	health -= amount
	if health <= 0:
		if explosion_scene:
			explode()
		if smoke_scene:
			smoke()
		destroy()
	
	if not hit_sprite_frame == -1:
		sprite.frame = hit_sprite_frame
		hit_sprite_duration_timer.start()

func explode() -> void:
	var explosion = explosion_scene.instantiate()
	explosion.global_position = object.global_position
	get_tree().current_scene.add_child(explosion)


func smoke() -> void:
	var smoke_instance = smoke_scene.instantiate()
	smoke_instance.global_position = object.global_position
	get_tree().current_scene.add_child(smoke_instance)


func destroy() -> void:
	Helpers.player_camera.shake_camera(death_camera_shake_time_ms, death_camera_shake_intensity)
	if object == Helpers.player_camera.get_parent():
		Helpers.player_camera.free_from_parent()
	object.queue_free()
