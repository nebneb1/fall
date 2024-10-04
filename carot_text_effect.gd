@tool
extends RichTextEffect
class_name CarrotPositioner

var bbcode = "|"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	Global.char_pos = char_fx.transform.x + char_fx.transform.y
	return true
