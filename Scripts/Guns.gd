extends Node2D

@export var muzzle_flash: AnimatedSprite2D
@export var max_ammo: int = 6
@export var reload_time: float = 1.5

var current_ammo: int = max_ammo
var is_reloading: bool = false

var ammo_label: Label


func _ready() -> void:
	muzzle_flash.play("default")
	if muzzle_flash:
		muzzle_flash.animation_finished.connect(_on_muzzle_flash_finished)
	
	ammo_label = Label.new()
	ammo_label.text = "Ammo: %d / %d" % [current_ammo, max_ammo]
	ammo_label.position = Vector2(20, 20)
	ammo_label.set("theme_override_colors/font_color", Color.WHITE)
	
	# Try to add to CanvasLayer named "UI" if it exists, else add to scene root
	var ui_layer = null
	if get_tree().current_scene.has_node("UI"):
		ui_layer = get_tree().current_scene.get_node("UI")
	else:
		ui_layer = get_tree().current_scene
	ui_layer.add_child(ammo_label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("mouse_left"):
		if not is_reloading and current_ammo > 0:
			muzzle_flash.play("flash")
			shoot_ray()
			current_ammo -= 1
			update_ammo_label()
		elif is_reloading:
			print("Reloading...")
		elif current_ammo == 0:
			print("Out of ammo! Press reload to reload.")
	
	if Input.is_action_just_pressed("reload"):
		if not is_reloading and current_ammo < max_ammo:
			start_reload()


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
    query.exclude = [self]

    var result = space_state.intersect_ray(query)
    if result:
        var collider = result.collider
        print("Ray hit: ", collider, " at ", result.position)

        # Walk up the node tree to find a node that can take damage (has take_damage or Health)
        var target := _find_damageable(collider)
        if target:
            var damage := 10
            if target.has_method("take_damage"):
                target.take_damage(damage)
                print("Dealt ", damage, " to ", target)
            elif target.get("Health", null) != null:
                target.Health -= damage
                print("Dealt ", damage, " to ", target, " — Health now: ", target.Health)
                if target.Health <= 0:
                    target.queue_free()
        else:
            print("Hit non-enemy or no damageable parent found: ", collider)
    else:
        print("No hit")
    
    await get_tree().create_timer(0.25).timeout
    muzzle_flash.stop()
    muzzle_flash.play("default")


# helper: climb parents to find a node with take_damage() or Health property
func _find_damageable(node: Node) -> Node:
    var cur := node
    while cur:
        # prefer explicit method
        if cur.has_method("take_damage"):
            return cur
        # fallback to Health property
        # use get() safely; if it returns null this likely isn't the Health property (Health is int)
        var val := null
        # try/catch in case get() raises — Godot's get returns null if missing, but be safe
        if cur.get_type() != "":
            val = cur.get("Health")
        if val != null:
            return cur
        cur = cur.get_parent()
    return null


func start_reload():
	is_reloading = true
	print("Reloading...")
	await get_tree().create_timer(reload_time).timeout
	current_ammo = max_ammo
	is_reloading = false
	update_ammo_label()
	print("Reloaded! Ammo:", current_ammo, "/", max_ammo)


func update_ammo_label():
	if ammo_label:
		ammo_label.text = "Ammo: %d / %d" % [current_ammo, max_ammo]
