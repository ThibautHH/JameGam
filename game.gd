extends Node2D

func assign_texture(tile : Node) -> void:
	tile.find_child("ground").texture = get_meta("tile_types")[tile.get_meta("type")]

func _ready() -> void:
	var tile_node = preload("res://Tile.tscn")
	var tiles : Array = get_meta("tiles")
	for x in range(0, 5):
		for y in range(0, 5):
			var tile : Node = tile_node.instantiate()
			tile.set_meta("pos", Vector2i(x, y))
			tile.set_meta("type", 5)
			assign_texture(tile)
			add_child(tile)
			tiles.insert(0, tile)

func _process(_delta: float) -> void:
	pass
