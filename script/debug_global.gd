extends Node

func _process(delta: float) -> void:
	
	if(Input.is_action_just_released("escape")):
		
		get_tree().quit()
