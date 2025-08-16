extends Node3D


func _ready() -> void:
	var map_resource: MapperMapResource = null
	map_resource = MapperMapResource.load_from_file("res://mapping/quake/maps/e1m1.map")
	var animated_wad := MapperWadResource.load_from_file("res://mapping/quake/wads/quake101.wad")

	var map_options := {}
	map_options["game_directory"] = "res://mapping/quake"
	map_options["game_loader"] = MapperSettings.QUAKE_GAME_LOADER
	map_options["skip_material_affects_collision"] = false
	map_options["prefer_static_lighting"] = true
	map_options["print_progress"] = true

	# using external lightmap:
	# import E1M1 as scene and bake lightmap
	# runtime constructed map will be using this lightmap
	# also enable lightmap_unwrap if using custom editor
	# compile Godot editor with XA_MULTITHREADED 0
	map_options["lightmap_unwrap"] = false
	map_options["__lightmap_external"] = true

	var settings := MapperSettings.new(map_options)
	var factory := MapperFactory.new(settings)
	var packed_scene := factory.build_map(map_resource, [animated_wad])

	self.add_child(packed_scene.instantiate())
	_spawn_player()


func _spawn_player() -> void:
	var player = preload("res://addons/observer/observer.tscn")
	var player_instance = player.instantiate()
	add_child(player_instance, true)

	player_instance.spring_arm_collision_mask = 1 + 4
	player_instance.set_collision_layer_value(1, true)
	player_instance.set_collision_layer_value(4, true)
	player_instance.set_collision_layer_value(6, true)
	player_instance.set_collision_mask_value(1, true)
	player_instance.set_collision_mask_value(2, true)
	player_instance.set_collision_mask_value(5, true)
	player_instance.set_collision_mask_value(6, true)
	player_instance.set_collision_mask_value(7, true)

	var spawns = get_tree().get_nodes_in_group("info_player_start")
	if spawns.size() != 0:
		player_instance.transform = spawns[randi() % spawns.size()].transform
