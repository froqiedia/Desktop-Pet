extends Node2D

var speed = 300
var direction = Vector2(1,0)
var screen_size = Vector2()
var window_size = Vector2(200,200)

var run_midle = false

var idle_timer = randf_range(1,3)
var is_idling = false
var mouse_left = false

var is_dragging = false
var drag_offset = Vector2()

var innan_Sov = INF
var sov_tid = randf_range(8, 18)

var har_skällt = false

enum State {WALK, SLEEP, PAUS}
var state = State.WALK

@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D


func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
			$skäll.play()
		else:
			is_dragging = false
			$skäll.stop()
func maybe_idle(): 
	if randf() < 0.3:
		state = State.PAUS
		is_idling = true
		idle_timer = randf_range(1,3)
	run_midle = false
func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play("hop")
	area.input_event.connect(_on_area_input)
func _physics_process(delta: float) -> void:
	match state:
		State.WALK:
			speed = 300
			animated_sprite.play("hop")
			innan_Sov -= delta
			if run_midle == true:
				maybe_idle()
			if innan_Sov <= 0:
				sov_tid = randf_range(8, 18)
				state = State.SLEEP
		State.PAUS:
			speed = 0
			animated_sprite.play("idle")
			if idle_timer >= 0 and idle_timer <= 1 and har_skällt == false:
				$"gnäll 1 sek".play()
				har_skällt = true
			elif idle_timer >= 1 and idle_timer <= 2 and har_skällt == false:
				$"gnäll 2 sek".play()
				har_skällt = true
			elif har_skällt == false and har_skällt == false:
				$"gnäll 3 sek".play()
				har_skällt = true
			idle_timer -= delta
			if idle_timer <= 0:
				har_skällt = false
				is_idling = false
				speed = 300
				animated_sprite.play("hop")
				$"gnäll 1 sek".stop()
				$"gnäll 2 sek".stop()
				$"gnäll 3 sek".stop()
				if randf() < 0.1:
					innan_Sov = randf_range(3,6)
				state = State.WALK
		State.SLEEP:
			print ("sover")
			speed = 0
			animated_sprite.play("sover")
			sov_tid -= delta
			if sov_tid <= 0:
				innan_Sov = INF
				state = State.WALK
	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		return
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta
	window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2(window_position))
	if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x :
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
		run_midle = true
	if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y :
		direction.y *= -1
