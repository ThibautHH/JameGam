extends Node

@onready var evil: Label = $evil
@onready var strength: Label = $strength
@onready var gold: Label = $gold
@onready var energy: Label = $energy

func _on_update_display_timeout() -> void:
	evil.text = str(Inventory.get_meta("evil"))
	gold.text = str(Inventory.get_meta("gold"))
	#energy.text = str(Inventory.get_meta("energy"))
	strength.text = str(Inventory.get_meta("strength"))
