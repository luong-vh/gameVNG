extends TextureProgressBar

var enemy: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Find the actual enemy node - could be parent or ancestor
	enemy = _find_enemy_node()
	
	if not enemy:
		print("[EnemyHealthBar] Warning: No enemy found for health bar")
		visible = false
		return
	
	# Check if enemy has healthChanged signal before connecting
	if enemy.has_signal("healthChanged"):
		enemy.healthChanged.connect(_update_progress)
		_update_progress()
	else:
		print("[EnemyHealthBar] Warning: Enemy %s doesn't have healthChanged signal" % enemy.name)
		# For enemies without signal, try manual update
		if "health" in enemy and "max_health" in enemy:
			_update_progress()
		else:
			visible = false  # Hide if no health system

func _find_enemy_node() -> Node:
	# Check parent first
	var parent = get_parent()
	if _is_enemy(parent):
		return parent
	
	# Check ancestors up to 3 levels
	var current = parent
	for i in range(3):
		current = current.get_parent()
		if not current:
			break
		if _is_enemy(current):
			return current
	
	return null

func _is_enemy(node: Node) -> bool:
	# Check if node is an enemy by checking if it extends EnemyCharacter or BaseCharacter
	return node is EnemyCharacter or node is BaseCharacter or node.has_signal("healthChanged")

func _update_progress():
	if not enemy:
		return
		
	# Safe check for health properties
	if "health" in enemy and "max_health" in enemy:
		if enemy.max_health > 0:
			value = enemy.health * 100.0 / enemy.max_health
		else:
			value = 0
	else:
		visible = false  # Hide health bar if no health system
