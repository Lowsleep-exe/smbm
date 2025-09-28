extends Node2D

@export var muzzle_flash: AnimatedSprite2D


func _ready() -> void:
	muzzle_flash.play("default")
	if muzzle_flash:
		muzzle_flash.animation_finished.connect(_on_muzzle_flash_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("mouse_left"):
		muzzle_flash.play("flash")
		shoot_ray()

func _on_muzzle_flash_finished():
	# Set to default frame (usually frame 0)
	muzzle_flash.stop()
	muzzle_flash.play("default")

func shoot_ray():
	var start_pos = global_position
	var end_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.new()
	query.from = start_pos
	query.to = end_pos
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)
	if result:
		var collider = result.collider
		if collider.is_in_group("Enemy"):
			print("Hit enemy at: ", result.position)
		else:
			print("Hit non-enemy: ", collider)
	else:
		print("No hit")
	
	await get_tree().create_timer(0.25).timeout
	muzzle_flash.stop()
	muzzle_flash.play("default")
