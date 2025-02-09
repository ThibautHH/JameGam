extends Control

@onready var buy_boat: Button = $"buy boat"
@onready var rest: Button = $rest
@onready var pillage: Button = $pillage

var inventory = Game.get_node("inventory")
var items : Array = inventory.get_meta("items")
var gold : int = inventory.get_meta("gold")
var evil : int = inventory.get_meta("evil")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (gold < 2 or items.has("boat")):
		buy_boat.disabled = true
	if (gold < 1):
		rest.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_buy_boat_button_up() -> void:
	items.append("boat");
	inventory.set_meta("items", items)
	inventory.set_meta("gold", gold - 2)
	buy_boat.disabled = true

func _on_rest_button_up() -> void:
	inventory.set_meta("gold", gold - 1)
	rest.disabled = true

func _on_pillage_button_up() -> void:
	inventory.set_meta("gold", gold + 1)
	inventory.set_meta("evil", evil + 1)
	pillage.disabled = true
	rest.disabled = true
	buy_boat.disabled = true
