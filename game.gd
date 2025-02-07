extends Node2D

func get_random_tile() -> Vector2i:
	return Vector2i(randi_range(0, 4), randi_range(0, 4))

func make_starting_tiles() -> void:
	var map : TileMapLayer = find_child("Ground Layer")
	var center : Vector2i = map.local_to_map(get_viewport_rect().size / 2)
	var starting_tiles : Array = [
		Vector2i(0, -1), Vector2i(1, -1 if (center.x % 2 == 0) else 1), Vector2i(1, 0),
		Vector2i(0, 1), Vector2i(-1, 0), Vector2i(-1, -1 if (center.x % 2 == 0) else 1)]
	set_meta("player_pos", center)
	find_child("Entity Layer").set_cell(center, 1, Vector2i(0, 0))
	map.set_cell(center, 1, Vector2i(4, 1))
	map.set_cell(center + starting_tiles.pop_at(randi_range(0, 5)), 1, get_random_tile())
	map.set_cell(center + starting_tiles[randi_range(0, 4)], 1, get_random_tile())

func _ready() -> void:
	make_starting_tiles()

func is_neighbour(a : Vector2i, b : Vector2i) -> bool:
	return (((a.x - 1 <= b.x and b.x <= a.x + 1)
			and (b.y == a.y or b.y == a.y + 1))
		or (b.y == a.y - 1 and b.x == a.x)) if (b.x % 2 == 0) else (
		((a.x - 1 <= b.x and b.x <= a.x + 1)
			and (b.y == a.y or b.y == a.y - 1))
		or (b.y == a.y + 1 and b.x == a.x))

func move_player(pos : Vector2i) -> void:
	var ground : TileMapLayer = find_child("Ground Layer")
	var entities : TileMapLayer = find_child("Entity Layer")
	var target_pos : Vector2i = ground.local_to_map(to_local(pos))
	var player_pos : Vector2i = get_meta("player_pos")
	if (is_neighbour(target_pos, player_pos)
		and ground.get_cell_source_id(target_pos) != -1):
		entities.set_cell(player_pos)
		entities.set_cell(target_pos, 1, Vector2i(0, 0))
		set_meta("player_pos", target_pos)

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed
		and event.button_index == MOUSE_BUTTON_LEFT):
			move_player(event.position)

func _process(_delta: float) -> void:
	pass
