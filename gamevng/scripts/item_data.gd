extends RefCounted
class_name ItemData

var item_name: String
var texture: Texture2D
var count: int
var max_stack: int

func _init(name: String = "", tex: Texture2D = null, amount: int = 1, stack: int = 99):
	item_name = name
	texture = tex
	count = amount
	max_stack = stack
