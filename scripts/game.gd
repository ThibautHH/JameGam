extends Node2D

@export var ground_layer : TileMapLayer
@export var entity_layer : TileMapLayer
@export var ui_layer : TileMapLayer

var player_pos : Vector2i
var player_stamina : int = 1
var player_max_stamina : int = 1

var lost : bool = false

const all_directions : Array = [
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE]

func get_random_tile() -> Vector2i:
	return Vector2i(randi_range(0, 4), randi_range(0, 4))

func make_starting_tiles() -> void:
	var center : Vector2i = ground_layer.local_to_map(get_viewport_rect().size / 2)
	var starting_tiles : Array = all_directions.duplicate()
	player_pos = center
	entity_layer.set_cell(center, 0, Vector2i(0, 0))
	ui_layer.set_cell(center, 0, Vector2i(1, 0))
	ground_layer.set_cell(center, 0, Vector2i(4, 1))
	ground_layer.set_cell(ground_layer.get_neighbor_cell(center,
			starting_tiles.pop_at(randi_range(0, 5))),
		0, get_random_tile())
	ground_layer.set_cell(ground_layer.get_neighbor_cell(center,
			starting_tiles.pick_random()),
		0, get_random_tile())

func _ready() -> void:
	make_starting_tiles()

func is_void(pos : Vector2i) -> bool:
	return !(pos in ground_layer.get_used_cells())

func get_neighbours(pos : Vector2i) -> Array:
	return all_directions.map(func(direction):
		return ground_layer.get_neighbor_cell(pos, direction))

func is_neighbour(a : Vector2i, b : Vector2i) -> bool:
	return all_directions.any(func(direction):
		return a == ground_layer.get_neighbor_cell(b, direction))

func get_tile_movement_cost(pos : Vector2i) -> int:
	return (ground_layer.get_cell_tile_data(pos)
		.get_custom_data("movement_cost"))

func move_player(pos : Vector2i) -> void:
	ui_layer.set_cell(player_pos)
	ui_layer.set_cell(pos, 0, Vector2i(1, 1))
	entity_layer.set_cell(player_pos)
	entity_layer.set_cell(pos, 0, Vector2i(0, 0))
	player_pos = pos
	player_stamina -= get_tile_movement_cost(pos)

func is_impassable(pos : Vector2i) -> bool:
	return ground_layer.get_cell_tile_data(pos).get_custom_data("impassable")

func can_move_to(pos : Vector2i) -> bool:
	return !is_impassable(pos) and player_stamina >= 1

func is_tile_possible_destination(pos : Vector2i) -> bool:
	return (is_neighbour(pos, player_pos) and !is_void(pos))

func is_surrounded(pos : Vector2i) -> bool:
	return !(get_neighbours(pos).any(is_void))

func get_random_empty_neighbour(pos : Vector2i) -> Vector2i:
	return (get_neighbours(pos).filter(is_void).pick_random())

func end_turn() -> void:
	ground_layer.set_cell(
		get_random_empty_neighbour(player_pos),
		0, get_random_tile())
	ground_layer.get_used_cells().filter(is_surrounded).map(func(pos):
		ground_layer.set_cell(pos, 0,
			Vector2i(#ground_layer.get_cell_atlas_coords(pos).x, 5)))
				1, 5)))
	if is_surrounded(player_pos):
		lost = true
		return
	if player_stamina < player_max_stamina:
		player_stamina += 1

func interact_with_tile(pos : Vector2i):
	if pos != player_pos:
		if (is_tile_possible_destination(pos) and can_move_to(pos)):
			move_player(pos)
			end_turn()
	else:
		end_turn()

func _input(event: InputEvent) -> void:
	if lost:
		return
	if (event is InputEventMouseButton and event.pressed
		and event.button_index == MOUSE_BUTTON_LEFT):
			interact_with_tile(
				ground_layer.local_to_map(
					ground_layer.to_local(event.position)))
	if event is InputEventMouseMotion:
		move_mouse_highlighting(event.relative)

func move_mouse_highlighting(offset : Vector2) -> void:
	var new_pos : Vector2i = ui_layer.local_to_map(get_local_mouse_position())
	var old_pos : Vector2i = ui_layer.local_to_map(get_local_mouse_position() - offset)
	ui_layer.set_cell(old_pos,
		-1 if ui_layer.get_cell_atlas_coords(old_pos).x == 0 else 0,
		Vector2i(ui_layer.get_cell_atlas_coords(old_pos).x, 0))
	if (new_pos in ground_layer.get_used_cells()):
		var overlay_type : int = (4 if (new_pos != player_pos
			and new_pos in entity_layer.get_used_cells())
			else (1 if (!is_tile_possible_destination(new_pos))
				else (2 if can_move_to(new_pos) else 3)))
		ui_layer.set_cell(new_pos, 0, Vector2i(
			maxi(ui_layer.get_cell_atlas_coords(new_pos).x, 0), overlay_type))
