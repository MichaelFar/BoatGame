extends Node3D

@export var animationPlayer : AnimationPlayer

func _ready() -> void:
	animationPlayer.play("Sitting(2)")
