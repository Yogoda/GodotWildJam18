extends Node

enum game_phases {MENU, GAME_RUNNING, GAME_ENDING}
enum seasons {SPRING, SUMMER, FALL, WINTER}
enum weathers {SUNNY, CLOUDY, RAIN}

var game_phase = game_phases.MENU

var season = seasons.SPRING
var weather = weathers.SUNNY

const c_spring = 0
const c_summer = 90
const c_fall = 180
const c_winter = 270

var game
var field
var drone
var silo
var swarms

var day = 0
var time_speed = 0.8

var swarm_spawn_counter
const swarm_spawn_rand = 2

const swarm_scene = preload("res://Scenes/swarm.tscn")

const rain_duration = 5
var rain_counter = 0

func weather_rocket():
	
	set_weather(weathers.RAIN)

func set_weather(w):
	
	weather = w
	
	game.make_it_rain()
	
	if weather == weathers.CLOUDY:
		$Clouds.show()

func start_game(game):
	
	self.game = game
	game_phase = game_phases.GAME_RUNNING
	_schedule_next_swarm()
	
func _schedule_next_swarm():
	
	swarm_spawn_counter = randf() * swarm_spawn_rand
	
func _spawn_swarm():
	
	var spawns = swarms.get_node("Spawns")

	var spawn = spawns.get_child(randi() % spawns.get_child_count())
	
	var swarm = swarm_scene.instance()
	
	swarm.global_position = spawn.global_position
	swarms.add_child(swarm)
	
func _physics_process(delta):
	
	if game_phase == game_phases.GAME_RUNNING:
		
		if season != seasons.SPRING:
			
			swarm_spawn_counter -= delta
			if swarm_spawn_counter <= 0:
				_spawn_swarm()
				_schedule_next_swarm()
		
		if silo.level == silo.level_max:
			print("GOOD JOB!")
			game_phase = game_phases.GAME_ENDING
		
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
			print("ITS WINTER, GAME OVER")
			game_phase = game_phases.GAME_ENDING
