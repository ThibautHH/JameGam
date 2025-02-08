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
	find_child("Entity Layer").set_cell(center, 0, Vector2i(0, 0))
	map.set_cell(center, 0, Vector2i(4, 1))
	map.set_cell(center + starting_tiles.pop_at(randi_range(0, 5)), 0, get_random_tile())
	map.set_cell(center + starting_tiles[randi_range(0, 4)], 0, get_random_tile())

func _ready() -> void:
	make_starting_tiles()

func is_neighbour(a : Vector2i, b : Vector2i) -> bool:
	return (((a.x - 1 <= b.x and b.x <= a.x + 1)
			and (b.y == a.y or b.y == a.y + 1))
		or (b.y == a.y - 1 and b.x == a.x)) if (b.x % 2 == 0) else (
		((a.x - 1 <= b.x and b.x <= a.x + 1)
			and (b.y == a.y or b.y == a.y - 1))
		or (b.y == a.y + 1 and b.x == a.x))

func is_impassable(pos : Vector2i) -> bool:
	return false

func has_action(pos : Vector2i) -> bool:
	return false

func move_player(pos : Vector2i) -> void:
	var ground : TileMapLayer = find_child("Ground Layer")
	var entities : TileMapLayer = find_child("Entity Layer")
	var ui : TileMapLayer = find_child("UI Layer")
	var target_pos : Vector2i = ground.local_to_map(to_local(pos))
	var player_pos : Vector2i = get_meta("player_pos")
	if (is_neighbour(target_pos, player_pos)
		and target_pos in ground.get_used_cells()
		and !is_impassable(target_pos)):
		ui.set_cell(player_pos,
			ui.get_cell_source_id(player_pos),
			Vector2i(0, ui.get_cell_atlas_coords(player_pos).y))
		entities.set_cell(player_pos)
		entities.set_cell(target_pos, 0, Vector2i(0, 0))
		set_meta("player_pos", target_pos)

func move_mouse_highlighting(offset : Vector2) -> void:
	var ui : TileMapLayer = find_child("UI Layer")
	var player_pos : Vector2i = get_meta("player_pos")
	var new_pos : Vector2i = ui.local_to_map(get_local_mouse_position())
	var old_pos : Vector2i = ui.local_to_map(get_local_mouse_position() - offset)
	ui.set_cell(old_pos,
		-1 if ui.get_cell_atlas_coords(old_pos).x == 0 else 0,
		Vector2i(ui.get_cell_atlas_coords(old_pos).x, 0))
	if (new_pos in find_child("Ground Layer").get_used_cells()):
		var overlay_type : int = (4 if (new_pos != player_pos
			and new_pos in find_child("Entity Layer").get_used_cells())
			else (1 if (!is_neighbour(new_pos, player_pos)
				or (new_pos == player_pos and !has_action(new_pos)))
				else (3 if is_impassable(new_pos) else 2)))
		ui.set_cell(new_pos, 0, Vector2i((ui.get_cell_atlas_coords(new_pos).x
			if ui.get_cell_atlas_coords(new_pos).x >= 0 else 0), overlay_type))

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed
		and event.button_index == MOUSE_BUTTON_LEFT):
			move_player(event.position)
	if event is InputEventMouseMotion:
		move_mouse_highlighting(event.relative)

func update_overlay() -> void:
	var ui : TileMapLayer = find_child("UI Layer")
	var player_pos : Vector2i = get_meta("player_pos")
	ui.set_cell(player_pos, 0, Vector2i(1, ui.get_cell_atlas_coords(player_pos).y))

func _process(_delta: float) -> void:
	update_overlay()
