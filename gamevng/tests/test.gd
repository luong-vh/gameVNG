extends Stage

## Script riêng cho Test scene để test puzzle mechanics
## Extend từ Stage để giữ nguyên logic base

# Node references - adjust path theo cấu trúc scene của mày
@onready var pressure_plate: PressurePlate = $PressurePlate 
@onready var door: PressurePlateDoor = $PressurePlateDoor 


func _ready() -> void:
	super._ready()  # Gọi _ready() của Stage trước
	# Connect puzzle signals
	_setup_puzzle_connections()


func _setup_puzzle_connections() -> void:
	"""Setup connections giữa pressure plate và door"""
	if pressure_plate and door:
		print("[TestStage] Found pressure_plate: ", pressure_plate.name)
		print("[TestStage] Found door: ", door.name)

		pressure_plate.activated.connect(_on_plate_activated)
		pressure_plate.deactivated.connect(_on_plate_deactivated)

		print("[TestStage] ✓ Puzzle connections setup complete!")
	else:
		if not pressure_plate:
			push_warning("[TestStage] PressurePlate node not found!")
		if not door:
			push_warning("[TestStage] PressurePlateDoor node not found!")


func _on_plate_activated(activator: Node2D) -> void:
	print("[TestStage] Plate activated by: ", activator.name)
	print("[TestStage] Calling door.open()...")
	door.open()


func _on_plate_deactivated(activator: Node2D) -> void:
	print("[TestStage] Plate deactivated by: ", activator.name)
	print("[TestStage] Calling door.close()...")
	door.close()
