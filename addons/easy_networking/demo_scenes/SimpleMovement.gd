extends Spatial


onready var player = preload("res://addons/easy_networking/demo_scenes/Player.tscn")
onready var ball = preload("res://addons/easy_networking/demo_scenes/Ball.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = Networking.connect("player_list_changed", self, "player_connected")
	
	var me = player.instance()
	me.name = str(get_tree().get_network_unique_id())
	me.set_network_master(get_tree().get_network_unique_id(), true)
	add_child(me)

func player_connected(list):
	for id in list:
		if find_node(str(id)) == null and Networking.is_server() and id != get_tree().get_network_unique_id():
			Networking.rpc_id(id, "join_game", filename)
