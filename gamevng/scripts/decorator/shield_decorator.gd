class_name ShieldDecorator
extends PowerupDecorator
## Shield that absorbs a limited number of hits (regardless of damage amount)

var max_shield_hits: int = 3
var shield_hits_remaining: int = 3
var shield_visual: Node2D = null

# Pulse effect variables
var pulse_timer: float = 0.0
var pulse_speed: float = 3.0

# Flash effect on hit
var hit_flash_timer: float = 0.0
var hit_flash_duration: float = 0.2
var is_flashing: bool = false

func _init(target_player: Player, decorator_data: PowerupDecoratorData):
	super._init(target_player, decorator_data)
	
	# Get max hits from data if available
	if decorator_data.has_meta("shield_max_hits"):
		max_shield_hits = decorator_data.get_meta("shield_max_hits")
	
	shield_hits_remaining = max_shield_hits

func on_apply():
	super.on_apply()
	_create_shield_visual()
	print("Shield activated: %d hits remaining" % shield_hits_remaining)

func update(delta: float):
	super.update(delta)
	
	if shield_visual:
		# Pulsing shield effect
		if not is_flashing:
			pulse_timer += delta * pulse_speed
			var pulse = 0.6 + (sin(pulse_timer * PI * 2) * 0.2 + 0.2)
			shield_visual.modulate = Color(0.5, 0.8, 1.0, pulse)
		else:
			# Hit flash effect
			hit_flash_timer += delta
			if hit_flash_timer >= hit_flash_duration:
				is_flashing = false
				hit_flash_timer = 0.0
			else:
				# Flash white when hit
				var flash_intensity = 1.0 - (hit_flash_timer / hit_flash_duration)
				shield_visual.modulate = Color(1.0, 1.0, 1.0, 0.8 + flash_intensity * 0.2)
		
		# Scale based on remaining hits
		var scale_factor = 0.8 + (float(shield_hits_remaining) / float(max_shield_hits)) * 0.4
		shield_visual.scale = Vector2(scale_factor, scale_factor)

func on_remove():
	_destroy_shield_visual()
	super.on_remove()
	print("Shield deactivated")

func _create_shield_visual():
	# Create a circular shield sprite
	shield_visual = Node2D.new()
	shield_visual.name = "ShieldEffect"
	
	# Create the shield circle using a Sprite2D
	var shield_sprite = Sprite2D.new()
	
	# You can either:
	# Option 1: Use a pre-made shield texture
	# shield_sprite.texture = preload("res://assets/shield_circle.png")
	
	# Option 2: Create a simple circle programmatically
	var circle_texture = _create_circle_texture(64, Color(0.5, 0.8, 1.0, 0.5))
	shield_sprite.texture = circle_texture
	
	shield_visual.add_child(shield_sprite)
	shield_visual.z_index = -1  # Behind player
	
	# Add to player
	player.add_child(shield_visual)
	shield_visual.position = Vector2.ZERO

func _destroy_shield_visual():
	if shield_visual:
		# Optional: Play break animation/effect here
		shield_visual.queue_free()
		shield_visual = null

func _create_circle_texture(size: int, color: Color) -> ImageTexture:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	
	var center = Vector2(size / 2.0, size / 2.0)
	var radius = size / 2.0 - 2
	
	for x in range(size):
		for y in range(size):
			var pos = Vector2(x, y)
			var dist = pos.distance_to(center)
			
			if dist <= radius and dist >= radius - 4:
				# Create ring effect
				var alpha = 1.0 - abs(dist - (radius - 2)) / 2.0
				var pixel_color = Color(color.r, color.g, color.b, color.a * alpha)
				img.set_pixel(x, y, pixel_color)
	
	return ImageTexture.create_from_image(img)

# Called when player would take damage - absorbs exactly X hits
func absorb_damage() -> bool:
	if shield_hits_remaining <= 0:
		# Shield broken, pass to next decorator
		if next_decorator:
			return next_decorator.absorb_damage()
		return false
	
	# Consume one hit
	shield_hits_remaining -= 1
	
	# Trigger flash effect
	is_flashing = true
	hit_flash_timer = 0.0
	
	print("Shield absorbed hit! Hits remaining: %d" % shield_hits_remaining)
	
	# Play shield hit sound (if you have one)
	# player.play_sound("shield_hit")
	
	if shield_hits_remaining <= 0:
		# Shield is broken after this hit
		_on_shield_broken()
	
	return true  # Always absorbs the damage

func _on_shield_broken():
	print("Shield broken!")
	# Optional: Play break effect/sound
	# player.play_sound("shield_break")
	
	# Remove this decorator from the manager
	if player.decorator_manager:
		player.decorator_manager.remove_decorator_instance(self)

# Provide immunity while shield is active
func can_take_damage() -> bool:
	if shield_hits_remaining > 0:
		return false  # Invincible while shield has hits
	
	# Shield broken, check next decorator
	if next_decorator:
		return next_decorator.can_take_damage()
	
	return true
