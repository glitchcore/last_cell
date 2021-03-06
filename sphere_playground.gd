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
		"is_player": false,
		"force_direction": -1
	}

func init_state(cells_state):
	cells_state[cell_fn.X_SIZE/2][cell_fn.Y_SIZE/2].state.is_player = true
	cells_state[cell_fn.X_SIZE/2][cell_fn.Y_SIZE/2].state.sphere_mass = 100
	
	return cells_state
	
const DRAW_LABELS = true

func draw_cell(cell, x, y):
	var label_text = ""
		# "m:" + str(cell.state.sphere_mass) + "\n" + \
		# "d:" + str(cell.state.force_direction) + "\n" + \
		# str(cell.calc_count) + " " + \
		# ("p" if cell.state.is_player else "")
		# "r:" + str(cell.state.rotate) + "\n" + \
		
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
		
		var material = SpatialMaterial.new()
		material.flags_transparent = true
		material.albedo_color = Color(1, 0, 1, 0.8)
		cell_mesh_instance.set_surface_material(0, material)
		
		
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

func mod(x, y):
	if x > 0:
		return x % y
	else:
		return (y - abs(x) % y) % y
	
func update_cell(state, neighbours, input):
	var new_state = state
	
	var input_force_direction = 0
	var force_value = 0
	
	if input.up:
		input_force_direction = 0
		force_value = 10
	if input.down:
		input_force_direction = 4
		force_value = 10
	
	var force_mat = [4, 5 , 6 , 7, 0, 1, 2, 3]
	
	# calc is_player and sphere_mass
	if state.is_player:
		var neighboor_sphere_count = -1
		
		var force_direction = mod(int(round(
			8.0 + (-state.rotate)/45.0 + 1.0 + float(input_force_direction)
		)), 8)
		
		for n in range(len(neighbours)):
			var neighbour = neighbours[n]
			
			if n != force_direction and neighbour.sphere_mass > 0:
				neighboor_sphere_count += 1
		
		new_state.force_direction = force_direction
		
			
		if force_value > 0 and state.sphere_mass == force_value:
			new_state.is_player = false
		else:
			new_state.is_player = true
			
		if force_value > 0 and state.sphere_mass > 0:
			new_state.sphere_mass = state.sphere_mass + force_value * neighboor_sphere_count
		else:
			new_state.sphere_mass = state.sphere_mass
			
		if input.left:
			new_state.rotate = state.rotate + 5
		if input.right:
			new_state.rotate = state.rotate - 5
		
	else:
		new_state.is_player = false
		new_state.sphere_mass = state.sphere_mass
		
		new_state.force_direction = -1
		
		for n in range(len(neighbours)):
			var neighbour = neighbours[n]
			
			var force_direction = mod(int(round(
				(-neighbour.rotate)/45.0 + 1.0 + float(input_force_direction)
			)), 8)
			
			force_direction = force_direction if force_direction > 0 else (force_direction + 8) % 8
			
			# only for debugging
			# if neighbour.is_player:
			#	new_state.force_direction = force_direction
			
			var neighbour_force_value = 0
			if force_mat[n] == force_direction:
				neighbour_force_value = 1
			else:
				if state.sphere_mass > 0:
					neighbour_force_value = -1
				else:
					neighbour_force_value = 0
			
			if neighbour_force_value > 0 and neighbour.is_player and neighbour.sphere_mass == force_value:
				new_state.is_player = true
				new_state.rotate = neighbour.rotate
			
			if neighbour.is_player and neighbour.sphere_mass > 0:
				new_state.sphere_mass = state.sphere_mass + force_value * neighbour_force_value
	
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
