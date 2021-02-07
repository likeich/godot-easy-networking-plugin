extends Spatial


onready var player = preload("res://Player.tscn")
onready var ball = preload("res://Ball.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var me = player.instance()
	me.name = str(get_tree().get_network_unique_id())
	me.set_network_master(get_tree().get_network_unique_id(), true)
	add_child(me)
