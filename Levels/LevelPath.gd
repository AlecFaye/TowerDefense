class_name LevelPath
extends Node2D

export (bool) var is_active = true


func activate() -> void:
	is_active = true


func deactivate() -> void:
	is_active = false
