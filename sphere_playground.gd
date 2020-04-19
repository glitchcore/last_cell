extends Node

var cell_fn
var viewport_size = Vector2(0, 0)
var rng
var node_2d

func _init(_viewport_size, _rng, _node_2d):
	cell_fn = load("res://cell_fn.gd").new()
	viewport_size = _viewport_size
	rng = _rng
	node_2d = _node_2d

func init_cell():
	return {
		"cell_fn": cell_fn.FN_SPHERE_PLAYGROUND,
		"sphere_mass": 0,
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
	var label_text = \
		"m:" + str(cell.state.sphere_mass) + "\n" + \
		"r:" + str(cell.state.rotate) + "\n" + \
		"f:" + str(cell.state.force_value) + " " + \
		("p" if cell.state.is_player else "") + \
		str(cell.calc_count)
	
	if cell.geometry == null:
		var label = Label.new()
		label.text = label_text
		label.rect_position = Vector2(
			viewport_size.x * float(x + 0.0)/cell_fn.X_SIZE,
			viewport_size.y * float(y + 0.0)/cell_fn.Y_SIZE
		)
		node_2d.add_child(label)
		
		return label
	else:
		cell.geometry.text = label_text
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


func update_cell(old_state, neighbours):
	var state = old_state
	
	if state.is_player:
		state = handle_ui(state)
	else:
		state = state
	
	# fet Von-neumann 1 rank
	var vonneuman_neighbours = [
		neighbours[1],
		neighbours[3],
		neighbours[5],
		neighbours[7]
	]
	
	if state.sphere_mass > 0:
		state = handle_sphere(state, vonneuman_neighbours)
	
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
