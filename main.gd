extends Control

@onready var player:AnimationPlayer = %Player

func _ready():
	get_viewport().files_dropped.connect(%Player.on_files_dropped)
	return
	
	OS.alert("Still on the todo list:
  ·  The main window does is not focused when dropping a file in the scene
  ·  Moving drawings are a bit jumpy (ignores current value)
  ·  Rendering is a image sequence (PNG files)
  ·  Some frames are probably skipped when rendering
  ·  Projects can not be saved",
		"Hi! This is a pre-alpha version, enjoy.")



func _on_button_pressed():
	OS.shell_open( ProjectSettings.globalize_path("user://") )
