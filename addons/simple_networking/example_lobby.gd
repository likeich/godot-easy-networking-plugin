extends Control

export var scene_to_start: String

onready var connect = $Connect
onready var lobby = $Lobby
onready var player_list = find_node("PlayerList")
onready var start_button = find_node("StartButton")
onready var ip_box = find_node("IPAddress")

# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = Networking.connect("connection_succeeded", self, "_connected")
	_err = Networking.connect("connection_failed", self, "_failure")
	_err = Networking.connect("player_list_changed", self, "_players_changed")
	_err = Networking.connect("global_ip_found", self, "set_global_ip")
	print(Networking.my_local_ip)

func _connected():
	connect.hide()
	lobby.show()
	
	update_players()
	start_button.disabled = true

func _failure():
	print("Failed!")

func _players_changed(_players: Array):
	update_players()

func _on_HostButton_pressed():
	Networking.start_server()
	connect.hide()
	lobby.show()
	
	update_players()
	start_button.disabled = false


func _on_JoinButton_pressed():
	Networking.start_client(ip_box.text)


func _on_ExitButton_pressed():
	Networking.exit()
	connect.show()
	lobby.hide()
	update_players()


func _on_StartButton_pressed():
	Networking.rpc("start_game", scene_to_start)

func update_players():
	for player in player_list.get_children():
		player.queue_free()
	
	for id in Networking.player_ids:
		var player = Label.new()
		player.text = str(id)
		
		player_list.add_child(player)

func set_global_ip():
	ip_box.text = Networking.my_global_ip
