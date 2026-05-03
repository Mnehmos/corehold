# Corehold
# File: scripts/util/DebugOverlay.gd
# Purpose: Debug overlay for development toggled with F12
#
# Contribution Flow:
# Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main
#
# Rules:
# - Do not edit without a linked issue.
# - Keep changes scoped to the issue.
# - Add or update tests when practical.
# - Update docs when behavior, architecture, setup, or data formats change.

extends CanvasLayer
## Debug overlay for development. Toggle with F12.
## Shows FPS, enemy count, wave number, and other debug info.

var _visible: bool = false

@onready var _label: Label = $DebugLabel

func _ready() -> void:
	layer = 100
	_label = Label.new()
	_label.name = "DebugLabel"
	_label.anchors_preset = Control.LAYOUT_ANCHOR_PRESET_TOP_LEFT
	_label.offset_left = 8.0
	_label.offset_top = 8.0
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color.YELLOW)
	add_child(_label)
	_label.visible = _visible

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_debug"):
		_visible = not _visible
		_label.visible = _visible
	if _visible:
		_update_debug_info()

func _update_debug_info() -> void:
	var fps: int = Engine.get_frames_per_second()
	var info: String = "FPS: %d" % fps
	_label.text = info

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_F12 and event.pressed:
			_visible = not _visible
			_label.visible = _visible
