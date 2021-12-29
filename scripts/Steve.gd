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
var camera_zoom = 50
const CAMERA_MAX_ZOOM = 40
const CAMERA_MIN_ZOOM = 5
var cameraTargetAngle = 0.0

# BULLET COLLISION
const BOOM_SPEED = 120
var bullet_class = load("res://assets/Bullet.tscn")


func _ready():
	pass
	
func _physics_process(delta):
	
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
	if Input.is_action_just_pressed("rotate_camera_left"):
		if (cameraTargetAngle == 360):
			$Camera_base.rotation_degrees.y = 0
			cameraTargetAngle = 45
		else:
			cameraTargetAngle += 45
	
	# ROTATE CAMERA RIGHT
	if Input.is_action_just_pressed("rotate_camera_right"):
		if (cameraTargetAngle == 0):
			$Camera_base.rotation_degrees.y = 360
			cameraTargetAngle = 315
		else:
			cameraTargetAngle -= 45
		
	# ZOOM
	if Input.is_action_just_released("zoom_out"):
		if(camera_zoom < CAMERA_MAX_ZOOM):
			camera_zoom += camera_zoom/5
	elif Input.is_action_just_released("zoom_in"):
		if(camera_zoom > CAMERA_MIN_ZOOM):
			camera_zoom -= camera_zoom/5
		
	$Camera_base.translation.y = lerp($Camera_base.translation.y, camera_zoom, 0.1)
	$Camera_base.rotation_degrees.y = lerp($Camera_base.rotation_degrees.y, cameraTargetAngle, 0.1)
	var cam_dist_from_player = 10
	var cam_angle_radians = Vector2(cam_dist_from_player, camera_zoom).angle()
	var cam_angle_degrees = rad2deg(cam_angle_radians)
	var new_cam_angle = -cam_angle_degrees + 20
	$Camera_base.get_child(0).rotation_degrees.x = lerp($Camera_base.get_child(0).rotation_degrees.x, new_cam_angle, 0.1)
		


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
