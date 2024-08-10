extends RigidBody2D

var affecting_bodies: Array

var radius: float
var gravitational_radius: float
var gravitational_radius_threshold: float = 0.001
var density: int = 100
var mass_number:int = 5
var mass_power:int = 0

var collision_shape: CollisionShape2D
var mesh: MeshInstance2D
var area_of_influence: CollisionShape2D
var highlight_area: CollisionShape2D

var settings_panel: Control
var info_panel: Control

var observer: Node2D
var world: Node2D

var editing_velocity:bool = false
var editing_velocity_points_count: int = 0
var editing_velocity_array:PackedVector2Array = PackedVector2Array()
var editing_velocity_reference_point: Vector2

# Node
func _ready():
	# UI children
	settings_panel = $Settings
	info_panel = $Info
	
	# Object children
	collision_shape = $CollisionShape2D
	mesh = $MeshInstance2D
	area_of_influence = $AreaOfInfulence/CollisionShape2D
	highlight_area = $HighLightArea/CollisionShape2D
	
	# Observer and world
	observer = self.get_parent().get_child(0)
	world = self.get_parent()
	
	# Signals
	world.Gravitational_Constant_Changed_Signal.connect(_on_gravitational_constant_changed)
	
	update_mass()


func _process(delta):
	update_labels()


func _physics_process(delta):
	for body in affecting_bodies:
		var vector_to_body = body.position - position
		var radius_squared: float = pow((vector_to_body.x), 2) + pow((vector_to_body.y), 2)
		var force: float = (world.gravitational_constant * mass * body.mass) / radius_squared
		self.apply_force(vector_to_body.normalized() * force)


func _unhandled_input(event):
	if editing_velocity == false || editing_velocity_points_count == 2:
		return
	
	if event.is_pressed():
		editing_velocity_array.append(event.position - editing_velocity_reference_point)
		editing_velocity_points_count += 1
		
		if editing_velocity_points_count == 2:
			editing_velocity = false
			editing_velocity_points_count = 0
			self.linear_velocity = Vector2(editing_velocity_array[1] - editing_velocity_array[0])
			editing_velocity_array.clear()


# Functions
func update_labels():
	if settings_panel.visible:
		settings_panel.scale = Vector2(1, 1) / world.zoom
		self.get_node("Settings/MarginContainer/GridContainer/HBoxContainer/MassLineEdit").placeholder_text = str(mass_number)
		self.get_node("Settings/MarginContainer/GridContainer/HBoxContainer/MassPowerLineEdit").placeholder_text = str(mass_power)
	elif info_panel.visible:
		info_panel.scale = Vector2(1, 1) / world.zoom
		self.get_node("Info/MarginContainer/GridContainer/VelocityInfoLabel").text = str(self.linear_velocity)
		self.get_node("Info/MarginContainer/GridContainer/PositionInfoLabel").text = str(self.position)
		self.get_node("Info/MarginContainer/GridContainer/MassInfoLabel").text = str(self.mass)
		self.get_node("Info/MarginContainer/GridContainer/RadiusLabel").text = str(self.radius)
		self.get_node("Info/MarginContainer/GridContainer/GravitationalRadiusLabel").text = str(self.gravitational_radius)


func update_mass():
	mass = mass_number * pow(10, mass_power)
	
	gravitational_radius = pow((world.gravitational_constant * mass) / gravitational_radius_threshold, 1.0/2.0)
	
	radius = max(pow(((mass * 3) / (4 * PI)), 1.0/3.0) / density, 1)
	
	collision_shape.shape.radius = radius
	mesh.mesh.radius = radius
	mesh.mesh.height = radius * 2
	highlight_area.shape.radius = radius + 50 / world.zoom
	area_of_influence.shape.radius = gravitational_radius


func register_body(body):
	if body == self:
		return
	
	self.affecting_bodies.append(body)


func unregister_body(body):
	if body == self:
		return
	
	self.affecting_bodies.erase(body)


# Signal handling
func _on_gravitational_constant_changed():
	update_mass()


func _on_high_light_area_mouse_entered():
	if observer.edit:
		settings_panel.visible = true
	else:
		info_panel.visible = true


func _on_high_light_area_mouse_exited():
	settings_panel.visible = false
	info_panel.visible = false


func _on_mass_line_edit_text_submitted(new_text):
	mass_number = int(new_text)
	update_mass()


func _on_mass_power_line_edit_text_submitted(new_text):
	mass_power = int(new_text)
	update_mass()


func _on_change_velocity_button_pressed():
	editing_velocity = true
	editing_velocity_reference_point = self.position


func _on_area_of_infulence_body_entered(body):
	body.register_body(self)


func _on_area_of_infulence_body_exited(body):
	body.unregister_body(self)
