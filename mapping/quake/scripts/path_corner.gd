extends Node3D

const NODE_PATH_UTILITIES := preload("utilities/node_paths.gd")

@export var _targets: Array[NodePath]
@export var wait_time: float = 0.0

var targets: Array[Node]:
	get:
		return NODE_PATH_UTILITIES.get_valid_nodes(self, _targets)
	set(_value):
		return

var target: Node:
	get:
		return NODE_PATH_UTILITIES.get_first_valid_node(self, _targets)
	set(_value):
		return
