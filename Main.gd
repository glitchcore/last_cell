extends Spatial

var cells_state = []

var cell_fn
var conway
var sphere_playground

# Called when the node enters the scene tree for the first time.
func _ready():
	cell_fn = load("res://cell_fn.gd").new()
	
	var viewport_size = get_node("Viewport").size
	
	var node_2d = get_node("Viewport/Node2D")
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	conway = load("res://conway.gd").new(viewport_size, rng, node_2d)
	sphere_playground = load("res://sphere_playground.gd").new(viewport_size, rng, node_2d)
	
	for x in range(cell_fn.X_SIZE):
		var col = []
		for y in range(cell_fn.Y_SIZE):
			# init cells state
			
			# cell.geometry = conway.draw_cell(cell, x, y)
			var cell = {
				"geometry": null,
				"calc_count": 0,
				"dirty": true,
				"state": sphere_playground.init_cell()
				# "state": conway.init_cell()
			}
			cell.geometry = sphere_playground.draw_cell(cell, x, y)
			
			col.append(cell)
		
		cells_state.append(col)
		
	if cell_fn.GLIDER:
		cells_state[0][0].state.alive = false
		cells_state[1][0].state.alive = true
		cells_state[2][0].state.alive = false
		
		cells_state[0][1].state.alive = false
		cells_state[1][1].state.alive = false
		cells_state[2][1].state.alive = true
		
		cells_state[0][2].state.alive = true
		cells_state[1][2].state.alive = true
		cells_state[2][2].state.alive = true
	
	# draw grid
	for x in range(cell_fn.X_SIZE):
		var new_line = Line2D.new()
		new_line.add_point(Vector2(viewport_size.x * float(x)/cell_fn.X_SIZE, viewport_size.y * 0.0))
		new_line.add_point(Vector2(viewport_size.x * float(x)/cell_fn.X_SIZE, viewport_size.y * 1.0))
		new_line.width = 2
		node_2d.add_child(new_line)
	
	for y in range(cell_fn.Y_SIZE):
		var new_line = Line2D.new()
		new_line.add_point(Vector2(viewport_size.x * 0.0, viewport_size.y * float(y)/cell_fn.Y_SIZE))
		new_line.add_point(Vector2(viewport_size.x * 1.0, viewport_size.y * float(y)/cell_fn.Y_SIZE))
		new_line.width = 2
		node_2d.add_child(new_line)

var frame_count = 0

func sort(dict):
	var sorted_dict = {}
	var keys = dict.keys()
	keys.sort()
	
	for key in keys:
		sorted_dict[key] = dict[key]
	
	return sorted_dict

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# optional skip frames
	frame_count += 1
	if frame_count % 1 != 0:
		return
	
	var new_cells_state = []
	var dirty_neighbours = []

	for x in range(cell_fn.X_SIZE):
		var col = []
		for y in range(cell_fn.Y_SIZE):
			# init cells state
			var current_cell = cells_state[x][y]
			
			var new_cell_state = null
			
			if current_cell.dirty:
				# make a calculations
				
				var neighbours_ids = cell_fn.get_neighbours_id(x, y)
				
				match current_cell.state.cell_fn:
					cell_fn.FN_CONWAYS_LIFE:
						new_cell_state = conway.update_cell(
							current_cell.state,
							cell_fn.get_neighbours(cells_state, neighbours_ids)
						)
					
					cell_fn.FN_SPHERE_PLAYGROUND:
						new_cell_state = sphere_playground.update_cell(
							current_cell.state,
							cell_fn.get_neighbours(cells_state, neighbours_ids)
						)
					_:
						pass
				
				if new_cell_state != current_cell.state:
					for id in neighbours_ids:
						dirty_neighbours.append(id)
			
			var new_cell = {}
			
			if new_cell_state != null and sort(new_cell_state).hash() != sort(current_cell.state).hash():
				new_cell = {
					"state": new_cell_state,
					"geometry": current_cell.geometry,
					"calc_count": current_cell.calc_count + 1,
					"dirty": true
				}
				
				new_cell.geometry = conway.draw_cell(new_cell, x, y)
				
			else:
				new_cell = current_cell
				new_cell.dirty = false
			
			col.append(new_cell)

		new_cells_state.append(col)
		
	cells_state = new_cells_state
	
	for id in dirty_neighbours:
		cells_state[id[0]][id[1]].dirty = true
