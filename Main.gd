extends Spatial

var node_2d
var cells_state = []
var rng

const X_SIZE = 20
const Y_SIZE = 20

var viewport_size = Vector2(0, 0)

func draw_cell(cell, x, y):
	if cell.geometry == null:
		var label = Label.new()
		label.text = "#" if cell.alive else ""
		label.rect_position = Vector2(
			viewport_size.x * float(x + 0.5)/X_SIZE,
			viewport_size.y * float(y + 0.5)/Y_SIZE
		)
		node_2d.add_child(label)
		
		return label
	else:
		cell.geometry.text = "#" if cell.alive else ""
		return cell.geometry

func get_neighbours(state, x, y):
	# get moore neighbourhood
	return [
		state[x + 1 if x + 1 < X_SIZE else 0][y],
		state[x - 1 if x > 0 else X_SIZE - 1][y],
		
		state[x][y + 1 if y + 1 < Y_SIZE else 0],
		state[x][y - 1 if y > 0 else Y_SIZE - 1],
		
		state[x + 1 if x + 1 < X_SIZE else 0][y + 1 if y + 1 < Y_SIZE else 0],
		state[x + 1 if x + 1 < X_SIZE else 0][y - 1 if y > 0 else Y_SIZE - 1],
		
		state[x - 1 if x > 0 else X_SIZE - 1][y + 1 if y + 1 < Y_SIZE else 0],
		state[x - 1 if x > 0 else X_SIZE - 1][y - 1 if y > 0 else Y_SIZE - 1]
	]

enum {FN_CONWAYS_LIFE}

func conways_life(current_cell, neighbours):
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
		"cell_fn": FN_CONWAYS_LIFE,
		"alive": new_state,
		"geometry": current_cell.geometry,
		"neighbours_count": neighbours_count
	}

func init_cell():
	return {
		"cell_fn": FN_CONWAYS_LIFE,
		"alive": rng.randf_range(-1.0, 1.0) > 0.0,
		"neighbours_count": 0,
		"geometry": null
	}
	
# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_size = get_node("Viewport").size
	
	node_2d = get_node("Viewport/Node2D")
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for x in range(X_SIZE):
		var col = []
		for y in range(Y_SIZE):
			# init cells state
			var cell = init_cell()
			
			cell.geometry = draw_cell(cell, x, y)
			
			col.append(cell)
		
		cells_state.append(col)
	
	# draw grid
	for x in range(X_SIZE):
		var new_line = Line2D.new()
		new_line.add_point(Vector2(viewport_size.x * float(x)/X_SIZE, viewport_size.y * 0.0))
		new_line.add_point(Vector2(viewport_size.x * float(x)/X_SIZE, viewport_size.y * 1.0))
		new_line.width = 2
		node_2d.add_child(new_line)
	
	for y in range(Y_SIZE):
		var new_line = Line2D.new()
		new_line.add_point(Vector2(viewport_size.x * 0.0, viewport_size.y * float(y)/Y_SIZE))
		new_line.add_point(Vector2(viewport_size.x * 1.0, viewport_size.y * float(y)/Y_SIZE))
		new_line.width = 2
		node_2d.add_child(new_line)

var frame_count = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	frame_count += 1
	if frame_count % 10 != 0:
		return
	
	var new_cells_state = []

	for x in range(X_SIZE):
		var col = []
		for y in range(Y_SIZE):
			# init cells state
			var current_cell = cells_state[x][y]

			var new_cell = null

			match current_cell.cell_fn:
				FN_CONWAYS_LIFE:
					new_cell = conways_life(
						current_cell,
						get_neighbours(cells_state, x, y)
					)
					# print(x, y, "new cell", new_cell)
				_:
					new_cell = null
			
			if not new_cell == current_cell:
				new_cell.geometry = draw_cell(new_cell, x, y)
			
			# new_cell.geometry = null
				
			col.append(new_cell)

		new_cells_state.append(col)
		
	cells_state = new_cells_state
