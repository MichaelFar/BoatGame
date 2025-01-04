extends Node2D
#I've decided that each minigame contains its own logic for how it works,
#we will not be making a complex system where we utilize multiple components to describe a minigame, as cool as that sounds
@export var targetScene : PackedScene

@export var playerPath : Path2D

@export var targetPath : Path2D

@export var playerPathFollow : PathFollow2D

@export var scoreLabel : Label

@export var targetScore : int

@export var attempts : int

var currentTarget = null

var playerInTargetZone := false

var successfulHits : int :
	
	set(value):
		
		successfulHits = value
		
		if(successfulHits == targetScore):
			
			completed_minigame.emit()
		
		updateScore()

var missedHits : int :
	
	set(value):
		
		missedHits = value
		
		if(missedHits == attempts):
			
			failed_minigame.emit()
			
		updateScore()

signal completed_minigame

signal failed_minigame

func _ready():
	
	successfulHits = 0
	missedHits = 0
	spawnTarget()
	tweenPlayerPath(1)
	
func _process(delta: float) -> void:
	
	if(Input.is_action_just_pressed("ui_accept") && playerInTargetZone):
		
		currentTarget.queue_free()
		
		spawnTarget()
		
		successfulHits += 1
		
	elif(Input.is_action_just_pressed("ui_accept")):
		
		missedHits += 1
		

func spawnTarget():
	
	var target_object := targetScene.instantiate()
	
	var rand_obj := RandomNumberGenerator.new()
	
	targetPath.add_child(target_object)
	
	target_object.global_position = targetPath.curve.get_point_position(0)
	print("Spawned target")
	target_object.progress_ratio = rand_obj.randf_range(0, 1)

func tweenPlayerPath(direction : float):
	
	var tween = get_tree().create_tween()
	var clamped_direction = clampf(direction, 0, 1)
	tween.tween_property(playerPathFollow, "progress_ratio", clamped_direction, 1)
	
	tween.finished.connect(tweenPlayerPath.bind(direction * -1))

func updateScore():
	
	scoreLabel.text = "Hit: " + str(successfulHits) + " Missed: " + str(missedHits) + "\nTarget: " + str(targetScore) + "\nTries: " + str(targetScore - missedHits) 

func _on_area_2d_area_entered(area: Area2D) -> void:
	
	print("Entered Area")
	playerInTargetZone = true
	currentTarget = area.owner

func _on_area_2d_area_exited(area: Area2D) -> void:
	print("Exited Area")
	playerInTargetZone = false
	currentTarget = null
