extends Sprite3D

@onready var text_box : RichTextLabel = get_node("UIViewport/Placement/TextBox")
@onready var animation : AnimationPlayer = get_node("UIViewport/Placement/TextBox/Animation")
@onready var input : TextEdit = get_node("UIViewport/Placement/TextBox/Edit")
@onready var viewport : SubViewport = get_node("UIViewport")

const DEFAULT_LENGTH = 850
const TEST_INTERVAL = 10
const MAX_TEXT_LINES = 15

var USEABLE_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-=!@#$%^&*_+()[]{}|\\;:\"\'<>?,./ "

func _ready():
	animation.play("chat")
	#find_minimum_border_size()
	for emoji in Global.emojis: 
		USEABLE_CHARS += emoji[1]
	
var prev_input : String
func _process(delta: float):
	if is_instance_valid(input):
		if input.has_focus() and input.text != prev_input:
			var carot_pos = input.get_caret_column()
			input.text = filter(input.text)
			if input.text.count(":") >= 2:
				for emoji in Global.emojis:
					if emoji[0] in input.text:
						input.text = input.text.replace(emoji[0], emoji[1]) 
			
			if text_box.get_line_count() > MAX_TEXT_LINES:
				input.text = input.text.erase(len(input.text)-1)
			input.set_caret_column(carot_pos)
			text_box.text = input.text
		find_minimum_border_size()
		text_box.anchor_top = 0.0
		prev_input = input.text


func filter(text : String):
	var out = ""
	for char in text:
		if char in USEABLE_CHARS:
			out += char
	
	return out

func set_readable_only():
	if is_instance_valid(input):
		input.release_focus()
		input.queue_free()

func enable_input():
	if is_instance_valid(input):
		input.grab_focus()

func disable_input():
	if is_instance_valid(input):
		input.release_focus()

func get_num_lines():
	return text_box.get_line_count()

func free_in_time(time : float):
	await get_tree().create_timer(time).timeout
	animation.play("float")
	var tween = create_tween()
	tween.tween_property(text_box, "position:y", -5000, 8.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	await get_tree().create_timer(8.0).timeout
	queue_free()
	

func find_minimum_border_size():
	text_box.offset_right = DEFAULT_LENGTH
	text_box.offset_top = 665.0
	text_box.offset_bottom = 665.0
	if text_box.get_line_count() == 1:
		var good_line_size = DEFAULT_LENGTH
		for test_size in range(DEFAULT_LENGTH, int(text_box.custom_minimum_size.x), -TEST_INTERVAL):
			text_box.offset_right = test_size
			if text_box.get_line_count() == 2: break
			else: good_line_size = test_size
		
		text_box.offset_right = good_line_size
		
func _input(event: InputEvent): viewport.push_input(event)
		
