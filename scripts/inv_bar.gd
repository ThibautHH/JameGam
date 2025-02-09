extends Node

@onready var evil: Label = $evil
@onready var strenght: Label = $strenght
@onready var gold: Label = $gold
@onready var energy: Label = $energy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_update_display_timeout() -> void:
	evil.text = str(Inventory.get_meta("evil"))
	gold.text = str(Inventory.get_meta("gold"))
	#energy.text = str(Inventory.get_meta("energy"))
	#strenght.text = str(Inventory.get_meta("strenght"))
