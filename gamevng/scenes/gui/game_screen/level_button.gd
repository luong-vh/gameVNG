extends TextureButton

var level_num : int = 1:
	set(value):
		level_num = value
		$Label.text = ("0" + str(value)) if value <10 else "10"
		
var is_locked: bool = true:
	set(value):
		is_locked = value
		disabled = value
		$Label.visible = !value

func _on_pressed() -> void:
	GameManager.level_selected(level_num)

	
