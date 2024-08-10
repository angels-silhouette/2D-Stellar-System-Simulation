extends Node2D

var velocity: Vector2
var velocity_damp: float = 0.9
var velocity_speed: int = 1000

var zoom_speed: float = 1.5

var camera: Camera2D

var world: Node2D

var edit:bool = false
var create:bool = false
var world_settings_visible:bool = false

var world_settings_panel:VBoxContainer
var gravitational_constant_number_line_edit: LineEdit
var gravitational_constant_power_line_edit: LineEdit

var gravitational_constant_number: float
var gravitational_constant_power: int

var object_file = load("res://scenes/object.tscn")

func _ready():
	world = self.get_parent()
	world_settings_panel = self.get_node("CanvasLayer/UI/MarginContainer/VBoxContainer/WorldSettingsPanel")
	gravitational_constant_number_line_edit = self.get_node("CanvasLayer/UI/MarginContainer/VBoxContainer/WorldSettingsPanel/GravitationalConstant/GravitationalConstantNumberLineEdit")
	gravitational_constant_power_line_edit = self.get_node("CanvasLayer/UI/MarginContainer/VBoxContainer/WorldSettingsPanel/GravitationalConstant/GracitationalConstantPowerLineEdit")
	camera = self.get_node("Camera2D")
	gravitational_constant_number = world.gravitational_constant_default_number
	gravitational_constant_power = world.gravitational_constant_default_power


func _process(delta):
	self.velocity *= velocity_damp
	
	if self.velocity.length() < 0.001:
		self.velocity = Vector2()
	
	self.position += self.velocity * delta


func _input(event):
	if event.is_action_pressed("up", true):
		self.velocity.y -= velocity_speed / world.zoom
	if event.is_action_pressed("down", true):
		self.velocity.y += velocity_speed / world.zoom
	if event.is_action_pressed("left", true):
		self.velocity.x -= velocity_speed / world.zoom
	if event.is_action_pressed("right", true):
		self.velocity.x += velocity_speed / world.zoom
	if event.is_action_pressed("in", true):
		camera.zoom *= zoom_speed
		world.zoom *= zoom_speed
	if event.is_action_pressed("out", true):
		camera.zoom *= 1/zoom_speed
		world.zoom *= 1/zoom_speed
	
	if event is InputEventMouseButton && create && event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT:
		var object = object_file.instantiate()
		object.position = self.position - (get_viewport().get_visible_rect().size / 2) + (event.position / camera.zoom)
		world.add_child(object)
	
	if event.is_action_pressed("ui_cancel"):
		edit = false
		create = false


func _on_quit_button_pressed():
	world.quit_request()


func _on_edit_button_pressed():
	edit = !edit


func _on_create_button_pressed():
	create = !create


func _on_world_settings_button_pressed():
	world_settings_visible = !world_settings_visible
	world_settings_panel.visible = world_settings_visible


func _on_gravitational_constant_number_line_edit_text_submitted(new_text):
	gravitational_constant_number = float(new_text)
	world.update_gravitational_constant(gravitational_constant_number, gravitational_constant_power)


func _on_gravitational_constant_power_line_edit_text_submitted(new_text):
	gravitational_constant_power = int(new_text)
	world.update_gravitational_constant(gravitational_constant_number, gravitational_constant_power)


func _on_gravitational_constant_reset_button_pressed():
	gravitational_constant_number_line_edit.text = str(world.gravitational_constant_default_number)
	gravitational_constant_power_line_edit.text = str(world.gravitational_constant_default_power)


func _on_back_to_origin_button_pressed():
	self.position = Vector2()
	camera.zoom = Vector2(1, 1)
	world.zoom = 1
