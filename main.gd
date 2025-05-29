extends Node3D


func _ready() -> void:
	var map_resource: MapperMapResource = null
	#map_resource = load("res://mapping/quake/maps/e1m%s.map" % str(randi() % 8 + 1))
	map_resource = load("res://mapping/quake/maps/e1m1.map")

	var map_options := {}
	map_options["game_directory"] = "res://mapping/quake"
	map_options["game_loader"] = MapperSettings.QUAKE_GAME_LOADER
	map_options["skip_material_affects_collision"] = false
	map_options["prefer_static_lighting"] = true
	map_options["lightmap_unwrap"] = false
	var settings := MapperSettings.new(map_options)

	var factory := MapperFactory.new(settings)
	var animated_wad = preload("res://mapping/quake/wads/quake101.wad")
	var packed_scene := factory.build_map(map_resource, [animated_wad], true)

	self.add_child(packed_scene.instantiate())
	_spawn_player()


func _spawn_player() -> void:
	var player = preload("res://characters/player/player.tscn")
	var player_instance = player.instantiate()
	add_child(player_instance, true)

	var spawns = get_tree().get_nodes_in_group("info_player_start")
	if spawns.size() != 0:
		player_instance.transform = spawns[randi() % spawns.size()].transform
