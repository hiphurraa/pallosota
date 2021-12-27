extends KinematicBody

var velocity = Vector3(0, 0, 0)
const NORMAL_SPEED = 12
const SPRINT_SPEED = 12
const DIAGONAL_SCALE = 1.414
const ACCELERATION = 0.05


func _ready():
	pass
	
func _physics_process(delta):
	
	var speed = NORMAL_SPEED
	
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	
	# X AXIS
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
		velocity.x = lerp(velocity.x, 0, ACCELERATION)
	elif Input.is_action_pressed("move_right"):
		velocity.x = lerp(velocity.x, speed, ACCELERATION)
	elif Input.is_action_pressed("move_left"):
		velocity.x = lerp(velocity.x, -speed, ACCELERATION)
	else:
		velocity.x = lerp(velocity.x, 0, ACCELERATION)
		
	# Z AXIS
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_down"):
		velocity.z = 0
	elif Input.is_action_pressed("move_up"):
		velocity.z = lerp(velocity.z, -speed, ACCELERATION)
	elif Input.is_action_pressed("move_down"):
		velocity.z = lerp(velocity.z, speed, ACCELERATION)
	else:
		velocity.z = lerp(velocity.z, 0, ACCELERATION)
		
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_right"):
		var diagonalSpeed = speed / DIAGONAL_SCALE
		velocity.z = lerp(velocity.z, -diagonalSpeed, ACCELERATION)
		velocity.x = lerp(velocity.x, diagonalSpeed, ACCELERATION)
	
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_down"):
		var diagonalSpeed = speed / DIAGONAL_SCALE
		velocity.x = lerp(velocity.x, diagonalSpeed, ACCELERATION)
		velocity.z = lerp(velocity.z, diagonalSpeed, ACCELERATION)
	
	if Input.is_action_pressed("move_down") and Input.is_action_pressed("move_left"):
		var diagonalSpeed = speed / DIAGONAL_SCALE
		velocity.z = lerp(velocity.z, diagonalSpeed, ACCELERATION)
		velocity.x = lerp(velocity.x, -diagonalSpeed, ACCELERATION)
		
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_up"):
		var diagonalSpeed = speed / DIAGONAL_SCALE
		velocity.x = lerp(velocity.x, -diagonalSpeed, ACCELERATION)
		velocity.z = lerp(velocity.z, -diagonalSpeed, ACCELERATION)
	
	$MeshInstance.rotate_z(deg2rad(-velocity.x))
	$MeshInstance.rotate_x(deg2rad(velocity.z))
	
	move_and_slide(velocity)
