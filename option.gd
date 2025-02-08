extends Control


var event = [
	{
		"actionCost": 1,
		"desc": "mine 1 gold"
	},
	{
		"actionCost": 2,
		"desc": "make a hole"
	},
	{
		"actionCost": 0,
		"desc": "kill a child"
	}
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnButton(event);

func spendAction(actionCost : int, button : Button) -> void:
	print(actionCost)
	button.find_child("AnimatedSprite2D").play("default")


func spawnButton(config) -> void:
	var i : int = 0;
	for item in config:
		var bt = preload("res://button.tscn").instantiate();
		bt.position = Vector2(50, i * 100);
		bt.text = item["desc"]
		bt.set_meta("id", i)
		bt.spendAction.connect(spendAction)
		add_child(bt);
		i += 1;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
