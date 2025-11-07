extends CanvasLayer

@onready var fog_overlay = $FogOverlay
@onready var darkness_overlay = $DarknessOverlay

func turn_on_fog():
	fog_overlay.texture_visible = true

func turn_off_fog():
	fog_overlay.texture_visible = false

func turn_on_darkness():
	darkness_overlay.texture_visible = true

func turn_off_darkness():
	darkness_overlay.texture_visible = false
