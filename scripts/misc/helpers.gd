extends Node

var game : Node
var player : Node
var player_camera : Node
var ui : Node
var vhs_shader : Node

func _ready() -> void:
	game = $"../Game"
	player = $"../Game/Player"
	player_camera = $"../Game/Player/PlayerCamera"
	ui = $"../Game/Player/PlayerCamera/UI"
	vhs_shader = $"../Game/Player/PlayerCamera/VHSShader"


func play_random(audio_player: AudioStreamPlayer2D) -> void:
	if audio_player.stream == null:
		push_error("AudioStreamPlayer2D has no stream assigned.")
		return

	# Get the total duration of the stream
	var duration = audio_player.stream.get_length()
	if duration <= 0:
		push_error("Audio stream has invalid or unknown duration.")
		return

	# Choose a random starting point
	var random_start_time = randf() * duration

	# Seek to that time and play
	audio_player.seek(random_start_time)
	audio_player.play()
