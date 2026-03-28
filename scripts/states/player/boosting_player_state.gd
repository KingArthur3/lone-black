extends State
class_name Boosting
## Boosting player state
##
## Player that is currently boosting

@onready var engine_component: EngineComponent = $"../../Components/EngineComponent"
@onready var health_component: HealthComponent = $"../../Components/HealthComponent"
@onready var shooting_component: ShootingComponent = $"../../Components/ShootingComponent"
@onready var player_movement_component: PlayerMovementComponent= $"../../Components/PlayerMovementComponent"

func enter() -> void:
	player_movement_component.can_boost = false
	if player_movement_component.boost_icon:
		player_movement_component.boost_icon.visible = false
	
	var lambda = func():
		finished.emit(self, "IdlePlayerState")
	player_movement_component.boost_duration_timer.timeout.connect(lambda)

	player_movement_component.boost_duration_timer.start()
	
	engine_component.boosting = true
	engine_component.intensity = 10
	engine_component.start()
	

func exit() -> void:
	player_movement_component.boost_reload_timer.start()
	
	engine_component.boosting = false
	engine_component.intensity = 0
	engine_component.stop()


func physics_update(_delta: float) -> void:
	player_movement_component.rotate_towards_mouse()	
	player_movement_component.thrust_forward_with_boost()
	player_movement_component.slow_down_boost_if_needed()
		
	if Input.is_action_pressed("shoot") and shooting_component.can_shoot:
		shooting_component.shoot()
