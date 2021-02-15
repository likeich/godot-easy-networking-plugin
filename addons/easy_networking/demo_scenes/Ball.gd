extends CSGSphere


var direction := Vector2.ZERO
var speed = 1
var timesout = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


func _physics_process(delta):
	var movement = translation + (Vector3(direction.x, direction.y, 0) * delta * speed)
	translation = movement
	
	if Input.is_key_pressed(KEY_Z):
		queue_free()


func _on_MoveTimer_timeout():
	if !is_network_master(): return
	
	timesout += 1
	direction = Vector2(rand_range(-1, 1), rand_range(-1, 1))
	
	if timesout > 5: direction = Vector2.ZERO

func interpolate_translation(old: Vector3, new: Vector3, interp_ratio: float):
	translation = lerp(old, new, interp_ratio)
