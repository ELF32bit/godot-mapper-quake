# Quake game profile for [godot-mapper](https://github.com/ELF32bit/godot-mapper) plugin
![Demonstration](screenshots/demonstration.webp)

Collision layers driven Quake entities with generic methods.<br>
Refer to the entity implementation table for the list of methods.<br>
Change **layers.gd** file to integrate entities into an existing project.<br>

> This repository needs a lot more work, better use it as a reference for now.

## Features
* Door linking is implemented.
* Platforms and doors can crush characters.
* Liquid areas use high precision camera detection.
* Animation states are stored inside a map.
* Most spawnflags are supported.

## Entity implementation table

State | Classname | Commentary
-- | ---------------------- | ----------------------------------------------------------- |
🟨 | worldspawn             | CD tracks 2-11 are not included for the `sounds` property.<br> World environment (sunlight and fog) needs more work.<br>`_quake_submerge(area: Area3D, liquid: int)`
✅ | info_*                 | Does not implement **progs.dat** hacks.
🟨 | item_*                 | Can't be picked up.
🟨 | weapon_*               | Can't be picked up.
✅ | light_*                | No light flickering.
✅ | monster_*              | Enemy AI is beyond the scope of this project.
✅ | ambient_*              |
✅ | func_door              | Might be driven by `quake_health: int`<br>`_quake_crush(body: PhysicsBody3D, damage: int)`
❌ | func_door_secret       | Is driven by `quake_health: int`<br>`_quake_crush(body: PhysicsBody3D, damage: int)`
✅ | func_wall              | **Uses extended alternative texture system.**
✅ | func_button            | Might be driven by `quake_health: int`
✅ | func_train             | `_quake_crush(body: PhysicsBody3D, damage: int)`
✅ | func_plat              | `_quake_crush(body: PhysicsBody3D, damage: int)`
✅ | func_illusionary       |
❌ | func_episodegate       | Unnecessary story entity.
❌ | func_bossgate          | Unnecessary story entity.
✅ | trigger_changelevel    | Does not change current `map`.
✅ | trigger_once           | Might be driven by `quake_health: int`
✅ | trigger_multiple       | Might be driven by `quake_health: int`
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
✅ | misc_explobox*         | Does not have script to explode.
🟨 | misc_fireball          | Does not move or deal damage.
✅ | misc_noisemaker        |
✅ | path_corner            |
✅ | testplayerstart        |
❌ |trap_shooter            | **Will require method on a character.**
❌ |trap_spikeshooter       | **Will require method on a character.**
✅ | viewthing              |