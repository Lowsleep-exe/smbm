extends CharacterBody2D

@export var Health: int = 100
signal died

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func take_damage(amount: int) -> void:
    Health -= amount
    print("Took ", amount, " damage. Health:", Health)
    if Health <= 0:
        die()

func die() -> void:
    emit_signal("died")
    queue_free()

