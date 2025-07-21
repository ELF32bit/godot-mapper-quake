# Quake game profile for [godot-mapper](https://github.com/ELF32bit/godot-mapper) plugin
![Demonstration](screenshots/demonstration.webp)

Collision layers driven Quake entities with generic methods.<br>
Refer to the entity implementation table for the list of methods.<br>
Change **layers.gd** file to integrate entities into your project.<br>

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
✏️ | worldspawn             | CD tracks 2-11 are not included for the `sounds` property.<br> World environment (sunlight and fog) needs more work.<br><u>Game script for liquid areas needs to be redesigned.</u><br>**Will require method on a character.**
✅ | info_*                 | `info_notnull` does not implement `progs.dat` hacks.
✏️ | item_*                 | Can't be picked up. Armor does not use MDL skins.
✏️ | weapon_*               | Can't be picked up.
❌ | light_*                | Poor spotlight implementation. No light flickering.
✅ | monster_*              | Enemy AI is beyond the scope of this project.
✅ | ambient_*              |
❌ | func_door              | <u>Game scripts need to be redesigned for a new implementation.</u><br> **Requires "crush" method on characters and collision objects.**<br>**Might be driven by a "health" property.**
❌ | func_door_secret       | Follows after `func_door`. Uses different logic.
✅ | func_wall              | Uses extended alternative texture system.
✅ | func_button            | **Might be driven by a "health" property.**
✅ | func_train             | **Requires "crush" method on characters and collision objects.**
✅ | func_plat              | **Requires "crush" method on characters and collision objects.**
✅ | func_illusionary       |
❌ | func_episodegate       | Doesn't implement necessary game logic.
❌ | func_bossgate          | Doesn't implement necessary game logic.
❌ | trigger_changelevel    | Game script is not implemented.
✅ | trigger_once           | **Might be driven by a "health" property.**
❌ | trigger_multiple       | Game script is not implemented.<br>**Might be driven by a "health" property.**
❌ | trigger_onlyregistered | Game script is not implemented.
❌ | trigger_secret         | Game script is not implemented.
✅ | trigger_teleport       | **Requires "push" method on a collision object.**
❌ | trigger_setskill       | Game script is not implemented.
✅ | trigger_relay          | Does not print `message`, nowhere to currently.
❌ | trigger_monsterjump    | Game script is not implemented.<br>**Will require method on a character.**
✅ | trigger_counter        | Does not print `message`, nowhere to currently.
✅ | trigger_push           | **Requires "push" method on a collision object.**
❌ | trigger_hurt           | Game script is not implemented.<br>**Will require method on a character.**
✏️ | air_bubbles            | Can use some placeholder particle system.
✏️ | event_lightning        | Can use some placeholder particle system.
✏️ | misc_explobox          | Game script is not implemented.<br>**Will require method on a character.**
✏️ | misc_explobox2         | Game script is not implemented.<br>**Will require method on a character.**
✏️ | misc_fireball          | Game script is not implemented.<br>**Will require method on a character.**
✅ | misc_noisemaker        |
✅ | path_corner            |
✅ | testplayerstart        |
❌ |trap_shooter            | Game script is not implemented.<br>**Will require method on a character.**
❌ |trap_spikeshooter       | Game script is not implemented.<br>**Will require method on a character.**
✅ | viewthing              |