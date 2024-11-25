extends Node2D

var gravitational_constant_default_number:float = 6.6743
var gravitational_constant_default_power:int = -11

var gravitational_constant: float

var time_scale: float = 1

var zoom: float = 1

var object_file = load("res://scenes/object.tscn")

signal Gravitational_Constant_Changed_Signal


func _ready():
	update_gravitational_constant(gravitational_constant_default_number, gravitational_constant_default_power)


func _process(delta):
	pass


func update_gravitational_constant(number, power):
	gravitational_constant = number * pow(10, power)
	Gravitational_Constant_Changed_Signal.emit()


func quit_request():
	self.get_tree().quit()


func create_object(object_position: Vector2, object_mass: float):
	print(object_mass)
	
	if object_mass < 0:
		object_mass = 5
	
	var new_object = object_file.instantiate()
	new_object.mass = object_mass
	new_object.position = object_position
	self.add_child(new_object)
