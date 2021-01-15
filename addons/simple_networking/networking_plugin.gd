tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	# Add the new type with a name, a parent type, a script and an icon.
	add_custom_type("NetworkSyncer", "Node", preload("network_syncer.gd"), preload("cloud_upload.png"))
	add_autoload_singleton("Networking", "res://addons/simple_networking/networking.gd")


func _exit_tree():
	# Clean-up of the plugin goes here.
	# Always remember to remove it from the engine when deactivated.
	remove_custom_type("Network Syncer")
	remove_autoload_singleton("Networking")
