@tool
extends CharacterBody3D

signal on_line_start
signal on_line_reset

@export_group("Nodes")
@export var source: AudioStreamPlayer = null
@export var camera: Node3D = null
@export var tailParent: Node3D = null
@export var tail: PackedScene = load("res://Objects/Tail.tscn")
@export var diePiece: PackedScene = load("res://Objects/DiePiece.tscn")

@export_group("Properties")
@export var color : Color : set = set_color, get = get_color
@export var rotations: Array[Vector3] = [Vector3(0, 0, 0), Vector3(0, 90, 0)]
@export var rotationIndex := 0
@export var speed := 5.0

var meshInstance: MeshInstance3D = null

var tails: Array[Node3D] = []
var currentTail: Node3D = null

var isStarted := false
var isAlive := true
var isGrounded := true
var wasFlying := false
var isHoveringUI := false

var customVelocity: float = 0

func _ready():
	if meshInstance == null:
		meshInstance = $MeshInstance3D

func _process(delta):
	if not Engine.is_editor_hint():
		if isAlive:
			if isGrounded:
				if Input.is_action_just_pressed("line_turn") or (Input.is_action_just_pressed("line_touch") and !isHoveringUI):
					turn_line()
			if isStarted:
				translate_line(delta)
				if isGrounded:
					translate_tail(delta)
					if wasFlying:
						create_tail()
						wasFlying = false
				else:
					wasFlying = true
		if Input.is_action_just_pressed("line_restart"):
			get_tree().reload_current_scene()

func reset_line():
	for tail in tails:
		tailParent.remove_child(tail)
		tail.free()
	tails = []
	transform.origin = Vector3(0, 0, 0)
	
	isStarted = false
	isAlive = true
	isGrounded = true
	wasFlying = false

	customVelocity = 0

func _physics_process(delta):
	if not Engine.is_editor_hint():
		isGrounded = is_grounded()
		if isGrounded:
			customVelocity = 0
		else:
			customVelocity += -9.81 * delta
		velocity = Vector3(0, customVelocity , 0)
		move_and_slide()

func is_grounded():
	var space_state = get_world_3d().direct_space_state
	var start = transform.origin
	var end = start + Vector3.DOWN * 0.53
	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	var hit = result.get("rid")
	return hit != null

func turn_line():
	if isStarted:
		rotationIndex += 1
		if rotationIndex >= len(rotations):
			rotationIndex = 0
	else:
		rotationIndex = 0
		source.play(0)
		on_line_start.emit()
		isStarted = true
	rotate_base()
	create_tail()
	
func rotate_base():
	rotation_degrees = rotations[rotationIndex]

func create_tail():
	var instance: Node3D = tail.instantiate()
	instance.position = position
	instance.transform.basis = transform.basis
	instance.scale = scale
	currentTail = instance
	tails.append(instance)
	tailParent.add_child(instance)

func translate_line(delta: float):
	position += transform.basis.z * delta * speed

func translate_tail(delta: float):
	if currentTail != null:
		var tailDelta = Vector3(0, 0, delta * speed)
		currentTail.scale += tailDelta
		currentTail.position += transform.basis.z / 2 * delta * speed

# UI
func _on_main_game_ui_mouse_entered():
	isHoveringUI = false

func _on_main_game_ui_mouse_exited():
	isHoveringUI = true

# Setters and getters
func set_color(value: Color):
	if meshInstance != null:
		meshInstance.get_active_material(0).albedo_color = value

func get_color() -> Color:
	if meshInstance != null:
		return meshInstance.get_active_material(0).albedo_color
	return Color(0, 0, 0)

func _on_obstacle_finder_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body != null:
		print(body.name)
		if body.name == "Obstacle_":
			die()

func die():
	if isAlive:
		for i in 3:
			create_die_piece(rand_on_unit_circle())
		isAlive = false

func create_die_piece(offset):
	var instance: RigidBody3D = diePiece.instantiate()
	instance.position = position + offset
	instance.transform.basis = transform.basis
	instance.scale = scale
	tails.append(instance)
	tailParent.add_child(instance)

func rand_on_unit_circle():
	return Vector3(randf_range(-1.0, 1.0), randf_range(0.0, 1.0), randf_range(-1.0, 1.0))
