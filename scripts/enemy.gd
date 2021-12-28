extends KinematicBody

# MOVEMENT
var velocity = Vector3(0, 0, 0)
const SNEAK_SPEED = 7
const NORMAL_SPEED = 17
const SPRINT_SPEED = 35
const ACCELERATION = 5
var move_up = false
var move_down = false
var move_left = false
var move_right = false
var time_passed = 0

const BOOM_SPEED = 150

var rng = RandomNumberGenerator.new()

func _on_Vision_area_body_entered(body):
	move_up = false
	move_down = false
	move_left = false
	move_right = false
	var rnd = rng.randf_range(0, 8)
	if rnd < 1:
		move_up = true
	elif rnd < 2:
		move_down = true
	elif rnd < 3:
		move_left = true
	elif rnd < 4:
		move_right = true
	elif rnd < 5:
		move_up = true
		move_right = true
	elif rnd < 6:
		move_right = true
		move_down = true
	elif rnd < 7:
		move_down = true
		move_left = true
	else:
		move_left = true
		move_up = true

func _ready():
	var rnd = rng.randf_range(0, 8)
	if rnd < 1:
		move_up = true
	elif rnd < 2:
		move_down = true
	elif rnd < 3:
		move_left = true
	elif rnd < 4:
		move_right = true
	elif rnd < 5:
		move_up = true
		move_right = true
	elif rnd < 6:
		move_right = true
		move_down = true
	elif rnd < 7:
		move_down = true
		move_left = true
	else:
		move_left = true
		move_up = true

func _physics_process(delta):

	# ENEMY MOVEMENT
	var dir = Vector3()
	var inputMoveVector = Vector2()
	
	# SPEED
	var speed = NORMAL_SPEED
		
	# UP AND DOWN MOVEMENT
	if move_up and move_down:
		pass
	elif move_up:
		inputMoveVector.y += 1
	elif move_down:
		inputMoveVector.y -= 1
	
	# LEFT AND RIGHT MOVEMENT
	if move_left and move_right:
		pass
	elif move_left:
		inputMoveVector.x -= 1
	elif move_right:
		inputMoveVector.x += 1
		
	# APPLY MOVEMENT
	inputMoveVector = inputMoveVector.normalized()
	dir.z += inputMoveVector.y
	dir.x += inputMoveVector.x
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


func _on_Collision_area_body_entered(body):
	print("enemy collided with: " +  body.name)
	if body.name == "Bullet" or body.name == "bullet_explosion":
		var bullet_location = body.global_transform.origin
		var player_location = global_transform.origin
		var dir = Vector3()
		dir.x = player_location.x - bullet_location.x
		dir.z = player_location.z - bullet_location.z
		dir.y = 0
		dir = dir.normalized()
		velocity = dir * BOOM_SPEED
