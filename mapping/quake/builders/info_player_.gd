extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null

	var node := Marker3D.new()
	match entity.get_classname_property():
		"info_player_start": # player 1 start
			node.add_to_group("info_player_start", true)
		"info_player_coop": # player cooperative start
			node.add_to_group("info_player_coop", true)
		"info_player_start2": # player episode return point
			node.add_to_group("info_player_start2", true)
		"info_player_deathmatch": # deathmatch start
			node.add_to_group("info_player_start2", true)
		_:
			node.free()
			return null

	return node
