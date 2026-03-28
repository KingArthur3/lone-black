extends Component2D
class_name EngineComponent
## Engine component
##
## Provides particles and sound for space vechicles with engines

@export var autostart : bool = false
@export var base_particles_amount : int = 10
@export var volume_fade_duration : float = 2.0
@export var max_volume_db : float = 0.0
@export var min_volume_db : float = -80.0
@export var engine_particles : Texture2D
@export var boost_particles : Texture2D
@export var engine_sound : AudioStream

@onready var engine_particles_emitter : CPUParticles2D = $"EngineParticles"
@onready var boost_particles_emitter : CPUParticles2D = $"BoostParticles"
@onready var engine_sound_player : AudioStreamPlayer2D = $"EngineSound"
@onready var intensity : float = 0:
	set(new_intensity):
		intensity = new_intensity
		engine_particles_emitter.amount = int(round(base_particles_amount + intensity))
		if engine_on:
			_fade_id += 1
			fade_volume_to(max_volume_db + intensity, _fade_id)

var boosting : bool = false:
	set(new_boosting):
		boosting = new_boosting
		boost_particles_emitter.emitting = new_boosting

var engine_on : bool = false		
var _fade_id := 0  # Used to cancel or ignore outdated fades

func _ready() -> void:
	intensity = 0
	engine_particles_emitter.texture = engine_particles
	boost_particles_emitter.texture = boost_particles
	engine_sound_player.stream = engine_sound
	
	if autostart:
		start()

func start():
	engine_on = true
	if engine_particles:
		engine_particles_emitter.emitting = true
	
	_fade_id += 1  # Cancel any previous fade
	if not engine_sound_player.playing:
		engine_sound_player.volume_db = min_volume_db
		engine_sound_player.play()
	await fade_volume_to(max_volume_db + intensity, _fade_id)
	

func stop():
	engine_on = false
	
	if engine_particles:
		engine_particles_emitter.emitting = false
	
	_fade_id += 1  # Cancel any previous fade
	var current_fade = _fade_id
	await fade_volume_to(min_volume_db, current_fade)
	if _fade_id == current_fade:  # Only stop if no newer fade started
		engine_sound_player.stop()

func fade_volume_to(target_db: float, fade_id: int) -> void:
	var initial_db := engine_sound_player.volume_db
	var time_passed := 0.0

	while time_passed < volume_fade_duration:
		if fade_id != _fade_id:
			return  # A newer fade started; exit this one

		await get_tree().process_frame  # More efficient than creating a zero-time timer
		var delta := get_process_delta_time()
		time_passed += delta

		var t : float = clamp(time_passed / volume_fade_duration, 0.0, 1.0)
		engine_sound_player.volume_db = lerp(initial_db, target_db, t)

	# Ensure final value is set if fade hasn't been interrupted
	if fade_id == _fade_id:
		engine_sound_player.volume_db = target_db
