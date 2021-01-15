extends Spatial


onready var player = preload("res://Player.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	for id in Networking.player_ids:
		var new_player = player.instance()
		new_player.set_network_master(id)
		new_player.name = str(id)
		add_child(new_player)
