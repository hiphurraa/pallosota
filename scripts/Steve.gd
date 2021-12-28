extends KinematicBody

var velocity = Vector3(0, 0, 0)
const NORMAL_SPEED = 20
const SPRINT_SPEED = 40
const DIAGONAL_SCALE = 1.414
const ACCELERATION = 5

var cameraTargetAngle = 0.0


func _ready():
	pass
	
func _physics_process(delta):
	print(delta)

	# CAMERA
	# ROTATE CAMERA LEFT
	if Input.is_action_just_pressed("rotate_camera_left"):
		if (cameraTargetAngle == 360):
			$Camera_base.rotation_degrees.y = 0
			cameraTargetAngle = 45
		else:
			cameraTargetAngle += 45
		print(cameraTargetAngle)
	
	# ROTATE CAMERA RIGHT		
	if Input.is_action_just_pressed("rotate_camera_right"):
		if (cameraTargetAngle == 0):
			$Camera_base.rotation_degrees.y = 360
			cameraTargetAngle = 315
		else:
			cameraTargetAngle -= 45
		print(cameraTargetAngle)
		
		
	$Camera_base.rotation_degrees.y = lerp($Camera_base.rotation_degrees.y, cameraTargetAngle, 0.1)
	
	var dir = Vector3()
	var inputMoveVector = Vector2()
	var camera_dir = $Camera_base.get_global_transform().basis
	
	# PLAYER MOVEMENT
	# SPEED
	var speed = NORMAL_SPEED
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
		
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
	# ACTUAL MOVEMENT
	#move_and_slide(velocity)






	

func decelerate_x():
	velocity.x = lerp(velocity.x, 0, ACCELERATION)
#
#func move_up(speed, is_original_event = true):
#	velocity.z = lerp(velocity.z, -speed, ACCELERATION)
#
#func move_down(speed, is_original_event:bool = true):
#	velocity.z = lerp(velocity.z, speed, ACCELERATION)
#
#func move_left(speed, is_original_event = true):
#	velocity.x = lerp(velocity.x, -speed, ACCELERATION)
#
#func move_right(speed, is_original_event = true):
#	velocity.x = lerp(velocity.x, speed, ACCELERATION)
#
#func move_up_and_right(speed, is_original_event = true):
#	var diagonalSpeed = speed / DIAGONAL_SCALE
#	velocity.z = lerp(velocity.z, -diagonalSpeed, ACCELERATION)
#	velocity.x = lerp(velocity.x, diagonalSpeed, ACCELERATION)
#
#func move_right_and_down(speed, is_original_event = true):
#	var diagonalSpeed = speed / DIAGONAL_SCALE
#	velocity.x = lerp(velocity.x, diagonalSpeed, ACCELERATION)
#	velocity.z = lerp(velocity.z, diagonalSpeed, ACCELERATION)
#
#func move_down_and_left(speed, is_original_event = true):
#	var diagonalSpeed = speed / DIAGONAL_SCALE
#	velocity.z = lerp(velocity.z, diagonalSpeed, ACCELERATION)
#	velocity.x = lerp(velocity.x, -diagonalSpeed, ACCELERATION)
#
#func move_left_and_up(speed, is_original_event = true):
#	var diagonalSpeed = speed / DIAGONAL_SCALE
#	velocity.x = lerp(velocity.x, -diagonalSpeed, ACCELERATION)
#	velocity.z = lerp(velocity.z, -diagonalSpeed, ACCELERATION)
