extends Spatial


onready var player = preload("res://Player.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	Networking.create_players(player, self)
