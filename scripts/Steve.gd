extends KinematicBody	

# MOVEMENT
var velocity = Vector3(0, 0, 0)
const SNEAK_SPEED = 7
const NORMAL_SPEED = 17
const SPRINT_SPEED = 35
const ACCELERATION = 5
# CAMERA
var camera_zoom = 30
const CAMERA_MAX_ZOOM = 50
const CAMERA_MIN_ZOOM = 15
var cameraTargetAngle = 0.0
# BULLER COLLISION
const BOOM_SPEED = 150


func _ready():
	pass
	
func _physics_process(delta):

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
		
	if Input.is_action_just_released("zoom_out"):
		if(camera_zoom < CAMERA_MAX_ZOOM):
			camera_zoom += camera_zoom/10
	elif Input.is_action_just_released("zoom_in"):
		if(camera_zoom > CAMERA_MIN_ZOOM):
			camera_zoom -= camera_zoom/10
		
	$Camera_base.translation.y = lerp($Camera_base.translation.y, camera_zoom, 0.1)
	$Camera_base.rotation_degrees.y = lerp($Camera_base.rotation_degrees.y, cameraTargetAngle, 0.1)
	
	
	# PLAYER MOVEMENT
	var dir = Vector3()
	var inputMoveVector = Vector2()
	var camera_dir = $Camera_base.get_global_transform().basis
	
	# SPEED
	var speed = NORMAL_SPEED
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	elif Input.is_action_pressed("sneak"):
		speed = SNEAK_SPEED
		
	# UP AND DOWN MOVEMENT
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_down"):
		pass
	elif Input.is_action_pressed("move_up"):
		inputMoveVector.y += 1
	elif Input.is_action_pressed("move_down"):
		inputMoveVector.y -= 1
	else:
		pass
	
	# LEFT AND RIGHT MOVEMENT
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
		pass
	elif Input.is_action_pressed("move_left"):
		inputMoveVector.x -= 1
	elif Input.is_action_pressed("move_right"):
		inputMoveVector.x += 1
	else:
		pass
		
	# APPLY MOVEMENT
	inputMoveVector = inputMoveVector.normalized()
	dir += -camera_dir.z * inputMoveVector.y
	dir += camera_dir.x * inputMoveVector.x
	dir.y = 0
	dir = dir.normalized()
	
	velocity.y = 0
	var moveDir = dir * speed
	var up = Vector3(0, 1, 0)
	velocity = velocity.linear_interpolate(moveDir, ACCELERATION * delta)
	velocity = move_and_slide(velocity, up, 0.05, 4, 45)
	
	# BALL MESH ROTATION ACCORDING TO SPEED
	$MeshInstance.rotate_z(deg2rad(-velocity.x))
	$MeshInstance.rotate_x(deg2rad(velocity.z))


func _on_player_collision_area_body_entered(body):
	print("player collided with: " +  body.name)
	if body.name == "Bullet" or body.name == "bullet_explosion":
		var bullet_location = body.global_transform.origin
		var player_location = global_transform.origin
		var dir = Vector3()
		dir.x = player_location.x - bullet_location.x
		dir.z = player_location.z - bullet_location.z
		dir.y = 0
		dir = dir.normalized()
		velocity = dir * BOOM_SPEED
