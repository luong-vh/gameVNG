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
	
	# Check if player has attack system
	if not player.has_method("get_attack_damage"):
		print("[ItemManager] Player doesn't have attack system!")
		# Apply temporary visual effect anyway
		_apply_damage_boost_effect(player)
		return true
	
	# Apply damage boost - increase attack power temporarily
	_apply_damage_boost_effect(player)
	
	print("[ItemManager] Damage boost activated!")
	AudioManager.play_sound("coin")
	
	item_used.emit("damage_boost", true)
	return true

func _apply_damage_boost_effect(player: Player) -> void:
	# Create temporary visual effect
	var tween = create_tween()
	var original_modulate = player.modulate
	
	# Flash red effect
	tween.tween_property(player, "modulate", Color(2.0, 0.5, 0.5, 1.0), 0.3)
	tween.tween_property(player, "modulate", original_modulate, 0.2)
	tween.tween_property(player, "modulate", Color(2.0, 0.5, 0.5, 1.0), 0.3)
	tween.tween_property(player, "modulate", original_modulate, 0.2)
	
	# Apply temporary damage boost (conceptual for now)
	print("[ItemManager] 🗡️ DAMAGE BOOST ACTIVE! Player glowing red!")
	print("[ItemManager] Next attacks will deal extra damage!")
	
	# TODO: When attack system allows, increase damage multiplier
	# player.damage_multiplier = 2.0 for X seconds

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
