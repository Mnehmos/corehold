extends Node2D
## Game scene controller. Manages the active run.

var run_time: float = 0.0
var wave_number: int = 0
var kills: int = 0
var salvage: int = 0

func _ready() -> void:
	run_time = 0.0
	wave_number = 0
	kills = 0
	salvage = 0

func _process(delta: float) -> void:
	run_time += delta
	_update_hud()

func _update_hud() -> void:
	var hud_panel: HBoxContainer = $HUD/HUDPanel
	hud_panel.get_node("TimerLabel").text = _format_time(run_time)

func _format_time(seconds: float) -> String:
	var mins: int = int(seconds) / 60
	var secs: int = int(seconds) % 60
	return "%d:%02d" % [mins, secs]
