extends Control

@export_group("Scene")
@export var player: Node3D = null

@export_group("UI")
@export var startupPanel: Control = null
@export var checkpointPanel: Control = null
@export var diePanel: Control = null

func on_start_pressed():
	player.turn_line()

func hide_ui():
	startupPanel.visible = false
