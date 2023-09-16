extends Area3D

@export_group("Target")
## Put your nodes here
@export var targetNode: Node3D = null

@export_group("Properties")
## Put your properties here
@export var curve := 1.0
@export var duration := 5.0

## Some states
var isTriggered := false
var s := 0.0

func _ready():
	$MeshInstance3D.queue_free()

func _process(delta):
	if isTriggered:
		s += delta / duration
		if s > 1:
			s = 1
			isTriggered = false
		else:
			## Do something with the node
			pass

func _on_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if s <= 0 and body != null:
		if body.name == "Player" and targetNode != null:
			s = 0
			isTriggered = true
