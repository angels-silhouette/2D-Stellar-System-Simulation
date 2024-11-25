extends RigidBody2D

@onready var observer: Node2D = self.get_parent().get_child(0)
@onready var world: Node2D = self.get_parent()

# Node
func _ready():
	world.Gravitational_Constant_Changed_Signal.connect(_on_gravitational_constant_changed)
	update_mass()


func _process(delta):
	update_labels()
	merge_objects()


var affecting_bodies: Array
var touching_bodies: Array
var touching_bodies_time: Array

func _physics_process(delta):
	var resulting_force: Vector2 = Vector2(0, 0)
	
	for body in affecting_bodies:
		var vector_to_body = body.position - position
		var radius_squared: float = pow((vector_to_body.x), 2) + pow((vector_to_body.y), 2)
		var force: float = (world.gravitational_constant * mass * body.mass) / radius_squared
		resulting_force += vector_to_body.normalized() * force
	
	var acceleration = resulting_force / self.mass
	
	self.linear_velocity += acceleration * world.time_scale * delta


# Functions
var radius: float
var gravitational_radius: float
var mass_number:int = 5
var mass_power:int = 0
@export var gravitational_radius_threshold: float = 0.00001
@export var density: int = 100
@export var max_touching_merge_time: float = 1000


func merge_objects():
	var time = Time.get_ticks_msec()
	for contact_time in touching_bodies_time:
		if time - contact_time > max_touching_merge_time:
			var contact_object = touching_bodies[touching_bodies_time.find(contact_time)]
			
			$CollisionShape2D.disabled = true
			contact_object.get_node("CollisionShape2D").disabled = true
			
			world.create_object((contact_object.position - self.position)/2 + self.position, self.mass + contact_object.mass)
			
			contact_object.queue_free()
			self.queue_free()


func update_labels():
	var edit_container = $Settings/MarginContainer/GridContainer
	var label_container = $Info/MarginContainer/GridContainer
	if $Settings.visible:
		$Settings.scale = Vector2(1, 1) / world.zoom
		edit_container.get_node("MassHBoxContainer/MassLineEdit").placeholder_text = str(mass_number)
		edit_container.get_node("MassHBoxContainer/MassPowerLineEdit").placeholder_text = str(mass_power)
		edit_container.get_node("VelocityHBoxContainer/VelocityXLineEdit").placeholder_text = str(self.linear_velocity.x)
		edit_container.get_node("VelocityHBoxContainer/VelocityYLineEdit").placeholder_text = str(self.linear_velocity.y)
	elif $Info.visible:
		$Info.scale = Vector2(1, 1) / world.zoom
		label_container.get_node("VelocityInfoLabel").text = str(self.linear_velocity)
		label_container.get_node("PositionInfoLabel").text = str(self.position)
		label_container.get_node("MassInfoLabel").text = str(self.mass)
		label_container.get_node("RadiusLabel").text = str(self.radius)
		label_container.get_node("GravitationalRadiusLabel").text = str(self.gravitational_radius)


func update_mass():
	self.mass = mass_number * pow(10, mass_power)
	
	gravitational_radius = pow((world.gravitational_constant * mass) / gravitational_radius_threshold, 1.0/2.0)
	
	# Using volume of sphere formula
	radius = max(pow(((mass * 3) / (4 * PI)), 1.0/3.0) / density, 1)
	
	$CollisionShape2D.shape.radius = radius
	$MeshInstance2D.mesh.radius = radius
	$MeshInstance2D.mesh.height = radius * 2
	$HighLightArea/CollisionShape2D.shape.radius = radius + 50 / world.zoom
	$TouchingArea/CollisionShape2D.shape.radius = radius + 1
	$AreaOfInfulence/CollisionShape2D.shape.radius = gravitational_radius


func register_body(body):
	if body == self:
		return
	
	self.affecting_bodies.append(body)


func unregister_body(body):
	if body == self:
		return
	
	self.affecting_bodies.erase(body)


func add_touching_body(body):
	if body == self || self.get_instance_id() < body.get_instance_id():
		return
	
	self.touching_bodies.append(body)
	self.touching_bodies_time.append(Time.get_ticks_msec())


func remove_touching_body(body):
	var time_index = touching_bodies.find(body)
	
	self.touching_bodies.erase(body)
	self.touching_bodies_time.remove_at(time_index)


# Signal handling
func _on_gravitational_constant_changed():
	update_mass()


func _on_high_light_area_mouse_entered():
	if observer.edit:
		$Settings.visible = true
	else:
		$Info.visible = true


func _on_high_light_area_mouse_exited():
	$Settings.visible = false
	$Info.visible = false


func _on_mass_line_edit_text_submitted(new_text):
	mass_number = int(new_text)
	update_mass()


func _on_mass_power_line_edit_text_submitted(new_text):
	mass_power = int(new_text)
	update_mass()


func _on_area_of_infulence_body_entered(body):
	body.register_body(self)


func _on_area_of_infulence_body_exited(body):
	body.unregister_body(self)


func _on_touching_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	add_touching_body(body)


func _on_touching_area_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	remove_touching_body(body)


func _on_velocity_x_line_edit_text_submitted(new_text: String) -> void:
	self.linear_velocity.x = float(new_text)


func _on_velocity_y_line_edit_text_submitted(new_text: String) -> void:
	self.linear_velocity.y = float(new_text)
