extends Camera2D

func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	self.position = mouse_pos
