@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if preload("__post.gd").bind_appearflags_base(map, entity):
		return null
	# testing player start
	var node := Marker3D.new()
	node.add_to_group("test_player_start", true)
	return node
