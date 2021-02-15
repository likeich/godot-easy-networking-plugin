extends KinematicBody

onready var ball = preload("res://addons/easy_networking/demo_scenes/Ball.tscn")

var ball_count = 0

var speed = .2
var moving := true


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
	
	if Input.is_key_pressed(KEY_Q):
		rotation.x += speed
	if Input.is_key_pressed(KEY_E):
		rotation.y += speed
	
	if Input.is_key_pressed(KEY_SPACE):
		var ball_ins = ball.instance()
		ball_ins.name = str(ball_count)
		get_parent().add_child(ball_ins)
		ball_count += 1

func interpolate_translation(old: Vector3, new: Vector3, interp_ratio: float):
	translation = lerp(old, new, interp_ratio)

func interpolate_rotation(old: Vector3, new: Vector3, interp_ratio: float):
	rotation = lerp(old, new, interp_ratio)
