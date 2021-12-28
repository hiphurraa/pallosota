extends KinematicBody


func _ready():
	pass


func _on_bullet_collision_area_body_entered(body):
	print(body.name)
