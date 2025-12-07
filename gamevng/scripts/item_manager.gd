extends Node
class_name ItemManager

signal item_used(item_name: String, success: bool)

# Define item effects here
func use_item(item_name: String) -> bool:
	match item_name:
		"health_potion":
			return use_health_potion()
		"mana_potion":
			return use_mana_potion()
		"speed_boost":
			return use_speed_boost()
		_:
			print("[ItemManager] Unknown item: %s" % item_name)
			return false

func use_health_potion() -> bool:
	var player = GameManager.get_player()
	if not player:
		print("[ItemManager] Player not found!")
		return false
	
	print("[ItemManager] Current player health: %d/%d" % [player.health, player.max_health])
	
	if player.health >= player.max_health:
		print("[ItemManager] Health already full!")
		return false
	
	# Heal player by 1 point (adjust as needed)
	var heal_amount = 1
	var old_health = player.health
	player.health = min(player.health + heal_amount, player.max_health)
	
	# Trigger UI update - check if signal exists first
	if player.has_signal("healthChanged"):
		player.healthChanged.emit()
		print("[ItemManager] Health updated from %d to %d" % [old_health, player.health])
	else:
		print("[ItemManager] Warning: Player doesn't have healthChanged signal")
	
	print("[ItemManager] Used health potion! Healed %d HP" % heal_amount)
	GUIManager.play_SFX("coin") # Play heal sound (reuse coin for now)
	
	item_used.emit("health_potion", true)
	return true

func use_mana_potion() -> bool:
	# TODO: Implement mana system first
	print("[ItemManager] Mana potions not implemented yet!")
	return false

func use_speed_boost() -> bool:
	# TODO: Implement temporary speed boost
	print("[ItemManager] Speed boost not implemented yet!")
	return false