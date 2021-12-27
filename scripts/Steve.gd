extends KinematicBody

var velocity = Vector3(0, 0, 0)
const NORMAL_SPEED = 20
const SPRINT_SPEED = 20
const DIAGONAL_SCALE = 1.414
const ACCELERATION = 0.05

var cameraTargetAngle = 0.0


func _ready():
	pass
	
func _physics_process(delta):

	# CAMERA
	# ROTATE CAMERA LEFT
	if Input.is_action_just_pressed("rotate_camera_left"):
		if (cameraTargetAngle == 0):
			$Camera_base.rotation_degrees.y = 360
			cameraTargetAngle = 315
		else:
			cameraTargetAngle -= 45
		print(cameraTargetAngle)
	
	# ROTATE CAMERA RIGHT		
	if Input.is_action_just_pressed("rotate_camera_right"):
		if (cameraTargetAngle == 360):
			$Camera_base.rotation_degrees.y = 0
			cameraTargetAngle = 45
		else:
			cameraTargetAngle += 45
		print(cameraTargetAngle)
		
	$Camera_base.rotation_degrees.y = lerp($Camera_base.rotation_degrees.y, cameraTargetAngle, 0.1)
	
	
	
	# PLAYER MOVEMENT
	# SPEED
	var speed = NORMAL_SPEED
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	
	# X AXIS
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
		decelerate_x()
	elif Input.is_action_pressed("move_right"):
		if(cameraTargetAngle == 45):
			pass
		move_right(speed)
	elif Input.is_action_pressed("move_left"):
		move_left(speed)
	else:
		decelerate_x()
		
	# Z AXIS
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_down"):
		decelerate_z()
	elif Input.is_action_pressed("move_up"):
		move_up(speed)
	elif Input.is_action_pressed("move_down"):
		move_down(speed)
	else:
		decelerate_z()
		
	# DIAGONAL MOVEMENT
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_right"):
		move_up_and_right(speed)
	
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_down"):
		move_right_and_down(speed)
	
	if Input.is_action_pressed("move_down") and Input.is_action_pressed("move_left"):
		move_down_and_left(speed)
		
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_up"):
		move_left_and_up(speed)
	
	
	
	
	# BALL MESH ROTATION ACCORDING TO SPEED
	$MeshInstance.rotate_z(deg2rad(-velocity.x))
	$MeshInstance.rotate_x(deg2rad(velocity.z))
	# ACTUAL MOVEMENT
	move_and_slide(velocity)








func decelerate_z():
	velocity.z = lerp(velocity.z, 0, ACCELERATION)
	
func decelerate_x():
	velocity.x = lerp(velocity.x, 0, ACCELERATION)

func move_up(speed, is_original_event = true):
	if (cameraTargetAngle == 315):
		move_up_and_right(speed)
	elif (cameraTargetAngle == 270):
		move_right(speed)
	elif(cameraTargetAngle == 225):
		move_right_and_down(speed)
	elif(cameraTargetAngle == 180):
		if (is_original_event):
			move_down(speed, false)
		else:
			velocity.z = lerp(velocity.z, -speed, ACCELERATION)
	elif(cameraTargetAngle == 135):
		move_down_and_left(speed)
	elif(cameraTargetAngle == 90):
		move_left(speed)
	elif(cameraTargetAngle == 45):
		move_left_and_up(speed)
	else:
		velocity.z = lerp(velocity.z, -speed, ACCELERATION)
	
func move_down(speed, is_original_event:bool = true):
	if (cameraTargetAngle == 315):
		move_down_and_left(speed)
	elif (cameraTargetAngle == 270):
		move_left(speed)
	elif(cameraTargetAngle == 225):
		move_left_and_up(speed)
	elif(cameraTargetAngle == 180):
		if(is_original_event):
			move_up(speed, false)
		else:
			velocity.z = lerp(velocity.z, speed, ACCELERATION)
	elif(cameraTargetAngle == 135):
		move_up_and_right(speed)
	elif(cameraTargetAngle == 90):
		move_right(speed)
	elif(cameraTargetAngle == 45):
		move_right_and_down(speed)
	else:
		velocity.z = lerp(velocity.z, speed, ACCELERATION)
	
func move_left(speed, is_original_event = true):
	velocity.x = lerp(velocity.x, -speed, ACCELERATION)
	
	
func move_right(speed, is_original_event = true):
	velocity.x = lerp(velocity.x, speed, ACCELERATION)
	
func move_up_and_right(speed, is_original_event = true):
	var diagonalSpeed = speed / DIAGONAL_SCALE
	velocity.z = lerp(velocity.z, -diagonalSpeed, ACCELERATION)
	velocity.x = lerp(velocity.x, diagonalSpeed, ACCELERATION)
	
func move_right_and_down(speed, is_original_event = true):
	var diagonalSpeed = speed / DIAGONAL_SCALE
	velocity.x = lerp(velocity.x, diagonalSpeed, ACCELERATION)
	velocity.z = lerp(velocity.z, diagonalSpeed, ACCELERATION)
	
func move_down_and_left(speed, is_original_event = true):
	var diagonalSpeed = speed / DIAGONAL_SCALE
	velocity.z = lerp(velocity.z, diagonalSpeed, ACCELERATION)
	velocity.x = lerp(velocity.x, -diagonalSpeed, ACCELERATION)
	
func move_left_and_up(speed, is_original_event = true):
	var diagonalSpeed = speed / DIAGONAL_SCALE
	velocity.x = lerp(velocity.x, -diagonalSpeed, ACCELERATION)
	velocity.z = lerp(velocity.z, -diagonalSpeed, ACCELERATION)
