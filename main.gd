extends Node2D

@onready var map: Sprite2D = $Map
var village := preload("res://village.tscn")

var noise = FastNoiseLite.new()
var img := Image.create(image_size.x, image_size.y, false, image_format) 
var villages_array := Array()

const image_size := Vector2(1280, 720)
const image_format := Image.FORMAT_RGB8
const center := Vector2(640,360)

var color := Color.BLACK
var reds := 0

# Water and sand treshholds
const water = 0.75
const sand = 0.8

func _ready():
	# Noise Settings
	randomize()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_octaves = 1
	noise.fractal_gain = 1
	noise.frequency = 0.0035
	
	for x in range(0, image_size.x):
		for y in range(0, image_size.y):
			var noise_level = (noise.get_noise_2d(x, y) + 1) / 2
			if noise_level > 0.95:
				color = Color(1,0,0,1)
				
				# City Generator
				var too_close = false # CAN'T BUILD HERE
				if x<50 or x>1230 or y<50 or y > 670:
					too_close = true
				for item:Node2D in villages_array:
					if item.position.distance_to(Vector2(x,y))<200 or center.distance_to(Vector2(x,y))<300:
						too_close = true
				if !too_close:
					var instance_village = village.instantiate()
					add_child(instance_village)
					instance_village.position = Vector2(x,y)
					villages_array.append(instance_village)
					
			# Color picker
			color = Color(noise_level*0.2, noise_level*0.5, noise_level, 1)
			if noise_level<water: # Water
				color = Color(0.1,0.5,1,1)
			elif noise_level<sand: # Sand
				color = Color(0.95,0.90,0,1)
			else: # Land
				color = Color(0.3,1,0.5,1)
				
			# Draw Dragon's Island
			if Vector2(x,y).distance_to(center)<88:
				color = Color(0.95,0.90,0,1)
			if Vector2(x,y).distance_to(center)<80:
				color = Color(0.3,1,0.5,1)
			img.set_pixel(x, y, color)
			
	map.texture = ImageTexture.create_from_image(img)
	$"123".play()

func _process(_delta):
	$Label2.text = String.num($TimerGameOver.time_left,0)
	if $GameStart.time_left!=0:
		$GameStartLabel.text = String.num($GameStart.time_left+1,0)
	elif Input.is_action_pressed("escape"):
			$TimerGameOver.stop()
			_on_timer_game_over_timeout()

func _on_spawn_coin_timer_timeout():
	var village_to_recieve_a_coin = villages_array[randi_range(0,villages_array.size()-1)].get_node("AnimatedSprite2D")
	village_to_recieve_a_coin.frame += 1 
	$Map/SpawnCoinTimer.start()


func _on_timer_game_over_timeout():
	$Player1Craft.can_move = false
	$GameStartLabel.visible = true
	$GameStartLabel.text = "Time's up!\nYour score: " + String.num_int64($Player1Craft.collected_coins) + "\nTry Again?"
	$Panel.visible=true
	$Restart.visible=true
	$Back.visible=true
	$music.stop()
	$timesupPlayer.play()

func _on_game_start_timeout():
	$Player1Craft.can_move = true
	$TimerGameOver.start()
	$GameStartLabel.visible = false
	$music.play()


func _on_restart_pressed():
	$ButtonSEPlayer.play()
	get_tree().reload_current_scene()


func _on_back_pressed():
	$ButtonSEPlayer.play()
	if get_tree():
		get_tree().change_scene_to_file("res://menu.tscn")


func _on_music_finished():
	$music.play()
