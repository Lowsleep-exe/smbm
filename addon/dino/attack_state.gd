extends NodeState

@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D
@export var speed : int
@export var jump_velocity : float = -400.0      # How fast the character jumps upward (negative for up)
@export var jump_check_distance : float = 32.0  # How far ahead to check for obstacles (pixels)
@export var jump_height : float = 48.0          # How high to check for clear space above obstacle (pixels)

var player : CharacterBody2D
var max_speed : int

func on_process(delta : float):
	pass


func on_physics_process(delta : float):
	var direction : int
	
	if character_body_2d.global_position > player.global_position:
		animated_sprite_2d.flip_h = true
		direction = -1
	elif character_body_2d.global_position < player.global_position:
		animated_sprite_2d.flip_h = false
		direction = 1
	
	animated_sprite_2d.play("attack")
	
	character_body_2d.velocity.x += direction * speed * delta
	character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -max_speed, max_speed)

	# Check for obstacle ahead
	if can_jump_over_block(direction):
		if character_body_2d.is_on_floor():
			character_body_2d.velocity.y = jump_velocity

	character_body_2d.move_and_slide()


func can_jump_over_block(direction: int) -> bool:
	var space_state = character_body_2d.get_world_2d().direct_space_state
	var start_pos = character_body_2d.global_position
	var end_pos = start_pos + Vector2(jump_check_distance * direction, 0)
	
	# Raycast forward to check for obstacle
	var ray_params := PhysicsRayQueryParameters2D.new()
	ray_params.from = start_pos
	ray_params.to = end_pos
	ray_params.exclude = [character_body_2d]
	var result = space_state.intersect_ray(ray_params)
	if result:
		# If obstacle detected, check if space above is clear
		var above_start = result.position
		var above_end = above_start + Vector2(0, -jump_height)
		var above_ray_params := PhysicsRayQueryParameters2D.new()
		above_ray_params.from = above_start
		above_ray_params.to = above_end
		above_ray_params.exclude = [character_body_2d]
		var above_result = space_state.intersect_ray(above_ray_params)
		return not above_result # True if space above is clear
	return false


func enter():
	player = get_tree().get_nodes_in_group("Player")[0] as CharacterBody2D
	max_speed = speed + 20


func exit():
	pass

