extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

signal spendAction




func _on_pressed() -> void:
	spendAction.emit(get_meta("actionCost"), self)


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
