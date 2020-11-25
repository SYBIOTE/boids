extends KinematicBody

export var max_speed: = 50
export var mouse_follow_force: = .05
export var cohesion_force: = .05
export var algin_force: = .05
export var separation_force: = .05
export(float) var view_distance: = 20
export(float) var avoid_distance: = 10
var save_mouse_force= mouse_follow_force

var _width = 50
var _height = 50
var _breadth = 50
var _flock: Array = []
var _obstacles: Array =[]
var _obs_name: Array=[]
var _mouse_target: Vector3
var _velocity: Vector3


func _ready():
	randomize()
	mouse_follow_force = 0
	_velocity = Vector3(rand_range(-1, 1), rand_range(-1, 1),rand_range(-1, 1)).normalized() * max_speed
	_mouse_target = get_random_target()
	$FlockView/view_radius.shape.radius = view_distance

func _on_FlockView_body_entered(body: PhysicsBody):
	if self != body and body.name != "StaticBody" :
		_flock.append(body)
	if body.name == "StaticBody":
		_obstacles.append(body)
		_obs_name.append(body.get_parent().name)
		print(_obs_name)


func _on_FlockView_body_exited(body: PhysicsBody):
	_flock.remove(_flock.find(body))
	
	if body.name == "StaticBody":
		_obstacles.remove(_obstacles.find(body))
		_obs_name.remove(_obs_name.find(body.get_parent().name))
		print(_obs_name)
func _input(event):
		if event.is_action_pressed("left_click"):
			_mouse_target = get_parent().give_target()
			mouse_follow_force = save_mouse_force
		
		elif event.is_action_pressed("right_click"):
			mouse_follow_force = 0
			
		elif event.is_action_pressed("random"):
			_mouse_target = get_random_target()


func _physics_process(_delta):
	var mouse_vector = Vector3.ZERO
	if _mouse_target != Vector3.INF:
		mouse_vector = global_transform.origin.direction_to(_mouse_target) * max_speed * mouse_follow_force
	
	# get cohesion, alginment, and separation vectors
	var vectors = get_flock_status(_flock)
	
	# steer towards vectors
	var cohesion_vector = vectors[0] * cohesion_force
	var align_vector = vectors[1] * algin_force
	var separation_vector = vectors[2] * separation_force
	var wall_vector=vectors[3] * separation_force
	
	var acceleration = cohesion_vector + align_vector + separation_vector + mouse_vector+wall_vector
	
	_velocity = (_velocity + acceleration).normalized()*max_speed
#	_velocity.x = clamp(_velocity.x,-max_speed,max_speed)
#	_velocity.y = clamp(_velocity.y,-max_speed,max_speed)
#	_velocity.z = clamp(_velocity.z,-max_speed,max_speed)
	look(_velocity)
	_velocity=move_and_slide(_velocity)
	
	

func get_flock_status(flock: Array):
	var center_vector: = Vector3()
	var flock_center: = Vector3()
	var align_vector: = Vector3()
	var avoid_vector: = Vector3()
	var wall_vector: = Vector3()
	for f in flock:
		var neighbor_pos: Vector3 = f.global_transform.origin

		align_vector += f._velocity
		flock_center += neighbor_pos

		var d = global_transform.origin.distance_to(neighbor_pos)
		if d > 0 and d < avoid_distance:
			avoid_vector -= (neighbor_pos - global_transform.origin).normalized() * (avoid_distance / d * max_speed)
	for o in _obstacles:
		var obs_pos: Vector3 = o.global_transform.origin
		var wall 
		if o.get_parent().name=="wall_y-":
			print("pushing u")
			wall= Plane(Vector3.DOWN,100)
			var d = abs(wall.distance_to(global_transform.origin))
			print("from bot ",d)
			if d > 0 and d < avoid_distance:
				print("pushing up")
				wall_vector += (Vector3.UP) * (avoid_distance / d * max_speed)
				print("repulsion from wall is ", wall_vector)
		if o.get_parent().name=="wall_y+":
#			print("pushing d")
			wall= Plane(Vector3.UP,100)
			var d = abs(wall.distance_to(global_transform.origin))
#			print("from top ",d)
			if d > 0 and d < avoid_distance:
				wall_vector += (Vector3.DOWN) * (avoid_distance / d * max_speed)
#				print("repulsion from wall is ", wall_vector)
		if o.get_parent().name=="wall_x-":
#			print("pushing r")
			wall= Plane(Vector3.LEFT,100)
			var d = abs(wall.distance_to(global_transform.origin))
#			print("from lwall ",d)
			if d > 0 and d < avoid_distance:
				wall_vector += (Vector3.RIGHT) * (avoid_distance / d * max_speed)
#				print("repulsion from wall is ", wall_vector)
		if o.get_parent().name=="wall_x+":
#			print("pushing l")
			wall= Plane(Vector3.RIGHT,100)
			var d = abs(wall.distance_to(global_transform.origin))
#			print("from rwall ",d)
			if d > 0 and d < avoid_distance:
				wall_vector += (Vector3.LEFT) * (avoid_distance / d * max_speed)
#				print("repulsion from wall is ", wall_vector)
		if o.get_parent().name=="wall_z-":
#			print("pushing f")
			wall= Plane(Vector3.FORWARD,100)
			var d = abs(wall.distance_to(global_transform.origin))
#			print("from bwall ",d)
			if d > 0 and d < avoid_distance:
#				print("pushing forward")
				wall_vector += (Vector3.BACK) * (avoid_distance / d * max_speed)
#				print("repulsion from wall is ", wall_vector)
		if o.get_parent().name=="wall_z+":
			print("pushing b")
			wall= Plane(Vector3.BACK,100)
			var d = abs(wall.distance_to(global_transform.origin))
			print("from fwall",d)
			if d > 0 and d < avoid_distance:
				print("pushing back")
				wall_vector += (Vector3.FORWARD) * (avoid_distance / d * max_speed)
				print("repulsion from wall is ", wall_vector)
	
			
			
	var flock_size = flock.size()
	if flock_size:
		align_vector /= flock_size
		flock_center /= flock_size

		var center_dir = global_transform.origin.direction_to(flock_center)
		var center_speed = max_speed * (global_transform.origin.distance_to(flock_center) / $FlockView/view_radius.shape.radius)
		center_vector = center_dir * center_speed

	return [center_vector, align_vector, avoid_vector,wall_vector]
func look(vector):
		var desired_rot=transform.looking_at(vector,transform.basis.y)
		var a=Quat(transform.basis.get_rotation_quat()).slerp(desired_rot.basis.get_rotation_quat(),1)
		set_transform(Transform(a,transform.origin))


func get_random_target():
	randomize()
	var target= Vector3(rand_range(-_width, _width), rand_range(-_height, _height),rand_range(-_breadth, _breadth))
	return target




