static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var scene_instance: Node3D = null

	match entity.get_classname_property("").trim_prefix("item_"):
		"artifact_envirosuit":
			var scene := map.loader.load_mdl("mdls/items/suit.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"artifact_super_damage":
			var scene := map.loader.load_mdl("mdls/items/quaddama.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"artifact_invulnerability":
			var scene := map.loader.load_mdl("mdls/items/invulner.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"artifact_invisibility":
			var scene := map.loader.load_mdl("mdls/items/invisibl.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"armorInv":
			var scene := map.loader.load_mdl("mdls/items/armor.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"armor2":
			var scene := map.loader.load_mdl("mdls/items/armor.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"armor1":
			var scene := map.loader.load_mdl("mdls/items/armor.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"key1":
			var scene := map.loader.load_mdl("mdls/keys/m_s_key.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"key2":
			var scene := map.loader.load_mdl("mdls/keys/m_g_key", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"sigil":
			var scene := map.loader.load_mdl("mdls/items/end1.mdl", true)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	if scene_instance:
		return scene_instance

	match entity.get_classname_property("").trim_prefix("item_"):
		"cells":
			var scene := map.loader.load_map("maps/items/b_batt1.map", false)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"rockets":
			var scene := map.loader.load_map("maps/items/b_explob.map", false)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"shells":
			var scene := map.loader.load_map("maps/items/b_shell0.map", false)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"spikes":
			var scene := map.loader.load_map("maps/items/b_nail0.map", false)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"health":
			var scene := map.loader.load_map("maps/items/b_bh25.map", false)
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	if scene_instance:
		return scene_instance

	return null
