extends Spatial

onready var yaw:Spatial = $Yaw;
onready var pitch:Spatial = $Yaw/Pitch;
onready var cam:Camera = $Yaw/Pitch/Camera;

var rotating_from_mouse:bool setget set_rot_from_mouse,get_rot_from_mouse;
var cam_distance:float setget set_cam_dist,get_cam_dist;
var rotate_speed:float setget set_rot_speed,get_rot_speed;
var move_speed:float setget set_move_speed,get_move_speed;
var zoom_speed:float setget set_zoom_speed,get_zoom_speed;
var mouse_sensitivity:float setget set_mouse_sens,get_mouse_sens;

const MIN_CAM_DIST:float = 5.0;
const MAX_CAM_DIST:float = 50.0;
const MIN_CAM_PITCH:float = -75.0;
const MAX_CAM_PITCH:float = -20.0;
const MIN_MOUSE_SENS:float = 0.001;
const MAX_MOUSE_SENS:float = 0.01;


func set_rot_from_mouse(enable:bool):
	rotating_from_mouse = enable;
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if rotating_from_mouse else Input.MOUSE_MODE_VISIBLE);

func get_rot_from_mouse():
	return rotating_from_mouse;

func set_cam_dist(dist:float):
	cam_distance = clamp(dist,MIN_CAM_DIST,MAX_CAM_DIST);
	cam.transform.origin.z = cam_distance;
func get_cam_dist():
	return cam_distance;

func set_rot_speed(speed:float):
	rotate_speed = speed;
func get_rot_speed():
	return rotate_speed;

func set_move_speed(speed:float):
	move_speed = speed;
func get_move_speed():
	return move_speed;

func set_zoom_speed(speed:float):
	zoom_speed = speed;
func get_zoom_speed():
	return zoom_speed;

func rotate_yaw(angle:float):
	yaw.transform = yaw.transform.rotated(Vector3.UP,angle);
func rotate_pitch(angle:float):
	pitch.transform = pitch.transform.rotated(Vector3.RIGHT,angle);
	pitch.rotation.x = clamp(pitch.rotation.x,deg2rad(-75),deg2rad(-10))
	

func move_right(dist:float):
	transform = transform.translated(yaw.transform.basis.x * dist);
func move_forward(dist:float):
	transform = transform.translated(yaw.transform.basis.z * dist);

func set_mouse_sens(sens:float):
	mouse_sensitivity = clamp(sens*MAX_MOUSE_SENS,MIN_MOUSE_SENS,MAX_MOUSE_SENS);
func get_mouse_sens():
	return mouse_sensitivity;

func _ready():
	rotating_from_mouse = false;
	set_mouse_sens(0.5)
	set_cam_dist(5.0);
	set_rot_speed(5.0);
	set_move_speed(5.0);
	set_zoom_speed(0.5);

func _input(event):
	if (event is InputEventMouseButton):
		if (event.pressed):
			if (event.button_index == BUTTON_WHEEL_UP):
				set_cam_dist(get_cam_dist() - zoom_speed);
			elif (event.button_index == BUTTON_WHEEL_DOWN):
				set_cam_dist(get_cam_dist() + zoom_speed);
			elif (event.button_index == BUTTON_MIDDLE):
				set_rot_from_mouse(true);
		else:
			if (event.button_index == BUTTON_MIDDLE):
				set_rot_from_mouse(false);
	
	elif (event is InputEventMouseMotion and rotating_from_mouse):
		rotate_yaw(-event.relative.x * mouse_sensitivity);
		rotate_pitch(-event.relative.y * mouse_sensitivity);
	elif (event is InputEventKey and event.pressed and event.scancode == KEY_F):
		transform.origin = Vector3.ZERO;

func _process(delta):
	if (Input.is_action_pressed("camera_zoom_in")):
		set_cam_dist(get_cam_dist() - move_speed * delta);
	if (Input.is_action_pressed("camera_zoom_out")):
		set_cam_dist(get_cam_dist() + move_speed * delta);

	if (Input.is_action_pressed("camera_rot_yaw_positive")):
		rotate_yaw(delta * rotate_speed);
	if (Input.is_action_pressed("camera_rot_yaw_negative")):
		rotate_yaw(delta * -rotate_speed);
	
	if (Input.is_action_pressed("camera_rot_pitch_positive")):
		rotate_pitch(delta * rotate_speed);
	if (Input.is_action_pressed("camera_rot_pitch_negative")):
		rotate_pitch(delta * -rotate_speed);
	
	var mouse_axes:Vector2 = Vector2(
		float(Input.is_action_pressed("camera_move_right")) - float(Input.is_action_pressed("camera_move_left")),
		float(Input.is_action_pressed("camera_move_back")) - float(Input.is_action_pressed("camera_move_forward"))
	).normalized();
	
	if (mouse_axes.x != 0):
		move_right(mouse_axes.x * move_speed * delta);
	if (mouse_axes.y != 0):
		move_forward(mouse_axes.y * move_speed * delta)
	
