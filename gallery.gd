extends Control


func _ready():
	reload()


func _on_add_drawing_pressed():
		var file = FileAccess.open(str("user://",Time.get_date_string_from_system()), FileAccess.WRITE)
		file.store_string(":)")
		reload()


func reload():
	
#	%ItemList.clear()
	print(DirAccess.get_files_at("user://"))
	for file in DirAccess.get_files_at("user://"):
		%ItemList.add_item(file)
	%ItemList.visible = %ItemList.item_count==0

