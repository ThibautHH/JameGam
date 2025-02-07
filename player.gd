extends Node2D

func update_position() -> void:
	var pos : Vector2i = get_meta("pos")
	position.x = pos.x * 75
	position.y = pos.y * 86.6
	if (pos.x % 2 == 1):
		position.y -= 43.3

func _process(_delta: float) -> void:
	update_position()
