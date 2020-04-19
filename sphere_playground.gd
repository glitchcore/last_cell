extends Node

var cell_fn
var viewport_size = Vector2(0, 0)
var rng
var node_2d
var mesh_instance_scale

func _init(_viewport_size, _rng, _node_2d, _mesh_instance_scale):
	cell_fn = load("res://cell_fn.gd").new()
	viewport_size = _viewport_size
	rng = _rng
	node_2d = _node_2d
	mesh_instance_scale = _mesh_instance_scale

func init_cell():
	return {
		"cell_fn": cell_fn.FN_SPHERE_PLAYGROUND,
		"sphere_mass": 0, # 0..100
		"rotate": 0,
		"force_value": 0,
		"force": [0, 0, 0, 0], # top right down left
		"is_player": false
	}

func init_state(cells_state):
	cells_state[cell_fn.X_SIZE/2][cell_fn.Y_SIZE/2].state.is_player = true
	cells_state[cell_fn.X_SIZE/2][cell_fn.Y_SIZE/2].state.sphere_mass = 100
	
	return cells_state
	
func draw_cell(cell, x, y):
#	var label_text = \
#		"m:" + str(cell.state.sphere_mass) + "\n" + \
#		"r:" + str(cell.state.rotate) + "\n" + \
#		"f:" + str(cell.state.force_value) + " " + \
#		("p" if cell.state.is_player else "") + \
#		str(cell.calc_count)
		
	var size_this = float(cell.state.sphere_mass/100.0)
	var cell_size_x = mesh_instance_scale.x/cell_fn.X_SIZE
	var cell_size_y = mesh_instance_scale.y/cell_fn.Y_SIZE
	if cell.geometry == null:
		var cell_mesh_instance = MeshInstance.new()
		var cell_mesh = CubeMesh.new()
		
		#set size
		cell_mesh.set_size(Vector3(cell_size_x * size_this, cell_size_x * size_this, cell_size_y * size_this))
		cell_mesh_instance.set_mesh(cell_mesh)
		
		#replace
		var x_position = mesh_instance_scale.x/cell_fn.X_SIZE * x + cell_size_x/2 - mesh_instance_scale.x/2
		var y_position = mesh_instance_scale.y/cell_fn.Y_SIZE * y + cell_size_y/2 - mesh_instance_scale.y/2
		cell_mesh_instance.set_translation(Vector3(x_position, 0, y_position))
		
		node_2d.add_child(cell_mesh_instance)
		return cell_mesh_instance
	else:
		cell.geometry.get_mesh().set_size(Vector3(cell_size_x * size_this, cell_size_x * size_this, cell_size_y * size_this))
		return cell.geometry
		
		
func handle_ui(state):
	var new_state = state
	
	if Input.is_action_pressed("ui_up"):
		# print("up")
		new_state.force_value = 1
	else:
		new_state.force_value = 0
		
	return new_state

func handle_sphere(state, neighbours):
	var new_state = state
	
	var force_direction = (int((state.rotate - 45)/90) + 1) % 4
	var next_cell = neighbours[force_direction]
	
	new_state.force = [0, 0, 0, 0]
	new_state.force[force_direction] = state.force_value
	
	if state.force_value > 0:
		# if next_cell is empty or true type
		if next_cell.sphere_mass < 0 or true:
			new_state.sphere_mass = state.sphere_mass - state.force_value
		
	# handle external sphere
	new_state.sphere_mass += neighbours[0].force[2]
	new_state.sphere_mass += neighbours[1].force[3]
	new_state.sphere_mass += neighbours[2].force[0]
	new_state.sphere_mass += neighbours[3].force[1]
	
	return new_state

func handle_free(state, neighbours):
	var new_state = state
	
	# handle external sphere
	new_state.sphere_mass += neighbours[0].force[2]
	new_state.sphere_mass += neighbours[1].force[3]
	new_state.sphere_mass += neighbours[2].force[0]
	new_state.sphere_mass += neighbours[3].force[1]
	
	return new_state

func update_cell(old_state, neighbours):
	var state = old_state
	
	if state.is_player:
		state = handle_ui(state)
	else:
		state = state
	
	# fet Von-neumann 1 rank
	var vonneuman_neighbours = [
		neighbours[3],
		neighbours[5],
		neighbours[7],
		neighbours[1]
	]
	
	if state.sphere_mass > 0:
		state = handle_sphere(state, vonneuman_neighbours)
	
	if state.sphere_mass == 0:
		state = handle_free(state, vonneuman_neighbours)
	
	return state

func get_player(current_cell, x, y):
	if current_cell.state.is_player:
		return {
			"rotation": current_cell.state.rotate,
			"x": x,
			"y": y
		}
	else:
		return null
