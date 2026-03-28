extends Component2D
class_name ShootingComponent
## Shooting component
##
## Allows the object to fire bullets

@export var reload_time : float = 0.5
@export var bullet_scene : PackedScene
@export var bullet_force : float = 500           # Speed of the bullet
@export var recoil_amount : float = 100           # Amount of recoil force

@onready var reload_timer : Timer = $"ReloadTimer"
@onready var shoot_sound : AudioStreamPlayer2D = $"ShootSound"

var can_shoot : bool = false


func _ready() -> void:
	reload_timer.wait_time = reload_time


func _on_reload_timer_timeout() -> void:
	can_shoot = true
	
func shoot() -> void:
	if bullet_scene:
		shoot_sound.play()

		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.rotation = object.rotation

		var shoot_direction = Vector2.RIGHT.rotated(object.rotation)
		bullet.linear_velocity = object.linear_velocity + shoot_direction * bullet_force

		get_tree().current_scene.add_child(bullet)

		recoil()
	can_shoot = false
	reload_timer.start()

		
func recoil() -> void:
	var direction = Vector2.LEFT.rotated(object.rotation)
	var force = direction * recoil_amount
	object.apply_central_force(force)
