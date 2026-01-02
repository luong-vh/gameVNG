class_name ShieldDecorator
extends PowerupDecorator
## Shield that grants invulnerability for 10 seconds

var shield_visual: Node2D = null

# Pulse effect variables
var pulse_timer: float = 0.0
var pulse_speed: float = 3.0

func _init(target_player: Player, decorator_data: PowerupDecoratorData):
	super._init(target_player, decorator_data)

func on_apply():
	super.on_apply()
	player.is_invulnerable = true
	player.invulnerable_timer.stop()
	_create_shield_visual()

func update(delta: float):
	super.update(delta)

	if shield_visual:
		pulse_timer += delta * pulse_speed
		var pulse = 0.7 + (sin(pulse_timer * PI * 2) * 0.3)
		shield_visual.modulate = Color(0.5, 0.8, 1.0, pulse)

		var scale_pulse = 1.0 + (sin(pulse_timer * PI * 2) * 0.1)
		shield_visual.scale = Vector2(scale_pulse, scale_pulse)

func on_remove():
	if player.invulnerable_timer.is_stopped():
		player.is_invulnerable = false
	_destroy_shield_visual()
	super.on_remove()

func _create_shield_visual():
	shield_visual = Node2D.new()
	shield_visual.name = "ShieldEffect"

	var shield_sprite = Sprite2D.new()
	var circle_texture = _create_circle_texture(64, Color(0.5, 0.8, 1.0, 0.5))
	shield_sprite.texture = circle_texture

	shield_visual.add_child(shield_sprite)
	shield_visual.z_index = -1

	player.add_child(shield_visual)
	shield_visual.position = Vector2.ZERO

func _destroy_shield_visual():
	if shield_visual:
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
				var alpha = 1.0 - abs(dist - (radius - 2)) / 2.0
				var pixel_color = Color(color.r, color.g, color.b, color.a * alpha)
				img.set_pixel(x, y, pixel_color)

	return ImageTexture.create_from_image(img)
