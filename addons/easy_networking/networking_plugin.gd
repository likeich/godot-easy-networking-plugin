tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	# Add the new type with a name, a parent type, a script and an icon.
	add_autoload_singleton("Networking", "res://addons/easy_networking/networking.gd")
	add_custom_type("NetworkSyncer", "Node", load("res://addons/easy_networking/network_syncer.gd"), preload("res://addons/easy_networking/cloud_upload.png"))


func _exit_tree():
	# Clean-up of the plugin goes here.
	# Always remember to remove it from the engine when deactivated.
	remove_custom_type("Network Syncer")
	remove_autoload_singleton("Networking")
