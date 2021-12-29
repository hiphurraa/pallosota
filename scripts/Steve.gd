extends KinematicBody	

# GRAVITY
var fall_velocity = Vector3()
const GRAVITY = 9.81 * 10

# MOVEMENT
var velocity = Vector3(0, 0, 0)
const SNEAK_SPEED = 7
const NORMAL_SPEED = 17
const SPRINT_SPEED = 35
const ACCELERATION = 5

# CAMERA
var camera_zoom = 15
const CAMERA_MAX_ZOOM = 20
const CAMERA_MIN_ZOOM = 5
var cameraTargetAngle = 0.0
const CAM_MAX_ROTATE_SPEED = 5
var cam_rotate_speed = 0
const CAM_ROTATE_ACCELERATION = 4
const CAM_ROTATE_DECELERATION = 20
const CAM_ROTATE_STARTING_SPEED = 1
const CAMERA_MODE_MOUSE = "MOUSE"
const CAMERA_MODE_KEYBOARD = "KEYBOARD"
var camera_mode = CAMERA_MODE_MOUSE
var MOUSE_SENSITIVITY = 0.15
var mouse_camera_max_angle = 15
var mouse_camera_min_angle = -70
var mouse_cursor = false

# BULLET COLLISION
const BOOM_SPEED = 120
var bullet_class = load("res://assets/Bullet.tscn")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion and !mouse_cursor:
		camera_mode = CAMERA_MODE_MOUSE
		$Camera_base.rotate_y(deg2rad(-event.relative.x*MOUSE_SENSITIVITY))
		var changev=-event.relative.y * MOUSE_SENSITIVITY
		var rotation_state = $Camera_base.get_node("lever").get_node("arm").rotation_degrees.x
		print(rotation_state)
		if (rotation_state < mouse_camera_max_angle and changev > 0 ) or (rotation_state > mouse_camera_min_angle and changev < 0):
			$Camera_base.get_node("lever").get_node("arm").rotate_x(deg2rad(changev))
		
	
func _physics_process(delta):
	
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_cursor = true
	
	# PLAYER MOVEMENT
	var dir = Vector3()
	var input_move_vector = Vector2()
	var camera_basis = $Camera_base.get_global_transform().basis
	
	# MOVEMENT SPEED
	var speed = NORMAL_SPEED
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	elif Input.is_action_pressed("sneak"):
		speed = SNEAK_SPEED
	
	# UP AND DOWN MOVEMENT
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_down"):
		pass
	elif Input.is_action_pressed("move_up"):
		input_move_vector.y += 1
	elif Input.is_action_pressed("move_down"):
		input_move_vector.y -= 1
	
	# LEFT AND RIGHT MOVEMENT
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
		pass
	elif Input.is_action_pressed("move_left"):
		input_move_vector.x -= 1
	elif Input.is_action_pressed("move_right"):
		input_move_vector.x += 1
		
	# GRAVITY
	if not is_on_floor():
		fall_velocity.y -= GRAVITY * delta
	else:
		fall_velocity.y = 0
		
	# MOVEMENT DIRECTION
	input_move_vector = input_move_vector.normalized()
	dir += -camera_basis.z * input_move_vector.y
	dir += camera_basis.x * input_move_vector.x
	dir = dir.normalized()
	
	# APPLY PHYSICS AND MOVEMENT INPUT
	var move_dir = dir * speed
	velocity = velocity.linear_interpolate(move_dir, ACCELERATION * delta)
	velocity.y = fall_velocity.y
	move_and_slide(velocity)
	
	# BALL MESH ROTATION ACCORDING TO SPEED
	$MeshInstance.rotate_z(deg2rad(-velocity.x))
	$MeshInstance.rotate_x(deg2rad(velocity.z))
	
	# SHOOTING
	if Input.is_action_just_pressed("shoot"):
		if mouse_cursor:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_cursor = false
		else:
			var shooting_direction = Vector3()
			shooting_direction += -camera_basis.z
			shooting_direction = shooting_direction.normalized()
			var bullet_instance = bullet_class.instance()
			var bullet_locations_to_be = Vector3()
			bullet_locations_to_be = global_transform.origin
			bullet_locations_to_be += shooting_direction * 2
			bullet_locations_to_be.y = 1
			bullet_instance.global_transform.origin = bullet_locations_to_be
			print(global_transform.origin)
			get_parent().add_child(bullet_instance)
			bullet_instance.init(shooting_direction)
		
	# CAMERA
	# ROTATE CAMERA LEFT
	if Input.is_action_pressed("rotate_camera_left"):
		camera_mode = CAMERA_MODE_KEYBOARD
		if(cam_rotate_speed < CAM_MAX_ROTATE_SPEED):
			if cam_rotate_speed < CAM_ROTATE_STARTING_SPEED:
				cam_rotate_speed = CAM_ROTATE_STARTING_SPEED
			cam_rotate_speed += cam_rotate_speed * CAM_ROTATE_ACCELERATION * delta
	
	# ROTATE CAMERA RIGHT
	elif Input.is_action_pressed("rotate_camera_right"):
		camera_mode = CAMERA_MODE_KEYBOARD
		if(cam_rotate_speed > -CAM_MAX_ROTATE_SPEED):
			if cam_rotate_speed > -CAM_ROTATE_STARTING_SPEED:
				cam_rotate_speed = -CAM_ROTATE_STARTING_SPEED
			cam_rotate_speed += cam_rotate_speed * CAM_ROTATE_ACCELERATION * delta
	
	# DECELERATE CAMERA BACK TO IDLE
	elif cam_rotate_speed < 0:
		cam_rotate_speed += -cam_rotate_speed * CAM_ROTATE_DECELERATION * delta
	elif cam_rotate_speed > 0:
		cam_rotate_speed -= cam_rotate_speed * CAM_ROTATE_DECELERATION * delta
	
	# ZOOM
	if Input.is_action_just_released("scroll_out"):
		if(camera_zoom < CAMERA_MAX_ZOOM):
			camera_zoom += camera_zoom * 0.2
	elif Input.is_action_just_released("scroll_in"):
		if(camera_zoom > CAMERA_MIN_ZOOM):
			camera_zoom -= camera_zoom * 0.2
	if Input.is_action_pressed("zoom_in"):
		camera_mode = CAMERA_MODE_KEYBOARD
		if(camera_zoom > CAMERA_MIN_ZOOM):
			camera_zoom -= camera_zoom * 0.05
	if Input.is_action_pressed("zoom_out"):
		camera_mode = CAMERA_MODE_KEYBOARD
		if(camera_zoom < CAMERA_MAX_ZOOM):
			camera_zoom += camera_zoom * 0.05
	
	# APPLY CAMERA ANGLE AND ZOOM
	var cam_dist_from_player = 10
	var cam_angle_radians = Vector2(cam_dist_from_player, camera_zoom).angle()
	var cam_angle_degrees = rad2deg(cam_angle_radians)
	var new_cam_angle = -cam_angle_degrees + 20
	
	cameraTargetAngle += cam_rotate_speed
	if camera_mode == CAMERA_MODE_KEYBOARD:
		$Camera_base.get_node("lever").get_node("arm").get_node("camera").translation.z = 10
		$Camera_base.rotation_degrees.y = lerp($Camera_base.rotation_degrees.y, cameraTargetAngle, 0.1)
		$Camera_base.get_node("lever").get_node("arm").rotation_degrees.x = lerp($Camera_base.get_node("lever").get_node("arm").rotation_degrees.x, new_cam_angle, 0.1)
		$Camera_base.translation.y = lerp($Camera_base.translation.y, camera_zoom, 0.1)
		$Camera_base.get_node("lever").get_node("arm").translation.z = lerp($Camera_base.get_node("lever").get_node("arm").translation.z, camera_zoom*0.2, 0.1)
		$Camera_base.get_node("lever").get_node("arm").get_node("camera").rotation_degrees.x = lerp($Camera_base.get_node("lever").get_node("arm").get_node("camera").rotation_degrees.x, 0, 0.1)
		$Camera_base.get_node("lever").rotation_degrees.x = lerp($Camera_base.get_node("lever").rotation_degrees.x, 0, 0.1)
	elif camera_mode == CAMERA_MODE_MOUSE:
		cameraTargetAngle = $Camera_base.rotation_degrees.y
		$Camera_base.translation.y = 3
		$Camera_base.get_node("lever").get_node("arm").translation.z = 0
		$Camera_base.get_node("lever").get_node("arm").get_node("camera").translation.z = lerp($Camera_base.get_node("lever").get_node("arm").get_node("camera").translation.z, camera_zoom + 3, 0.1)
		$Camera_base.get_node("lever").get_node("arm").get_node("camera").rotation_degrees.x = lerp($Camera_base.get_node("lever").get_node("arm").get_node("camera").rotation_degrees.x, camera_zoom, 0.1)
		$Camera_base.get_node("lever").rotation_degrees.x = lerp($Camera_base.get_node("lever").rotation_degrees.x, -camera_zoom, 0.1)
		
		
		


func _on_player_collision_area_body_entered(body):
	#print("player collided with: " +  body.name)
	if body.name == "bullet_explosion":
		var bullet_location = body.global_transform.origin
		var player_location = global_transform.origin
		var dir = Vector3()
		dir.x = player_location.x - bullet_location.x
		dir.z = player_location.z - bullet_location.z
		dir.y = 0
		dir = dir.normalized()
		velocity = dir * BOOM_SPEED
