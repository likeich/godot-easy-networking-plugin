extends Node

export var root_node: NodePath
export var server_owned: bool = false
export var synced_properties: PoolStringArray = [] # Where synced vars are placed.
export var synced_booleans: PoolStringArray = [] # Maximum of up to 64 booleans
export var updates_per_second := 60.0
export var update_percent_required := 100.0
export var print_latency: bool = false

var can_update := true
var previous_full_state: Networking.NetState # The last state with no null values.
var sync_timer = Timer.new()
var update_count := 0
var parent_has_interpolator := []
var parent_has_setter := []
var parent_has_bool_setter := []

var network_sync_num: int

onready var body = get_parent() # The object being networked.

func _ready():
	Networking.connect("peer_ready_for_objects", self, "create_node_on_client")
	add_to_group(str(get_node(root_node).name, "NetworkSyncers"))
	network_sync_num = get_network_syncer_count()
	name = str(get_node(root_node).name, "NS", network_sync_num)
	Networking.cached_node_paths[name] = get_path()
	Networking.networked_objects_count += 1
	if server_owned:
		body.set_network_master(1)
	
	cache_parent_methods()
	previous_full_state = Networking.NetState.new(fill_properties(), fill_booleans(), OS.get_system_time_msecs())
	
	sync_timer.autostart = true
	sync_timer.wait_time = (1.0 / updates_per_second)
	sync_timer.one_shot = true
	sync_timer.connect("timeout", self, "send_state")
	add_child(sync_timer)
	
	peer_node_setup()

func peer_node_setup() -> void:
	if is_instance_valid(get_tree().network_peer) and Networking.network_type == Networking.NETWORK_TYPES.PEER_TO_PEER:
		Networking.rpc_id(0, "cache_local_path_on_server", name, get_path())
	elif is_instance_valid(get_tree().network_peer) and !Networking.is_server() and is_network_master():
		Networking.rpc_id(1, "cache_local_path_on_server", name, get_path())
	
	if is_instance_valid(get_tree().network_peer) and is_network_master() and network_sync_num == 1:
		var root = get_node(root_node)
		Networking.rpc_id(0, "create_self_on_peers", root.filename, root.name, root.get_parent().get_path())

func create_node_on_client(scene_name: String, peer_id: int) -> void:
	# If they aren't in the same scene, don't attempt to recreate this node.
	if get_tree().current_scene.name != scene_name or network_sync_num != 1 or peer_id == get_tree().get_network_unique_id(): return
	
	print("Creating node")
	var root = get_node(root_node)
	Networking.rpc_id(peer_id, "create_self_on_peers", root.filename, root.name, root.get_parent().get_path())

# Returns the number of this network syncer for naming purposes.
func get_network_syncer_count() -> int:
	var syncer_count := 0
	
	for child in get_tree().get_nodes_in_group(str(get_node(root_node).name, "NetworkSyncers")):
		syncer_count += 1
		if child == self:
			return syncer_count
	
	return 0

func cache_parent_methods() -> void:
	for num in synced_properties.size():
		if body.has_method("interpolate_" + synced_properties[num]):
			parent_has_interpolator.append(true)
		else:
			parent_has_interpolator.append(false)
		
		if body.has_method("net_set_" + synced_properties[num]):
			parent_has_setter.append(true)
		else:
			parent_has_setter.append(false)
	
	for num in synced_booleans.size():
		if body.has_method("net_set_" + synced_booleans[num]):
			parent_has_bool_setter.append(true)
		else:
			parent_has_bool_setter.append(false)

# Used to create the state custom_data from the properties export var.
func fill_properties() -> Array:
	var properties: Array = []
	for property_num in synced_properties.size():
		properties.append(body.get(synced_properties[property_num]))
	
	return properties

# Used to create the state custom_bools from the booleans export var.
func fill_booleans() -> int:
	var lbool = Networking.LongBool.new()
	for property_num in synced_booleans.size():
		lbool.set_value(property_num, body.get(synced_booleans[property_num]))
	
	return lbool.get_data()

# Sends the state to the server if it has new information to send.
func send_state():
	if !is_instance_valid(get_tree().network_peer) or !is_network_master(): return
	
	update_count += 1
	
	# Nulls state variables that are the same to save bandwidth.
	var state: Networking.NetState = Networking.NetState.new(fill_properties(), fill_booleans(), OS.get_system_time_msecs())
	
	#Calculates if a required packet should be sent.
	if is_required_update():
		set_previous_full_state(state)
		Networking.send_state(state, name)
		sync_timer.start((1 / updates_per_second))
		reset_update_count()
		
		return
	
	# If the object state has not changed, then don't send another state.
	if !was_changed(state): 
		sync_timer.start((1 / updates_per_second))
		reset_update_count()
		
		return
	
	set_previous_full_state(state)
	Networking.send_state(state, name)
	sync_timer.start((1 / updates_per_second))
	reset_update_count()

# Sets the received variables in the parent object.
func interpolate_state(old_state: Networking.NetState, new_state: Networking.NetState, interp_ratio: float = .5):
	#if old_state.timestamp >= new_state.timestamp: return
	
	for num in new_state.custom_data.size():
		if new_state.custom_data[num] == null: # Can be null from was_changed.
			continue
		elif parent_has_interpolator[num] and old_state != null:
			body.call("interpolate_" + synced_properties[num], old_state.custom_data[num], new_state.custom_data[num], interp_ratio)
		elif parent_has_setter[num]:
			body.call("net_set_" + synced_properties[num], new_state.custom_data[num])
		else:
			body.set(synced_properties[num], new_state.custom_data[num])
	
	var lbool := Networking.LongBool.new(new_state.custom_bools)
	for num in synced_booleans.size():
		if parent_has_bool_setter[num]:
			body.call("net_set_" + synced_booleans[num], lbool.get_value(num))
		else: 
			body.set(synced_booleans[num], lbool.get_value(num))

func is_required_update() -> bool:
	var calculation: int = int(round((update_percent_required / 100) * updates_per_second))
	return (calculation != 0) and (update_count % int(round(updates_per_second / calculation)) == 0)

# Updates the previous full state var and returns if the state has new data.
func was_changed(new_state: Networking.NetState) -> bool:
	for num in new_state.custom_data.size():
		if new_state.custom_data[num] != previous_full_state.custom_data[num]:
			return true
	
	if new_state.custom_bools != previous_full_state.custom_bools:
		return true
	
	return false

func set_states_null(state: Networking.NetState) -> void:
	for num in state.custom_data.size():
		if state.custom_data[num] != previous_full_state.custom_data[num]:
			state.custom_data[num] = null

func reset_update_count() -> void:
	if update_count >= updates_per_second:
			update_count = 0

# Sets the previous full state by ignoring null values.
func set_previous_full_state(new_state: Networking.NetState):
	for property in previous_full_state.custom_data.size():
		if new_state.custom_data[property] != null:
			previous_full_state.custom_data[property] = new_state.custom_data[property]
	previous_full_state.custom_bools = new_state.custom_bools
	previous_full_state.timestamp = new_state.timestamp

func _exit_tree():
	Networking.networked_objects_count -= 1
	Networking.remove_timestamp(name)
	Networking.cached_node_paths.erase(name)
	
	if is_instance_valid(get_tree().network_peer) and is_network_master():
		if !Networking.is_server():
			Networking.rpc_id(1, "remove_client_cached_path", name)
		rpc("delete_object")

remote func delete_object():
	Networking.cached_node_paths.erase(name)
	body.queue_free()

func get_class() -> String:
	return "NetworkSyncer"

func _get_configuration_warning() -> String:
	if root_node == "":
		return "Root Node must be set and named uniquely at runtime!"
	elif synced_properties.size() == 0 and synced_booleans.size() == 0:
		return "You should probably sync some variables."
	return ""
