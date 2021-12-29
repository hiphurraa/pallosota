extends KinematicBody

const BULLET_SPEED = 300
const BULLET_ACCELERATION = 3
const EXPLOSION_SIZE = 8
const SELF_COLLISIONS = 2
var collided_with_my_self = 0
var exploded = false
var shrinking = false
var been_exploded_for = 0
var velocity = Vector3(0, 0, 0)
var shooting_direction = null
var life_timer = 0

func _ready():
	pass

func init(dir):
	shooting_direction = dir

func _on_bullet_collision_area_body_entered(body):
	if collided_with_my_self < SELF_COLLISIONS:
		collided_with_my_self += 1
	else:
		explode()
		
func _physics_process(delta):
	life_timer += delta
	if (life_timer > 1):
		explode()
	
	if shooting_direction != null and not exploded:
		velocity = velocity.linear_interpolate(shooting_direction * BULLET_SPEED, BULLET_ACCELERATION * delta)
		move_and_slide(velocity)
	
	# BOOM
	if exploded and !shrinking:
		$bullet_explosion.scale.x = lerp($bullet_explosion.scale.x, EXPLOSION_SIZE, 0.4)
		$bullet_explosion.scale.y = lerp($bullet_explosion.scale.y, EXPLOSION_SIZE, 0.4)
		$bullet_explosion.scale.z = lerp($bullet_explosion.scale.z, EXPLOSION_SIZE, 0.4)
		if $bullet_explosion.scale.x > EXPLOSION_SIZE * 0.95:
			shrinking = true
	
	# SHRINKING
	elif exploded and shrinking:
		been_exploded_for += delta
		if (been_exploded_for > 0.1):
			$bullet_explosion.scale.x = lerp($bullet_explosion.scale.x, 0, 0.5)
			$bullet_explosion.scale.y = lerp($bullet_explosion.scale.y, 0, 0.5)
			$bullet_explosion.scale.z = lerp($bullet_explosion.scale.z, 0, 0.5)
		if $bullet_explosion.scale.x < 0.05:
			get_parent().remove_child(self)
		

func explode():
	exploded = true
	$MeshInstance.scale.x = 0
	$MeshInstance.scale.y = 0
	$MeshInstance.scale.z = 0
		
	
