extends CharacterBody2D


var SPEED = 300.0
const JUMP_VELOCITY = -400.0
var speedbuff = 0.0
var healthbuff = 0.0
var jumpbuff = 0.0
var Health = 100


func _physics_process(delta: float) -> void:

	if Health <= 0:
		queue_free()
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY + jumpbuff

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x := Input.get_axis("left", "right")
	if direction_x:
		velocity.x = direction_x * (SPEED + speedbuff)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	
	look_at_mouse(delta)
	move_and_slide()

func look_at_mouse(delta):
	var child = get_node("Hand")
	child.look_at(get_global_mouse_position())
	
	
