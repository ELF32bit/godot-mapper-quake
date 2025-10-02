# Quake game profile for [godot-mapper](https://github.com/ELF32bit/godot-mapper) plugin
![Demonstration](screenshots/demonstration.webp)<br>

Collision layers driven Quake entities with generic methods.<br>
Refer to the entity implementation table for the list of methods.<br>
Change **layers.gd** file to integrate entities into an existing project.<br>

> This repository needs a lot more polishing, but a solid foundation is established.

## Features
* Door linking is implemented.
* Platforms and doors can crush characters.
* Liquid areas use high precision camera detection.
* Animation states are stored inside a map.
* Most spawnflags are supported.

> Requires compiling Godot editor with **`XA_MULTITHREADED 0`** for lightmapping.

## Entity implementation table

State | Classname | Commentary
-- | ---------------------- | ----------------------------------------------------------- |
🟨 | worldspawn             | CD tracks 2-11 are not included for the `sounds` property.<br> World environment (sunlight and fog) needs more work.<br>`_quake_submerge(area: Area3D, liquid: int)`
✅ | info_*                 |
❌ | info_notnull           | Does not implement **progs.dat** hacks.
🟨 | item_*                 | Can't be picked up.
🟨 | weapon_*               | Can't be picked up.
✅ | light_*                | Light flickering is visible in Forward+ renderer.
✅ | monster_*              | Enemy AI is beyond the scope of this project.
✅ | ambient_*              |
✅ | func_door              | Might have `quake_health: int` property.<br>`_quake_crush(body: PhysicsBody3D, damage: int)`
✅ | func_door_secret       | Has `quake_health: int` property.<br>`_quake_crush(body: PhysicsBody3D, damage: int)`
✅ | func_wall              | **Uses extended alternative texture system.**
✅ | func_button            | Might have `quake_health: int` property.
✅ | func_train             | `_quake_crush(body: PhysicsBody3D, damage: int)`
✅ | func_plat              | `_quake_crush(body: PhysicsBody3D, damage: int)`
✅ | func_illusionary       |
🟨 | func_episodegate       | Unnecessary story entity.
🟨 | func_bossgate          | Unnecessary story entity.
✅ | trigger_changelevel    | Requires game specific logic to change `map`.
✅ | trigger_once           | Might have `quake_health: int` property.
✅ | trigger_multiple       | Might have `quake_health: int` property.
✅ | trigger_onlyregistered | Uses map `game_registered` option.
✅ | trigger_secret         | Does not award a secret credit.
✅ | trigger_teleport       | `_quake_push(velocity: Vector3)`
✅ | trigger_setskill       | Does not set skill, use map `game_mode` option instead.
✅ | trigger_relay          |
✅ | trigger_monsterjump    | `_quake_monsterjump(velocity: Vector3, height: float)`
✅ | trigger_counter        |
✅ | trigger_push           | `_quake_push(velocity: Vector3)`
✅ | trigger_hurt           | `_quake_hurt(damage: int)`
🟨 | air_bubbles            | Uses placeholder particle system.
🟨 | event_lightning        | Uses placeholder particle system.
❌ | misc_explobox*         | Has `quake_health: int` property.<br>`_quake_explode(damage: int)`
🟨 | misc_fireball          | Does not move or deal damage.
✅ | misc_noisemaker        |
✅ | path_corner            |
✅ | testplayerstart        |
❌ |trap_shooter            | Does not shoot.
❌ |trap_spikeshooter       | Does not shoot.
✅ | viewthing              |
