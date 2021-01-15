extends Node

export var server_owned: bool = false
export var synced_properties: PoolStringArray = [] # Where synced vars are placed.
export var print_latency: bool = false

var can_update := true
var previous_full_state: Networking.State # The last state with no null values.

onready var body = get_parent() # The object being networked.

func _ready():
	if server_owned:
		body.set_network_master(1)
	
	previous_full_state = Networking.State.new(fill_properties(), 0, OS.get_system_time_msecs())

func _physics_process(_delta):
	# Master process
	if is_instance_valid(get_tree().network_peer) and is_network_master() and can_update:
		var timer = Timer.new()
		timer.connect("timeout", self, "update_rate_timeout")
		add_child(timer)
		can_update = false
		timer.start(1.0/30.0)
		# Send snapshot
		send_state()

func update_rate_timeout():
	can_update = true

func _enter_tree():
	pass

# Used to create the state custom_data from the properties export var.
func fill_properties() -> Array:
	var properties: Array = []
	for property_num in synced_properties.size():
		properties.append(body.get(synced_properties[property_num]))
	
	return properties

# Sends the state to the server if it has new information to send.
func send_state():
	# Creates a property array and fills it with variables from the parent.
	var properties = fill_properties()
	
	# Nulls state variables that are the same to save bandwidth.
	var state: Networking.State = Networking.State.new(properties, Networking.LongBool.new().get_data(), OS.get_system_time_msecs())
	#var changed := set_changed_states(state)
	
	#if !changed: return # If the state hasn't changed then don't send state.
	
	set_previous_full_state(state)
	Networking.send_state(state, body.name)

# Sets the received variables in the parent object.
func interpolate_state(old_state: Networking.State, new_state: Networking.State, interp_ratio: float = .5):
	for num in new_state.custom_data.size():
		#print(synced_properties[num], " : ", new_state.custom_data[num])
		
		if print_latency:
			print(new_state.timestamp - old_state.timestamp)
		
		if new_state.custom_data[num] == null: # Can be null from set_changed_states.
			continue
		elif body.has_method("interpolate_" + synced_properties[num]):
			body.call("interpolate_" + synced_properties[num], old_state, new_state, interp_ratio)
		else:
			#print("Not Null: ", new_state.custom_data[num])
			body.set(synced_properties[num], new_state.custom_data[num])

# Updates the previous full state var and returns if the state has new data.
func set_changed_states(new_state: Networking.State) -> bool:
	var changed := false
	
	for num in new_state.custom_data.size():
		#print(synced_properties[num], " : ", new_state.custom_data[num])
		if new_state.custom_data[num] == previous_full_state.custom_data[num]:
			new_state.custom_data[num] = null
		else:
			changed = true
	
	return changed

func set_previous_full_state(new_state: Networking.State):
	for property in previous_full_state.custom_data.size():
		if new_state.custom_data[property] != null:
			previous_full_state.custom_data[property] = new_state.custom_data[property]
