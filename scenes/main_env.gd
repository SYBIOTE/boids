extends Spatial


export(int) var boids = 100
export(PackedScene) var Boid

var _width = 100
var _height = 100
var _breadth= 100
var boid_array : Array = []

var target : Vector3 

func _ready():
	for _i in range(boids):
		randomize()
		var boid = Boid.instance()
		boid.transform.origin = Vector3(rand_range(-_width, _width), rand_range(0, _height),rand_range(-_breadth,_breadth))
		add_child(boid)
		boid_array.append(boid)


func give_target():
	$target.global_transform.origin=target
	return target

func _input(event):
	if event.is_action_pressed("left_click"):
		target = get_random_target()
		
		$target.visible=true
	elif event.is_action_pressed("right_click"):
		$target.visible=false
			

func get_random_target():
	randomize()
	var target= Vector3(rand_range(-_width, _width), rand_range(-_height, _height),rand_range(-_breadth, _breadth))
	return target





func _on_target_force_value_changed(value):
	for i in boid_array:
		i.mouse_follow_force = value
	print(" tf changed to", value)

func _on_cohesion_force_value_changed(value):
	for i in boid_array:
		i.cohesion_force= value
	print(" cf changed to", value)

func _on_seperation_force_value_changed(value):
	for i in boid_array:
		i.separation_force=value
	print(" sf changed to", value)
func _on_align_force_value_changed(value):
	for i in boid_array:
		i.algin_force= value
	print(" af changed to", value)


func _on_view_distance_value_changed(value):
	for i in boid_array:
		i.view_distance= value
	print(" vd changed to", value)


func _on_avoid_distance_value_changed(value):
	for i in boid_array:
		i.avoid_distance= value
	print(" ad changed to", value)


func _on_count_value_changed(value):
	if value<boids:
		for i in range(value,boids):
			boids-=1
			boid_array[i].queue_free()
		boid_array.resize(value)
		print(boid_array.size())
	if value>boids:
		for i in range(boids,value):
			randomize()
			var boid = Boid.instance()
			boid.transform.origin = Vector3(rand_range(-_width, _width), rand_range(0, _height),rand_range(-_breadth,_breadth))
			add_child(boid)
			boid_array.append(boid)
			boids+=1
		
