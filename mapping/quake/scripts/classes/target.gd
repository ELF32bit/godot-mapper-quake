extends Node

@export var _target: NodePath
@export var _kill_target: NodePath


func _get_node_of_class(from: Node, node_path: NodePath, node_class: StringName = "Node") -> Node:
	if not ClassDB.class_exists(node_class):
		return null
	if not ClassDB.is_parent_class(node_class, "Node"):
		return null
	var node_path_node := from.get_node_or_null(node_path)
	if node_path_node != null:
		if node_path_node.is_class(node_class):
			return node_path_node
	return null


func get_target_node(node_class: StringName = "Node") -> Node:
	return _get_node_of_class(self, _target, node_class)


func get_killtarget_node(node_class: StringName = "Node") -> Node:
	return _get_node_of_class(self, _kill_target, node_class)
