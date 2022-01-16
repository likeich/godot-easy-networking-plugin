extends Resource
class_name LongBool

# Long Bool is used to send object/character NetState data efficiently over a network.
# The data format used is an integer, and each individual bit is set and get 
# individually as if they are a boolean.
#
# This can be used to send input commands (forward = true, etc.) or other frame
# variables like shot = true. An enum is recommended to fill a longbool to provide
# a nice interface as opposed to setting and remembering indexes manually.
#
# Valid indexes for longbool are 0-63. Out of bound indexes will not be recorded.
var data: int

func _init(new_data: int = 0):
	data = new_data

func get_data() -> int:
	return data

func set_data(new_data: int) -> void:
	data = new_data

func clear_data() -> void:
	data = 0

func get_array() -> Array:
	var array = []
	for index in 63:
		if get_value(index):
			array.append(1)
		else:
			array.append(0)
	return array

func print_bool() -> void:
	print(get_array())

func get_value(index : int) -> bool:
	return data & (1 << index) != 0

func set_value(index: int, value: bool) -> void:
	if value:
		data = enable_index(index)
	else:
		data = disable_index(index)

func enable_index(index : int) -> int:
	return data | 1 << index

func disable_index(index : int) -> int:
	return data & ~(1 << index)
