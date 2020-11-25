extends CollisionShape


func _ready():
	shape.radius = get_parent().view_distance


