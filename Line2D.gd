extends Line2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var position = get_point_position(0)
	position.x += 10 * delta
	position.y += 10 * delta
	set_point_position(0, position)
#	pass
