# Quake game profile for [godot-mapper](https://github.com/ELF32bit/godot-mapper) plugin
![Demonstration](screenshots/demonstration.webp)<br>
Collision layers driven Quake entities with generic methods.<br>
Refer to the entity implementation table for the list of methods.<br>
Change **layers.gd** file to integrate entities into an existing project.<br>

> Game scripts in the repository are very short and need a lot more polishing.

## Features
* Door linking is implemented.
* Platforms and doors can crush characters.
* Liquid areas use high precision camera detection.
* Animation states are stored inside a map.
* Most spawnflags are supported.

> Requires compiling Godot editor with **`XA_MULTITHREADED 0`** for lightmapping.

## Running the examples
Maps in the repository are not constructed, so a fresh project can open.<br>
The **main scene** is a basic game launcher that will construct playable maps at runtime.<br>
As the maps are constructed, you will see `mapdata` directory getting filled with placeholder files.<br>
Lightmap and navigation region resources must be baked inside the editor to appear in the game.<br>
Import map resources as scenes inside the editor and bake the necessary data.<br>

> The most efficient way to develop new maps is to insert them into scenes.<br>
External animation players will then be able to retain node paths upon reimport.<br>
Create a dedicated `scenes` directory near the `maps` directory and overlay changes.

## Entity implementation table

State | Classname | Commentary
-- | ---------------------- | ----------------------------------------------------------- |
🟨 | worldspawn             | CD tracks 2-11 are not included for the `sounds` property.<br> World environment (sunlight and fog) needs more work.<br>`_quake_submerge(area: Area3D, liquid: int)`
✅ | info_*                 |
❌ | info_notnull           | Does not implement **progs.dat** hacks.
✅ | item_*                 | Keys are not registered for opening doors.<br>Some items are loaded as sub-maps.
✅ | weapon_*               |
✅ | light_*                | Light flickering is visible in Forward+ renderer.
✅ | monster_*              | Enemy AI is beyond the scope of this project.
✅ | ambient_*              |
✅ | func_door              | Might have `quake_health: int` property.<br>`_quake_crush(body: Node3D, damage: int)`
✅ | func_door_secret       | Has `quake_health: int` property.<br>`_quake_crush(body: Node3D, damage: int)`
✅ | func_wall              | **Implements extended alternative texture system.**
✅ | func_button            | Might have `quake_health: int` property.
✅ | func_train             | `_quake_crush(body: Node3D, damage: int)`
✅ | func_plat              | `_quake_crush(body: Node3D, damage: int)`
✅ | func_illusionary       |
🟨 | func_episodegate       | Unnecessary story entity.
🟨 | func_bossgate          | Unnecessary story entity.
✅ | trigger_changelevel    | Requires game specific logic to change `map`.
✅ | trigger_once           | Might have `quake_health: int` property.
✅ | trigger_multiple       | Might have `quake_health: int` property.
✅ | trigger_onlyregistered | Requires map `game_registered` option.
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
✅ | misc_explobox*         | Has `quake_health: int` property.<br>`_quake_explode(damage: int)`
✅ | misc_fireball          | Does not use the exact speed and gravity.<br>`_quake_hurt(damage: int)`
✅ | misc_noisemaker        |
✅ | misc_teleporttrain     |
✅ | path_corner            |
✅ | testplayerstart        |
✅ |trap_shooter            | `_quake_hurt(damage: int)`
✅ |trap_spikeshooter       | `_quake_hurt(damage: int)`
✅ | viewthing              |
