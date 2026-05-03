extends Control
## Run summary screen. Shows run results and offers restart/menu options.

func _ready() -> void:
	$CenterContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$CenterContainer/VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
