extends CanvasLayer

# 1. Định nghĩa các tín hiệu
signal fade_to_black_finished
signal fade_from_black_finished
var setting_popup_scene

@onready var _fade_animation_player = $FadeController/AnimationPlayer
@onready var _heart_container = $CanvasLayer/HeartsContainer
@onready var _hotbar = $CanvasLayer/Hotbar
@onready var _inventory_screen = $CanvasLayer/InventoryScreen
@onready var _coin_HUD = $CanvasLayer/CoinHUD
@onready var _key_HUD = $CanvasLayer/KeyHUD

func _ready():
	print("[GUIManager] Starting GUIManager initialization...")
	_fade_animation_player.animation_finished.connect(_on_animation_finished)

	# Check if hotbar exists
	if _hotbar:
		print("[GUIManager] Hotbar found and loaded successfully!")
		_hotbar.slot_selected.connect(_on_hotbar_slot_selected)
		_hotbar.item_used.connect(_on_hotbar_item_used)
	else:
		print("[GUIManager] WARNING: Hotbar not found in scene!")

	# Connect inventory signals when GameManager is ready
	call_deferred("_connect_inventory_signals")
	print("[GUIManager] Initialization complete")

func fade_to_black():
	_fade_animation_player.play("fade_to_black")

func fade_from_black():
	_fade_animation_player.play("fade_from_black")

func on_level_selection_scene():
	_coin_HUD.visible = false
	_key_HUD.visible = false
	_heart_container.visible = false
	if _hotbar:
		_hotbar.visible = false  # Hide hotbar in level selection
	if _inventory_screen:
		_inventory_screen.visible = false  # Hide inventory in level selection
	setting_popup_scene = preload("res://scenes/gui/game_screen/settings_level_selection_popup.tscn")

func on_stage_scene():
	print("[GUIManager] Setting up stage scene...")
	_heart_container.visible = true
	_coin_HUD.visible = true
	
	if _hotbar:
		_hotbar.visible = true  # Show hotbar in game
		print("[GUIManager] Hotbar set to visible, position: %s, size: %s" % [_hotbar.position, _hotbar.size])
	if _inventory_screen:
		# Inventory screen starts hidden, player opens with Tab
		_inventory_screen.visible = false
	setting_popup_scene = preload("res://scenes/gui/game_screen/settings_popup.tscn")
	
func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		emit_signal("fade_to_black_finished")
	elif anim_name == "fade_from_black":
		emit_signal("fade_from_black_finished")

func set_max_heart_gui(max :int):
	if max > 10:
		print("wtf max health = %d??" %max)
		_heart_container.set_max_heart(5)
		return
	_heart_container.set_max_heart(max)

func update_heart_gui(health: int):
	if (health <=0): return
	var hearts = _heart_container.get_children()
	if hearts.size() == 0: return
		
	for i in range(health):
		if i >= hearts.size(): return
		hearts[i].update(true)
		
	for i in range(health,hearts.size()):
		hearts[i].update(false)

func open_stage_clear_popup():
	var stage_clear_popup_preload = preload("res://scenes/gui/game_screen/finished_level_poppup.tscn")
	var popup = stage_clear_popup_preload.instantiate()
	$CanvasLayer.add_child(popup)


func _on_settings_texture_button_pressed() -> void:
	var popup_settings = setting_popup_scene.instantiate()
	$CanvasLayer.add_child(popup_settings)

# ==================== Hotbar System ====================

func _connect_inventory_signals() -> void:
	print("[GUI] Connecting inventory signals...")
	if GameManager.inventory_system:
		GameManager.inventory_system.hotbar_updated.connect(_on_hotbar_updated)
		GameManager.inventory_system.hotbar_cleared.connect(_on_hotbar_cleared)
		GameManager.inventory_system.coin_changed.connect(update_coin)
		GameManager.inventory_system.key_changed.connect(update_key)
		print("[GUI] Inventory signals connected successfully!")
	else:
		print("[GUI] WARNING: GameManager.inventory_system is null!")

func _on_hotbar_slot_selected(slot_index: int) -> void:
	print("[GUI] Hotbar slot %d selected" % slot_index)

func _on_hotbar_item_used(slot_index: int) -> void:
	print("[GUI] *** USING ITEM from slot %d ***" % slot_index)
	if GameManager.inventory_system and GameManager.item_manager:
		var item = GameManager.inventory_system.get_hotbar_item(slot_index)
		if item and item.count > 0:
			print("[GUI] Item found: '%s' (count: %d)" % [item.item_name, item.count])
			# Try to use the item
			var success = GameManager.item_manager.use_item(item.item_name)
			if success:
				print("[GUI] ✅ Item used successfully!")
				play_SFX("coin")
				# Check if item is consumable (blade is not consumable)
				if item.item_name != "blade":
					print("[GUI] Removing consumable item from hotbar...")
					GameManager.inventory_system.use_item_from_hotbar(slot_index)
				else:
					print("[GUI] Blade is equipment - keeping in hotbar")
			else:
				print("[GUI] ❌ Item usage failed!")
		else:
			print("[GUI] ❌ No item in slot %d to use" % slot_index)

func _on_hotbar_updated(slot_index: int, texture: Texture2D, count: int) -> void:
	if _hotbar:
		_hotbar.set_slot_item(slot_index, texture, count)

func _on_hotbar_cleared(slot_index: int) -> void:
	if _hotbar:
		_hotbar.clear_slot(slot_index)

func add_item_to_hotbar(item_name: String, texture: Texture2D, count: int = 1) -> bool:
	if GameManager.inventory_system:
		return GameManager.inventory_system.add_item_to_hotbar(item_name, texture, count)
	return false

func update_coin(value: int):
	_coin_HUD.get_node("Label").text = str(value)

func update_key(is_collected: bool):
	_key_HUD.visible = is_collected

func play_SFX(sound_name: String):
	# TODO: Implement sound effects
	pass
