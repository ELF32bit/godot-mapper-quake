extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	var spawnflags: int = entity.get_int_property("spawnflags", 0)

	var monster: PackedScene = null
	match entity.get_classname_property():
		"monster_army": # grunt
			monster = map.loader.load_mdl("mdls/monsters/soldier.mdl")
		"monster_dog": # nasty doggie
			monster = map.loader.load_mdl("mdls/monsters/dog.mdl")
		"monster_ogre": # ogre
			monster = map.loader.load_mdl("mdls/monsters/ogre.mdl")
		"monster_ogre_marksman": # ogre marksman
			monster = map.loader.load_mdl("mdls/monsters/ogre.mdl")
		"monster_knight": # knight
			monster = map.loader.load_mdl("mdls/monsters/knight.mdl")
		"monster_hell_knight": # hell knight
			monster = map.loader.load_mdl("mdls/monsters/hknight.mdl")
		"monster_wizard": # scrag
			monster = map.loader.load_mdl("mdls/monsters/wizard.mdl")
		"monster_demon1": # fiend
			monster = map.loader.load_mdl("mdls/monsters/demon.mdl")
		"monster_shambler": # shambler
			monster = map.loader.load_mdl("mdls/monsters/shambler.mdl")
		"monster_boss": # chthon
			monster = map.loader.load_mdl("mdls/monsters/boss.mdl")
		"monster_enforcer": # enforcer
			monster = map.loader.load_mdl("mdls/monsters/enforcer.mdl")
		"monster_shalrath": # vore
			monster = map.loader.load_mdl("mdls/monsters/shalrath.mdl")
		"monster_tarbaby": # spawn
			monster = map.loader.load_mdl("mdls/monsters/tarbaby.mdl")
		"monster_fish": # rotfish
			monster = map.loader.load_mdl("mdls/monsters/fish.mdl")
		"monster_oldone": # shub-niggurath
			monster = map.loader.load_mdl("mdls/monsters/oldone.mdl")
		"monster_zombie": # zombie
			monster = map.loader.load_mdl("mdls/monsters/zombie.mdl")
			if spawnflags & 1: # frame: 192
				pass
	if not monster:
		return null

	var monster_instance := monster.instantiate()
	monster_instance.set_script(preload("../scripts/editor/monster.gd"))
	monster_instance.monster_name = entity.get_classname_property("").trim_prefix("monster_")

	# binding monster properties
	bind_monster_base(entity)

	return monster_instance
