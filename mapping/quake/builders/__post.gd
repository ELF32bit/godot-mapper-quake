@warning_ignore("unused_parameter")
static func build(map: MapperMap) -> void:
	var lightmap_gi := MapperUtilities.create_lightmap_gi(map, map.node)
	lightmap_gi.set_script(preload("../scripts/editor/lightmap.gd"))


@warning_ignore("unused_parameter")
static func __build_faces_colors(face: MapperFace, colors: PackedColorArray) -> void:
	var c := absf(face.plane.normal.dot(Vector3.UP))
	colors.fill(Color(c, c, c))
	return
