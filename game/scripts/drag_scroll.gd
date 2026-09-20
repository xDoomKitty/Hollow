extends ScrollContainer
## Drag on rows or empty space. A short tap is replayed through Godot's normal
## GUI dispatch, so buttons, focus, and disabled controls keep their behavior.
var input_allowed: Callable
var held = false
var dragging = false
var pointer = -2 # -1 mouse; >= 0 touch index
var origin = Vector2.ZERO
var previous = Vector2.ZERO
var replaying = false
var suppress_touch_mouse = false
const DEADZONE = 8.0

func _ready():
	horizontal_scroll_mode = SCROLL_MODE_DISABLED

func _can_start(at: Vector2) -> bool:
	if not is_visible_in_tree() or (input_allowed.is_valid() and not input_allowed.call()): return false
	var ancestor:Node=self
	while ancestor:
		if ancestor.is_queued_for_deletion():return false
		ancestor=ancestor.get_parent()
	if not get_global_rect().has_point(at): return false
	for bar in [get_v_scroll_bar(), get_h_scroll_bar()]:
		if bar.is_visible_in_tree() and bar.get_global_rect().has_point(at): return false
	return true

func _input(event):
	if replaying: return
	if not is_visible_in_tree() or (input_allowed.is_valid() and not input_allowed.call()):
		held = false
		return
	# Android sends native touch and emulated mouse events. Only one may act.
	if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION:
		if suppress_touch_mouse or _can_start(event.position): get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch:
		if held and event.index!=pointer and _can_start(event.position):
			get_viewport().set_input_as_handled()
			return
		if event.pressed and not held and _can_start(event.position):
			_begin(event.position,event.index)
			suppress_touch_mouse = true
		elif held and event.index == pointer and not event.pressed:
			_end(event.position,event.canceled)
			set_deferred("suppress_touch_mouse",false)
		else: return
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not held and _can_start(event.position): _begin(event.position,-1)
		elif held and pointer == -1 and not event.pressed: _end(event.position,event.canceled)
		else: return
	elif event is InputEventScreenDrag and held and event.index == pointer:
		_drag(event.position)
	elif event is InputEventMouseMotion and held and pointer == -1:
		_drag(event.position)
	else: return
	get_viewport().set_input_as_handled()

func _begin(at: Vector2, id: int):
	held = true; dragging = false; pointer = id
	origin = at; previous = at

func _drag(at: Vector2):
	if not dragging and at.distance_to(origin) > DEADZONE:
		dragging = true
		scroll_vertical -= int(at.y-origin.y)
	elif dragging:
		scroll_vertical -= int(at.y-previous.y)
	previous = at

func _end(at: Vector2, canceled: bool):
	var tap = not canceled and not dragging and at.distance_to(origin) <= DEADZONE and _can_start(at)
	held = false; pointer = -2
	if not tap: return
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = origin; press.global_position = origin; press.pressed = true
	var release = press.duplicate()
	release.position = at; release.global_position = at; release.pressed = false
	# Deferred replay avoids recursively changing the viewport's handled state.
	call_deferred("_replay_tap",press,release)

func _replay_tap(press: InputEventMouseButton, release: InputEventMouseButton):
	if not _can_start(press.position): return
	replaying = true
	get_viewport().push_input(press,true)
	get_viewport().push_input(release,true)
	replaying = false

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		held = false; suppress_touch_mouse = false
