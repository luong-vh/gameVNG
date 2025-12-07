extends Stage

## Level 3 with save clearing for testing
## TODO: Remove this script and use stage.gd when done testing

func _ready() -> void:
	# ==========================================
	# TEMPORARY: Clear all save data for testing
	# ==========================================
	print("[Level3] ========================================")
	print("[Level3] CLEARING ALL SAVE DATA FOR TESTING!")
	print("[Level3] ========================================")
	
	# Clear checkpoint data
	SaveSystem.reset_data()
	
	# Clear GameManager checkpoint data
	GameManager.clear_checkpoint_data()
	
	# Reset inventory
	if GameManager.inventory_system:
		GameManager.inventory_system.reset_inventory()
	
	print("[Level3] All save data cleared!")
	print("[Level3] Items will respawn every time you enter!")
	print("[Level3] ========================================")
	# ==========================================
	# END TEMPORARY CODE
	# ==========================================
	
	# Call parent _ready
	super._ready()
