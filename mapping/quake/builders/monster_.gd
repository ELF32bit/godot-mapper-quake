@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	var scene_instance: Node3D = null

	match entity.get_classname_property("").trim_prefix("monster_"):
		"army":
			var scene := map.loader.load_mdl("mdls/monsters/soldier.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"dog":
			var scene := map.loader.load_mdl("mdls/monsters/dog.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"ogre":
			var scene := map.loader.load_mdl("mdls/monsters/ogre.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"ogre_marksman":
			var scene := map.loader.load_mdl("mdls/monsters/ogre.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"knight":
			var scene := map.loader.load_mdl("mdls/monsters/knight.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"hell_knight":
			var scene := map.loader.load_mdl("mdls/monsters/hknight.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"wizard":
			var scene := map.loader.load_mdl("mdls/monsters/wizard.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"demon1":
			var scene := map.loader.load_mdl("mdls/monsters/demon.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"shambler":
			var scene := map.loader.load_mdl("mdls/monsters/shambler.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"boss":
			var scene := map.loader.load_mdl("mdls/monsters/boss.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"enforcer":
			var scene := map.loader.load_mdl("mdls/monsters/enforcer.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"shalrath":
			var scene := map.loader.load_mdl("mdls/monsters/shalrath.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"tarbaby":
			var scene := map.loader.load_mdl("mdls/monsters/tarbaby.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"fish":
			var scene := map.loader.load_mdl("mdls/monsters/fish.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"oldone":
			var scene := map.loader.load_mdl("mdls/monsters/oldone.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		"zombie":
			var scene := map.loader.load_mdl("mdls/monsters/zombie.mdl")
			scene_instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	if not scene_instance:
		return null

	scene_instance.set_script(preload("../scripts/editor/monster.gd"))
	scene_instance.monster_name = entity.get_classname_property("").trim_prefix("monster_")

	return scene_instance
