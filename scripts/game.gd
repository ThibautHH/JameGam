extends Node2D

@export var ground_layer : TileMapLayer
@export var entity_layer : TileMapLayer
@export var ui_layer : TileMapLayer
@onready var console: RichTextLabel = $GUI/console
@onready var tile_preview: Sprite2D = $"GUI/tile preview"

var player_pos : Vector2i
var target_tile : Vector2i = Vector2i(0, 0)

@export var events : Node

@export var gold_display : Label
@export var evil_display : Label
@export var strength_display : Label
@export var energy_display : Label

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
	return (!(pos in ground_layer.get_used_cells())
		or ground_layer.get_cell_atlas_coords(pos).y == 5)

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
	clearInteractions()
	spawnInterations(ground_layer.get_cell_tile_data(pos), pos)

func is_impassable(pos : Vector2i) -> bool:
	return (ground_layer.get_cell_tile_data(pos).get_custom_data("impassable")
		or (get_meta("items").any(func(item):
			return (ground_layer.get_cell_tile_data(pos).get_custom_data("requirements")
				.any(func(requirement): return item == requirement)))))

func can_move_to(pos : Vector2i) -> bool:
	return !is_impassable(pos) and get_meta("energy") >= 1

func is_tile_possible_destination(pos : Vector2i) -> bool:
	return (is_neighbour(pos, player_pos) and !is_void(pos))

func is_surrounded(pos : Vector2i) -> bool:
	return !(get_neighbours(pos).any(is_void))

func get_random_empty_neighbour(pos : Vector2i) -> Vector2i:
	return (get_neighbours(pos).filter(is_void).pick_random())

func create_new_tile(pos : Vector2i) -> void:
	ground_layer.set_cell(pos, 0, get_random_tile())
	if (randi_range(0, 1) == 1):
		var type : int = randi_range(1, 7)
		entity_layer.set_cell(pos, 0,
			Vector2i(type % 3, type / 3))

func end_turn() -> void:
	create_new_tile(get_random_empty_neighbour(player_pos))
	ground_layer.get_used_cells().filter(is_surrounded).map(func(pos): spwanUfo(pos))
	if is_surrounded(player_pos):
		lost = true
		return
	var energy : int = get_meta("energy")
	if energy < get_meta("max_energy"):
		set_meta("energy", energy + 1)
	else:
		set_meta("energy", get_meta("max_energy")) 

func interact_with_tile(pos : Vector2i):
	if is_tile_possible_destination(pos):
		target_tile = pos
		var atlas_coords = ground_layer.get_cell_atlas_coords(target_tile)
		var texture_scr = "res://assets/tiles/" + str(atlas_coords.y) + "_" + str(atlas_coords.x) + ".png"
		tile_preview.texture = load(texture_scr)
	if pos != player_pos:
		pass

func move() -> void:
	if !(is_tile_possible_destination(target_tile) and can_move_to(target_tile)):
		return
	set_meta("energy",
		get_meta("energy") - get_tile_movement_cost(target_tile))
	if target_tile in entity_layer.get_used_cells():
		var odds : int = maxi(entity_layer.get_cell_tile_data(target_tile)
			.get_custom_data("strength") - get_meta("strength"), 0)
		if odds != 0 and randi_range(0, odds) != 0:
			return
	move_player(target_tile)

func move_mouse_highlighting(offset : Vector2) -> void:
	var new_pos : Vector2i = ui_layer.local_to_map(get_local_mouse_position())
	var old_pos : Vector2i = ui_layer.local_to_map(get_local_mouse_position() - offset)
	ui_layer.set_cell(old_pos,
		-1 if ui_layer.get_cell_atlas_coords(old_pos).x == 0 else 0,
		Vector2i(ui_layer.get_cell_atlas_coords(old_pos).x, 0))
	if (new_pos in ground_layer.get_used_cells()):
		var overlay_type : int = (1 if (!is_tile_possible_destination(new_pos))
				else (3 if !can_move_to(new_pos)
					else 4 if (new_pos != player_pos
							and new_pos in entity_layer.get_used_cells())
						else 2))
		ui_layer.set_cell(new_pos, 0, Vector2i(
			maxi(ui_layer.get_cell_atlas_coords(new_pos).x, 0), overlay_type))

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

func clearInteractions() -> void:
	var to_delete = events.get_children()
	for elem in to_delete:
		elem.queue_free()

func spawnInterations(terrainData, pos) -> void:
	var index : int = 0;
	for elem : Dictionary in terrainData.get_custom_data("events"):
		var button = preload("res://scenes/button.tscn").instantiate()
		button.text = elem.description
		button.set_meta("index", index)
		button.set_meta("target_tile", pos)
		button.position = Vector2i(0, index * 50)
		button.button_up_index.connect(apply_effects)
		events.add_child(button)
		index += 1
		if (not elem.has("effects")):
			return

func apply_effects(index : int, target_tile : Vector2i) -> void:
	var data = ground_layer.get_cell_tile_data(target_tile).get_custom_data("events")[index]
	if data.has("effects"):
		for effect in data.effects:
			if (get_meta(effect.type) + effect.value) < 0:
				console.text = "[color=red]not enough " + effect.type + "[/color]"
				return
		for effect in data.effects:
			set_meta(effect.type, get_meta(effect.type) + effect.value)
	if (data.has("items")):
		for item in data.items:
			get_meta("items").append(item)
	if (data.has("special")):
		var special = data.special;
		if (special == "destroy"):
			clearInteractions()

func _process(delta: float) -> void:
	gold_display.text = str(get_meta("gold"))
	evil_display.text = str(get_meta("evil"))
	strength_display.text = str(get_meta("strength"))
	energy_display.text = str(get_meta("energy")) + " / " + str(get_meta("max_energy"))
func spwanUfo(pos : Vector2i) -> void:
	if (ground_layer.get_cell_atlas_coords(pos).y == 5):
		return
	var ufo = preload("res://scenes/ufo.tscn").instantiate()
	ufo.position = pos * Vector2i(56, 72) + Vector2i(0, 20)
	ufo.animation_finished.connect(destroyTile)
	add_child(ufo)

func destroyTile() -> void:
	ground_layer.get_used_cells().filter(is_surrounded).map(func(pos):
		ground_layer.set_cell(pos, 0, Vector2i(1, 5));
		entity_layer.set_cell(pos)
	)
