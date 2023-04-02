extends TextureProgressBar


func health_update(health: float) -> void:
	value = health * 33.3333
