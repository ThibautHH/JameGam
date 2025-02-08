extends Control

@onready var windowed: Button = $windowed

func _ready() -> void:
	windowed.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_windowed_button_up() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_fullscreen_button_up() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_back_button_up() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn");
