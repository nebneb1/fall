extends Control
@onready var container = $VBoxContainer

# tracked values format
# 0 [display tag : String, 
# 1 label object pointer : Label, 
# 2 value from function : bool, 
# 3 Callable func or object : Callable or Node,
# 4 param name in case of non-Callable : String]


var tracked_values : Array = [
	{
		"tag": "FPS",
		"label": null,
		"is_function": true,
		"object": null,
		"parameter": "",
		"callable": Callable(Engine, "get_frames_per_second"),
		"print": false
	}
]

func _ready():
	_update_list()
	
func _process(delta: float):
	_update()
	
func _update():
	for value in tracked_values:
		var label = value["label"]
		if label:
			if value["is_function"]:
				label.text = value["tag"] + ": " + str(value["callable"].call())
				if value["print"]: print(str(value["callable"].call()))
			else:
				label.text = value["object"].name + " - " + value["tag"] + ": " + str(value["object"].get(value["parameter"]))
				if value["print"]: print(str(value["object"].get(value["parameter"])))
				
		else: print("aa im missing my label this is the worst day of my short computer life...")

func _update_list():
	for child in container.get_children():
		child.queue_free()
	
	for value in tracked_values:
		var label = Label.new()
		label.text = value["tag"] + ": "
		container.add_child(label)
		tracked_values[tracked_values.find(value)]["label"] = container.get_child(container.get_child_count()-1)
	
	_update()
		

func track(object : Node, track_string : String, print : bool = false, tag : String = "", is_func = false):
	var out = {
		"tag": "",
		"label": null,
		"is_function": is_func,
		"object": null,
		"parameter": "",
		"callable": null,
		"print": print
		}
		
	if tag != "": out["tag"] = tag
	else: out["tag"] = track_string
	
	if is_func: 
		out["callable"] = Callable(object, track_string)
	else: 
		out["object"] = object
		out["parameter"] = track_string
	
	tracked_values.append(out)
	_update_list()
