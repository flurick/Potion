extends Control

@onready var player:AnimationPlayer = %Player

func _input(event):
	if event.is_action("ui_home"):
		player.seek_home()
	if event.is_action("ui_end"):
		player.seek_end()

func _ready():
	get_viewport().files_dropped.connect(%Player.on_files_dropped)



func _on_button_pressed():
	OS.shell_open( ProjectSettings.globalize_path("user://") )
