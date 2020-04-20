extends Node

var cell_fn
var viewport_size = Vector2(0, 0)
var rng
var node_2d
var mesh_instance_scale
var mesh_instance

func _init(_viewport_size, _rng, _node_2d, _mesh_instance):
	cell_fn = load("res://cell_fn.gd").new()
	viewport_size = _viewport_size
	rng = _rng
	node_2d = _node_2d
	mesh_instance_scale = _mesh_instance.scale
	mesh_instance = _mesh_instance

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
	
const DRAW_LABELS = true

func draw_cell(cell, x, y):
	var label_text = \
		"m:" + str(cell.state.sphere_mass) + "\n" + \
		"r:" + str(cell.state.rotate) + "\n" + \
		"f:" + str(cell.state.force_value) + " " + \
		str(cell.calc_count)
		# ("p" if cell.state.is_player else "") + \
		
	var size_this = float(cell.state.sphere_mass/100.0)
	var cell_size_x = mesh_instance_scale.x/cell_fn.X_SIZE
	var cell_size_y = mesh_instance_scale.y/cell_fn.Y_SIZE
	
	if cell.geometry == null:
		var cell_mesh_instance = MeshInstance.new()
		#var cell_mesh = CubeMesh.new()
		var cell_mesh = SphereMesh.new()
		
		#set size
		cell_mesh.set_radius(cell_size_x * size_this / 2)
		cell_mesh.set_height(cell_size_x * size_this)
		#cell_mesh.set_size(Vector3(cell_size_x * size_this, cell_size_x * size_this, cell_size_y * size_this))
		cell_mesh_instance.set_mesh(cell_mesh)
		
		#replace
		var x_position = mesh_instance_scale.x/cell_fn.X_SIZE * x + cell_size_x/2 - mesh_instance_scale.x/2
		var y_position = mesh_instance_scale.y/cell_fn.Y_SIZE * y + cell_size_y/2 - mesh_instance_scale.y/2
		cell_mesh_instance.set_translation(Vector3(x_position, cell_size_y/2, y_position))
		
		node_2d.add_child(cell_mesh_instance)
		
		var label
		
		if DRAW_LABELS:
			label = Label.new()
			label.text = label_text
			label.rect_position = Vector2(
				viewport_size.x * float(x + 0.0)/cell_fn.X_SIZE,
				viewport_size.y * float(y + 0.0)/cell_fn.Y_SIZE
			)
			node_2d.add_child(label)
		else:
			label = null
		
		return [cell_mesh_instance, label]
	else:
		cell.geometry[0].get_mesh().set_radius(cell_size_x * size_this / 2)
		cell.geometry[0].get_mesh().set_height(cell_size_x * size_this)
		#cell.geometry.get_mesh().set_size(Vector3(cell_size_x * size_this, cell_size_x * size_this, cell_size_y * size_this))
		
		if DRAW_LABELS:
			cell.geometry[1].text = label_text
		
		return cell.geometry


func update_cell(state, neighbours, input):
	var new_state = state
	
	# fet Von-neumann 1 rank
	var vonneuman_neighbours = [
		neighbours[3],
		neighbours[5],
		neighbours[7],
		neighbours[1]
	]
	
	var input_force_direction = 0
	var force_value = 0
	
	if input.up:
		input_force_direction = 1
		force_value = 5
	if input.down:
		input_force_direction = 3
		force_value = 5
	if input.left:
		input_force_direction = 2
		force_value = 5
	if input.right:
		input_force_direction = 0
		force_value = 5
	
	var force_mat = [2, 3, 0, 1]
	
	# calc is_player and sphere_mass
	if state.is_player:
		if force_value > 0 and state.sphere_mass == force_value:
			new_state.is_player = false
		else:
			new_state.is_player = true
			
		if force_value > 0 and state.sphere_mass > 0:
			new_state.sphere_mass = state.sphere_mass - force_value
		else:
			new_state.sphere_mass = state.sphere_mass
		
	else:
		new_state.is_player = false
		new_state.sphere_mass = state.sphere_mass
		
		for n in range(len(vonneuman_neighbours)):
			var neighbour = vonneuman_neighbours[n]
			
			var force_direction = (int((neighbour.rotate - 45)/90) + input_force_direction) % 4
			
			var neighbour_force_value = 0
			if force_mat[n] == force_direction:
				neighbour_force_value = force_value
			else:
				neighbour_force_value = 0
			
			if neighbour_force_value > 0 and neighbour.is_player and neighbour.sphere_mass == neighbour_force_value:
				new_state.is_player = true
			
			if neighbour_force_value > 0 and neighbour.is_player and neighbour.sphere_mass > 0:
				new_state.sphere_mass = state.sphere_mass + force_value
	
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
