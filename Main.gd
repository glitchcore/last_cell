extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var line
var node_2d
var cells_state = []

const X_SIZE = 20
const Y_SIZE = 20

var viewport_size = Vector2(0, 0)

func draw_cell(cell, x, y):
	var points = PoolVector2Array()
	
	points.push_back(Vector2(
		viewport_size.x * float(x)/X_SIZE,
		viewport_size.y * float(y)/Y_SIZE
	))
	points.push_back(Vector2(
		viewport_size.x * float(x + 1)/X_SIZE,
		viewport_size.y * float(y)/Y_SIZE
	))
	points.push_back(Vector2(
		viewport_size.x * float(x + 1)/X_SIZE,
		viewport_size.y * float(y + 1)/Y_SIZE
	))
	points.push_back(Vector2(
		viewport_size.x * float(x)/X_SIZE,
		viewport_size.y * float(y + 1)/Y_SIZE
	))
	
	var color = PoolColorArray([Color("FFFFFF")])
	
	node_2d.draw_polygon(points, color)

func get_neighbours(state, x, y):
	# get Fon-neumann 1 rank w circular
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
		if neighbour.state:
			live_neighbours.append(neighbour)
	
	var neighbours_count = len(live_neighbours)
	
	var new_state = false
	
	if not current_cell.state and neighbours_count == 3 :
		new_state = true
	
	if current_cell.state and (neighbours_count == 2 or neighbours_count == 3):
		new_state = true
	
	return {
		"cell_fn": FN_CONWAYS_LIFE,
		"state": new_state
	}
	
# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_size = get_node("Viewport").size
	
	line = get_node("Viewport/Node2D/Line2D")
	node_2d = get_node("Viewport/Node2D")
	
	for x in range(X_SIZE):
		var col = []
		for y in range(Y_SIZE):
			# init cells state
			var cell = {
				"cell_fn": FN_CONWAYS_LIFE,
				"state": false
			}
			
			col.append(cell)
			
			draw_cell(cell, x, y)
		
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
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
				_:
					new_cell = null
			
			col.append(new_cell)
			
			if not new_cell == current_cell:
				draw_cell(new_cell, x, y)
		
		new_cells_state.append(col)
