extends Area3D

@export_group("Target")
@export var cameraPivot: Node3D = null

@export_group("Properties")
@export var rotationAxis: Vector3 = Vector3(45, 45, 0)
@export var distance := 20.0
@export var curve := 1.0
@export var duration := 5.0

var isTriggered := false
var sv := Vector3(0, 0, 0)
var sd := 0.0
var s := 0.0

func _ready():
	if cameraPivot == null:
		cameraPivot = get_node("../../CameraPivot")
	$MeshInstance3D.queue_free()

func _process(delta):
	if isTriggered:
		s += delta / duration
		if s > 1:
			s = 1
			isTriggered = false
		else:
			cameraPivot.rotationAxis = lerp(sv, rotationAxis, ease(s, curve))
			cameraPivot.distance = lerp(sd, distance, ease(s, curve))

func _on_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if s <= 0 and body != null:
		if body.name == "Player" and cameraPivot != null:
			s = 0
			sv = cameraPivot.rotationAxis
			sd = cameraPivot.distance
			isTriggered = true
