extends Camera2D

func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport_rect().size
	self.position = mouse_pos / viewport_size
