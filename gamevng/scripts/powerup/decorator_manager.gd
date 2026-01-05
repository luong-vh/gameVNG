class_name DecoratorManager
extends Node

## Manage decorator chain with data-driven approach
var player: Player
var powerup_database: PowerupDatabase
var decorator_chain_head: PowerupDecorator = null
var active_decorators: Array[PowerupDecorator] = []

func _ready():
	# Load database
	powerup_database = load("res://data/powerup/powerup_database.tres")
	if not powerup_database:
		push_error("PowerupDatabase not found!")

func initialize(target_player: Player):
	player = target_player

func apply_powerup(powerup_id: String) -> bool:
	var powerup_data = powerup_database.get_powerup(powerup_id)
	if not powerup_data:
		print("Powerup data not found: ", powerup_id)
		return false
	# Check conflicts
	if _has_conflicts(powerup_data):
		_resolve_conflicts(powerup_data)
	# Create decorator from data
	var decorator = powerup_data.create_decorator(player)
	if not decorator:
		print("Failed to create decorator for: ", powerup_id)
		return false
	# Add to chain
	_add_to_chain(decorator)
	decorator.on_apply() # Sets is_active = true
	active_decorators.append(decorator)
	return true
	
	# Centralized visual update
	_reapply_all_visuals()
	
	print("Applied powerup: ", powerup_data.id)
	return true

func _reapply_all_visuals():
	# 1. Revert player to absolute default state
	player.modulate = Color.WHITE

	# Reset to correct base sprite based on player state (blade or no blade)
	if player.has_blade:
		if player.get_node_or_null("Direction/BladeAnimatedSprite2D"):
			player.set_animated_sprite(player.get_node("Direction/BladeAnimatedSprite2D"))
	else:
		if player.get_node_or_null("Direction/AnimatedSprite2D"):
			player.set_animated_sprite(player.get_node("Direction/AnimatedSprite2D"))

	# 2. Get effective visuals from the current chain (if it exists)
	if decorator_chain_head:
		var effective_sprite_path = decorator_chain_head.get_sprite_override()
		var effective_color = decorator_chain_head.get_color_modulate()

		# 3. Apply effective visuals
		if not effective_sprite_path.is_empty():
			var sprite_node = player.get_node_or_null("Direction/" + effective_sprite_path)
			if sprite_node:
				player.set_animated_sprite(sprite_node)

		if effective_color != Color.WHITE:
			player.modulate = effective_color


func _has_conflicts(new_powerup_data: PowerupDecoratorData) -> bool:
	for decorator in active_decorators:
		# Check if existing decorator conflicts with the new one
		if new_powerup_data.conflicts_with.has(decorator.data.id):
			return true
		# Check if the existing decorator should be replaced
		if new_powerup_data.replaces.has(decorator.data.id):
			return true
		# Check same ID
		if decorator.data.id == new_powerup_data.id and not new_powerup_data.can_stack:
			return true
	
	return false

func _resolve_conflicts(new_powerup_data: PowerupDecoratorData):
	var to_remove = []
	
	for decorator in active_decorators:
		# Remove conflicting decorators
		if new_powerup_data.conflicts_with.has(decorator.data.id):
			to_remove.append(decorator)
		
		# Remove replaced decorators
		elif new_powerup_data.replaces.has(decorator.data.id):
			to_remove.append(decorator)
		
		# Remove same type if can't stack
		elif decorator.data.id == new_powerup_data.id and not new_powerup_data.can_stack:
			to_remove.append(decorator)
	
	for decorator in to_remove:
		remove_decorator_instance(decorator)

func _add_to_chain(decorator: PowerupDecorator):
	if decorator_chain_head == null:
		decorator_chain_head = decorator
	else:
		# Insert based on priority
		if decorator.data.priority >= decorator_chain_head.data.priority:
			decorator.next_decorator = decorator_chain_head
			decorator_chain_head = decorator
		else:
			_insert_by_priority(decorator)

func _insert_by_priority(decorator: PowerupDecorator):
	var current = decorator_chain_head
	
	while current.next_decorator != null:
		if decorator.data.priority >= current.next_decorator.data.priority:
			decorator.next_decorator = current.next_decorator
			current.next_decorator = decorator
			return
		current = current.next_decorator
	
	# Insert at end
	current.next_decorator = decorator

func remove_decorator(powerup_id: String) -> bool:
	for decorator in active_decorators:
		if decorator.data.id == powerup_id:
			return remove_decorator_instance(decorator)
	return false

func remove_decorator_instance(decorator: PowerupDecorator) -> bool:
	# Remove from chain
	_remove_from_chain(decorator)
	
	# Mark as inactive
	decorator.on_remove()
	
	# Remove from active list
	active_decorators.erase(decorator)
	
	# Centralized visual update
	_reapply_all_visuals()
	
	print("Removed powerup: ", decorator.data.id)
	return true

func _remove_from_chain(decorator: PowerupDecorator):
	if decorator_chain_head == decorator:
		decorator_chain_head = decorator.next_decorator
	else:
		var current = decorator_chain_head
		while current and current.next_decorator != decorator:
			current = current.next_decorator
		
		if current:
			current.next_decorator = decorator.next_decorator

func _process(delta: float):
	if decorator_chain_head:
		decorator_chain_head.update(delta)
	
	_check_expired_decorators()

func _check_expired_decorators():
	var to_remove = []
	
	for decorator in active_decorators:
		if decorator.data.duration > 0 and decorator.time_remaining <= 0:
			to_remove.append(decorator)
	
	for decorator in to_remove:
		remove_decorator_instance(decorator)

# Getter methods
func get_effective_movement_speed() -> float:
	if decorator_chain_head:
		return decorator_chain_head.get_movement_speed()
	return player.movement_speed

func get_effective_jump_speed() -> float:
	if decorator_chain_head:
		return decorator_chain_head.get_jump_speed()
	return player.jump_speed

func get_effective_health() -> int:
	if decorator_chain_head:
		return decorator_chain_head.get_max_health()
	return player.max_health

func get_effective_attack_damage() -> int:
	if decorator_chain_head:
		return decorator_chain_head.get_attack_damage()
	return player.attack_damage

func get_effective_max_jumps() -> int:
	if decorator_chain_head:
		return decorator_chain_head.get_max_jumps()
	return 1

func can_absorb_damage() -> bool:
	if decorator_chain_head:
		return decorator_chain_head.absorb_damage()
	return false

func can_blade_attack() -> bool:
	if decorator_chain_head:
		return decorator_chain_head.can_blade_attack()
	return false

func can_double_jump() -> bool:
	if decorator_chain_head:
		return decorator_chain_head.can_double_jump()
	return false
