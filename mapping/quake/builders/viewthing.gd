@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	# debug entity: fake player model
	var player := map.loader.load_mdl("mdls/monsters/player.mdl")
	if not player:
		return null

	var player_instance := player.instantiate()
	return player_instance
