extends SpaceCraft

@onready var torpedo = load("res://Objects/torpedo.tscn") 

@onready var thrust_animation = $Thrust
@onready var engine_sprite = $Engine
@onready var target_sprite = $Target

@export var collected_coins := 0
var coins := 0
var income := 0
var coins_in_city := 0
@export var can_move = false

func _ready():
	super._ready()
	$Body.play()
	connect("torpedo_hit", _on_hit_by_torpedo)

func _physics_process(delta):
	super._physics_process(delta)
	if can_move:
		if Input.is_action_pressed("Thrust_P1"):
			thrust_animation.play("thrust")
			calculate_thrust_direction(engine_sprite, target_sprite)
			
		if Input.is_action_pressed("Left_P1"):
			rotation += -rotation_speed * delta
			
		if Input.is_action_pressed("Right_P1"):
			rotation += rotation_speed * delta
		
	#if Input.is_action_just_pressed("Fire_P1"):
		#fire("player_2")


func _on_hit_by_torpedo():
	$HitAnimation.play("hit")

func _unhandled_input(event):
	if Input.is_action_just_released("Thrust_P1"):
		thrust_animation.play("idle")


func _on_death_zone_body_entered(body):
	if body.is_in_group("player_2"):
		body.destroy()
		get_tree().call_group_flags(0, "player_1", "destroy")


func _on_death_zone_area_entered(area):
	if area.get_parent().name != "Castle":
		coins_in_city = area.get_parent().get_node("AnimatedSprite2D").frame
		if coins_in_city>0:
			$pickupCoinPlayer.play()
			income = min(5-coins, 3)
			coins += min(income,coins_in_city)
			area.get_parent().get_node("AnimatedSprite2D").frame -= min(income,coins_in_city)
	else:
		if coins>0:
			$discardCoinPlayer.play()
			collected_coins += coins
			$"../Coin6/Label".text = String.num_int64(collected_coins)
			coins = 0
		
	var mod1 :CanvasItem= $"../Coin"
	var mod2 :CanvasItem= $"../Coin2"
	var mod3 :CanvasItem= $"../Coin3"
	var mod4 :CanvasItem= $"../Coin4"
	var mod5 :CanvasItem= $"../Coin5"
		
	if coins == 0:
		mod1.modulate = Color(1,1,1,0.4)
		mod2.modulate = Color(1,1,1,0.4)
		mod3.modulate = Color(1,1,1,0.4)
		mod4.modulate = Color(1,1,1,0.4)
		mod5.modulate = Color(1,1,1,0.4)
	if coins > 0:
		mod1.modulate = Color(1,1,1,1)
	if coins > 1:
		mod2.modulate = Color(1,1,1,1)
	if coins > 2:
		mod3.modulate = Color(1,1,1,1)
	if coins > 3:
		mod4.modulate = Color(1,1,1,1)
	if coins > 4:
		mod5.modulate = Color(1,1,1,1)
		
