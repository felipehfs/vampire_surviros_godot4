extends CharacterBody2D

@export var movement_speed = 20.0
var hp = 10
@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@export var knockback_recovery = 1.5
@onready var sound_hit = $SoundHit
@onready var sprite = $Sprite2D
@onready var experience = 1

var knockback = Vector2.ZERO
var death_animation = preload("res://Scenes/explosion.tscn")
var exp_gem = preload("res://Objects/experience_gem.tscn")

signal remove_from_array(object)

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction  = global_position.direction_to(player.global_position)
	
	if direction.x > 0:
		$Sprite2D.flip_h = true
	elif direction.x < 0:
		$Sprite2D.flip_h = false
		
	if direction != Vector2.ZERO:
		$AnimationPlayer.play("walk")
	else:
		$AnimationPlayer.stop()
	
	velocity = direction * movement_speed
	velocity += knockback
	move_and_slide()

func death():
	emit_signal("remove_from_array", self)
	var enemy_death = death_animation.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	queue_free()

func _on_hurt_box_hurt(damage, angle, knowback_amount):
	hp -= damage
	knockback = angle * knowback_amount
	if hp <= 0:
		death()
	else:
		sound_hit.play()
