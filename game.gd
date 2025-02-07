extends Node2D

func assign_texture(tile : Node) -> void:
	tile.find_child("ground").texture = get_meta("tile_types")[tile.get_meta("type")]

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
