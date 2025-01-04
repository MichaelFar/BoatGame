extends CharacterBody3D

@export var cameraRotator : Node3D

@export var boatMesh : Node3D

@export var camera : Camera3D

@export var animationPlayer : AnimationPlayer

@export var particleContainer : Node3D

@export var fishSpawnLocation : Marker3D

@export var debugFishScene : PackedScene

var speed := 250

var previousRotationCoefficient := 0.0

var rotationTracker : float :
	
	set(value):
		
		if(value != rotationTracker):
			
			emitParticleChildren(true)
		
		rotationTracker = value

var acceleration := 0.0

var rotationAmount := 0.0

var globalDelta : float

var rotationAlpha := 0.0

var tweenReference : Tween

var accelerationAlpha : float :
	
	set(value):
		
		if(value > 0):
		
			emitParticleChildren(true)
		
		else:

			emitParticleChildren(false)

		accelerationAlpha = value
		
func _ready():
	
	accelerationAlpha = 0
	
	animationPlayer.play("boat_movement")
	
func _physics_process(delta: float) -> void:
	
	movement(delta)
	
	print("Frame rate is " + str(1/delta))
	
	move_and_slide()
	
func movement(delta):
	
	var rotationCoefficient := 0.0
	
	rotationCoefficient = (Input.get_action_strength("TurnLeft")  * -1) + (Input.get_action_strength("TurnRight"))
	
	var zDirection = boatMesh.global_transform.basis.z
	
	rotation.y += delta * (Input.get_action_strength("TurnLeft") + Input.get_action_strength("TurnRight") * -1) 
	
	acceleration = lerpf(0, speed, accelerationAlpha)
	
	rotationAmount = lerpf(0, 7, rotationAlpha)
	
	accelerationAlpha += (delta * ((Input.get_action_strength("MoveForward") * 2) - 1)) / 3
	
	if(rotationCoefficient != 0):
		
		if(tweenReference != null):
			
			tweenReference.stop()
			
		rotationAlpha += delta * (rotationCoefficient)
		rotationAlpha = clampf(rotationAlpha, minf(rotationCoefficient, rotationCoefficient * -1) , maxf(rotationCoefficient, rotationCoefficient * -1))
		previousRotationCoefficient = rotationCoefficient
	
	elif(Input.is_action_just_released("TurnLeft") || Input.is_action_just_released("TurnRight")):
		
		var tween := get_tree().create_tween()
		tween.tween_property(self, "rotationAlpha", 0, abs(rotationAlpha * 2)).set_trans(Tween.TRANS_CIRC)
		tweenReference = tween
	
	if(Input.is_action_just_released("DebugSpawnFish")):
		var fishScene = debugFishScene.instantiate()
		add_child(fishScene)
		fishScene.global_position = fishSpawnLocation.global_position
		
	
	accelerationAlpha = clampf(accelerationAlpha, 0, 1)
	
	boatMesh.rotation_degrees.z = rotationAmount
	
	velocity = zDirection * (acceleration) * delta
	
	cameraRotator.global_position = global_position
	#velocity.y = get_gravity().y
	
	rotationTracker = rotation.y
	
	globalDelta = delta
	
func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		 
		if(Input.is_action_pressed("RotateCamera")):
			
			cameraRotator.rotation.y -= event.screen_relative.x * globalDelta
			cameraRotator.rotation.x += event.screen_relative.y * globalDelta
			cameraRotator.rotation.x = clampf(cameraRotator.rotation.x, 0, PI / 2)
	
func emitParticleChildren(new_value : bool):
	for i in particleContainer.get_children():
		i.emitting = new_value
		
