# Quake game profile for [godot-mapper](https://github.com/ELF32bit/godot-mapper) plugin [WIP]
![Demonstration](screenshots/demonstration.webp)

Collision layers driven Quake entities.<br>

* Door linking is implemented.
* Platforms and doors can crush characters.
* Liquid areas use high precision camera detection.
* Animation states are stored inside a map.
* Most spawnflags are supported.

Change **layers.gd** file to integrate entities into your project.
> This repository needs a lot more work, better use it as a reference.

## Generated scene tree examples
|Scene Tree|func_door|
|:-:|:-:|
|<img src="screenshots/func_door-nodes.png" height="256px">|<img src="screenshots/func_door-demo.webp" height="256px">|

|Scene Tree|func_plat|
|:-:|:-:|
|<img src="screenshots/func_plat-nodes.png" height="256px">|<img src="screenshots/func_plat-demo.webp" height="256px">|

|Scene Tree|func_button|
|:-:|:-:|
|<img src="screenshots/func_button-nodes.png" height="256px">|<img src="screenshots/func_button-demo.webp" height="256px">|