extends KinematicBody


var speed = .2


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _physics_process(_delta):
	if !is_network_master(): return
	
	if Input.is_key_pressed(KEY_UP):
		translation.y += speed
	if Input.is_key_pressed(KEY_DOWN):
		translation.y -= speed
	if Input.is_key_pressed(KEY_LEFT):
		translation.x -= speed
	if Input.is_key_pressed(KEY_RIGHT):
		translation.x += speed
