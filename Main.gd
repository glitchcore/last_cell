extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var line
var node_2d

const X_SIZE = 20
const Y_SIZE = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	var viewport_size = get_node("Viewport").size
	
	line = get_node("Viewport/Node2D/Line2D")
	node_2d = get_node("Viewport/Node2D")
	
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
	var position = line.get_point_position(0)
	position.x += 10 * delta
	position.y += 10 * delta
	line.set_point_position(0, position)
