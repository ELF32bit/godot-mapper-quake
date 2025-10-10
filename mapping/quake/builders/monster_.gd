extends "__classes.gd"

@warning_ignore("unused_parameter")
static func build(map: MapperMap, entity: MapperEntity) -> Node:
	if bind_appearflags_base(map, entity):
		return null
	var spawnflags: int = entity.get_int_property("spawnflags", 0)

	var monster: PackedScene = null
	var monster_animation: String = ""
	match entity.get_classname_property():
		"monster_army": # grunt
			monster = map.loader.load_mdl("mdls/monsters/soldier.mdl")
			monster_animation = "stand"
		"monster_dog": # nasty doggie
			monster = map.loader.load_mdl("mdls/monsters/dog.mdl")
			monster_animation = "stand"
		"monster_ogre": # ogre
			monster = map.loader.load_mdl("mdls/monsters/ogre.mdl")
			monster_animation = "stand"
		"monster_ogre_marksman": # ogre marksman
			monster = map.loader.load_mdl("mdls/monsters/ogre.mdl")
			monster_animation = "stand"
		"monster_knight": # knight
			monster = map.loader.load_mdl("mdls/monsters/knight.mdl")
			monster_animation = "stand"
		"monster_hell_knight": # hell knight
			monster = map.loader.load_mdl("mdls/monsters/hknight.mdl")
			monster_animation = "stand"
		"monster_wizard": # scrag
			monster = map.loader.load_mdl("mdls/monsters/wizard.mdl")
			monster_animation = "hover"
		"monster_demon1": # fiend
			monster = map.loader.load_mdl("mdls/monsters/demon.mdl")
			monster_animation = "stand"
		"monster_shambler": # shambler
			monster = map.loader.load_mdl("mdls/monsters/shambler.mdl")
			monster_animation = "stand"
		"monster_boss": # chthon
			monster = map.loader.load_mdl("mdls/monsters/boss.mdl")
			monster_animation = "walk"
		"monster_enforcer": # enforcer
			monster = map.loader.load_mdl("mdls/monsters/enforcer.mdl")
			monster_animation = "stand"
		"monster_shalrath": # vore
			monster = map.loader.load_mdl("mdls/monsters/shalrath.mdl")
			monster_animation = "walk"
		"monster_tarbaby": # spawn
			monster = map.loader.load_mdl("mdls/monsters/tarbaby.mdl")
			monster_animation = "walk"
		"monster_fish": # rotfish
			monster = map.loader.load_mdl("mdls/monsters/fish.mdl")
			monster_animation = "swim"
		"monster_oldone": # shub-niggurath
			monster = map.loader.load_mdl("mdls/monsters/oldone.mdl")
			monster_animation = "old"
		"monster_zombie": # zombie
			monster = map.loader.load_mdl("mdls/monsters/zombie.mdl")
			monster_animation = "stand"
			if spawnflags & 1: # frame 192
				monster_animation = "cruc_"
	if not monster:
		return null

	var monster_instance := monster.instantiate()
	monster_instance.set_script(map.loader.load_script("scripts/monster"))
	monster_instance.set("classname", entity.get_classname_property())
	monster_instance.set("animation_name", monster_animation)

	# binding monster properties
	bind_monster_base(entity)

	return monster_instance
