extends Spatial


onready var player = preload("res://Player.tscn")
onready var ball = preload("res://Ball.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = Networking.create_players(player, self)
	
	for i in 500:
		var ball_ins = ball.instance()
		ball_ins.name = "ball" + str(i)
		add_child(ball_ins)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
