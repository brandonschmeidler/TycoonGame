extends Spatial

onready var cam_controller = $CameraController;
onready var cam:Camera = $CameraController/Yaw/Pitch/Camera;

var floor_level:int = 0;

func _input(event):
	if (event is InputEventKey and event.pressed):
		if (event.scancode == KEY_PAGEUP):
			floor_level = floor_level + 1;
			cam_controller.global_transform.origin.y = floor_level;
		if (event.scancode == KEY_PAGEDOWN):
			floor_level = max(floor_level - 1,0);
			cam_controller.global_transform.origin.y = floor_level;

func _process(delta):
	var mouse_pos:Vector2 = get_viewport().get_mouse_position();
	var dropPlane:Plane  = Plane(Vector3(0, 1, 0), floor_level);
	var in_game_pos = dropPlane.intersects_ray(cam.project_ray_origin(mouse_pos),cam.project_ray_normal(mouse_pos));
	if (in_game_pos != null):
		in_game_pos.x = floor(in_game_pos.x) + 0.5;
		in_game_pos.y = floor_level + 1;
		in_game_pos.z = floor(in_game_pos.z) + 0.5;
		$MeshInstance2.global_transform.origin = in_game_pos;
