extends Node2D

var gravitational_constant_default_number:float = 6.6743
var gravitational_constant_default_power:int = -11

var gravitational_constant: float

var zoom: float = 1

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
