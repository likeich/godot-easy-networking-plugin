extends Node

export var server_owned: bool = false
export var synced_properties: PoolStringArray = []

onready var body = get_parent()

func _ready():
	pass

func _physics_process(delta):
	if is_network_master():
		send_state()

func _enter_tree():
	pass

func send_state():
	var properties: Array = []
	
	for property_num in synced_properties.size():
		properties.append(body.get(synced_properties[property_num]))
	
	var state: Networking.State = Networking.State.new(properties, Networking.LongBool.new().get_data(), OS.get_system_time_msecs())
	Networking.send_state(state, body.name)

func interpolate_state(old_state: Networking.State, new_state: Networking.State, interp_ratio: float = .5):
	#print(Networking.LongBool.new(new_state.custom_bools).print_bool())
	for num in new_state.custom_data.size():
		#print(synced_properties[num], " : ", new_state.custom_data[num])
		body.set(synced_properties[num], new_state.custom_data[num])
