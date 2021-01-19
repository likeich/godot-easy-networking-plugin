extends KinematicBody


var speed = .2
var custom_color: Color = Color(1, 1, 1)
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
	
	if Input.is_action_just_pressed("change_color"):
		custom_color = Color(randf(), randf(), randf())
		net_set_custom_color(custom_color)

func interpolate_translation(old: Vector3, new: Vector3, interp_ratio: float):
	#print("Ratio: ", interp_ratio)
	translation = lerp(old, new, interp_ratio)

func net_set_custom_color(color: Color):
	get_node("CSGBox").material = get_node("CSGBox").material.duplicate()
	get_node("CSGBox").material.set_albedo(color)
