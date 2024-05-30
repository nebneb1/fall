extends Node

func _ready():
	var file = FileAccess.open("res://countries.txt", FileAccess.READ)
	var arr = file.get_as_text().split("\n")
	var out = ""
	for line in arr:
		var temp = line.split(",")
		if len(line) > 2:
			out += temp[1] + ":" + temp[3] + "\n"
			print(temp[3])
	
	print(out)
	file.close()
	file = FileAccess.open("res://countries.txt", FileAccess.WRITE)
	file.store_string(out)
	file.close()
		
