extends Node2D

func multiply_base_speed(multiplier: float) -> void:
	for node in get_children():
		node.multiply_base_speed(multiplier)
