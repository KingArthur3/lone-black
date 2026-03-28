extends State
class_name IdlePlayerState
## State for an idle player
##
## a blueprint for states managed by the state machine

@onready var engine_component: EngineComponent = $"../../Components/EngineComponent"
@onready var shooting_component: ShootingComponent = $"../../Components/ShootingComponent"
@onready var player_movement_component: PlayerMovementComponent= $"../../Components/PlayerMovementComponent"

func physics_update(_delta: float) -> void:
	player_movement_component.rotate_towards_mouse()
	player_movement_component.slow_down_if_needed()
	
	if Input.is_action_pressed("thrust"):
		if player_movement_component.boost_double_click_interval_timer.time_left and player_movement_component.can_boost:
			finished.emit(self, "BoostingPlayerState")
		else:
			player_movement_component.boost_double_click_interval_timer.start()
			finished.emit(self, "ThrustingPlayerState")
		
	if Input.is_action_pressed("shoot") and shooting_component.can_shoot:
		shooting_component.shoot()
