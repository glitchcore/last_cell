extends Node

var cell_fn
var viewport_size
var rng
var node_2d

func _init(_viewport_size, _rng, _node_2d):
	viewport_size = _viewport_size
	rng = _rng
	node_2d = _node_2d
	
	cell_fn = load("res://cell_fn.gd").new()

func init_cell():
	return {
		"cell_fn": cell_fn.FN_CONWAYS_LIFE,
		"alive": false if cell_fn.GLIDER else rng.randf_range(-1.0, 1.0) > 0.0,
		"neighbours_count": 0,
	}

func draw_cell(cell, x, y):
	var label_text = "#" + str(cell.calc_count) + "#" if cell.state.alive else " " + str(cell.calc_count) + " "
	if cell.geometry == null:
		var label = Label.new()
		label.text = label_text
		label.rect_position = Vector2(
			viewport_size.x * float(x + 0.5)/cell_fn.X_SIZE,
			viewport_size.y * float(y + 0.5)/cell_fn.Y_SIZE
		)
		node_2d.add_child(label)
		
		return label
	else:
		cell.geometry.text = label_text
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
	
