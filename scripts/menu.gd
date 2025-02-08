extends Control

@onready var continue_bt: Button = $continue
@onready var start: Button = $start


const SETTIGNS = preload("res://scenes/settigns.tscn")
const GAME = preload("res://scenes/Game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	continue_bt.disabled = true;
	start.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_up() -> void:
	get_tree().change_scene_to_packed(GAME)

func _on_settings_up() -> void:
	get_tree().change_scene_to_packed(SETTIGNS)

func _on_continue_up() -> void:
	pass

func _on_quit_up() -> void:
	get_tree().quit()
