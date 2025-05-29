static func get_node_or_null(from: Node, node_path: NodePath, node_class: StringName = "Node") -> Node:
	if not ClassDB.class_exists(node_class):
		return null
	if not ClassDB.is_parent_class(node_class, "Node"):
		return null
	var node_path_node := from.get_node_or_null(node_path)
	if node_path_node != null:
		if node_path_node.is_class(node_class):
			return node_path_node
	return null


static func get_first_valid_node(from: Node, node_paths: Array[NodePath], node_class: StringName = "Node") -> Node:
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


static func get_valid_nodes(from: Node, node_paths: Array[NodePath], node_class: StringName = "Node") -> Array[Node]:
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
