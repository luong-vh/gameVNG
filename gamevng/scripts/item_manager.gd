extends Node
class_name ItemManager

signal item_used(item_name: String, success: bool)

# Define item effects here
func use_item(item_name: String) -> bool:
	match item_name:
		"health_potion":
			return use_health_potion()
		"speed_boost":
			return use_speed_boost()
		"damage_boost":
			return use_damage_boost()
		"shield":
			return use_shield()
		_:
			print("[ItemManager] Unknown item: %s" % item_name)
			return false

func use_health_potion() -> bool:
	var player = GameManager.get_player()
	if not player:
		print("[ItemManager] Player not found!")
		return false
	print("[ItemManager] Current player health: %d/%d" % [player.health, player.get_max_health()])
	
	# Heal player by 1 point (adjust as needed)
	var heal_amount = 1
	player.health += heal_amount
	player.collect_powerup("health_potion")
	player.healthChanged.emit()
	AudioManager.play_sound("coin") # Play heal sound (reuse coin for now)
	
	item_used.emit("health_potion", true)
	return true

func use_damage_boost() -> bool:
	var player = GameManager.get_player()
	if not player:
		print("[ItemManager] Player not found!")
		return false
	
	print("[ItemManager] Using damage boost...")
	player.collect_powerup("damage_boost")
	AudioManager.play_sound("coin")
	
	item_used.emit("damage_boost", true)
	return true

func use_shield() -> bool:
	var player = GameManager.get_player()
	if not player:
		print("[ItemManager] Player not found!")
		return false
	
	print("[ItemManager] Using shield...")
	player.collect_powerup("shield")
	AudioManager.play_sound("coin")
	
	item_used.emit("shield", true)
	return true

func use_speed_boost() -> bool:
	var player = GameManager.get_player()
	if not player:
		print("[ItemManager] Player not found!")
		return false

	print("[ItemManager] Using speed boost...")

	# Use the existing powerup system (should work now that player_state uses get_movement_speed())
	player.collect_powerup("speed_up")

	print("[ItemManager] Speed boost activated!")
	#GUIManager.play_SFX("coin")

	item_used.emit("speed_boost", true)
	return true
