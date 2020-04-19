extends Node

var cell_fn
var viewport_size
var rng
var node_2d
var mesh_instance_scale

func _init(_viewport_size, _rng, _node_2d, _mesh_instance_scale):
	viewport_size = _viewport_size
	rng = _rng
	node_2d = _node_2d
	mesh_instance_scale = _mesh_instance_scale
	
	cell_fn = load("res://cell_fn.gd").new()

func init_cell():
	return {
		"cell_fn": cell_fn.FN_CONWAYS_LIFE,
		"alive": false if cell_fn.GLIDER else rng.randf_range(-1.0, 1.0) > 0.0,
		"neighbours_count": 0,
	}

func draw_cell(cell, x, y):
	var size_this = 0.75 if cell.state.alive else 0
	var cell_size_x = mesh_instance_scale.x/cell_fn.X_SIZE
	var cell_size_y = mesh_instance_scale.y/cell_fn.Y_SIZE
	if cell.geometry == null:
		var cell_mesh_instance = MeshInstance.new()
		var cell_mesh = CubeMesh.new()
		
		#set size
		cell_mesh.set_size(Vector3(cell_size_x * size_this, cell_size_x * size_this, cell_size_y * size_this))
		cell_mesh_instance.set_mesh(cell_mesh)
		
		#replace
		print(mesh_instance_scale.x/cell_fn.X_SIZE)
		var x_position = mesh_instance_scale.x/cell_fn.X_SIZE * x + cell_size_x/2 - mesh_instance_scale.x/2
		var y_position = mesh_instance_scale.y/cell_fn.Y_SIZE * y + cell_size_y/2 - mesh_instance_scale.y/2
		cell_mesh_instance.set_translation(Vector3(x_position, 0, y_position))
		
		node_2d.add_child(cell_mesh_instance)
		return cell_mesh_instance
	else:
		cell.geometry.get_mesh().set_size(Vector3(cell_size_x * size_this, cell_size_x * size_this, cell_size_y * size_this))
		return cell.geometry

func update_cell(current_cell, neighbours):
	var live_neighbours = []
	for neighbour in neighbours:
		if neighbour.alive:
			live_neighbours.append(neighbour)
	
	var neighbours_count = len(live_neighbours)
	
	var new_state = false
	
	if not current_cell.alive and neighbours_count == 3 :
		new_state = true
	
	if current_cell.alive and (neighbours_count == 2 or neighbours_count == 3):
		new_state = true
	
	return {
		"cell_fn": cell_fn.FN_CONWAYS_LIFE,
		"alive": new_state,
		"neighbours_count": neighbours_count
	}
	
