extends Node

enum game_phases {MENU, GAME_RUNNING, GAME_ENDING}
enum seasons {SPRING, SUMMER, FALL, WINTER}

var game_phase = game_phases.MENU

var season = seasons.SPRING

const c_spring = 0
const c_summer = 90
const c_fall = 180
const c_winter = 270

var drone
var silo

var day = 0
var time_speed = 5

func start_game():
	
	game_phase = game_phases.GAME_RUNNING

func _physics_process(delta):
	
	if game_phase == game_phases.GAME_RUNNING:
		
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
