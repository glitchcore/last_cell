extends Spatial

var cells_state = []

var cell_fn
var conway
var sphere_playground
var player_node
var plane_size
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	cell_fn = load("res://cell_fn.gd").new()
	
	var viewport_size = get_node("Viewport").size
	plane_size = get_node("MeshInstance").scale
	# plane_size = {"x": plane_size.x, "y": plane_size.z}
	
	var node_2d = get_node("Viewport/Node2D")
	
	player_node = get_node("PlayerCenter")
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	conway = load("res://conway.gd").new(viewport_size, rng, node_2d, get_node("MeshInstance").scale)
	sphere_playground = load("res://sphere_playground.gd").new(viewport_size, rng, node_2d, get_node("MeshInstance"))
	
	for _x in range(cell_fn.X_SIZE):
		var col = []
		for _y in range(cell_fn.Y_SIZE):
			# init cells state
			var cell = {
				"geometry": null,
				"calc_count": 0,
				"dirty": true,
				"state": sphere_playground.init_cell()
				# "state": conway.init_cell()
			}
			
			col.append(cell)
		
		cells_state.append(col)
	
	cells_state = sphere_playground.init_state(cells_state)
	# cells_state = conway.init_state(cells_state)
	
	for x in range(cell_fn.X_SIZE):
		for y in range(cell_fn.Y_SIZE):
			cells_state[x][y].geometry = sphere_playground.draw_cell(
				cells_state[x][y], x, y
			)
			# cells_state[x][y].geometry = conway.draw_cell(
			# 	cell[x][y], x, y
			# )
			
			# update player
			var _player = sphere_playground.get_player(cells_state[x][y], x, y)
			if _player != null:
				player = _player
	
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
			
			var is_player = (player != null and player.x == x and player.y == y)
			
			var neighbours_ids = null
			
			if current_cell.dirty or is_player:
				# make a calculations
				
				neighbours_ids = cell_fn.get_neighbours_id(x, y)
				
				match current_cell.state.cell_fn:
					cell_fn.FN_CONWAYS_LIFE:
						new_cell_state = conway.update_cell(
							current_cell.state.duplicate(),
							cell_fn.get_neighbours(cells_state, neighbours_ids)
						)
					
					cell_fn.FN_SPHERE_PLAYGROUND:
						new_cell_state = sphere_playground.update_cell(
							current_cell.state.duplicate(),
							cell_fn.get_neighbours(cells_state, neighbours_ids)
						)
					_:
						pass
			
			var new_cell = {}
			
			var need_update = new_cell_state != null and \
				sort(new_cell_state).hash() != sort(current_cell.state).hash()
			
			if need_update or is_player:
				new_cell = {
					"state": new_cell_state,
					"geometry": current_cell.geometry,
					"calc_count": current_cell.calc_count + 1,
					"dirty": true
				}
				
				new_cell.geometry = sphere_playground.draw_cell(new_cell, x, y)
				
				# update player
				var _player = sphere_playground.get_player(new_cell, x, y)
				if _player != null:
					player = _player
					# set player position
					player_node.translation = Vector3(
						plane_size.x * (player.x + 0.5) / cell_fn.X_SIZE - plane_size.x/2,
						0,
						plane_size.y * (player.y + 0.5) / cell_fn.Y_SIZE - plane_size.y/2
					)
					player_node.rotation_degrees.y = player.rotation
				
				if need_update:
					assert(neighbours_ids != null)
					for id in neighbours_ids:
						dirty_neighbours.append(id)
				
			else:
				new_cell = current_cell
				new_cell.dirty = false
			
			col.append(new_cell)

		new_cells_state.append(col)
		
	cells_state = new_cells_state
	
	for id in dirty_neighbours:
		cells_state[id[0]][id[1]].dirty = true
