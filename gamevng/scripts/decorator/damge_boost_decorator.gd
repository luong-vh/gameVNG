class_name DamageBoostDecorator
extends PowerupDecorator
## Strong red damage boost with pulsing aura + particles

var pulse_timer := 0.0
var pulse_speed := 3.0

# Particles
var particles: GPUParticles2D


func _init(target_player: Player, decorator_data: PowerupDecoratorData):
	super._init(target_player, decorator_data)

func _ready() -> void:
	_spawn_particles()

func update(delta: float) -> void:
	super.update(delta)

	pulse_timer += delta * pulse_speed
	var pulse := sin(pulse_timer * TAU) * 0.5 + 0.5

	# EXTREMELY red
	var red := 1.3 + pulse * 0.4
	var gb := 0.15 + pulse * 0.1

	player.modulate = Color(red, gb, gb)

func _spawn_particles() -> void:
	if particles and particles.is_inside_tree():
		return

	particles = GPUParticles2D.new()
	particles.name = "DamageBoostParticles"
	particles.amount = 32
	particles.lifetime = 0.8
	particles.emitting = true
	particles.one_shot = false
	particles.z_index = -1
	particles.position = Vector2.ZERO

	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 12.0

	mat.initial_velocity_min = 6.0
	mat.initial_velocity_max = 20.0
	mat.gravity = Vector3.ZERO

	mat.scale_min = 0.3
	mat.scale_max = 0.6

	mat.color = Color(1.0, 0.05, 0.05, 0.85)

	particles.process_material = mat
	player.add_child(particles)

func on_remove() -> void:
	super.on_remove()

	# Restore visuals
	player.modulate = Color.WHITE

	# Remove particles safely
	if particles and particles.is_inside_tree():
		particles.queue_free()
	particles = null
