# Simple Networking Plugin
A plugin for the Godot game engine that provides a simple drag-and-drop networking interface that requires as little code as possible.

Inlcuded: 
A Networking global script that provides many networking functions, including: state changes, creating players, and receiving local and global IP addresses from an API.
A NetworkSyncer node that allows a user to type-in the properties of the parent that need to be synced. Lastly, an example lobby for rapid prototyping that also functions as a lobby demo.

This is still in development, expect a lot of issues and missing features (interpolation being one of them).

The networking state-syncer is heavily based on vec64's Godot-Multiplayer-FPS https://github.com/vec64/Godot-Multiplayer-FPS

The cloud icons are by Kenney - https://kenney.nl/

# Basic Tutorial

![til](https://github.com/likeich/Godot-Simple-Networking-Plugin/blob/main/preview.gif?raw=true)

1. Add the addons folder from this repo into your godot project.
2. Enable the plugin and the autoload Networking script (Errors will show up, you will probably have to restart the editor a couple times)
3. Assign the lobby tscn as the startup scene.
4. On the lobby scene, set the export variable "scene to start" as the path to the scene your game will take place in.
5. Create a script for that world that creates players. Networking.create_players() can be used for this.
6. On the player scene, add the NetworkSync node as a child of the root node. On it's array export variable, set the names of the variables to be synced. Ensure that the player objects that are puppets aren't going to receive player input.
7. Test it out.

**Q:** How do I use a NetworkSyncer node?

**A:** Add it to whatever object you want to sync and set the root node as the main node of the scene (the root node MUST be individually named or the caching of the NetworkSyncer node will not work). Any object can have multiple network nodes as long as the root node is named in a unique way.

**Q:** How do I delete a networked node over the network?

**A:** You don't have to. The nodes will handle the networking of deletion automatically.

**Q:** How do I add interpolation to reduce jitter?

**A:** NetworkSyncer nodes check their parent for a custom property interpolating function in this format: "interpolate_[variable name from synced properties]". If the parent has this function, it will use that for interpolation by sending the old variable, new variable, and interpolation ratio. Place a function with that name in the parent.

Ex: place 'func interpolate_velocity(old_ver: Vector3, new_vel: Vector3, interp: float)' in the parent function and "velocity" in the NetworkSyncer property array.

There is an example of this in the Player Scene.
