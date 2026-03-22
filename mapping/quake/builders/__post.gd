@warning_ignore("unused_parameter")
static func build(map: MapperMap) -> void:
	if map.settings.options.get("_map_is_item", false):
		return
	if map.settings.options.get("_map_is_explobox", false):
		return

	# creating lightmapGI
	var lightmap_gi := MapperUtilities.create_lightmap_gi(map, map.node)
	lightmap_gi.set_script(preload("../scripts/lightmap.gd"))

	# creating world environment and directional light
	var first_world_entity := map.get_first_world_entity()
	if first_world_entity != null:
		preload("worldspawn.gd").post_build_environment(map, first_world_entity)

	# creating func_door entities from linking data
	for entity in map.classnames.get("func_door", []):
		var linking_data := link_entities(map, entity, 32.0, true)
		if linking_data.size():
			preload("func_door.gd").post_build(map, linking_data)


static func link_entities(map: MapperMap, entity: MapperEntity, link_units: float = 32.0, use_door_spawnflags: bool = false) -> Array:
	if not entity.node:
		return []
	if not entity.aabb.has_surface():
		return []
	if entity.metadata.get("__is_linked", false):
		return []

	var linked_aabb := entity.aabb
	var linked_entities: Array[MapperEntity] = [entity]
	if use_door_spawnflags:
		if entity.get_int_property("spawnflags", 0) & 4: # don't link
			return [linked_entities, linked_aabb, link_units]

	entity.metadata["__is_linked"] = true
	var grow_by: float = link_units / map.settings.unit_size
	var classname: Variant = entity.get_classname_property()
	var entites: Array = map.classnames.get(classname, [])

	for another_entity in entites:
		if not another_entity.node:
			continue
		if not another_entity.aabb.has_surface():
			continue
		if another_entity.metadata.get("__is_linked", false):
			continue
		if use_door_spawnflags:
			if another_entity.get_int_property("spawnflags", 0) & 4: # don't link
				continue

		if linked_aabb.grow(grow_by).intersects(another_entity.aabb.grow(grow_by)):
			another_entity.metadata["__is_linked"] = true
			linked_entities.append(another_entity)
			linked_aabb = linked_aabb.merge(another_entity.aabb)

	return [linked_entities, linked_aabb, link_units]
