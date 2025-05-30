@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	match entity.get_classname_property("").trim_prefix("monster_"):
		"army":
			var scene := map.loader.load_mdl("mdls/monsters/soldier.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"dog":
			var scene := map.loader.load_mdl("mdls/monsters/dog.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"ogre":
			var scene := map.loader.load_mdl("mdls/monsters/ogre.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"ogre_marksman":
			var scene := map.loader.load_mdl("mdls/monsters/ogre.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"knight":
			var scene := map.loader.load_mdl("mdls/monsters/knight.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"hell_knight":
			var scene := map.loader.load_mdl("mdls/monsters/hknight.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"wizard":
			var scene := map.loader.load_mdl("mdls/monsters/wizard.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"wizard":
			var scene := map.loader.load_mdl("mdls/monsters/wizard.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"demon1":
			var scene := map.loader.load_mdl("mdls/monsters/demon.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"shambler":
			var scene := map.loader.load_mdl("mdls/monsters/shambler.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"boss":
			var scene := map.loader.load_mdl("mdls/monsters/boss.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"enforcer":
			var scene := map.loader.load_mdl("mdls/monsters/enforcer.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"shalrath":
			var scene := map.loader.load_mdl("mdls/monsters/shalrath.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"tarbaby":
			var scene := map.loader.load_mdl("mdls/monsters/tarbaby.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"fish":
			var scene := map.loader.load_mdl("mdls/monsters/fish.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"oldone":
			var scene := map.loader.load_mdl("mdls/monsters/oldone.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance
		"zombie":
			var scene := map.loader.load_mdl("mdls/monsters/zombie.mdl")
			var scene_instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			return scene_instance

	return null
