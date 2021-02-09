extends Spatial

var custom_color: Color = Color(1, 1, 1)

func _physics_process(_delta):
	if !is_network_master():
		return
	
	if Input.is_action_just_pressed("change_color"):
		custom_color = Color(randf(), randf(), randf())
		net_set_custom_color(custom_color)

func net_set_custom_color(color: Color):
	get_node("CSGBox").material = get_node("CSGBox").material.duplicate()
	get_node("CSGBox").material.set_albedo(color)
