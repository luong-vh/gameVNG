extends Node2D
class_name LeverPlatformController

@export_group("References")
@export var lever: Lever = null 
@export var platforms: Array[ToggleableTerrainPlatform] = []  
@export var auto_find_platforms: bool = true  

@export_group("Behavior")
@export_enum("Toggle", "Activate Only", "Deactivate Only", "Inverse") var control_mode: int = 0


@onready var platforms_node = $Platforms if has_node("Platforms") else null


func _ready() -> void:
	if auto_find_platforms and platforms.is_empty() and platforms_node:
		_find_platforms()
	elif not platforms_node:
		push_warning("[LeverPlatformController] platforms_node is null! Check node structure.")

	if lever and lever.has_signal("activated"):
		lever.activated.connect(_on_lever_hitted)
	else:
		push_warning("[LeverPlatformController] No lever assigned or lever missing signal!")
	print("[LeverPlatformController] Managing ", platforms.size(), " platforms")

	for i in range(platforms.size()):
		print("[LeverPlatformController] Platform ", i, ": ", platforms[i].name, " active=", platforms[i].is_platform_active())


func _find_platforms() -> void:
	platforms.clear()

	if not platforms_node:
		return

	for child in platforms_node.get_children():
		if child is ToggleableTerrainPlatform:
			platforms.append(child)
		elif child.has_method("activate") and child.has_method("deactivate"):
			platforms.append(child)


func _on_lever_hitted(is_activate: bool) -> void:
	match control_mode:
		0:  
			_toggle_platforms()
		1:
			if is_activate:
				_activate_platforms()
		2: 
			if is_activate:
				_deactivate_platforms()
		3: 
			if is_activate:
				_deactivate_platforms()
			else:
				_activate_platforms()


func _toggle_platforms() -> void:
	for platform in platforms:
		if platform and is_instance_valid(platform):
			print("[LeverPlatformController] Toggling platform: ", platform.name)
			platform.toggle()
		else:
			print("[LeverPlatformController] ERROR: Invalid platform!")


func _activate_platforms() -> void:
	for platform in platforms:
		if platform and is_instance_valid(platform):
			print("[LeverPlatformController] Activating platform: ", platform.name)
			platform.activate()
		else:
			print("[LeverPlatformController] ERROR: Invalid platform!")


func _deactivate_platforms() -> void:
	for platform in platforms:
		if platform and is_instance_valid(platform):
			print("[LeverPlatformController] Deactivating platform: ", platform.name)
			platform.deactivate()
		else:
			print("[LeverPlatformController] ERROR: Invalid platform!")


func activate_all() -> void:
	_activate_platforms()


func deactivate_all() -> void:
	_deactivate_platforms()


func toggle_all() -> void:
	_toggle_platforms()
