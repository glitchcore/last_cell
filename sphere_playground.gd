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
	cells_state[cell_fn.X_SIZE/2][cell_fn.Y_SIZE/2].state.sphere_mass = 10
	
	return cells_state
	
const DRAW_LABELS = true

func draw_cell(cell, x, y):
	var label_text = \
		"m:" + str(cell.state.sphere_mass) + "\n" + \
		"r:" + str(cell.state.rotate) + "\n" + \
		"f:" + str(cell.state.force_value) + " " + \
		("p" if cell.state.is_player else "") + \
		str(cell.calc_count)
		
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
		cell.geometry[0].get_mesh().set_size(Vector3(cell_size_x * size_this, cell_size_x * size_this, cell_size_y * size_this))
		if DRAW_LABELS:
			cell.geometry[1].text = label_text
		
		return cell.geometry
		

func handle_sphere(state, new_state, neighbours):
	var force_direction = 0
	var force_value = 0
	
	if state.is_player:
		if Input.is_action_pressed("ui_up"):
			force_direction = (int((state.rotate - 45)/90) + 1) % 4
			force_value = 1
		if Input.is_action_pressed("ui_down"):
			force_direction = (int((state.rotate - 45)/90) + 3) % 4
			force_value = 1
		if Input.is_action_pressed("ui_left"):
			force_direction = (int((state.rotate - 45)/90) + 2) % 4
			force_value = 1
		if Input.is_action_pressed("ui_right"):
			force_direction = (int((state.rotate - 45)/90) + 0) % 4
			force_value = 1
		
	new_state.force_value = force_value
	
	var next_cell = neighbours[force_direction]
	
	new_state.force = [0, 0, 0, 0]
	new_state.force[force_direction] = state.force_value
	
	if state.force_value > 0:
		# if next_cell is empty or true type
		if next_cell.sphere_mass < 0 or true:
			new_state.sphere_mass = state.sphere_mass - state.force_value
			
	if state.sphere_mass == 1 and state.force_value > 0:
		new_state.is_player = false
		new_state.force = [0, 0, 0, 0]
	
	# handle external sphere
	new_state.sphere_mass += neighbours[0].force[2]
	new_state.sphere_mass += neighbours[1].force[3]
	new_state.sphere_mass += neighbours[2].force[0]
	new_state.sphere_mass += neighbours[3].force[1]
	
	for neighbour in neighbours:
		if neighbour.sphere_mass == 1:
			print("king is dead I'm new king!")
			new_state.is_player = true
	
	return new_state

func handle_void(state, new_state, neighbours):
	# handle external sphere
	new_state.sphere_mass += neighbours[0].force[2]
	new_state.sphere_mass += neighbours[1].force[3]
	new_state.sphere_mass += neighbours[2].force[0]
	new_state.sphere_mass += neighbours[3].force[1]
	
	return new_state

func update_cell(state, neighbours):
	var new_state = state
	
	# fet Von-neumann 1 rank
	var vonneuman_neighbours = [
		neighbours[3],
		neighbours[5],
		neighbours[7],
		neighbours[1]
	]
	
	if state.sphere_mass > 0:
		new_state = handle_sphere(state, new_state, vonneuman_neighbours)
	
	if state.sphere_mass == 0:
		new_state = handle_void(state, new_state, vonneuman_neighbours)
	
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
