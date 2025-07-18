extends Node

@export var _targets: Array = [] # typed array (NodePath) throws errors
@export var _kill_targets: Array = [] # typed array (NodePath) throws errors


func _get_first_node_of_class(from: Node, node_paths: Array[NodePath], node_class: StringName = "Node") -> Node:
	if not ClassDB.class_exists(node_class):
		return null
	if not ClassDB.is_parent_class(node_class, "Node"):
		return null
	for node_path in node_paths:
		var node_path_node := from.get_node_or_null(node_path)
		if node_path_node != null:
			if node_path_node.is_class(node_class):
				return node_path_node
	return null


func _get_nodes_of_class(from: Node, node_paths: Array[NodePath], node_class: StringName = "Node") -> Array[Node]:
	var nodes: Array[Node] = []
	if not ClassDB.class_exists(node_class):
		return nodes
	if not ClassDB.is_parent_class(node_class, "Node"):
		return nodes
	for node_path in node_paths:
		var node_path_node := from.get_node_or_null(node_path)
		if node_path_node != null:
			if node_path_node.is_class(node_class):
				nodes.append(node_path_node)
	return nodes


func get_first_target_node(node_class: StringName = "Node") -> Node:
	return _get_first_node_of_class(self, _targets, node_class)


func get_first_killtarget_node(node_class: StringName = "Node") -> Node:
	return _get_first_node_of_class(self, _kill_targets, node_class)


func get_target_nodes(node_class: StringName = "Node") -> Array[Node]:
	return _get_nodes_of_class(self, _targets, node_class)


func get_killtarget_nodes(node_class: StringName = "Node") -> Array[Node]:
	return _get_nodes_of_class(self, _kill_targets, node_class)
