extends Node3D

@export var target: Node3D = null

@export var rotationAxis := Vector3(45, 45, 0)
@export var pivotOffset := Vector3(0, 0, 0)
@export var followSpeed := 2.0
@export var distance := 10.0

func _ready():
	if target == null:
		target = get_node("../Essential/Player")

func _process(delta):
	if(target != null):
		$Camera3D.transform.origin = Vector3(0, 0, distance)
		rotation_degrees = Vector3(-rotationAxis.x, -rotationAxis.y -90, -rotationAxis.z)
		transform.origin = lerp(transform.origin, target.transform.origin + pivotOffset, delta * followSpeed)
