extends TextureProgressBar

# Timer for blinking
var blink_timer := 0.0
var is_blinking := false
var blink_interval := 0.3  # seconds
var visible_state := true  # current visibility toggle

func _process(delta: float) -> void:
	# Check if health is 1
	if value == 1:
		if not is_blinking:
			is_blinking = true
			blink_timer = 0.0
	else:
		# Reset if health is not 1
		is_blinking = false
		visible = true  # Ensure it's visible when not blinking
		return

	# If blinking, update the blink timer
	if is_blinking:
		blink_timer += delta
		if blink_timer >= blink_interval:
			blink_timer = 0.0
			visible_state = not visible_state
			visible = visible_state
