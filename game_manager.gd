extends Node

enum game_phases {MENU, GAME_RUNNING, GAME_ENDING}
enum seasons {SPRING, SUMMER, FALL, WINTER}
enum {SUNNY, CLOUDY, RAIN, ACID_RAIN}

var game_phase = game_phases.MENU

var season = seasons.SPRING
var weather = SUNNY

const c_spring = 0
const c_summer = 90
const c_fall = 180
const c_winter = 270

var game
var field
var drone
var silo
var swarms
var wheel

var day = 0
var time_speed = 0.8

var swarm_spawn_counter
const swarm_spawn_rand = 5

const wave_counter_min = 10
const wave_counter_rand = 30
const wave_duration = 15

var wave_counter = 0

const swarm_scene = preload("res://Scenes/swarm.tscn")

const rain_duration = 5
var rain_counter = 0

var weather_min = 10
var weather_max = 60
var weather_counter = 0

func start_game(game = null):
	
	if game != null:
		self.game = game

	game_phase = game_phases.GAME_RUNNING
	
	wheel.connect("sig_rain", self, "set_rain")
	wheel.connect("sig_acid_rain", self, "set_acid_rain")
	
	swarm_spawn_counter = 0
	weather_counter = 0
	wave_counter = 0
	day = 0
	
	_schedule_next_swarm()
	
	set_weather(SUNNY)
	
	get_tree().paused = false
	
func spin_wheel():
	
	wheel.spin()

func set_rain():
	
	set_weather(RAIN)
	
func set_acid_rain():
	
	set_weather(ACID_RAIN)
	
func _schedule_next_swarm():
	
	swarm_spawn_counter = randf() * swarm_spawn_rand
	
func _spawn_swarm():
	
	var spawns = swarms.get_node("Spawns")
	
	var spawn = spawns.get_child(randi() % spawns.get_child_count())
	
	var swarm = swarm_scene.instance()
	
	swarm.global_position = spawn.global_position
	swarms.add_child(swarm)
	
func get_swarm_escape():
	
	var escape_node = swarms.get_node("Escape")
	
	return escape_node.get_child(randi() % escape_node.get_child_count())
	
func is_raining():
	
	return weather == RAIN or weather == ACID_RAIN
	
func is_acid_raining():
	
	return weather == ACID_RAIN
	
func set_weather(new_weather):
	
	if new_weather == RAIN or new_weather == ACID_RAIN:
		
		if weather == SUNNY:
			game.set_cloudy()
			
		if new_weather == RAIN:
			weather_counter = game.set_rain()
		else:
			weather_counter = game.set_acid_rain()
		
	else:
		
		if new_weather == SUNNY:
			game.set_sunny()
		elif new_weather == CLOUDY:
			game.set_cloudy()
			
		weather_counter = weather_min + randf() * (weather_max - weather_min)
			
	weather = new_weather
	
func _physics_process(delta):
	
	if game_phase == game_phases.GAME_RUNNING:
		
		if day >= 35: #season != seasons.SPRING:
			
			wave_counter -= delta
			if wave_counter <= 0:
				
				if wave_counter <= -wave_duration:
					wave_counter = wave_counter_min + randf() * wave_counter_rand
			
				swarm_spawn_counter -= delta
				if swarm_spawn_counter <= 0:
					_spawn_swarm()
					_schedule_next_swarm()
		
		if silo.level == silo.level_max:
#			print("GOOD JOB!")
			game_phase = game_phases.GAME_ENDING
			game.show_victory()
		
		day += time_speed * delta
		
		silo.set_day(day)
		
		if day >= c_winter:
			season = seasons.WINTER
		elif day >= c_fall:
			season = seasons.FALL
		elif day >= c_summer:
			season = seasons.SUMMER
		else:
			season = seasons.SPRING

		if day >= c_winter:
#			print("ITS WINTER, GAME OVER")
			game.show_defeat()
			game_phase = game_phases.GAME_ENDING

		weather_counter -= delta
		
		if weather_counter <= 0:
			if weather == SUNNY:
				set_weather(CLOUDY)
			else:
				set_weather(SUNNY)
