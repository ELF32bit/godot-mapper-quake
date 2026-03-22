extends MapperQuake

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	# debug entity: fake player model
	var player := map.loader.load_mdl("mdls/monsters/player")
	if not player:
		return null

	var player_instance := player.instantiate()
	player_instance.set_script(map.loader.load_script("scripts/monster"))
	player_instance.classname = entity.get_classname_property()
	player_instance.animation_name = "stand"

	return player_instance
