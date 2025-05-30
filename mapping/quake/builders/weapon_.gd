static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var scene_instance: Node3D = null

	match entity.get_classname_property("").trim_prefix("weapon_"):
		"supershotgun":
			var scene := map.loader.load_mdl("mdls/items/g_shot.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"nailgun":
			var scene := map.loader.load_mdl("mdls/items/g_nail.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"supernailgun":
			var scene := map.loader.load_mdl("mdls/items/g_nail2.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"grenadelauncher":
			var scene := map.loader.load_mdl("mdls/items/g_rock.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"rocketlauncher":
			var scene := map.loader.load_mdl("mdls/items/g_rock2.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"lightning":
			var scene := map.loader.load_mdl("mdls/items/g_light.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)

	return scene_instance
