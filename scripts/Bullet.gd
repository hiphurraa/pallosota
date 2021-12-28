extends KinematicBody

const BULLET_SPEED = 100
const EXPLOSION_SIZE = 8
const SELF_COLLISIONS = 2
var collided_with_my_self = 0
var exploded = false
var been_exploded_for = 0
var shrink = false
var velocity = Vector3(0, 0, 0)
var fly_dir = null

func _ready():
	pass

func init(dir):
	fly_dir = dir

func _on_bullet_collision_area_body_entered(body):
	if collided_with_my_self < SELF_COLLISIONS:
		collided_with_my_self += 1
	else:
		#print("Bullet collided with: " + body.name)
		exploded = true
		
func _physics_process(delta):
	
	if fly_dir != null:
		var direction = - fly_dir.z * BULLET_SPEED
		velocity = velocity.linear_interpolate(direction, 100 * delta)
		velocity = move_and_slide(velocity, Vector3.UP, 0.05, 4, 45)
	
	# BOOM
	if exploded and !shrink:
		$bullet_explosion.scale.x = lerp($bullet_explosion.scale.x, EXPLOSION_SIZE, 0.3)
		$bullet_explosion.scale.y = lerp($bullet_explosion.scale.y, EXPLOSION_SIZE, 0.3)
		$bullet_explosion.scale.z = lerp($bullet_explosion.scale.z, EXPLOSION_SIZE, 0.3)
		if $bullet_explosion.scale.x > EXPLOSION_SIZE * 0.95:
			shrink = true
	
	# SHRINKING
	if exploded and shrink:
		if (been_exploded_for > 0.1):
			$bullet_explosion.scale.x = lerp($bullet_explosion.scale.x, 0, 0.5)
			$bullet_explosion.scale.y = lerp($bullet_explosion.scale.y, 0, 0.5)
			$bullet_explosion.scale.z = lerp($bullet_explosion.scale.z, 0, 0.5)
		$MeshInstance.scale.x = 0
		$MeshInstance.scale.y = 0
		$MeshInstance.scale.z = 0
		been_exploded_for += delta
		if $bullet_explosion.scale.x < 0.05:
			get_parent().remove_child(self)
		

		
		
	
