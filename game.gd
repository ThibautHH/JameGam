extends Node2D

func _ready() -> void:
	var map : TileMapLayer = find_child("Map")
	for x in range(0, 5):
		for y in range(0, 5):
			pass

func is_neighbour(a : Vector2i, b : Vector2i) -> bool:
	return (((a.x - 1 <= b.x and b.x <= a.x + 1)
			and (b.y == a.y or b.y == a.y - 1))
		or (b.y == a.y + 1 and b.x == a.x))

func _input(event: InputEvent) -> void:
	var map : TileMapLayer = find_child("Map")
	var player : Node2D = find_child("Player")
	if (event is InputEventMouseButton and event.pressed
		and event.button_index == MOUSE_BUTTON_LEFT):
			var target_pos : Vector2i = map.local_to_map(to_local(event.position))
			#if is_neighbour(target_pos, player.get_meta("pos")):
				#player.set_meta("pos", target_pos)

func _process(_delta: float) -> void:
	pass
