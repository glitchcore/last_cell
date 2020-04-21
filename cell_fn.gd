extends Node

enum {FN_CONWAYS_LIFE, FN_SPHERE_PLAYGROUND}

const X_SIZE = 20
const Y_SIZE = 20

const GLIDER = true

func get_neighbours_id(x, y):
	return [
		[x - 1 if x > 0 else X_SIZE - 1, y - 1 if y > 0 else Y_SIZE - 1],
		[x, y - 1 if y > 0 else Y_SIZE - 1],
		[x + 1 if x + 1 < X_SIZE else 0, y - 1 if y > 0 else Y_SIZE - 1],
		
		[x + 1 if x + 1 < X_SIZE else 0, y],
		
		[x + 1 if x + 1 < X_SIZE else 0, y + 1 if y + 1 < Y_SIZE else 0],
		[x, y + 1 if y + 1 < Y_SIZE else 0],
		[x - 1 if x > 0 else X_SIZE - 1, y + 1 if y + 1 < Y_SIZE else 0],
		
		[x - 1 if x > 0 else X_SIZE - 1, y]
	]

func get_neighbours(state, ids):
	var neighbours = []
	
	# get moore neighbourhood
	for id in ids:
		neighbours.append(state[id[0]][id[1]].state)
	
	return neighbours
