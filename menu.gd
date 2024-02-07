extends Node2D

var village := preload("res://village.tscn")
var noise = FastNoiseLite.new()
var villages_array := Array()

const center := Vector2(640,360)
var color := Color.BLACK
var reds := 0
var y_offset := 0

var img : Image
const image_format := Image.FORMAT_RGB8
const image_size : Vector2 = Vector2(1280,720)

# Water and sand treshholds
const water = 0.75
const sand = 0.8

func draw_map():
	img = Image.create(image_size.x, image_size.y, false, image_format) 
	var map_instance := $Map.duplicate()
	add_child(map_instance)
	map_instance.position = Vector2(0, y_offset*720)
	for x in range(0, image_size.x):
		for y in range(0, image_size.y):
			var noise_level = (noise.get_noise_2d(x, y+(y_offset*720)) + 1) / 2
			if noise_level > 0.95:
				color = Color(1,0,0,1)
				
				# City Generator
				var too_close = false # CAN'T BUILD HERE
				if x<50 or x>1230:
					too_close = true
				for item:Node2D in villages_array:
					if item.position.distance_to(Vector2(x,y+(y_offset*720)))<200 or center.distance_to(Vector2(x,y+(y_offset*720)))<300:
						too_close = true
				if !too_close:
					var instance_village = village.instantiate()
					add_child(instance_village)
					instance_village.position = Vector2(x,y+(y_offset*720))
					villages_array.append(instance_village)
					
			# Color picker
			color = Color(noise_level*0.2, noise_level*0.5, noise_level, 1)
			if noise_level<water: # Water
				color = Color(0.1,0.5,1,1)
			elif noise_level<sand: # Sand
				color = Color(0.95,0.90,0,1)
			else: # Land
				color = Color(0.3,1,0.5,1)
			img.set_pixel(x, y, color)
	map_instance.texture = ImageTexture.create_from_image(img)
	y_offset += 1

func _ready():
	$menuMusicPlayer.play()
	# Noise Settings
	randomize()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_octaves = 1
	noise.fractal_gain = 1
	noise.frequency = 0.0035
	#Map Drawer
	draw_map()
	draw_map()

func _process(_delta):
	if Input.is_action_pressed("start"):
		_on_play_pressed()
		
	position.y -= 1
	$BoxContainer.position.y += 1
	if position.y < ((y_offset-1)*720)*-1:
		draw_map()
		
func _on_spawn_coin_timer_timeout():
	var village_to_recieve_a_coin = villages_array[randi_range(0,villages_array.size()-1)].get_node("AnimatedSprite2D")
	village_to_recieve_a_coin.frame += 1 
	$Map/SpawnCoinTimer.start()


func _on_timer_game_over_timeout():
	pass


func _on_play_pressed():
	$start.play()      
	get_tree().change_scene_to_file("res://main.tscn")
