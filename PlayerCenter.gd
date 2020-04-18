extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const MOUSE_SPEED = 0.01
var camera

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("Camera")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_left"):
		translate_object_local(Vector3(-50 * delta, 0, 0))
	if Input.is_action_pressed("ui_right"):
		translate_object_local(Vector3(50 * delta, 0, 0))
	if Input.is_action_pressed("ui_up"):
		translate_object_local(Vector3(0, 0, -50 * delta))
	if Input.is_action_pressed("ui_down"):
		translate_object_local(Vector3(0, 0, 50 * delta))
	
func _input(event):
	if event is InputEventMouseMotion:
		camera.rotation.x = clamp(
			camera.rotation.x - event.relative.y * MOUSE_SPEED,
			deg2rad(-30), deg2rad(30)
		)
		
		rotation.y -= event.relative.x * MOUSE_SPEED
	
#
#	if Input.is_action_pressed("ui_right"):
#		direction.x += 1
#	if Input.is_action_pressed("ui_up"):
#		direction.z -= 1
#	if Input.is_action_pressed("ui_down"):
#		direction.z += 1
