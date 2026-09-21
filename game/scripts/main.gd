extends Control
const World = preload("res://scripts/world.gd")
const MapView = preload("res://scripts/map_view.gd")
const DragScroll = preload("res://scripts/drag_scroll.gd")
const SAVE_PATH = "user://hollow-save.json"
var world: HollowWorld
var selected = 0
var map: Control
var header: Label
var objective: Label
var status: Label
var pawn_info: Label
var job_label: Label
var pawn_buttons: Array = []
var pawn_bar: HBoxContainer
var pause_button: Button
var inventory_button: Button
var draft_button: Button
var action_button: Button
var queue_button: Button
var cancel_button: Button
var haul_work_button: Button
var build_work_button: Button
var job_progress: ProgressBar
var selection: Dictionary = {}
var building = ""
var building_colony = true
var popup: Control
var popup_kind = ""
var inv_id = -1
var inv_direction = "take"
var inv_item = "timber"
var inv_quantity = 1
var inv_error = ""
var inv_rows: Dictionary = {}
var inv_count: Label
var inv_amount: Label
var inv_status: Label
var inv_action: Button
var inv_drop: Button
var inv_use: Button
var inv_equip: Button
var inv_plus: Button
var inv_minus: Button
var inv_max: Button
var inv_picker: OptionButton
var inv_auto: Button
var inv_filter: Button
var inv_pack: Button
var retreat_button: Button
var info_clock = 0.0
var save_clock = 0.0
var current_depth = 0
var muted = false
var sound_players: Array = []
var sound_cursor = 0
var started = false
var save_problem = ""
var queue_mode = false
var interaction_dialogs: Array = []
var expedition_list: VBoxContainer
var expedition_essentials = true
var expedition_query = ""

func scroll_list() -> ScrollContainer:
	var scroll=DragScroll.new()
	scroll.input_allowed=func():return not is_instance_valid(popup) or popup.is_ancestor_of(scroll)
	return scroll

func box(color: String, border: String = "30464a", radius: int = 5) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(color)
	style.border_color = Color(border)
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	return style

func text_label(text: String, font_size: int = 18, color: String = "d5ddd1") -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",Color(color))
	return label

func button(text: String, callback: Callable, height: int = 44, primary: bool = false) -> Button:
	var b = Button.new()
	b.text = text
	b.custom_minimum_size.y = height
	b.add_theme_font_size_override("font_size",18)
	b.add_theme_stylebox_override("normal",box("bf9c60" if primary else "22363a","c9ac76" if primary else "3a5254"))
	b.add_theme_stylebox_override("hover",box("d3b17a" if primary else "304a4c","a6bcad"))
	b.add_theme_stylebox_override("pressed",box("a38959" if primary else "46605b","d4b679"))
	b.add_theme_stylebox_override("disabled",box("1b282b","29383b"))
	b.add_theme_stylebox_override("focus",box("00000000","d9ba7e"))
	b.add_theme_color_override("font_color",Color("112124" if primary else "d9dfd1"))
	b.add_theme_color_override("font_hover_color",Color("112124" if primary else "fff0d1"))
	b.add_theme_color_override("font_pressed_color",Color("112124" if primary else "fff0d1"))
	b.add_theme_color_override("font_disabled_color",Color("687b78"))
	b.pressed.connect(callback)
	return b

func _ready():
	world = World.new()
	var loaded = load_game()
	build_ui()
	for i in 4:
		var player = AudioStreamPlayer.new()
		player.volume_db = -14
		add_child(player)
		sound_players.append(player)
	var ambience = AudioStreamPlayer.new()
	ambience.stream = load("res://assets/underground.wav")
	ambience.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	ambience.stream.loop_end = int(ambience.stream.mix_rate * ambience.stream.get_length())
	ambience.volume_db = -25
	add_child(ambience)
	if DisplayServer.get_name() != "headless": ambience.play()
	_refresh()
	if not loaded: show_intro()
	else: started = true; feedback("Expedition restored. Press Play when you are ready.")
	get_tree().auto_accept_quit = false

func build_ui():
	var background = ColorRect.new()
	background.color = Color("0d191e")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margins = MarginContainer.new()
	margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right","top","bottom"]: margins.add_theme_constant_override("margin_"+side,10)
	add_child(margins)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation",8)
	margins.add_child(column)
	var top = HBoxContainer.new()
	column.add_child(top)
	var brand = text_label("H O L L O W",25,"e5c087")
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(brand)
	top.add_child(button("Crew",show_expedition,42))
	top.add_child(button("Journal",show_journal,42))
	top.add_child(button("Menu",show_menu,42))
	pause_button = button("PLAY",toggle_pause,42,true)
	pause_button.custom_minimum_size.x = 90
	top.add_child(pause_button)
	var body = HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",10)
	column.add_child(body)
	var left = VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(left)
	var toolbar = HBoxContainer.new()
	left.add_child(toolbar)
	header = text_label("DEPTH 01 / BURIED SHELTER",17,"a7c9bf")
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(header)
	toolbar.add_child(button("−",func(): map.zoom = max(.45,map.zoom*.8),38))
	toolbar.add_child(button("+",func(): map.zoom = min(1.8,map.zoom*1.2),38))
	toolbar.add_child(button("Follow",func(): map.follow=true; map.depth=world.data.pawns[selected].z,38))
	map = MapView.new()
	map.world = world
	map.selected = selected
	map.depth = world.data.pawns[selected].z
	map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map.tile_clicked.connect(_map_clicked)
	left.add_child(map)
	var travel = HBoxContainer.new()
	travel.add_theme_constant_override("separation",7)
	left.add_child(travel)
	var up = button("Ascend",func(): execute(world.order_travel(selected,world.data.pawns[selected].z-1)),46)
	up.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	travel.add_child(up)
	var down = button("Descend",func(): execute(world.order_travel(selected,world.data.pawns[selected].z+1)),46)
	down.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	travel.add_child(down)
	retreat_button = button("Retreat together",retreat_together,46)
	retreat_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	travel.add_child(retreat_button)
	var side_scroll=scroll_list()
	side_scroll.custom_minimum_size.x=248
	side_scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
	side_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(side_scroll)
	var side_panel = PanelContainer.new()
	side_panel.custom_minimum_size.x = 238
	side_panel.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	side_panel.add_theme_stylebox_override("panel",box("17282d","334c4c",7))
	side_scroll.add_child(side_panel)
	var side = VBoxContainer.new()
	side.add_theme_constant_override("separation",4)
	side_panel.add_child(side)
	pawn_bar = HBoxContainer.new()
	side.add_child(pawn_bar)
	rebuild_pawn_buttons()
	pawn_info = text_label("",12,"aec0b4")
	pawn_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(pawn_info)
	job_label = text_label("Idle",17)
	job_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(job_label)
	job_progress = ProgressBar.new()
	job_progress.show_percentage = false
	job_progress.custom_minimum_size.y = 5
	job_progress.add_theme_stylebox_override("background",box("263c3d","263c3d",2))
	job_progress.add_theme_stylebox_override("fill",box("c8a36a","c8a36a",2))
	side.add_child(job_progress)
	var order_row=HBoxContainer.new()
	order_row.add_theme_constant_override("separation",6)
	side.add_child(order_row)
	queue_button=button("Queue: off",toggle_queue,38)
	queue_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	order_row.add_child(queue_button)
	cancel_button=button("Clear",cancel_orders,38)
	order_row.add_child(cancel_button)
	var work_row=HBoxContainer.new()
	work_row.add_theme_constant_override("separation",6)
	side.add_child(work_row)
	haul_work_button=button("Haul: Normal",func(): cycle_work("haul"),38)
	haul_work_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	haul_work_button.tooltip_text="Automatic supply and stockpile hauling"
	work_row.add_child(haul_work_button)
	build_work_button=button("Build: Normal",func(): cycle_work("build"),38)
	build_work_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	build_work_button.tooltip_text="Automatic blueprint construction"
	work_row.add_child(build_work_button)
	inventory_button = button("Inventory",func(): open_inventory(),44)
	side.add_child(inventory_button)
	side.add_child(button("Build",show_build,44))
	draft_button = button("Draft for combat",toggle_draft,44)
	side.add_child(draft_button)
	action_button = button("Talk to traveler",context_action,48,true)
	action_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(action_button)
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(spacer)
	var hint = text_label("Tap objects to walk and interact.\nDrag lists to scroll; drag map to look.",13,"879f97")
	side.add_child(hint)
	objective = text_label("",17,"dec38e")
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(objective)
	status = text_label("",14,"97ada5")
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(status)

func _process(dt):
	if not world: return
	world.tick(min(dt,.1))
	var z = int(world.data.pawns[selected].z)
	if z != current_depth:
		current_depth = z
		map.depth = z
		map.focus = Vector2(world.data.pawns[selected].x+.5,world.data.pawns[selected].y+.5)
		map.follow = true
		selection.clear()
		close_popup()
	while not world.events.is_empty():
		var event = world.events.pop_front()
		if event.kind == "note":
			if status: status.text = event.text
		elif event.kind == "interaction_ready":interaction_dialogs.append(event)
		elif event.kind == "story": show_story()
		elif event.kind == "station":show_station()
		elif event.kind == "recruit":show_recruit()
		elif event.kind == "outpost":show_outpost()
		elif event.kind == "bellwether":show_bellwether()
		elif event.kind == "spindle":show_spindle()
		elif event.kind == "ashline":show_ashline()
		elif event.kind == "service":show_service_ring()
		elif event.kind == "foundry":show_foundry()
		elif event.kind == "archive":show_archive()
		elif event.kind == "wake":show_wake()
		elif event.kind == "quiet":show_quiet()
		elif event.kind == "stillworks":show_stillworks()
		elif event.kind == "cistern":show_cistern()
		elif event.kind == "drowned":show_drowned()
		elif event.kind == "tidecourt":show_tidecourt()
		elif event.kind == "sump":show_sump()
		elif event.kind == "market":show_market()
		elif event.kind == "depot":show_depot()
		elif event.kind == "refuge":show_refuge()
		elif event.kind == "ashrail":show_ashrail()
		elif event.kind == "customs":show_customs()
		elif event.kind == "railcourt":show_railcourt()
		elif event.kind == "registry":show_registry()
		elif event.kind == "morrow":show_morrow()
		elif event.kind == "terminus":show_terminus()
		elif event.kind == "farline":show_farline()
		elif event.kind == "thimble":show_thimble()
		elif event.kind == "latchwater":show_latchwater()
		elif event.kind == "driftglass":show_driftglass()
		elif event.kind == "bellhome":show_bellhome()
		elif event.kind == "commons":show_commons()
		elif event.kind == "yard":show_yard()
		elif event.kind == "kiln":show_kiln()
		elif event.kind == "junction":show_junction()
		elif event.kind == "ember_commons":show_ember_commons()
		elif event.kind == "deepcoil":show_deepcoil()
		elif event.kind == "coilward":show_coilward()
		elif event.kind == "charterwell":show_charterwell()
		elif event.kind == "writwell":show_writwell()
		elif event.kind == "concordance":show_concordance()
		elif event.kind == "reservefall":show_reservefall()
		elif event.kind == "reserve_commons":show_reserve_commons()
		elif event.kind == "shieldline":show_shieldline()
		elif event.kind == "marchhold":show_marchhold()
		elif event.kind == "march_refuge":show_march_refuge()
		elif event.kind == "wallward":show_wallward()
		elif event.kind == "wayfarer":show_wayfarer()
		elif event.kind == "underway":show_underway()
		else: sound(event.kind)
	if not is_instance_valid(popup) and not interaction_dialogs.is_empty():
		show_arrived_interaction(interaction_dialogs.pop_front())
	info_clock += dt
	save_clock += dt
	if info_clock > .2:
		_refresh()
		info_clock = 0
	if save_clock > 8 and started:
		save_game()
		save_clock = 0

func _refresh():
	if not header: return
	if pawn_buttons.size()!=world.data.pawns.size():rebuild_pawn_buttons()
	var p = world.data.pawns[selected]
	var f = world.floor_at(p.z)
	header.text = "DEPTH %02d / %s" % [map.depth+1,world.floor_at(map.depth).name.to_upper()]
	if int(map.depth)!=int(p.z):header.text+=" · VIEW ONLY"
	pause_button.text = "PLAY" if world.data.paused else "PAUSE"
	var pressure=world.pressure_report(int(p.z))
	var threat = "COLD" if f.heat < 20 else "WARM" if f.heat < 45 else "DRAWING ATTENTION"
	if f.alarm >= 0: threat = "INCOMING: %ds" % int(ceil(f.alarm))
	var protection="Coat" if p.equipment.body=="armor" else "None"
	var trend="cooling" if float(pressure.rate)<0 else "+%.2f/s"%float(pressure.rate)
	var lure=" · %d lure"%int(pressure.beacons) if int(pressure.beacons)>0 else ""
	var alarms=" · %d alarm"%int(pressure.alarms) if int(pressure.alarms)>0 else ""
	if int(pressure.ringing)>0:alarms+=" RINGING"
	var social=world.social_summary(selected)
	pawn_info.text = "HP %d %s · Food %d%% · Fatigue %d%% %s\nMorale %d%% %s · %s · %s · D%d · %s %d (%s%s%s)" % [int(p.hp),World.INJURY_LEVELS[int(p.injury)].capitalize(),int(100-p.hunger),int(p.fatigue),world.fatigue_state(p).capitalize(),int(p.morale),world.morale_state(p).capitalize(),social,protection,int(p.z)+1,threat.capitalize(),int(f.heat),trend,lure,alarms]
	var lines:Array=[]
	if p.hp<=0:lines.append("Lost")
	elif p.job.is_empty():lines.append(world.work_status(selected))
	else:
		var automatic="AUTO · " if bool(p.job.get("extra",{}).get("automatic",false)) else ""
		lines.append(automatic+("Walking → " if not p.job.get("path",[]).is_empty() else "Working · ")+describe_order(p.job))
	if not p.orders.is_empty():
		var waiting:Array=[]
		for i in min(3,p.orders.size()):waiting.append(str(i+1)+" "+describe_order(p.orders[i]))
		lines.append("Next: "+"  ·  ".join(waiting)+("  +%d"%(p.orders.size()-3) if p.orders.size()>3 else ""))
	job_label.text="\n".join(lines)
	job_progress.value = 0 if p.job.is_empty() or float(p.job.get("duration",0))<=0 else 100*p.job.elapsed/p.job.duration
	queue_button.text="Queue: ON · %d"%p.orders.size() if queue_mode else "Queue: off · %d"%p.orders.size()
	cancel_button.disabled=p.job.is_empty() and p.orders.is_empty()
	haul_work_button.text="Haul: "+World.WORK_LEVELS[world.work_priority(selected,"haul")].capitalize()
	build_work_button.text="Build: "+World.WORK_LEVELS[world.work_priority(selected,"build")].capitalize()
	haul_work_button.disabled=p.hp<=0;build_work_button.disabled=p.hp<=0
	inventory_button.text = "Inventory · %.1f / 12 kg" % world.weight(p.inventory)
	draft_button.text = "Stand down" if p.drafted else "Draft for combat"
	for i in pawn_buttons.size():
		var button_pawn=world.data.pawns[i]
		pawn_buttons[i].text = button_pawn.name+(" · DOWN" if world.incapacitated(button_pawn) else "")+(" *" if i == selected else "")
		pawn_buttons[i].disabled = world.data.pawns[i].hp <= 0
	objective.text = world.objective() if building == "" else ("PLAN: " if building_colony else "BUILD: ")+World.RECIPES[building].name+" · Tap a clear floor tile. Esc or Build to cancel."
	if not selection.is_empty():
		match selection.kind:
			"container":
				var c = world.container_by_id(p.z,selection.id)
				action_button.text = "Open inventory" if not c.is_empty() and c.searched else "Search container"
			"enemy": action_button.text = "Attack target"
			"patient":
				var patient_index=int(selection.get("index",-1));var patient=world.data.pawns[patient_index] if patient_index>=0 and patient_index<world.data.pawns.size() else {}
				action_button.text=("Tend "+str(patient.get("name","colonist"))+" · 1 medkit") if not patient.is_empty() and not world.pawn_at_bed(patient).is_empty() else "Rescue "+str(patient.get("name","colonist"))+" to bedroll"
			"traveler": action_button.text = "Talk to traveler"
			"recruit":action_button.text="Talk to Vale"
			"station":action_button.text="Inspect waystation"
			"lore":action_button.text="Inspect relic"
			"hazard":action_button.text="Inspect hazard"
			"spring":action_button.text="Choose spring's fate" if str(selection.get("state","untouched"))=="untouched" else "Inspect spring"
			"pump":action_button.text="Reroute emergency pump" if str(selection.get("state","idle"))=="idle" else "Inspect dead pump"
			"outpost":action_button.text="Meet the Lantern Compact" if str(selection.get("state","waiting"))=="waiting" else "Review Low Lantern choice"
			"bellwether":action_button.text="Choose Bellwether route" if str(selection.get("state","waiting"))=="waiting" else "Review fixed route"
			"spindle":action_button.text="Answer the Gate Watch" if str(selection.get("state","waiting"))=="waiting" else "Review first contact"
			"ashline":
				var ash_state=str(selection.get("state","waiting"))
				action_button.text="Submit to screening" if ash_state=="waiting" else "Return purifier cartridge" if ash_state=="assigned" else "Review Ashline clearance"
			"service_ring":action_button.text="Choose standing terms" if str(selection.get("state","waiting"))=="waiting" else "Review Meridian standing"
			"foundry":
				var foundry_state=str(selection.get("state","waiting"))
				action_button.text="Review standing contract" if foundry_state=="waiting" else "Return foundry regulator" if foundry_state=="assigned" else "Review Foundry Ward outcome"
			"archive":
				var archive_state=str(selection.get("state","waiting"))
				action_button.text="Request survey file" if archive_state=="waiting" else "Decide evidence custody" if archive_state=="assigned" else "Review traveler record"
			"wake":
				var wake_state=str(selection.get("state","waiting"))
				action_button.text="Begin survey recovery" if wake_state=="waiting" else "Return survey compass" if wake_state=="assigned" else "Review final waymark"
			"quiet_post":action_button.text="Tune listening post" if str(selection.get("state","locked"))=="available" else "Inspect listening post"
			"quiet_receiver":action_button.text="Replay final signal" if world.data.quiet_state=="open" else "Review Quiet Mile receiver"
			"stillworks":action_button.text="Choose life-support route" if str(selection.get("state","waiting"))=="waiting" else "Review Stillworks choice"
			"cistern":
				var cistern_state=str(selection.get("state","waiting"))
				action_button.text="Accept reservoir request" if cistern_state=="waiting" else "Return cistern gate seal" if cistern_state=="assigned" else "Review secured reservoir"
			"drowned_control":action_button.text="Cycle gallery sluice" if world.data.drowned_state=="" else "Review surge"
			"drowned_rescue":action_button.text="Rescue Keeper Olan" if world.data.drowned_state=="warning" else "Inspect rescue wing"
			"drowned_salvage":action_button.text="Recover regulator" if world.data.drowned_state=="warning" else "Inspect salvage wing"
			"tidecourt":
				var tide_state=str(selection.get("state","waiting"))
				action_button.text="Present Gallery outcome" if tide_state=="waiting" else "Return water docket" if tide_state=="assigned" else "Review Tidecourt access"
			"sump":
				var sump_state=str(selection.get("state","waiting"))
				action_button.text="Accept pump repair" if sump_state=="waiting" else "Return pump impeller" if sump_state=="assigned" else "Review Commons foothold"
			"market":action_button.text="Review Mainspring exchange" if str(selection.get("state","waiting"))=="waiting" else "Review market welcome"
			"depot":
				var depot_state=str(selection.get("state","waiting"))
				action_button.text="Accept Clockline recovery" if depot_state=="waiting" else "Install split freight" if depot_state=="assigned" else "Review reopened depot"
			"refuge":action_button.text="Plan resident evacuation" if str(selection.get("state","waiting"))=="waiting" else "Review Switchyard outcome"
			"ashrail":action_button.text="Provision far platform" if str(selection.get("state","waiting"))=="waiting" else "Review Ashrail exchange"
			"customs":action_button.text="Choose customs route" if str(selection.get("state","waiting"))=="waiting" else "Review Emberline route"
			"railcourt":action_button.text="Review Railcourt contract"
			"registry":action_button.text="Review registry contract"
			"morrow":action_button.text="Review freight departure"
			"terminus":action_button.text="Review Cairn Reach request"
			"farline":action_button.text="Review Farline road"
			"thimble":action_button.text="Review Thimble warning"
			"latchwater":action_button.text="Review shared heater"
			"driftglass":action_button.text="Review glass excavation"
			"bellhome":action_button.text="Review convoy warning"
			"commons":action_button.text="Review housing repair"
			"yard":action_button.text="Review Hearthline expansion"
			"kiln":action_button.text="Review Kilnreach works"
			"junction":action_button.text="Review Embervault freight"
			"ember_commons":action_button.text="Review signal-house repair"
			"deepcoil":action_button.text="Review paired relay"
			"coilward":action_button.text="Review community charter"
			"charterwell":action_button.text="Review delegation warning"
			"writwell":action_button.text="Review assembly vote"
			"concordance":action_button.text="Review gate defense"
			"reservefall":action_button.text="Review incursion warning"
			"reserve_commons":action_button.text="Review communal repair"
			"shieldline":action_button.text="Review mobile defense"
			"marchhold":action_button.text="Review crossing warning"
			"march_refuge":action_button.text="Review refuge defense"
			"wallward":action_button.text="Review convoy warning"
			"wayfarer":action_button.text="Review shared repair"
			"underway":action_button.text="Review road survey"
			"structure":action_button.text="Manage "+str(World.RECIPES.get(selection.get("recipe",""),{"name":"structure"}).name).to_lower()
			"bed": action_button.text = "Rest at bedroll"
			"designation":action_button.text="Cancel blueprint"
			"stairs": action_button.text = "Use stairs"
			_: action_button.text = "Inspect"
	elif not world.data.traveler and p.z == 0: action_button.text = "Talk to traveler"
	else: action_button.text = "Find supplies"
	if popup_kind == "inventory": refresh_inventory()

func describe_order(order:Dictionary)->String:
	match str(order.get("kind","")):
		"interact":return "search / open storage" if order.get("extra",{}).get("type","")=="container" else "interact"
		"walk":return "move"
		"search":return "search"
		"transfer":return ("take " if order.get("extra",{}).get("direction","")=="take" else "store ")+str(order.get("extra",{}).get("quantity",1))+" "+str(order.get("extra",{}).get("item","item"))
		"build":return "build "+str(World.RECIPES.get(order.get("extra",{}).get("recipe",""),{"name":"structure"}).name).to_lower()
		"construct":return "construct "+str(World.RECIPES.get(order.get("extra",{}).get("recipe",""),{"name":"structure"}).name).to_lower()
		"talk":return "talk"
		"recruit":return "talk to Vale"
		"spring":return "drink from spring" if order.get("extra",{}).get("choice","")=="drink" else "harvest spring"
		"pump":return "drain residences" if order.get("extra",{}).get("choice","")=="residences" else "drain substation"
		"outpost":return "aid Low Lantern" if order.get("extra",{}).get("choice","")=="aid" else "trade at Low Lantern"
		"bellwether":return "open courier cage" if order.get("extra",{}).get("choice","")=="courier" else "open maintenance bypass"
		"spindle":return "answer Spindle Gate"
		"ashline":return "accept Ashline request" if order.get("extra",{}).get("action","")=="accept" else "deliver purifier cartridge"
		"service":return "work for city quarters" if order.get("extra",{}).get("choice","")=="city" else "secure field charter"
		"foundry":
			var action=str(order.get("extra",{}).get("action",""))
			return "accept foundry repair" if action=="accept" else "deliver foundry regulator" if action=="deliver" else "post material bond"
		"archive":
			var action=str(order.get("extra",{}).get("action",""))
			return "open survey stacks" if action=="open" else "share traveler dossier" if action=="share" else "preserve traveler dossier"
		"wake":return "begin survey recovery" if order.get("extra",{}).get("action","")=="start" else "align final survey route"
		"quiet":return "tune listening post "+str(order.get("extra",{}).get("stage",0)) if order.get("extra",{}).get("action","")=="tune" else "replay traveler signal"
		"stillworks":return "restore Stillworks scrubbers" if order.get("extra",{}).get("choice","")=="restore" else "baffle dark overflow"
		"cistern":return "accept reservoir request" if order.get("extra",{}).get("action","")=="start" else "return cistern gate seal"
		"drowned":
			var drowned_action=str(order.get("extra",{}).get("action",""))
			return "cycle Gallery sluice" if drowned_action=="start" else "rescue Keeper Olan" if drowned_action=="rescue" else "recover pressure regulator"
		"tidecourt":
			var tide_action=str(order.get("extra",{}).get("action",""))
			return "accept Olan's sponsorship" if tide_action=="sponsor" else "post Tidecourt material bond" if tide_action=="contract" else "open public recovery" if tide_action=="start" else "return water docket"
		"sump":return "accept Commons pump repair" if order.get("extra",{}).get("action","")=="start" else "return pump impeller"
		"market":return "complete Mainspring exchange"
		"depot":return "begin Clockline recovery" if order.get("extra",{}).get("action","")=="start" else "install split freight"
		"refuge":return "anchor Switchyard sanctuary" if order.get("extra",{}).get("choice","")=="foothold" else "launch mobile supply corridor"
		"ashrail":return "provision Ashrail far platform"
		"customs":return "declare cargo" if order.get("extra",{}).get("choice","")=="security" else "move cargo off ledger"
		"railcourt":return "open switchhouse" if order.get("extra",{}).get("action","")=="start" else "return switch warrant" if order.get("extra",{}).get("action","")=="finish" else "post resident compact"
		"registry":return "open audit vault" if order.get("extra",{}).get("action","")=="start" else "return registry plate" if order.get("extra",{}).get("action","")=="finish" else "copy Morrow waybill"
		"morrow":return "call Morrow train" if order.get("extra",{}).get("action","")=="start" else "board Morrow train together"
		"terminus":return "open Cairn witness hall" if order.get("extra",{}).get("action","")=="start" else "return Cairn witness ledger" if order.get("extra",{}).get("action","")=="finish" else "repair Cairn far lift"
		"farline":return "open Farline road" if order.get("extra",{}).get("action","")=="start" else "bind Farline route braid"
		"thimble":
			var action=str(order.get("extra",{}).get("action",""))
			return "prepare Thimble defense" if action=="defend" else "prepare Thimble evacuation" if action=="evacuate" else "seal Thimble breach" if action=="hold" else "evacuate Thimble residents"
		"latchwater":
			var action=str(order.get("extra",{}).get("action",""))
			return "open Latchwater heater route" if action=="start" else "restore full ward warmth" if action=="warm" else "baffle Latchwater heater"
		"driftglass":
			var action=str(order.get("extra",{}).get("action",""))
			return "open Driftglass excavation" if action=="start" else "power Driftglass cutters" if action=="powered" else "shade Driftglass lower seam"
		"bellhome":
			var action=str(order.get("extra",{}).get("action",""))
			return "open Bellhome convoy gate" if action=="start" else "escort Bellhome convoy" if action=="escort" else "divert Bellhome convoy"
		"commons":return "open Bellhome housing route" if order.get("extra",{}).get("action","")=="start" else "repair Bellhome homes"
		"yard":return "open Hearthline cargo lanes" if order.get("extra",{}).get("action","")=="start" else "install Hearthline lift"
		"kiln":
			var action=str(order.get("extra",{}).get("action",""))
			return "survey Kilnreach works" if action=="start" else "rebuild Kilnreach furnace" if action=="build" else "conceal Kilnreach flues"
		"junction":
			var action=str(order.get("extra",{}).get("action",""))
			return "answer Embervault signal" if action=="start" else "receive Embervault freight" if action=="receive" else "shunt Embervault freight"
		"ember_commons":return "open Embervault settlement route" if order.get("extra",{}).get("action","")=="start" else "repair Embervault signal house"
		"deepcoil":return "open Deepcoil galleries" if order.get("extra",{}).get("action","")=="start" else "synchronize Deepcoil relays"
		"coilward":return "open Coilward charter route" if order.get("extra",{}).get("action","")=="start" else "ratify Coilward charter"
		"charterwell":return "open Charterwell delegation" if order.get("extra",{}).get("action","")=="start" else "escort Charterwell delegation" if order.get("extra",{}).get("action","")=="escort" else "fund Charterwell passage"
		"writwell":return "convene Writwell Assembly" if order.get("extra",{}).get("action","")=="start" else "ratify Writwell pledge"
		"concordance":return "open Concordance Gate" if order.get("extra",{}).get("action","")=="start" else "build Concordance bastion" if order.get("extra",{}).get("action","")=="bastion" else "provision mobile reserve"
		"reservefall":return "answer Reservefall warning" if order.get("extra",{}).get("action","")=="start" else "hold Reservefall line" if order.get("extra",{}).get("action","")=="hold" else "withdraw Reservefall residents"
		"reserve_commons":return "open Reservefall Commons" if order.get("extra",{}).get("action","")=="start" else "repair Reservefall shield"
		"shieldline":return "accept Shieldline carriage" if order.get("extra",{}).get("action","")=="start" else "assemble Shieldline walking wall"
		"marchhold":return "sound Marchhold warning" if order.get("extra",{}).get("action","")=="start" else "deploy Marchhold wall" if order.get("extra",{}).get("action","")=="deploy" else "retreat Marchhold camp"
		"march_refuge":return "present Marchhold seal" if order.get("extra",{}).get("action","")=="start" else "donate folded wall" if order.get("extra",{}).get("action","")=="donate" else "repair refuge defense"
		"wallward":return "signal Wallward convoy" if order.get("extra",{}).get("action","")=="start" else "escort Wallward convoy" if order.get("extra",{}).get("action","")=="escort" else "screen Wallward convoy"
		"wayfarer":return "present convoy tally" if order.get("extra",{}).get("action","")=="start" else "repair shared roadstead"
		"underway":return "open Underway survey" if order.get("extra",{}).get("action","")=="start" else "install waylights" if order.get("extra",{}).get("action","")=="lit" else "conceal bypass"
		"dismantle":return "pack up "+str(World.RECIPES.get(order.get("extra",{}).get("recipe",""),{"name":"structure"}).name).to_lower()
		"reset_alarm":return "reset tripwire alarm"
		"rescue":return "rescue "+str(world.data.pawns[int(order.get("extra",{}).get("patient",0))].name)
		"tend":return "tend "+str(world.data.pawns[int(order.get("extra",{}).get("patient",0))].name)
		"travel":return "travel"
		"retreat":return "rally at stairs"
		"rest":return "rest"
		"attack":return "attack"
	return "order"

func toggle_queue():
	queue_mode=not queue_mode
	feedback("Queue mode: taps add orders for "+world.data.pawns[selected].name+"." if queue_mode else "Direct orders: finish or clear current work first.")
	_refresh()

func cycle_work(role:String):
	var level=(world.work_priority(selected,role)+1)%World.WORK_LEVELS.size()
	var error=world.set_work_priority(selected,role,level)
	if error!="":feedback(error)
	else:feedback(world.data.pawns[selected].name+" · "+role.capitalize()+" "+World.WORK_LEVELS[level].to_lower())
	_refresh()
	save_game()

func cancel_orders():
	world.cancel(selected)
	interaction_dialogs=interaction_dialogs.filter(func(event):return int(event.pawn)!=selected)
	feedback("Current and waiting orders cleared. Items stay where they are.")
	_refresh()

func feedback(message: String):
	status.text = message

func execute(error: String):
	if error != "":
		feedback(error)
		if popup_kind == "inventory": inv_error = error
	else:
		feedback("Order added to the queue." if queue_mode else "Order queued while time is paused." if world.data.paused else "Order given.")
		map.follow = true
	_refresh()
	save_game()

func select_pawn(index: int):
	selected = index
	map.selected = index
	map.depth = world.data.pawns[index].z
	current_depth = map.depth
	map.follow = true
	selection.clear()
	building = ""; map.building = ""
	_refresh()

func rebuild_pawn_buttons():
	if not pawn_bar:return
	for child in pawn_bar.get_children():child.queue_free()
	pawn_buttons.clear()
	for i in world.data.pawns.size():
		var b=button(world.data.pawns[i].name,func():select_pawn(i),44)
		b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		pawn_bar.add_child(b)
		pawn_buttons.append(b)

func toggle_pause():
	world.data.paused = not world.data.paused
	_refresh()

func toggle_draft():
	var p = world.data.pawns[selected]
	if world.incapacitated(p):feedback("This colonist is incapacitated and must be rescued.");return
	p.drafted = not p.drafted
	world.cancel(selected)
	feedback("Drafted: tap an enemy, then Attack. Colonists defend themselves if attacked." if p.drafted else "Standing down.")
	_refresh()

func retreat_together():
	var target = int(world.data.pawns[selected].z)+1
	var result=world.order_retreat(int(world.data.pawns[selected].z),target)
	if result.error!="":feedback(result.error)
	else:
		var message="Rallying "+", ".join(result.joined)+" at the lower stairs."
		if not result.skipped.is_empty():message+=" Not joining: "+" ".join(result.skipped)
		feedback(message);map.follow=true
	_refresh();save_game()

func _map_clicked(tile: Vector2i,right: bool):
	if int(map.depth)!=int(world.data.pawns[selected].z):
		feedback("This is a remembered floor. Find a colonist here in Crew, or press Follow to return.")
		return
	if building!="":_select_map_target(tile,right);return
	selection.clear()
	_select_map_target(tile,right)
	if right or selection.is_empty():return
	var pawn=world.data.pawns[selected]
	match selection.kind:
		"lore","hazard":return
		"enemy":
			if pawn.drafted:context_action()
			return
		"traveler","recruit","patient","stairs":context_action();return
		"structure":
			var structure=world.structure_by_id(int(pawn.z),int(selection.id))
			if structure.kind=="bed":execute(world.order_rest(selected,tile,queue_mode));return
			if structure.kind=="tripwire" and structure.get("state","")=="spent":execute(world.order_reset_alarm(selected,int(structure.id),queue_mode));return
	var target:Dictionary={}
	if selection.kind=="container":target={"type":"container","id":selection.id}
	elif selection.kind=="designation":target={"type":"blueprint","id":selection.id}
	elif selection.kind=="structure":target={"type":"structure","id":selection.id}
	else:
		for mark in world.floor_at(int(pawn.z)).landmarks:
			if world.point(mark)==tile:target={"type":"landmark","mark":str(mark.kind)};break
	if not target.is_empty():execute(world.order_interact(selected,tile,target,queue_mode))

func show_arrived_interaction(event:Dictionary):
	var index=int(event.pawn)
	if index<0 or index>=world.data.pawns.size():return
	var pawn=world.data.pawns[index];var tile=world.vec(event.target)
	if pawn.hp<=0 or world.incapacitated(pawn) or int(pawn.z)!=int(event.z) or world.point(pawn).distance_to(tile)>1.01:return
	if world.interaction_target(int(event.z),tile,event.extra).is_empty():return
	if not pawn.job.is_empty() or not pawn.orders.is_empty():
		feedback(pawn.name+" reached the object. Finish queued orders, then tap it to open its choices.")
		return
	select_pawn(index)
	if event.extra.type=="container":
		selection={"kind":"container","id":int(event.extra.id)}
		open_inventory(int(event.extra.id))
	elif event.extra.type=="blueprint":
		selection={"kind":"designation","id":int(event.extra.id)}
		show_blueprint()
	elif event.extra.type=="structure":
		var structure=world.structure_by_id(int(pawn.z),int(event.extra.id))
		selection={"kind":"structure","id":int(structure.id),"recipe":str(structure.kind),"point":event.target}
		show_structure()
	else:
		_select_map_target(tile,false,false)
		context_action()
	_refresh()

func _select_map_target(tile: Vector2i,right: bool,select_people:bool=true):
	var p = world.data.pawns[selected]
	var z = int(p.z)
	if not world.valid(tile): return
	if building != "":
		var error = world.place_designation(z,building,tile) if building_colony else world.order_build(selected,building,tile,queue_mode)
		if error == "": building = ""; map.building = ""
		if building_colony and error=="":
			feedback("Blueprint placed. Idle colonists will supply it when this level is safe.")
			_refresh();save_game()
		else:execute(error)
		return
	for i in world.data.pawns.size():
		var other = world.data.pawns[i]
		if select_people and other.z == map.depth and world.point(other) == tile and other.hp > 0 and not right:
			if world.incapacitated(other):
				selection={"kind":"patient","index":i}
				feedback(other.name+" is incapacitated. Carry them to a free bedroll, then tend them safely with a medkit.")
				_refresh();return
			select_pawn(i); return
	if map.depth != z: feedback("Follow the selected colonist before giving orders."); return
	if not world.floor_at(z).seen.has(world.cell_key(tile)):
		# Explore to the last visible reachable point in this direction.
		var origin = world.point(p)
		var best = origin
		for i in range(1,9):
			var point = Vector2i((Vector2(origin)+Vector2(tile-origin).normalized()*i).round())
			if world.walkable(z,point) and world.floor_at(z).seen.has(world.cell_key(point)): best = point
		if best != origin: execute(world.order_walk(selected,best,queue_mode))
		else: feedback("Explore the edge of the visible passage first.")
		return
	for e in world.floor_at(z).enemies:
		if world.point(e) == tile and world.is_visible(z,tile):
			selection = {"kind":"enemy","id":e.id}
			feedback(world.enemy_readout(z,e)+" · "+str(int(e.hp))+" health")
			if right: execute(world.target_enemy(selected,e.id))
			_refresh(); return
	var c = world.container_at(z,tile)
	if not c.is_empty() and not right:
		if c.get("kind","")=="blueprint":
			selection={"kind":"designation","id":c.id}
			var supplied=0;var needed=0
			for item in World.RECIPES[c.recipe].cost:
				supplied+=min(int(c.items.get(item,0)),int(World.RECIPES[c.recipe].cost[item]));needed+=int(World.RECIPES[c.recipe].cost[item])
			feedback(c.name+" · "+str(supplied)+" / "+str(needed)+" materials")
		else:
			selection = {"kind":"container","id":c.id}
			feedback(c.name+(" · searched" if c.searched else " · contents unknown"))
		_refresh(); return
	for mark in world.floor_at(z).landmarks:
		if world.point(mark) == tile:
			if mark.kind == "traveler": selection={"kind":"traveler"}; feedback("A stranger stands by the shelter.")
			elif mark.kind=="recruit":selection={"kind":"recruit"};feedback("Vale watches from beside the station lamp.")
			elif mark.kind=="station":selection={"kind":"station"};feedback("Cinder Waystation · occupied, barely.")
			elif mark.kind in ["transit_sign","train_wreck","memorial"]:
				selection={"kind":"lore","text":str(mark.get("description",mark.name))}
				feedback(selection.text)
			elif mark.kind=="unstable_roof":
				var hazard_text=str(mark.get("description",mark.name))
				if mark.get("state","")=="warning":hazard_text="CAVE-IN IMMINENT · %.1f seconds. Move away."%float(mark.get("timer",0))
				elif mark.get("state","")=="collapsed":hazard_text="The roof is down. Search the exposed rubble for salvage."
				selection={"kind":"hazard","text":hazard_text};feedback(hazard_text)
			elif mark.kind=="spring":
				selection={"kind":"spring","point":world.arr(tile),"state":str(mark.get("state","untouched"))}
				var spring_text=str(mark.get("description",mark.name))
				if mark.get("state","")=="drunk":spring_text="The luminous water is gone. Bare limestone remembers the choice."
				elif mark.get("state","")=="harvested":spring_text="The pool was drained. Broken crystal marks where it shone."
				feedback(spring_text)
			elif mark.kind in ["fossil","roots"]:
				selection={"kind":"lore","text":str(mark.get("description",mark.name))}
				feedback(selection.text)
			elif mark.kind=="pump_console":
				selection={"kind":"pump","point":world.arr(tile),"state":str(mark.get("state","idle"))}
				var pump_text=str(mark.get("description",mark.name)) if mark.get("state","")=="idle" else "The pump burned out after draining the "+("residential shelter." if mark.state=="residences" else "utility substation.")
				feedback(pump_text)
			elif mark.kind=="flooded_route":
				var route_text=str(mark.get("description",mark.name))
				if mark.get("state","")=="drained":route_text="The water is falling. This branch is open."
				elif mark.get("state","")=="sealed":route_text="The pump's final cycle sealed this route beneath the water."
				selection={"kind":"lore","text":route_text};feedback(route_text)
			elif mark.kind=="quarter_lore":
				selection={"kind":"lore","text":str(mark.get("description",mark.name))};feedback(selection.text)
			elif mark.kind=="outpost":
				selection={"kind":"outpost","point":world.arr(tile),"state":str(mark.get("state","waiting"))}
				feedback("Low Lantern · Lantern Compact council" if mark.get("state","")=="waiting" else "Low Lantern remembers the expedition's "+str(mark.state)+" choice.")
			elif mark.kind=="outpost_lore":
				selection={"kind":"lore","text":str(mark.get("description",mark.name))};feedback(selection.text)
			elif mark.kind=="bellwether":
				selection={"kind":"bellwether","point":world.arr(tile),"state":str(mark.get("state","waiting"))}
				feedback("Bellwether Lift · two sealed descent systems" if mark.get("state","")=="waiting" else "Bellwether's "+str(mark.state)+" route is fixed.")
			elif mark.kind in ["bellwether_evidence","bellwether_route"]:
				var lift_text=str(mark.get("description",mark.name))
				if mark.kind=="bellwether_route" and mark.get("state","")!="sealed":lift_text+=" Route: "+str(mark.state)+"."
				selection={"kind":"lore","text":lift_text};feedback(lift_text)
			elif mark.kind=="spindle":
				selection={"kind":"spindle","point":world.arr(tile),"state":str(mark.get("state","waiting"))}
				feedback("A living voice waits behind Spindle's quarantine glass." if mark.get("state","")=="waiting" else "Meridian's Gate Watch remembers this expedition.")
			elif mark.kind in ["spindle_lore","spindle_route"]:
				var gate_text=str(mark.get("description",mark.name))
				if mark.kind=="spindle_route":gate_text+=" Approach: "+str(mark.get("state","closed"))+"."
				selection={"kind":"lore","text":gate_text};feedback(gate_text)
			elif mark.kind=="ashline":
				selection={"kind":"ashline","point":world.arr(tile),"state":str(mark.get("state","waiting"))}
				feedback("Officer Tamsin waits behind Ashline's screening desk." if mark.get("state","")=="waiting" else "Ashline's record marks the expedition "+str(mark.state)+".")
			elif mark.kind in ["ashline_lore","ashline_route"]:
				var ash_text=str(mark.get("description",mark.name))
				if mark.kind=="ashline_route":ash_text+=" Route: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":ash_text};feedback(ash_text)
			elif mark.kind=="service_ring":
				selection={"kind":"service_ring","point":world.arr(tile),"state":str(mark.get("state","waiting"))}
				feedback("Registrar Rook is assigning terms to newly cleared outsiders." if mark.get("state","")=="waiting" else "Meridian records the expedition under "+str(mark.state)+" standing.")
			elif mark.kind in ["service_lore","service_option","service_route"]:
				var service_text=str(mark.get("description",mark.name))
				if mark.kind in ["service_option","service_route"]:service_text+=" Status: "+str(mark.get("state","available"))+"."
				selection={"kind":"lore","text":service_text};feedback(service_text)
			elif mark.kind=="foundry":
				selection={"kind":"foundry","point":world.arr(tile),"state":str(mark.get("state","waiting"))}
				feedback("Forewoman Kes checks Rook's standing record against the ward slate." if mark.get("state","")=="waiting" else "Foundry Ward records the expedition as "+str(mark.state)+".")
			elif mark.kind in ["foundry_lore","foundry_contract","foundry_route"]:
				var foundry_text=str(mark.get("description",mark.name))
				if mark.kind in ["foundry_contract","foundry_route"]:foundry_text+=" Status: "+str(mark.get("state","available"))+"."
				selection={"kind":"lore","text":foundry_text};feedback(foundry_text)
			elif mark.kind=="archive":
				selection={"kind":"archive","point":world.arr(tile),"state":str(mark.get("state","waiting"))}
				feedback("Archivist Sen guards a sealed survey record matching the vanished traveler." if mark.get("state","")=="waiting" else "Archive Junction records the traveler's file as "+str(mark.state)+".")
			elif mark.kind in ["archive_lore","archive_choice","archive_route"]:
				var archive_text=str(mark.get("description",mark.name))
				if mark.kind in ["archive_choice","archive_route"]:archive_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":archive_text};feedback(archive_text)
			elif mark.kind=="wake":
				selection={"kind":"wake","point":world.arr(tile),"state":str(mark.get("state","waiting"))}
				feedback(str(mark.name)+(" is ready to open the recovery route." if mark.get("state","")=="waiting" else " records the final survey as "+str(mark.state)+"."))
			elif mark.kind in ["wake_lore","wake_route","wake_exit"]:
				var wake_text=str(mark.get("description",mark.name))
				if mark.kind in ["wake_route","wake_exit"]:wake_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":wake_text};feedback(wake_text)
			elif mark.kind=="quiet_post":
				selection={"kind":"quiet_post","point":world.arr(tile),"stage":int(mark.get("stage",0)),"state":str(mark.get("state","locked"))}
				feedback("Listening post "+str(mark.get("stage",0))+" · "+str(mark.get("state","locked"))+" · darkness and stillness required")
			elif mark.kind=="quiet_receiver":
				selection={"kind":"quiet_receiver","point":world.arr(tile),"state":str(mark.get("state","ready"))}
				feedback("Quiet Mile receiver · "+("the final signal is ready to replay" if world.data.quiet_state=="open" else "three acoustic posts guard the final recording"))
			elif mark.kind in ["quiet_lore","quiet_exit"]:
				var quiet_text=str(mark.get("description",mark.name))
				if mark.kind=="quiet_exit":quiet_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":quiet_text};feedback(quiet_text)
			elif mark.kind=="stillworks":
				selection={"kind":"stillworks","point":world.arr(tile),"state":str(mark.get("state","waiting"))}
				feedback("The Bell manifold is waiting for a permanent life-support route." if mark.get("state","")=="waiting" else "The Stillworks records the "+str(mark.state)+" route as permanent.")
			elif mark.kind in ["stillworks_lore","stillworks_option","stillworks_exit","stillworks_light"]:
				var works_text=str(mark.get("description",mark.name))
				if mark.kind in ["stillworks_option","stillworks_exit"]:works_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":works_text};feedback(works_text)
			elif mark.kind=="cistern":
				selection={"kind":"cistern","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","pressure"))}
				feedback("Water Keeper Nera is waiting with a reservoir request." if mark.get("state","")=="waiting" else "Cistern Spine records the reservoir as "+str(mark.state)+".")
			elif mark.kind in ["cistern_lore","cistern_route","cistern_exit"]:
				var cistern_text=str(mark.get("description",mark.name))
				if mark.kind in ["cistern_route","cistern_exit"]:cistern_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":cistern_text};feedback(cistern_text)
			elif mark.kind in ["drowned_control","drowned_rescue","drowned_salvage"]:
				selection={"kind":str(mark.kind),"point":world.arr(tile),"state":str(mark.get("state","sealed"))}
				var surge=" · %d seconds remain"%int(ceil(float(world.data.drowned_timer))) if world.data.drowned_state=="warning" else ""
				feedback(str(mark.name)+" · "+str(mark.get("state","sealed"))+surge)
			elif mark.kind in ["drowned_safe","drowned_exit"]:
				var drowned_text=str(mark.get("description",mark.name))+" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":drowned_text};feedback(drowned_text)
			elif mark.kind=="tidecourt":
				selection={"kind":"tidecourt","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","recovery"))}
				feedback("Clerk Sable is waiting to record the Gallery outcome." if mark.get("state","")=="waiting" else "Tidecourt records access as "+str(mark.state)+".")
			elif mark.kind in ["tidecourt_lore","tidecourt_route","tidecourt_exit"]:
				var tide_text=str(mark.get("description",mark.name))
				if mark.kind in ["tidecourt_route","tidecourt_exit"]:tide_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":tide_text};feedback(tide_text)
			elif mark.kind=="sump":
				selection={"kind":"sump","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Pumpwright Edda needs the communal pump repaired." if mark.get("state","")=="waiting" else "Sump Commons records the pump as "+str(mark.state)+".")
			elif mark.kind in ["sump_route","sump_foothold","sump_exit"]:
				var sump_text=str(mark.get("description",mark.name))+" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":sump_text};feedback(sump_text)
			elif mark.kind=="market":
				selection={"kind":"market","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Broker Ysra is waiting to match the Commons standing." if mark.get("state","")=="waiting" else "Mainspring records the exchange as "+str(mark.state)+".")
			elif mark.kind in ["market_arcade","market_recruit","market_exit"]:
				var market_text=str(mark.get("description",mark.name))+" Status: "+str(mark.get("state","waiting"))+"."
				selection={"kind":"lore","text":market_text};feedback(market_text)
			elif mark.kind=="depot":
				selection={"kind":"depot","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Dispatcher Jun needs Tavi to read the freight route." if mark.get("state","")=="waiting" else "Clockline Depot records the recovery as "+str(mark.state)+".")
			elif mark.kind in ["depot_lane","depot_exit"]:
				var depot_text=str(mark.get("description",mark.name))+" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":depot_text};feedback(depot_text)
			elif mark.kind=="refuge":
				selection={"kind":"refuge","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Signal Keeper Esi needs the switch hall secured before the evacuation plan is fixed." if mark.get("state","")=="waiting" else "Switchyard Refuge records the permanent plan as "+str(mark.state)+".")
			elif mark.kind in ["refuge_option","refuge_exit","refuge_lore"]:
				var refuge_text=str(mark.get("description",mark.name))
				if mark.kind in ["refuge_option","refuge_exit"]:refuge_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":refuge_text};feedback(refuge_text)
			elif mark.kind=="ashrail":
				selection={"kind":"ashrail","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","corridor"))}
				feedback("Rail Steward Niko needs the opened lane secured and physically supplied." if mark.get("state","")=="waiting" else "Ashrail's far exchange platform is stocked.")
			elif mark.kind in ["ashrail_route","ashrail_exit","ashrail_lore"]:
				var ashrail_text=str(mark.get("description",mark.name))
				if mark.kind in ["ashrail_route","ashrail_exit"]:ashrail_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":ashrail_text};feedback(ashrail_text)
			elif mark.kind=="customs":
				selection={"kind":"customs","point":world.arr(tile),"state":str(mark.get("state","waiting")),"cargo":str(mark.get("cargo","provisions"))}
				feedback("Captain Vara is waiting for a declaration—or a quiet tariff." if mark.get("state","")=="waiting" else "Emberline records the expedition's route as "+str(mark.state)+".")
			elif mark.kind in ["customs_route","customs_exit","customs_lore"]:
				var customs_text=str(mark.get("description",mark.name))
				if mark.kind in ["customs_route","customs_exit"]:customs_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":customs_text};feedback(customs_text)
			elif mark.kind=="railcourt":
				selection={"kind":"railcourt","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","authority"))}
				feedback("Railcourt is offering public switchhouse work." if mark.get("route","")=="authority" and mark.get("state","")=="waiting" else "The resident compact waits beyond the undercroft." if mark.get("state","")=="waiting" else "Railcourt records the expedition as "+str(mark.state)+".")
			elif mark.kind in ["railcourt_route","railcourt_exit","railcourt_lore"]:
				var railcourt_text=str(mark.get("description",mark.name))
				if mark.kind in ["railcourt_route","railcourt_exit"]:railcourt_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":railcourt_text};feedback(railcourt_text)
			elif mark.kind=="registry":
				selection={"kind":"registry","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","official"))}
				feedback("Registrar Kade is offering a public plate audit." if mark.get("route","")=="official" and mark.get("state","")=="waiting" else "Copyist Moss waits beyond the dark copy room." if mark.get("state","")=="waiting" else "Cinder Registry records the expedition as "+str(mark.state)+".")
			elif mark.kind in ["registry_route","registry_exit","registry_lore"]:
				var registry_text=str(mark.get("description",mark.name))
				if mark.kind in ["registry_route","registry_exit"]:registry_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":registry_text};feedback(registry_text)
			elif mark.kind=="morrow":
				selection={"kind":"morrow","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","official"))}
				feedback("Morrow's dispatcher can call the waybill's train." if mark.get("state","")=="waiting" else "Morrow's train is boarding now." if mark.get("state","")=="boarding" else "The expedition caught Morrow's "+str(mark.route)+" freight line.")
			elif mark.kind in ["morrow_route","morrow_exit","morrow_lore"]:
				var morrow_text=str(mark.get("description",mark.name))
				if mark.kind in ["morrow_route","morrow_exit"]:morrow_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":morrow_text};feedback(morrow_text)
			elif mark.kind=="terminus":
				selection={"kind":"terminus","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","official"))}
				feedback("Cairn Reach asks the authority arrival to witness its independence." if mark.get("route","")=="official" and mark.get("state","")=="waiting" else "Cairn Reach's free siding needs its communal lift repaired." if mark.get("state","")=="waiting" else "Cairn Reach records the expedition as "+str(mark.state)+".")
			elif mark.kind in ["terminus_route","terminus_exit","terminus_lore"]:
				var terminus_text=str(mark.get("description",mark.name))
				if mark.kind in ["terminus_route","terminus_exit"]:terminus_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":terminus_text};feedback(terminus_text)
			elif mark.kind=="farline":
				selection={"kind":"farline","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","accord"))}
				feedback("Farline's delegates will open Cairn's witness road." if mark.get("route","")=="accord" and mark.get("state","")=="waiting" else "Farline's cachekeepers will open the free cacheway." if mark.get("state","")=="waiting" else "Farline records the settlement road as "+str(mark.state)+".")
			elif mark.kind in ["farline_route","farline_exit","farline_lore"]:
				var farline_text=str(mark.get("description",mark.name))
				if mark.kind in ["farline_route","farline_exit"]:farline_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":farline_text};feedback(farline_text)
			elif mark.kind=="thimble":
				selection={"kind":"thimble","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","accord"))}
				feedback("Thimble's warning bell offers one prepared choice." if mark.get("state","")=="waiting" else "Thimble's warning is "+str(mark.state)+".")
			elif mark.kind in ["thimble_breach","thimble_evacuation","thimble_exit","thimble_lore"]:
				var thimble_text=str(mark.get("description",mark.name))
				if mark.kind!="thimble_lore":thimble_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":thimble_text};feedback(thimble_text)
			elif mark.kind=="latchwater":
				selection={"kind":"latchwater","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Miri needs the ward's physical heat exchanger." if mark.get("state","") in ["waiting","assigned"] else "Latchwater's heater is set "+str(mark.state)+".")
			elif mark.kind in ["latchwater_route","latchwater_option","latchwater_exit","latchwater_lore"]:
				var latchwater_text=str(mark.get("description",mark.name))
				if mark.kind!="latchwater_lore":latchwater_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":latchwater_text};feedback(latchwater_text)
			elif mark.kind=="driftglass":
				selection={"kind":"driftglass","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","shaded"))}
				feedback("Sela needs the hall's physical focusing prism." if mark.get("state","") in ["waiting","assigned"] else "Driftglass's lens is set "+str(mark.state)+".")
			elif mark.kind in ["driftglass_route","driftglass_option","driftglass_exit","driftglass_lore"]:
				var driftglass_text=str(mark.get("description",mark.name))
				if mark.kind!="driftglass_lore":driftglass_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":driftglass_text};feedback(driftglass_text)
			elif mark.kind=="bellhome":
				selection={"kind":"bellhome","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","darkway"))}
				feedback("Orra is ready to open Bellhome's warned convoy gate." if mark.get("state","")=="waiting" else "Bellhome's convoy is "+str(mark.state)+".")
			elif mark.kind in ["bellhome_route","bellhome_convoy","bellhome_diversion","bellhome_exit","bellhome_lore"]:
				var bellhome_text=str(mark.get("description",mark.name))
				if mark.kind!="bellhome_lore":bellhome_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":bellhome_text};feedback(bellhome_text)
			elif mark.kind=="commons":
				selection={"kind":"commons","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Orra offers Bellhome's housing repair contract." if mark.get("state","") in ["waiting","assigned"] else "Bellhome's homes are repaired through the "+str(mark.route)+" reception.")
			elif mark.kind in ["commons_route","commons_repair","commons_exit","commons_lore"]:
				var commons_text=str(mark.get("description",mark.name))
				if mark.kind!="commons_lore":commons_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":commons_text};feedback(commons_text)
			elif mark.kind=="yard":
				selection={"kind":"yard","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Sori offers Hearthline's communal lift expansion." if mark.get("state","") in ["waiting","assigned"] else "Hearthline's "+str(mark.route)+" lower line is running.")
			elif mark.kind in ["yard_lane","yard_gantry","yard_recruit","yard_exit","yard_lore"]:
				var yard_text=str(mark.get("description",mark.name))
				if mark.kind!="yard_lore":yard_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":yard_text};feedback(yard_text)
			elif mark.kind=="kiln":
				selection={"kind":"kiln","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","shared"))}
				feedback("Pell can survey Kilnreach's abandoned controls." if mark.get("state","")=="waiting" else "Kilnreach's furnace crown is "+str(mark.state)+".")
			elif mark.kind in ["kiln_route","kiln_option","kiln_exit","kiln_lore"]:
				var kiln_text=str(mark.get("description",mark.name))
				if mark.kind!="kiln_lore":kiln_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":kiln_text};feedback(kiln_text)
			elif mark.kind=="junction":
				selection={"kind":"junction","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","shadowline"))}
				feedback("Signalkeeper Ren is watching an unscheduled independent freight signal." if mark.get("state","")=="waiting" else "Embervault's freight warning is "+str(mark.state)+".")
			elif mark.kind in ["junction_route","junction_platform","junction_shunt","junction_exit","junction_lore"]:
				var junction_text=str(mark.get("description",mark.name))
				if mark.kind!="junction_lore":junction_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":junction_text};feedback(junction_text)
			elif mark.kind=="ember_commons":
				selection={"kind":"ember_commons","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Keeper Sable offers Embervault's signal-house repair." if mark.get("state","") in ["waiting","assigned"] else "Embervault's "+str(mark.route)+" signal house is restored.")
			elif mark.kind in ["ember_commons_route","ember_commons_repair","ember_commons_exit","ember_commons_lore"]:
				var ember_text=str(mark.get("description",mark.name))
				if mark.kind!="ember_commons_lore":ember_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":ember_text};feedback(ember_text)
			elif mark.kind=="deepcoil":
				selection={"kind":"deepcoil","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","echo"))}
				feedback("A voice below answers Deepcoil's paired relay." if mark.get("state","") in ["waiting","assigned"] else "Deepcoil records the "+str(mark.route)+" answer.")
			elif mark.kind in ["deepcoil_crown","deepcoil_root","deepcoil_sync","deepcoil_exit","deepcoil_lore"]:
				var deepcoil_text=str(mark.get("description",mark.name))
				if mark.kind!="deepcoil_lore":deepcoil_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":deepcoil_text};feedback(deepcoil_text)
			elif mark.kind=="coilward":
				selection={"kind":"coilward","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","echo"))}
				feedback("Coilward offers a community charter shaped by Deepcoil's answer." if mark.get("state","") in ["waiting","assigned"] else "Coilward's "+str(mark.route)+" charter is ratified.")
			elif mark.kind in ["coilward_route","coilward_seal","coilward_exit","coilward_lore"]:
				var coilward_text=str(mark.get("description",mark.name))
				if mark.kind!="coilward_lore":coilward_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":coilward_text};feedback(coilward_text)
			elif mark.kind=="charterwell":
				selection={"kind":"charterwell","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Charterwell's departure bell recognizes Coilward's signed charter." if mark.get("state","") in ["waiting","warning"] else "Charterwell's delegation road is resolved.")
			elif mark.kind in ["charterwell_route","charterwell_platform","charterwell_supply","charterwell_safe","charterwell_exit","charterwell_lore"]:
				var charterwell_text=str(mark.get("description",mark.name))
				if not mark.kind in ["charterwell_safe","charterwell_lore"]:charterwell_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":charterwell_text};feedback(charterwell_text)
			elif mark.kind=="writwell":
				selection={"kind":"writwell","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","commons"))}
				feedback("Writwell's convener recognizes Charterwell's physical delegation writ." if mark.get("state","") in ["waiting","assigned"] else "Writwell's shared-supply mandate is ratified.")
			elif mark.kind in ["writwell_route","writwell_table","writwell_stores","writwell_exit","writwell_lore"]:
				var writwell_text=str(mark.get("description",mark.name))
				if mark.kind!="writwell_lore":writwell_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":writwell_text};feedback(writwell_text)
			elif mark.kind=="concordance":
				selection={"kind":"concordance","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Concordance recognizes Writwell's physical assembly mandate." if mark.get("state","") in ["waiting","assigned"] else "Concordance's coordinated defense is active.")
			elif mark.kind in ["concordance_route","concordance_bastion","concordance_reserve","concordance_stores","concordance_exit","concordance_lore"]:
				var concordance_text=str(mark.get("description",mark.name))
				if mark.kind!="concordance_lore":concordance_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":concordance_text};feedback(concordance_text)
			elif mark.kind=="reservefall":
				selection={"kind":"reservefall","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","reserve"))}
				feedback("Quarterkeeper Orin recognizes Concordance's physical response token." if mark.get("state","") in ["waiting","warning"] else "Reservefall's lower road is open.")
			elif mark.kind in ["reservefall_route","reservefall_line","reservefall_fallback","reservefall_safe","reservefall_exit","reservefall_lore"]:
				var reservefall_text=str(mark.get("description",mark.name))
				if mark.kind!="reservefall_lore":reservefall_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":reservefall_text};feedback(reservefall_text)
			elif mark.kind=="reserve_commons":
				selection={"kind":"reserve_commons","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Steward Nera recognizes Reservefall's physical quarter pass." if mark.get("state","") in ["waiting","assigned"] else "Reservefall Commons' communal defense is repaired.")
			elif mark.kind in ["reserve_commons_route","reserve_commons_cache","reserve_commons_repair","reserve_commons_exit","reserve_commons_lore"]:
				var reserve_commons_text=str(mark.get("description",mark.name))
				if mark.kind!="reserve_commons_lore":reserve_commons_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":reserve_commons_text};feedback(reserve_commons_text)
			elif mark.kind=="shieldline":
				selection={"kind":"shieldline","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Kest recognizes Reservefall's physical quarter pass." if mark.get("state","") in ["waiting","assigned"] else "Shieldline's mobile walking wall is assembled.")
			elif mark.kind in ["shieldline_lane","shieldline_carriage","shieldline_recruit","shieldline_exit","shieldline_lore"]:
				var shieldline_text=str(mark.get("description",mark.name))
				if mark.kind!="shieldline_lore":shieldline_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":shieldline_text};feedback(shieldline_text)
			elif mark.kind=="marchhold":
				selection={"kind":"marchhold","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Marchwarden Sela asks Kest to ready the walking wall." if mark.get("state","") in ["waiting","warning"] else "Marchhold's lower road is open.")
			elif mark.kind in ["marchhold_route","marchhold_cache","marchhold_line","marchhold_fallback","marchhold_safe","marchhold_exit","marchhold_lore"]:
				var marchhold_text=str(mark.get("description",mark.name))
				if mark.kind!="marchhold_lore":marchhold_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":marchhold_text};feedback(marchhold_text)
			elif mark.kind=="march_refuge":
				selection={"kind":"march_refuge","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Refuge Keeper Orra asks to see Marchhold's physical crossing seal." if mark.get("state","") in ["waiting","assigned"] else "Marchhold Refuge's communal defense is settled.")
			elif mark.kind in ["march_refuge_route","march_refuge_cache","march_refuge_repair","march_refuge_exit","march_refuge_lore"]:
				var march_refuge_text=str(mark.get("description",mark.name))
				if mark.kind!="march_refuge_lore":march_refuge_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":march_refuge_text};feedback(march_refuge_text)
			elif mark.kind=="wallward":
				selection={"kind":"wallward","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Wallward's signal post waits for Marchhold's physical crossing seal." if mark.get("state","") in ["waiting","warning"] else "Wallward's Wayfarer road is open.")
			elif mark.kind in ["wallward_route","wallward_cache","wallward_rally","wallward_screen","wallward_safe","wallward_exit","wallward_lore"]:
				var wallward_text=str(mark.get("description",mark.name))
				if mark.kind not in ["wallward_lore","wallward_safe"]:wallward_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":wallward_text};feedback(wallward_text)
			elif mark.kind in ["wayfarer","wayfarer_repair"]:
				selection={"kind":"wayfarer","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Wayfarer Commons · shared roadstead. Review the tally and nearby packs.")
			elif mark.kind in ["wayfarer_route","wayfarer_cache","wayfarer_exit","wayfarer_lore"]:
				var wayfarer_text=str(mark.get("description",mark.name))
				if mark.kind!="wayfarer_lore":wayfarer_text+=" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":wayfarer_text};feedback(wayfarer_text)
			elif mark.kind in ["underway","underway_light","underway_hide"]:
				selection={"kind":"underway","point":world.arr(tile),"state":str(mark.get("state","waiting")),"route":str(mark.get("route","public"))}
				feedback("Underway Fork · physical survey kit and exact route supplies.")
			elif mark.kind in ["underway_route","underway_cache","underway_exit"]:
				var underway_text=str(mark.get("description",mark.name))+" Status: "+str(mark.get("state","sealed"))+"."
				selection={"kind":"lore","text":underway_text};feedback(underway_text)
			else: world.data.rumor=true; feedback("Scratched into stone: 'The city still breathes. Follow the old mine shafts.'")
			_refresh(); return
	var f = world.floor_at(z)
	if tile == world.vec(f.down) or tile == world.vec(f.up):
		selection={"kind":"stairs","destination":z+(1 if tile == world.vec(f.down) else -1)}
		_refresh(); return
	var s = world.structure_at(z,tile)
	if not s.is_empty():
		selection={"kind":"structure","id":int(s.id),"recipe":str(s.kind),"point":world.arr(tile)}
		if s.kind=="tripwire":
			var alarm_state=str(s.get("state","armed"))
			feedback("Tripwire alarm · "+("ringing after "+str(s.get("triggered_by","unknown threat")) if alarm_state=="ringing" else "spent; send a colonist to reset it" if alarm_state=="spent" else "armed and watching this passage"))
		else:feedback(World.RECIPES[s.kind].name+" · can be packed into recoverable materials.")
		_refresh();return
	selection.clear()
	execute(world.order_walk(selected,tile,queue_mode))

func context_action():
	var p = world.data.pawns[selected]
	# The explicit sidebar remains usable while a tap's approach is in flight.
	if not queue_mode and p.job.get("kind","")=="interact":world.cancel(selected)
	if not selection.is_empty():
		match selection.kind:
			"container":
				var c = world.container_by_id(p.z,selection.id)
				if c.is_empty(): selection.clear(); return
				if c.searched: open_inventory(c.id)
				else: execute(world.order_search(selected,c.id,queue_mode))
			"enemy": execute(world.target_enemy(selected,selection.id))
			"patient":
				var patient_index=int(selection.get("index",-1));var patient=world.data.pawns[patient_index] if patient_index>=0 and patient_index<world.data.pawns.size() else {}
				if patient.is_empty():feedback("That colonist is no longer here.")
				elif world.pawn_at_bed(patient).is_empty():execute(world.order_rescue(selected,patient_index,queue_mode))
				else:execute(world.order_tend(selected,patient_index,queue_mode))
			"traveler": execute(world.order_talk(selected,queue_mode))
			"recruit":execute(world.order_recruit(selected,queue_mode))
			"station":show_station()
			"lore":feedback(str(selection.get("text","The ruin has nothing more to say.")))
			"hazard":feedback(str(selection.get("text","The supports complain under the stone.")))
			"spring":show_spring()
			"pump":show_pump()
			"outpost":show_outpost()
			"bellwether":show_bellwether()
			"spindle":show_spindle()
			"ashline":show_ashline()
			"service_ring":show_service_ring()
			"foundry":show_foundry()
			"archive":show_archive()
			"wake":show_wake()
			"quiet_post","quiet_receiver":show_quiet()
			"stillworks":show_stillworks()
			"cistern":show_cistern()
			"drowned_control","drowned_rescue","drowned_salvage":show_drowned()
			"tidecourt":show_tidecourt()
			"sump":show_sump()
			"market":show_market()
			"depot":show_depot()
			"refuge":show_refuge()
			"ashrail":show_ashrail()
			"customs":show_customs()
			"railcourt":show_railcourt()
			"registry":show_registry()
			"morrow":show_morrow()
			"terminus":show_terminus()
			"farline":show_farline()
			"thimble":show_thimble()
			"latchwater":show_latchwater()
			"driftglass":show_driftglass()
			"bellhome":show_bellhome()
			"commons":show_commons()
			"yard":show_yard()
			"kiln":show_kiln()
			"junction":show_junction()
			"ember_commons":show_ember_commons()
			"deepcoil":show_deepcoil()
			"coilward":show_coilward()
			"charterwell":show_charterwell()
			"writwell":show_writwell()
			"concordance":show_concordance()
			"reservefall":show_reservefall()
			"reserve_commons":show_reserve_commons()
			"shieldline":show_shieldline()
			"marchhold":show_marchhold()
			"march_refuge":show_march_refuge()
			"wallward":show_wallward()
			"wayfarer":show_wayfarer()
			"underway":show_underway()
			"stairs": execute(world.order_travel(selected,selection.destination,queue_mode))
			"structure":show_structure()
			"designation":
				var error=world.cancel_designation(p.z,int(selection.id))
				selection.clear()
				if error=="":feedback("Blueprint cancelled. Delivered supplies remain here.");_refresh();save_game()
				else:execute(error)
		return
	if not world.data.traveler and p.z == 0: execute(world.order_talk(selected,queue_mode)); return
	var nearest: Dictionary = {}
	var distance = INF
	for c in world.floor_at(p.z).containers:
		if c.get("kind","")=="blueprint":continue
		if not world.floor_at(p.z).seen.has(world.cell_key(world.point(c))): continue
		var d = world.point(p).distance_squared_to(world.point(c))
		if d < distance: nearest=c; distance=d
	if nearest.is_empty(): feedback("Follow an open passage to reveal more of this level.")
	else:
		selection={"kind":"container","id":nearest.id}
		if nearest.searched: open_inventory(nearest.id)
		else: execute(world.order_search(selected,nearest.id,queue_mode))

func make_popup(title: String, width: int = 740) -> VBoxContainer:
	close_popup()
	popup = Control.new()
	popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(popup)
	var shade = ColorRect.new()
	shade.color = Color(0.015,0.025,0.03,.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.add_child(shade)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.add_child(center)
	var panel = PanelContainer.new()
	panel.custom_minimum_size.x = min(width,size.x-30)
	panel.add_theme_stylebox_override("panel",box("182b31","567571",10))
	center.add_child(panel)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation",8)
	panel.add_child(column)
	var heading = HBoxContainer.new()
	column.add_child(heading)
	var name_label = text_label(title,25,"ecc892")
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(name_label)
	heading.add_child(button("Close",close_popup,40))
	return column

func close_popup():
	if popup_kind == "intro": started = true
	if popup_kind in ["intro","story","station","recruit","spring","pump","outpost","bellwether","spindle","ashline","service_ring","foundry","archive","wake","quiet","stillworks","cistern","drowned","tidecourt","sump","market","depot","refuge","ashrail","customs","railcourt","registry","morrow","terminus","farline","thimble","latchwater","driftglass","bellhome","commons","yard","kiln","junction","ember_commons","deepcoil","coilward","charterwell","writwell","concordance","reservefall","reserve_commons","shieldline","marchhold","march_refuge","wallward","wayfarer","underway","structure"] and world:world.data.paused=false
	if is_instance_valid(popup): popup.queue_free()
	popup=null; popup_kind=""

func show_intro():
	world.data.paused = true
	var col = make_popup("THE WORLD ABOVE IS GONE",740)
	popup_kind="intro"
	var intro = text_label("Ash and Iona followed the last working stairwell underground. A traveler waits beside the shelter.\n\nFIRST STEPS\n1 · Tap the traveler — a colonist walks over and speaks on arrival.\n2 · Tap Shelter supplies and search it.\n3 · Open Inventory and move 4 timber + 2 scrap into one pack.\n4 · Open Build, choose Selected Colonist and place a Workbench.\n\nCamps offer safety for a while. Their warmth can also tell the things above exactly where you are.",19)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(intro)
	col.add_child(text_label("The objective bar keeps the current step visible. Lists scroll by pressing and dragging up or down.",17,"9dbbb0"))
	col.add_child(button("Begin the descent",func(): started=true; world.data.paused=false; close_popup(); _refresh(),54,true))

func show_story():
	world.data.paused = true
	var col = make_popup("A RUMOR BELOW",760)
	popup_kind="story"
	var story = text_label("“There is a city below the old mines. Warm lights. Clean water. A place the surface hasn't found.”\n\n“Keep your fires small. Keep your packs close. When you hear the scratching, don't wait for it to stop.”\n\nThe traveler passes into the dark. You look away for a moment. When you look back, no one is there.",20)
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(story)
	col.add_child(button("Find out if the city is real",func(): close_popup(); world.data.paused=false; _refresh(),54,true))

func show_station():
	world.data.paused=true
	var col=make_popup("CINDER WAYSTATION",760)
	popup_kind="station"
	var copy="A patched lantern burns above a barricaded transit kiosk. Vale has kept this place alive alone.\n\n‘Two rations and a medkit. Help me get steady, and I’ll travel with you.’" if not world.data.recruit_joined else "The old kiosk is still scarred and cold, but three bedrolls now sit beneath its patched lantern."
	var story=text_label(copy,20);story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
	col.add_child(button("Return to the transit ruins",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_recruit():
	world.data.paused=true
	var col=make_popup("VALE JOINS",720)
	popup_kind="recruit"
	var story=text_label("Vale eats slowly, binds an old wound, and shoulders an empty pack.\n\n‘The station is done. Let’s see whether your city is real.’\n\nVale is now fully selectable, with practiced combat and scavenging skills.",20)
	story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
	col.add_child(button("Three descend",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_spring():
	var pawn=world.data.pawns[selected]
	var spring:Dictionary={}
	for mark in world.floor_at(pawn.z).landmarks:
		if mark.get("kind","")=="spring" and (not selection.has("point") or world.point(mark)==world.vec(selection.point)):
			spring=mark;break
	if spring.is_empty():feedback("The luminous spring is not on this level.");return
	world.data.paused=true
	var col=make_popup("LUMINOUS SPRING",760)
	popup_kind="spring"
	var state=str(spring.get("state","untouched"))
	if state=="untouched":
		var story=text_label("Cold mineral water shines beneath a thin crystal skin. The spring holds one choice for the whole expedition.\n\nDrink: the chosen colonist recovers 35 health, 35 hunger, and one injury step.\nHarvest: drain the pool and leave exactly 3 glowstone on the cavern floor.",19)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		col.add_child(button("Drink · heal and ease injury",func():close_popup();world.data.paused=false;execute(world.order_spring(selected,"drink",queue_mode));_refresh(),52,true))
		col.add_child(button("Harvest · leave 3 glowstone",func():close_popup();world.data.paused=false;execute(world.order_spring(selected,"harvest",queue_mode));_refresh(),52))
	else:
		var outcome="The luminous water was drunk. The pool is clear and still." if state=="drunk" else "The spring was drained. Broken crystal remains in the limestone."
		col.add_child(text_label(outcome+"\n\nThis choice belongs to the expedition and will not return.",20))
		col.add_child(button("Return to the caverns",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_pump():
	var pawn=world.data.pawns[selected]
	var console:Dictionary={}
	for mark in world.floor_at(pawn.z).landmarks:
		if mark.get("kind","")=="pump_console" and (not selection.has("point") or world.point(mark)==world.vec(selection.point)):
			console=mark;break
	if console.is_empty():feedback("There is no emergency pump on this level.");return
	world.data.paused=true
	var col=make_popup("EMERGENCY PUMP",790)
	popup_kind="pump"
	var state=str(console.get("state","idle"))
	if state=="idle":
		var story=text_label("The civic pump can reclaim one branch before its windings burn out. The other will remain submerged for this expedition.\n\nResidential shelter: 4 rations, 2 medkits and a reinforced coat.\nUtility substation: 6 scrap, 4 glowstone and 2 timber.\n\nA colonist must operate the console; recovered supplies remain inside an unsearched physical cache.",19)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		col.add_child(button("Drain residential shelter",func():close_popup();world.data.paused=false;execute(world.order_pump(selected,"residences",queue_mode));_refresh(),52,true))
		col.add_child(button("Drain utility substation",func():close_popup();world.data.paused=false;execute(world.order_pump(selected,"substation",queue_mode));_refresh(),52))
	else:
		var outcome="The residential shelter was reclaimed. The substation is lost below the water." if state=="residences" else "The utility substation was reclaimed. The residential shelter is lost below the water."
		col.add_child(text_label(outcome+"\n\nThe pump is burned out. This district remembers the decision.",20))
		col.add_child(button("Return to the quarter",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_outpost():
	var council=world.outpost_landmark()
	if council.is_empty():feedback("Low Lantern has not been reached.");return
	world.data.paused=true
	var col=make_popup("LOW LANTERN · LANTERN COMPACT",830)
	popup_kind="outpost"
	var state=str(council.get("state","waiting"))
	if state=="waiting":
		var story=text_label("A hundred people live behind Low Lantern's patched freight gate. Their scouts know the routes below, including where safe-city couriers last passed. The council will share its chart after one permanent choice.\n\nAID THE WARD · carry 3 rations and 1 medkit. The Compact opens its sanctuary; idle colonists recover fatigue here.\n\nTRADE FOR SUPPLIES · carry 4 scrap and 2 glowstone. Receive a physical crate with 5 rations, 2 medkits and a reinforced coat.\n\nEither choice reveals the route. Supplies leave the selected colonist's own pack only after they reach the council.",19)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		col.add_child(button("Aid ward · 3 rations + 1 medkit",func():close_popup();world.data.paused=false;execute(world.order_outpost(selected,"aid",queue_mode));_refresh(),52,true))
		col.add_child(button("Trade · 4 scrap + 2 glowstone",func():close_popup();world.data.paused=false;execute(world.order_outpost(selected,"trade",queue_mode));_refresh(),52))
	else:
		var outcome="You aided the fever ward. Low Lantern is a sanctuary: idle colonists recover fatigue while they remain here." if state=="aid" else "You made the Compact's trade. Their survival crate remains physical property on the outpost floor until hauled."
		var result=text_label(outcome+"\n\nThe chart is precise: descend to depth 8 and follow three white bars to Bellwether Lift. Compact couriers saw safe-city traffic there recently.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Follow the three white bars",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_bellwether():
	var control=world.bellwether_landmark()
	if control.is_empty():feedback("Bellwether Lift has not been reached.");return
	world.data.paused=true
	var col=make_popup("BELLWETHER LIFT · DEPTH 8",830)
	popup_kind="bellwether"
	var state=str(control.get("state","waiting"))
	if state=="waiting":
		var marked_cost="The ward's lantern phrase releases the brake with no materials." if world.data.outpost_choice=="aid" else "The traded chart is right, but the brake needs 2 carried scrap and 1 glowstone."
		var story=text_label("The Compact account holds: fresh boot mud, warm wax and a two-shift-old manifest all carry the same safe-city water seal. Both routes descend, but Bellwether can open only one.\n\nTHREE-BAR COURIER CAGE · "+marked_cost+" Opens a safer marked route and a physical satchel with 2 rations and 1 medkit.\n\nMAINTENANCE BYPASS · no material cost. Opens an unmarked trench with 4 scrap and 2 glowstone—and a waiting burrower.\n\nThe chosen exit becomes this floor's lower stair and persists for the expedition.",18)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		if world.data.outpost_choice=="":
			col.add_child(text_label("Return to Low Lantern and secure the Compact chart before operating the lift.",17,"e2a178"))
		else:
			var courier_label="Open courier cage · trusted access" if world.data.outpost_choice=="aid" else "Repair courier cage · 2 scrap + 1 glowstone"
			col.add_child(button(courier_label,func():close_popup();world.data.paused=false;execute(world.order_bellwether(selected,"courier",queue_mode));_refresh(),52,true))
			col.add_child(button("Open maintenance bypass · wake burrower",func():close_popup();world.data.paused=false;execute(world.order_bellwether(selected,"maintenance",queue_mode));_refresh(),52))
	else:
		var outcome="The three-bar courier cage is open. A fresh satchel remains physical property beside the lower landing." if state=="courier" else "The maintenance counterweight is open. Industrial salvage and a disturbed burrower wait beside the lower landing."
		var result=text_label(outcome+"\n\nBellwether's manifest confirms that safe-city couriers continued toward Spindle Gate within the last two shifts.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Continue toward Spindle Gate",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_spindle():
	var watch=world.spindle_landmark()
	if watch.is_empty():feedback("Spindle Gate has not been reached.");return
	world.data.paused=true
	var col=make_popup("SPINDLE GATE · MERIDIAN PERIMETER",840)
	popup_kind="spindle"
	var state=str(watch.get("state","waiting"))
	if state=="waiting":
		var route_text="The three-bar cage delivered you to an intact quarantine lane. The Gate Watch recognizes the Compact seals." if world.data.bellwether_choice=="courier" else "The counterweight delivered you through a torn service intake. The Gate Watch refuses to cycle the threshold while burrowers remain inside the perimeter."
		var consequence="Answer the watch to open the threshold and receive a physical relief locker with 3 rations and 2 medkits." if world.data.bellwether_choice=="courier" else "Clear every burrower on this floor, then answer the watch. Meridian will open the service threshold and leave 3 scrap, 2 glowstone and 1 medkit in a physical repair cache."
		var story=text_label("A rifle port tracks the expedition. Behind armored glass, a woman lowers her mask.\n\n‘Mara, Spindle Watch. The city is Meridian. If you came for a miracle, turn around. If you came alive, state your route.’\n\n"+route_text+"\n\n"+consequence,18)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		var threats=world.floor_at(9).enemies.any(func(enemy):return enemy.hp>0)
		var answer=button("Answer Gate Watch Mara",func():close_popup();world.data.paused=false;execute(world.order_spindle(selected,queue_mode));_refresh(),54,true)
		answer.disabled=world.data.bellwether_choice=="maintenance" and threats
		col.add_child(answer)
		if answer.disabled:col.add_child(text_label("The service intake is still unsafe. The living burrowers are marked on the map.",16,"e2a178"))
	else:
		var outcome="Mara recognized the three-bar courier seals and opened Meridian's quarantine threshold. The relief locker remains on the floor until hauled." if state=="recognized" else "After the breach was cleared, Mara opened Meridian's service threshold. The repair cache remains on the floor until hauled."
		var result=text_label(outcome+"\n\nThe safe city is real, but Spindle is only its outer quarantine. The Gate Watch directs the expedition to Ashline checkpoint below; no promise of admission was made.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Continue toward Ashline",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_ashline():
	var officer=world.ashline_landmark()
	if officer.is_empty():feedback("Ashline checkpoint has not been reached.");return
	world.data.paused=true
	var col=make_popup("ASHLINE · MERIDIAN QUARANTINE",850)
	popup_kind="ashline"
	var state=str(officer.get("state","waiting"))
	if state=="waiting":
		var roster:Array=[]
		for pawn in world.data.pawns:
			if pawn.hp>0:roster.append(str(pawn.name)+" · "+World.INJURY_LEVELS[int(pawn.injury)].capitalize()+" · fatigue "+str(int(pawn.fatigue))+"% · "+world.morale_state(pawn).capitalize())
		var story=text_label("Ashline's lamps are painfully white. Officer Tamsin records each face, wound and carried item before speaking.\n\n‘Spindle says you survived the road. Survival is not clearance. Our decontamination scrubber failed with a purifier cartridge trapped in its sealed service wing. Bring it back intact and I can justify opening the city-side threshold.’\n\nQUARANTINE ROSTER\n"+"\n".join(roster)+"\n\nAccepting opens the scrubber wing. The cartridge remains a physical item: search its case, carry exactly one back, and clear the breach threat before Ashline cycles the door.",18)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		col.add_child(button("Accept scrubber recovery",func():close_popup();world.data.paused=false;execute(world.order_ashline(selected,"accept",queue_mode));_refresh(),54,true))
	elif state=="assigned":
		var pawn=world.data.pawns[selected];var has_filter=int(pawn.inventory.get("filter",0))>0
		var threats=world.floor_at(11).enemies.any(func(enemy):return enemy.hp>0)
		var guidance="The selected colonist carries the purifier cartridge." if has_filter else "Search the scrubber case, then take the purifier cartridge into this colonist's own pack."
		if threats:guidance+=" The breach burrower must also be cleared before quarantine can cycle."
		var story=text_label("The scrubber service wing is open. Tamsin keeps the city-side pressure door sealed until the cartridge returns and the breach is quiet.\n\n"+guidance+"\n\nCompletion consumes exactly one carried cartridge. Meridian will leave 2 rations and 1 medkit as physical field payment beside the threshold.",19)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		var deliver=button("Deliver purifier cartridge",func():close_popup();world.data.paused=false;execute(world.order_ashline(selected,"deliver",queue_mode));_refresh(),54,true)
		deliver.disabled=not has_filter or threats;col.add_child(deliver)
	else:
		var result=text_label("The restored purifier hums behind the wall. Ashline's slate now reads PROVISIONAL FIELD ACCESS beside the expedition's names.\n\nThe connected lower threshold is open into Meridian's service ring. Tamsin warns that entry is employment, scrutiny and obligation—not sanctuary. The field payment remains on the floor until physically hauled.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Enter Meridian's service ring",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_service_ring():
	var registrar=world.service_landmark()
	if registrar.is_empty():feedback("Meridian's service ring has not been reached.");return
	world.data.paused=true
	var col=make_popup("MERIDIAN SERVICE RING · STANDING TERMS",860)
	popup_kind="service_ring"
	var state=str(registrar.get("state","waiting"))
	if state=="waiting":
		var story=text_label("The first district inside Meridian is all pipes, shift bells and people moving with stamped work tabs. Registrar Rook studies Ashline's clearance, then offers two permanent forms of standing.\n\nCITY QUARTERS · one colonist completes a full utility shift. The expedition becomes a municipal crew, gains a quiet dormitory where idle colonists recover fatigue, and receives a physical allotment of 2 rations and 1 medkit.\n\nINDEPENDENT FIELD CHARTER · carry exactly 3 scrap and 2 glowstone. Meridian opens a shielded construction berth that cuts camp-pressure gain on this floor by 55%, plus physical stores containing 4 timber and 1 ration.\n\nEither choice opens the connected lower service lock. The other offer closes permanently.",18)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		col.add_child(button("City quarters · work one shift",func():close_popup();world.data.paused=false;execute(world.order_service(selected,"city",queue_mode));_refresh(),54,true))
		var field_button=button("Field charter · 3 scrap + 2 glowstone",func():close_popup();world.data.paused=false;execute(world.order_service(selected,"field",queue_mode));_refresh(),54)
		var pawn=world.data.pawns[selected];field_button.disabled=int(pawn.inventory.get("scrap",0))<3 or int(pawn.inventory.get("crystal",0))<2;col.add_child(field_button)
		if field_button.disabled:col.add_child(text_label("The selected colonist does not carry the charter materials.",16,"e2a178"))
	else:
		var outcome="The expedition is registered as a municipal crew. Idle colonists recover fatigue in the opened city dormitory; the worker allotment remains physical property until hauled." if state=="city" else "The expedition retained independent standing. Camp pressure rises 55% more slowly on this service-ring floor; the berth stores remain physical property until hauled."
		var result=text_label(outcome+"\n\nRook opened the lower service lock, but Meridian's promise is clearer now: safety here is maintained by obligations, not given freely.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Follow Meridian deeper",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_foundry():
	var forewoman=world.foundry_landmark()
	if forewoman.is_empty():feedback("Foundry Ward has not been reached.");return
	world.data.paused=true
	var col=make_popup("FOUNDRY WARD · STANDING CONTRACT",870)
	popup_kind="foundry"
	var state=str(forewoman.get("state","waiting"));var standing=str(world.data.service_choice);var pawn=world.data.pawns[selected]
	if state=="waiting" and standing=="city":
		var story=text_label("Foundry Ward is louder than the service ring: casting bells, water hammers and hundreds of workers behind heat glass. Forewoman Kes reads the municipal stamp on Rook's slate.\n\n‘City quarters mean city duty. Our furnace regulator failed inside a line a burrower has occupied. Open the line, search the service case, carry exactly one regulator back and clear the threat. Restore public heat and I open the freight gate.’\n\nCompletion consumes the physical regulator, grants the worker 2 practiced building ranks and leaves a municipal tool issue containing 3 scrap and one reinforced coat.",18)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		col.add_child(button("Accept municipal furnace repair",func():close_popup();world.data.paused=false;execute(world.order_foundry(selected,"accept",queue_mode));_refresh(),54,true))
	elif state=="waiting" and standing=="field":
		var story=text_label("Foundry Ward is louder than the service ring: casting bells, water hammers and hundreds of workers behind heat glass. Forewoman Kes reads the independent field charter on Rook's slate.\n\n‘No city duty, then no city subsidy. Post a material bond of exactly 5 scrap and 2 glowstone. We cast what Meridian needs, you keep your independence, and I open the freight gate.’\n\nThe selected colonist must physically carry the full bond. Completion leaves contractor surplus containing 3 timber, 2 rations and 1 medkit.",18)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		var contract=button("Post bond · 5 scrap + 2 glowstone",func():close_popup();world.data.paused=false;execute(world.order_foundry(selected,"contract",queue_mode));_refresh(),54,true)
		contract.disabled=int(pawn.inventory.get("scrap",0))<5 or int(pawn.inventory.get("crystal",0))<2;col.add_child(contract)
		if contract.disabled:col.add_child(text_label("The selected colonist does not carry the full material bond.",16,"e2a178"))
	elif state=="assigned":
		var has_regulator=int(pawn.inventory.get("coil",0))>0;var threats=world.floor_at(13).enemies.any(func(enemy):return enemy.hp>0)
		var guidance="The selected colonist carries the foundry regulator." if has_regulator else "Search the opened service case and take its one foundry regulator into this colonist's pack."
		if threats:guidance+=" The burrower inside the repair line must also be cleared."
		var story=text_label("The failed municipal furnace line is open. Kes will not restart it until the physical regulator returns and the occupied line is safe.\n\n"+guidance+"\n\nThe regulator is consumed only when the repair completes.",19)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		var deliver=button("Install foundry regulator",func():close_popup();world.data.paused=false;execute(world.order_foundry(selected,"deliver",queue_mode));_refresh(),54,true)
		deliver.disabled=not has_regulator or threats;col.add_child(deliver)
	else:
		var outcome="The repaired municipal furnace carries the expedition's work stamp. The completing colonist gained two building ranks; the tool issue remains physical property on the floor." if state=="municipal" else "The independent material bond is cast into Meridian's infrastructure. The expedition kept its field standing; contractor surplus remains physical property on the floor."
		var result=text_label(outcome+"\n\nKes has opened the connected lower freight gate. The service-ring choice now has a concrete cost—and a different reward—inside the city.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Continue through Meridian",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_archive():
	var archivist=world.archive_landmark()
	if archivist.is_empty():feedback("Archive Junction has not been reached.");return
	world.data.paused=true
	var col=make_popup("ARCHIVE JUNCTION · THE VANISHED TRAVELER",890)
	popup_kind="archive"
	var state=str(archivist.get("state","waiting"));var pawn=world.data.pawns[selected]
	if state=="waiting":
		var story=text_label("Archive Junction is quieter than the foundry: staffed reading bays, sealed route surveys and walls of names that never came home. Archivist Sen recognizes the traveler's description in Meridian's missing-surveyor index.\n\nThe city once sent route surveyors outward carrying one deliberate rumor: warm lights, clean water, a safe city below. The traveler who found your shelter was one of them—and left an instruction that the rumor should keep moving if they vanished.\n\nSen can open the sealed stacks, but the original dossier must be searched and physically carried back before its custody is decided.",18)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		col.add_child(button("Open the sealed survey stacks",func():close_popup();world.data.paused=false;execute(world.order_archive(selected,"open",queue_mode));_refresh(),54,true))
	elif state=="assigned":
		var has_dossier=int(pawn.inventory.get("dossier",0))>0
		var guidance="The selected colonist carries the only physical dossier." if has_dossier else "Search the opened survey file and take its one dossier into this colonist's pack."
		var story=text_label("The file proves the traveler was a Meridian route surveyor, not a wandering stranger. Their return line was cut after they chose to keep the safe-city rumor moving.\n\n"+guidance+"\n\nSHARE · return the original to Meridian's public archive, raising expedition morale and receiving 2 rations, 1 medkit and 1 glowstone.\n\nPRESERVE · keep the dossier in this colonist's physical pack; Sen quietly reveals an unindexed cache with 3 scrap and 2 glowstone.\n\nEither permanent decision opens the connected lower catalog gate.",18)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		var share=button("Share dossier with Meridian",func():close_popup();world.data.paused=false;execute(world.order_archive(selected,"share",queue_mode));_refresh(),54,true)
		share.disabled=not has_dossier;col.add_child(share)
		var preserve=button("Preserve dossier in expedition pack",func():close_popup();world.data.paused=false;execute(world.order_archive(selected,"preserve",queue_mode));_refresh(),54)
		preserve.disabled=not has_dossier;col.add_child(preserve)
		if not has_dossier:col.add_child(text_label("The selected colonist does not carry the traveler dossier.",16,"e2a178"))
	else:
		var outcome="The original dossier now belongs to Meridian's public archive. The expedition gave the missing surveyor a name in the city record, and the witness allotment remains physical property until hauled." if state=="shared" else "The original dossier remains in the expedition pack. Meridian's public index stays incomplete, while the unindexed route and survey cache remain available."
		var result=text_label(outcome+"\n\nThe traveler did not simply disappear into the dark: they chose to make the rumor outlive them. Archive Junction's lower catalog gate is open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Follow the survey route deeper",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_wake():
	var contact=world.wake_landmark()
	if contact.is_empty():feedback("Surveyor's Wake has not been reached.");return
	world.data.paused=true
	var col=make_popup("SURVEYOR'S WAKE · LAST RECOVERY",900)
	popup_kind="wake"
	var state=str(contact.get("state","waiting"));var custody=str(world.data.archive_choice);var pawn=world.data.pawns[selected]
	if state=="waiting":
		var official=custody=="shared"
		var story_text="The public dossier reached Meridian before you. Rescue Marshal Rell has come to Surveyor's Wake with a marked gallery key and can hold one flank while you recover the missing team's survey compass." if official else "The dossier in your pack contains annotations Meridian never indexed. They reveal an unmarked crawl from Surveyor's Wake, but no city escort will enter it."
		story_text+="\n\nThe route opens only when this recovery begins. Search the field case, physically carry its one compass back, and clear every burrower before the final descent can be aligned.\n\n"+("OFFICIAL ROUTE · one burrower; completion leaves 3 rations and 2 medkits." if official else "UNINDEXED ROUTE · two burrowers; completion leaves 4 scrap and 3 glowstone. The dossier remains in the selected colonist's pack.")
		var story=text_label(story_text,18);story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		var start=button("Join Marshal Rell's recovery" if official else "Follow the traveler's annotations",func():close_popup();world.data.paused=false;execute(world.order_wake(selected,"start",queue_mode));_refresh(),54,true)
		start.disabled=not official and int(pawn.inventory.get("dossier",0))<1;col.add_child(start)
		if start.disabled:col.add_child(text_label("The selected colonist must carry the preserved traveler dossier.",16,"e2a178"))
	elif state=="assigned":
		var has_compass=int(pawn.inventory.get("compass",0))>0;var threats=world.floor_at(15).enemies.any(func(enemy):return enemy.hp>0)
		var guidance="The selected colonist carries the recovered survey compass." if has_compass else "Search the missing survey team's field case and take its one compass into this colonist's pack."
		if threats:guidance+=" The recovery route is still occupied; every burrower must be cleared."
		var story=text_label("The "+("marked recovery gallery" if custody=="shared" else "unindexed survey crawl")+" is open. The compass is physical evidence and will be consumed only when the route is aligned.\n\n"+guidance+"\n\nThe last route board reads: QUIET MILE · LISTEN BEFORE LIGHT.",19)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		var finish=button("Return compass to Marshal Rell" if custody=="shared" else "Align compass with the waymark",func():close_popup();world.data.paused=false;execute(world.order_wake(selected,"finish",queue_mode));_refresh(),54,true)
		finish.disabled=not has_compass or threats;col.add_child(finish)
	else:
		var outcome="Marshal Rell recorded the lost team and aligned Meridian's safe approach. The recovery allotment remains physical property until hauled." if state=="marshal" else "The compass matched the traveler's private annotations. The hidden cache remains physical property, and the preserved dossier is still in the expedition pack."
		var result=text_label(outcome+"\n\nThe connected descent to Quiet Mile is open. Whatever the traveler found below, their warning is unambiguous: listen before light.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Follow the final waymark",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_quiet():
	if selection.is_empty() or not selection.get("kind","") in ["quiet_post","quiet_receiver"]:return
	world.data.paused=true
	var col=make_popup("QUIET MILE · LISTEN BEFORE LIGHT",900)
	popup_kind="quiet"
	var pawn=world.data.pawns[selected]
	if selection.kind=="quiet_post":
		var stage=int(selection.get("stage",0));var post=world.quiet_post(stage)
		if post.is_empty():close_popup();feedback("That listening post is gone.");return
		var state=str(post.get("state","locked"));var silence=world.quiet_error(selected,world.point(post))
		var copy="Tune the three acoustic gates in order. The worker needs darkness; nearby companions must be still; alarms and clatter beacons must be silent.\n\nGloam stalkers hunt lantern light and work noise. Still darkness hides you, but calibration itself can be heard."
		if state=="available":
			copy+="\n\nListening post "+str(stage)+" is next. "+("The conditions are quiet enough to begin." if silence=="" else silence)
			var tune=button("Tune listening post "+str(stage),func():close_popup();world.data.paused=false;execute(world.order_quiet(selected,"tune",stage,queue_mode));_refresh(),54,true)
			var available_copy=text_label(copy,18);available_copy.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
			tune.disabled=silence!="";col.add_child(available_copy);col.add_child(tune)
		elif state=="complete":
			copy+="\n\nListening post "+str(stage)+" is calibrated. "+("The recorder alcove is open; search it and physically carry the signal tape back to the receiver." if world.data.quiet_state=="open" else "The next acoustic gate is open.")
			var complete_copy=text_label(copy,18);complete_copy.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(complete_copy)
		else:
			copy+="\n\nListening post "+str(stage)+" is still locked. Tune the earlier post first."
			var locked_copy=text_label(copy,18);locked_copy.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(locked_copy)
	else:
		var state=str(world.data.quiet_state)
		if state=="heard":
			var heard_copy=text_label("The traveler's last recording now plays through the dark receiver. Their voice confirms a surviving maintenance route below Meridian and warns that its lower intake is being deliberately kept dark.\n\nThe physical signal tape remains in its colonist's pack. The lower stair is open, and the expedition's morale has risen.",19);heard_copy.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(heard_copy)
			col.add_child(button("Follow the maintenance bells",func():close_popup();world.data.paused=false;_refresh(),52,true))
		elif state=="open":
			var has_tape=int(pawn.inventory.get("tape",0))>0;var receiver=world.quiet_receiver_landmark();var silence=world.quiet_error(selected,world.point(receiver))
			var guidance="The selected colonist carries the traveler's signal tape." if has_tape else "Search the opened recorder alcove and take its one physical signal tape into this colonist's pack."
			if silence!="":guidance+=" "+silence
			var playback_copy=text_label("All three posts are tuned. Return the recording to this receiver in still darkness. Replaying it opens the connected lower stair but does not consume or transfer the tape.\n\n"+guidance,19);playback_copy.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(playback_copy)
			var play=button("Replay traveler's final signal",func():close_popup();world.data.paused=false;execute(world.order_quiet(selected,"play",0,queue_mode));_refresh(),54,true)
			play.disabled=not has_tape or silence!="";col.add_child(play)
		else:
			var waiting_copy=text_label("The receiver catches three faint carrier tones from deeper in the conduit. Tune each listening post in order, without lantern light and while nearby companions remain still. Each calibration opens the next acoustic gate.\n\nThe first post is marked on the explored route. Gloam stalkers beyond it see light and hear work, but lose motionless colonists in darkness.",19);waiting_copy.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(waiting_copy)

func show_stillworks():
	var manifold=world.stillworks_landmark()
	if manifold.is_empty():feedback("The Stillworks has not been reached.");return
	world.data.paused=true
	var col=make_popup("STILLWORKS · AIR OR DARKNESS",900)
	popup_kind="stillworks"
	var pawn=world.data.pawns[selected];var state=str(world.data.stillworks_choice)
	if state=="":
		var has_tape=int(pawn.inventory.get("tape",0))>0
		var can_restore=has_tape and int(pawn.inventory.get("scrap",0))>=4 and int(pawn.inventory.get("crystal",0))>=2
		var can_dark=has_tape and int(pawn.inventory.get("timber",0))>=2 and int(pawn.inventory.get("scrap",0))>=2
		var story=text_label("The traveler's signal tape decodes the maintenance bells at Meridian's failed life-support intake. The Bell manifold can pressurize only one route, and the decision is permanent. The tape must be physically carried but remains expedition property.\n\nRESTORE SCRUBBERS · install exactly 4 scrap and 2 glowstone. Fixed work lights wake two Gloam stalkers, but after the floor is safe, idle colonists recover fatigue in clean air.\n\nPRESERVE DARKNESS · fit exactly 2 timber and 2 scrap as acoustic baffles. No Gloam wake, a hidden survival cache becomes reachable, and positive camp pressure on this floor falls by 60%; the scrubbers remain dead.",18)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		if not has_tape:col.add_child(text_label("The selected colonist must carry the traveler's physical signal tape.",17,"e2a178"))
		var restore=button("Restore scrubbers · 4 scrap + 2 glowstone",func():close_popup();world.data.paused=false;execute(world.order_stillworks(selected,"restore",queue_mode));_refresh(),54,true)
		restore.disabled=not can_restore;col.add_child(restore)
		var dark=button("Baffle dark overflow · 2 timber + 2 scrap",func():close_popup();world.data.paused=false;execute(world.order_stillworks(selected,"dark",queue_mode));_refresh(),54)
		dark.disabled=not can_dark;col.add_child(dark)
	else:
		var outcome="The scrubbers are running and the restored pressure lock is open. Fixed lights make the two awakened Gloam stalkers dangerous, but safe idle colonists recover fatigue in the clean-air intake." if state=="restore" else "The overflow route remains unlit and its acoustic baffles suppress camp pressure. The traveler's survival cache and dark lower stair are open; the city scrubbers remain dead."
		var result=text_label(outcome+"\n\nThe signal tape remains in its colonist's pack. This life-support decision is now part of the expedition's saved history.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Follow the "+("restored pressure lock" if state=="restore" else "dark overflow stair"),func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_cistern():
	var keeper=world.cistern_landmark()
	if keeper.is_empty():feedback("Cistern Spine has not been reached.");return
	world.data.paused=true
	var col=make_popup("CISTERN SPINE · THE MISSING SEAL",900)
	popup_kind="cistern"
	var pawn=world.data.pawns[selected];var state=str(world.data.cistern_state);var route="pressure" if world.data.stillworks_choice=="restore" else "spillway"
	if state=="":
		var consequence="Restoring the Stillworks gives Nera enough pressure to open the main gallery. Water hammer will wake two blind burrowers, but securing it pays in 3 rations and 2 medkits and immediately eases every living colonist's hunger." if route=="pressure" else "Keeping the Stillworks dark leaves the keeper spillway usable. One Gloam stalker nests in the unlit route; darkness and silence are useful, and securing it pays 4 scrap and 3 glowstone."
		var story=text_label("Meridian's water keepers have isolated a failing lower reservoir. Its unique gate seal is missing from the control spine, and the connected descent remains locked until a colonist searches for it, physically carries it back, and secures the gate.\n\n"+consequence+"\n\nNeither route changes the Stillworks decision. Nera can only open the circuit that decision left available.",18)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		col.add_child(button("Open the "+("powered pressure gallery" if route=="pressure" else "unlit keeper spillway"),func():close_popup();world.data.paused=false;execute(world.order_cistern(selected,"start",queue_mode));_refresh(),56,true))
	elif state=="assigned":
		var has_seal=int(pawn.inventory.get("seal",0))>0
		var threats=world.floor_at(18).enemies.filter(func(enemy):return enemy.hp>0).size()
		var guidance="The selected colonist carries the unique physical gate seal." if has_seal else "Search the floodgate seal cradle and take its one gate seal into this colonist's pack."
		if threats>0:guidance+=" "+str(threats)+" reservoir threat"+(" remains." if threats==1 else "s remain.")
		var active=text_label(("The powered pressure gallery is open. Burrowers feel movement through the reservoir walls." if route=="pressure" else "The unlit keeper spillway is open. The Gloam hunts lantern light and work noise.")+"\n\n"+guidance+"\n\nNera will not cycle the reservoir while a route threat survives.",19)
		active.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(active)
		var finish=button("Install recovered gate seal",func():close_popup();world.data.paused=false;execute(world.order_cistern(selected,"finish",queue_mode));_refresh(),54,true)
		finish.disabled=not has_seal or threats>0;col.add_child(finish)
	else:
		var outcome="The powered gate is sealed and clean water reaches Meridian. The keepers' physical food and medicine allotment remains on the floor until hauled." if state=="pressure" else "The dark spillway gate is sealed without relighting the route. The keepers' industrial salvage remains on the floor until hauled."
		var result=text_label(outcome+"\n\nThe recovered seal was consumed by the repair, and the connected lower reservoir stair is permanently open. This outcome persists with the Stillworks history.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Follow the lower reservoir stair",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_drowned():
	var control=world.drowned_landmark("drowned_control")
	if control.is_empty():feedback("The Drowned Gallery has not been reached.");return
	world.data.paused=true
	var col=make_popup("DROWNED GALLERY · RESERVOIR SURGE",920)
	popup_kind="drowned"
	var state=str(world.data.drowned_state)
	if state=="":
		var advantage="The powered reservoir keeps the east rescue wing stable. Keeper Olan can be reached without a guardian, while water hammer wakes a burrower beside the western regulator cage." if world.data.cistern_state=="pressure" else "The dark spillway keeps the western regulator route quiet. The salvage cage is unguarded, while a Gloam stalker waits on Keeper Olan's eastern rescue wing."
		var story=text_label("The lower gallery is dry only because its emergency sluice is holding back Cistern Spine. Cycling it opens both wings and starts a visible 24-second surge. The game pauses when the warning begins so you can inspect the choice.\n\nRESCUE · reach trapped Keeper Olan and spend 4 seconds freeing them. The regulator is lost; Olan leaves 3 rations and 2 medkits and lifts colony morale.\n\nSALVAGE · spend 4 seconds cutting free the pressure regulator. Olan's wing is lost; 6 scrap and 3 glowstone remain as physical floor salvage.\n\nRETREAT · move behind the marked dry line before time expires. Anyone deeper in the gallery takes surge damage; the descent eventually drains open, but both opportunities are lost.\n\n"+advantage,18)
		story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
		col.add_child(button("Cycle sluice · begin 24-second warning",func():close_popup();world.data.paused=false;execute(world.order_drowned(selected,"start",queue_mode));_refresh(),56,true))
	elif state=="warning":
		var active=text_label("SURGE IN %d SECONDS\n\nThe clock advances only while play is running. Complete one objective to seal the opposite wing, or move every colonist behind the dry retreat line before time expires. The stair opens after rescue, salvage, or the final wave."%int(ceil(float(world.data.drowned_timer))),21,"e8a36d")
		active.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(active)
		var rescue=world.drowned_landmark("drowned_rescue");var salvage=world.drowned_landmark("drowned_salvage")
		var rescue_button=button("Rescue Keeper Olan · 4 seconds",func():close_popup();world.data.paused=false;execute(world.order_drowned(selected,"rescue",queue_mode));_refresh(),54,true)
		rescue_button.disabled=not world.floor_at(19).seen.has(world.cell_key(world.point(rescue)));col.add_child(rescue_button)
		var salvage_button=button("Recover regulator · 4 seconds",func():close_popup();world.data.paused=false;execute(world.order_drowned(selected,"salvage",queue_mode));_refresh(),54,true)
		salvage_button.disabled=not world.floor_at(19).seen.has(world.cell_key(world.point(salvage)));col.add_child(salvage_button)
		col.add_child(button("Resume surge · move or retreat",func():close_popup();world.data.paused=false;_refresh(),50))
	else:
		var outcome="Keeper Olan escaped alive. The regulator wing flooded; the rescue allotment remains physical cargo until hauled." if state=="rescued" else "The pressure regulator was recovered. Keeper Olan's wing flooded; industrial salvage remains physical cargo until hauled." if state=="salvaged" else "The wave reached both objectives. Colonists behind the dry line were safe; anyone in a flooded wing took damage."
		var result=text_label(outcome+"\n\nThe surge is over and the connected drained-gallery stair is permanently open. This outcome persists with the secured Cistern route.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Follow the drained gallery stair",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_tidecourt():
	var clerk=world.tidecourt_landmark()
	if clerk.is_empty():feedback("Tidecourt has not been reached.");return
	world.data.paused=true
	var col=make_popup("TIDECOURT · LOWER WATER ACCESS",920)
	popup_kind="tidecourt"
	var pawn=world.data.pawns[selected];var state=str(world.data.tidecourt_state);var route=str(clerk.get("route","recovery"))
	if state=="":
		var story="Keeper Olan reached Tidecourt alive and will sponsor the expedition. Registration opens a staffed recovery ward, leaves 2 rations and 2 medkits as physical cargo, and lets safe idle colonists recover fatigue here." if route=="sponsor" else "The recovered regulator proves an independent material claim. Carry exactly 3 scrap and 2 glowstone to post the bond. Tidecourt opens a quiet exchange, leaves 4 timber and reinforced armor, and halves positive camp-pressure growth on this floor." if route=="contract" else "Both Gallery objectives were lost, but progression is recoverable. Accept public duty to open a silted records route guarded by a burrower. Search its case, physically carry the unique water docket back, and Tidecourt will certify access with 2 rations and 1 medkit."
		var intro=text_label("Meridian's lower court records what the expedition chose under the reservoir surge. The consequence changes the route and lasting benefit, but every outcome can earn connected access.\n\n"+story,18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		if route=="sponsor":col.add_child(button("Accept Olan's sponsorship · 4 seconds",func():close_popup();world.data.paused=false;execute(world.order_tidecourt(selected,"sponsor",queue_mode));_refresh(),56,true))
		elif route=="contract":
			var has_bond=int(pawn.inventory.get("scrap",0))>=3 and int(pawn.inventory.get("crystal",0))>=2
			var bond=button("Post 3 scrap + 2 glowstone · 6 seconds",func():close_popup();world.data.paused=false;execute(world.order_tidecourt(selected,"contract",queue_mode));_refresh(),56,true)
			bond.disabled=not has_bond;col.add_child(bond)
		else:col.add_child(button("Accept public recovery · 4 seconds",func():close_popup();world.data.paused=false;execute(world.order_tidecourt(selected,"start",queue_mode));_refresh(),56,true))
	elif state=="assigned":
		var has_docket=int(pawn.inventory.get("docket",0))>0;var threats=world.floor_at(20).enemies.filter(func(enemy):return enemy.hp>0).size()
		var guidance="The selected colonist carries the unique water docket." if has_docket else "Search the silted water court case and take its one docket into this colonist's pack."
		if threats>0:guidance+=" "+str(threats)+" record-route threat"+(" remains." if threats==1 else "s remain.")
		var active=text_label("The public recovery route is open. A blind burrower feels movement and work through the flooded stacks.\n\n"+guidance+"\n\nSable will not certify the docket while a route threat survives.",19)
		active.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(active)
		var finish=button("Return recovered water docket",func():close_popup();world.data.paused=false;execute(world.order_tidecourt(selected,"finish",queue_mode));_refresh(),54,true)
		finish.disabled=not has_docket or threats>0;col.add_child(finish)
	else:
		var outcome="Olan's sponsorship opened a staffed ward. Its food and medicine remain physical cargo, and safe idle colonists recover fatigue here." if state=="sponsored" else "The material bond opened the regulator exchange. Contractor equipment remains physical cargo, and positive camp-pressure growth is halved here." if state=="contracted" else "The returned water docket repaired Tidecourt's record. Its public allotment remains physical cargo until hauled."
		var result=text_label(outcome+"\n\nThe connected lower water district stair is permanently open, and this access history persists.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Follow the lower water district stair",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_sump():
	var pumpwright=world.sump_landmark()
	if pumpwright.is_empty():feedback("Sump Commons has not been reached.");return
	world.data.paused=true
	var col=make_popup("SUMP COMMONS · PUMP REPAIR",920)
	popup_kind="sump"
	var pawn=world.data.pawns[selected];var state=str(world.data.sump_state);var route=str(pumpwright.get("route","public"))
	if state=="":
		var branch="Olan's sponsorship brings resident escorts. One burrower guards the seized pump rotor; completion leaves 3 rations and 2 medkits and makes the staffed berth especially restorative." if route=="resident" else "Independent standing opens a dark service crawl. One Gloam stalker guards the stripped rotor; completion leaves 5 scrap and 2 glowstone and makes the berth exceptionally quiet under pressure." if route=="service" else "Public standing opens the abandoned silt channel without escorts. Two burrowers guard the rotor; completion leaves 2 rations, 1 medkit, and 2 scrap at a balanced public berth."
		var intro=text_label("Sump Commons is inhabited, but its communal pump has seized. Recover its unique physical impeller and carry it back to Pumpwright Edda. The repair creates the expedition's first durable lower-city foothold: safe idle recovery, reduced local camp pressure, and a connected stair below.\n\n"+branch,18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		col.add_child(button("Accept pump repair · 4.5 seconds",func():close_popup();world.data.paused=false;execute(world.order_sump(selected,"start",queue_mode));_refresh(),56,true))
	elif state=="assigned":
		var has_impeller=int(pawn.inventory.get("impeller",0))>0;var threats=world.floor_at(21).enemies.filter(func(enemy):return enemy.hp>0).size()
		var guidance="The selected colonist carries the unique pump impeller." if has_impeller else "Search the seized pump rotor and take its one impeller into this colonist's pack."
		if threats>0:guidance+=" "+str(threats)+" route threat"+(" remains." if threats==1 else "s remain.")
		var active=text_label("The "+route+" service route is open.\n\n"+guidance+"\n\nEdda will not start the repaired pump while a route threat survives.",19)
		active.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(active)
		var finish=button("Install recovered pump impeller",func():close_popup();world.data.paused=false;execute(world.order_sump(selected,"finish",queue_mode));_refresh(),54,true)
		finish.disabled=not has_impeller or threats>0;col.add_child(finish)
	else:
		var outcome="Resident crews staff the repaired berth; its physical food and medicine remain until hauled, and safe idle colonists recover especially quickly." if state=="resident" else "Independent pumpwrights keep the berth quiet; its industrial cache remains physical cargo, and positive camp-pressure growth is strongly suppressed." if state=="service" else "The public pump is running. Mixed physical supplies remain until hauled, with modest safe recovery and pressure shelter."
		var result=text_label(outcome+"\n\nThe Commons foothold and connected lower mains stair are permanently open. The pump repair and exact item ownership persist.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the durable Commons foothold",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_market():
	var broker=world.market_landmark()
	if broker.is_empty():feedback("Mainspring Market has not been reached.");return
	world.data.paused=true
	var col=make_popup("MAINSPRING MARKET · RESIDENT EXCHANGE",920)
	popup_kind="market"
	var pawn=world.data.pawns[selected];var state=str(world.data.market_state);var route=str(broker.get("route","public"))
	if state=="":
		var branch="Resident sponsorship asks exactly 2 rations and 1 medkit for the shared table. Makers leave 4 timber and 2 scrap; Tavi joins with practiced scavenging." if route=="resident" else "Independent standing asks exactly 4 scrap and 2 glowstone to restore the freight hoist. Contractors leave 3 rations, 2 medkits, and a reinforced coat; Tavi joins with practiced building." if route=="service" else "Public standing asks exactly 2 scrap and 1 ration at the open counter. It leaves 2 timber, 1 medkit, and 1 glowstone; Tavi joins as a balanced hand."
		var intro=text_label("Sump Commons' foothold determines who will trade with the expedition. Broker Ysra completes one standing-shaped physical bargain, opens the matching arcade and lower Clockline stair, and introduces Tavi as a new independently selectable colonist with a separate pack.\n\n"+branch,18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var cost=world._market_cost(route);var parts:Array=[];var affordable=true
		for item in cost:parts.append(str(cost[item])+" "+World.ITEMS[item].name.to_lower());affordable=affordable and int(pawn.inventory.get(item,0))>=int(cost[item])
		var exchange=button("Exchange "+" + ".join(parts)+" · 6 seconds",func():close_popup();world.data.paused=false;execute(world.order_market(selected,queue_mode));_refresh(),56,true)
		exchange.disabled=not affordable;col.add_child(exchange)
		if not affordable:
			var guidance=text_label("Move the exact terms into the selected colonist's pack. Materials are only consumed when the exchange finishes.",17)
			guidance.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(guidance)
	else:
		var outcome="The resident table is stocked; maker goods remain on the floor, and Tavi joined with a separate food-and-medicine pack and practiced scavenging." if state=="resident" else "The freight hoist runs; survival goods and armor remain on the floor, and Tavi joined with a separate tool pack and practiced building." if state=="service" else "The public counter is open; mixed wages remain on the floor, and Tavi joined with a separate pack and balanced skills."
		var result=text_label(outcome+"\n\nThe branch-shaped exchange, recruit, exact item ownership, and connected Clockline stair persist.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use Mainspring's open Clockline",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_depot():
	var dispatcher=world.depot_landmark()
	if dispatcher.is_empty():feedback("Clockline Depot has not been reached.");return
	world.data.paused=true
	var col=make_popup("CLOCKLINE DEPOT · SPLIT FREIGHT",920)
	popup_kind="depot"
	var state=str(world.data.depot_state);var route=str(dispatcher.get("route","public"));var tavi_index=world._tavi_index()
	if state=="":
		var branch="Tavi's scavenger experience identifies the passenger freight. One Gloam stalker watches the traction case; reopening it leaves 4 rations and 2 medkits." if route=="resident" else "Tavi's building experience identifies the industrial freight. One burrower guards the brake cradle; reopening it leaves 6 scrap and 3 glowstone." if route=="service" else "Tavi's balanced training identifies two public freight lanes. A Gloam stalker and a burrower guard them; reopening leaves mixed supplies."
		var intro=text_label("The Clockline is disabled by two oversized mechanisms: a 6.5 kg traction drive and a 6.5 kg brake drum. One 12 kg pack cannot hold both. Tavi must first stand beside Dispatcher Jun to identify the standing-shaped lanes; then two colonists must return together, each physically carrying one mechanism.\n\n"+branch,18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var tavi_ready=tavi_index>=0 and int(world.data.pawns[tavi_index].z)==23 and world.point(world.data.pawns[tavi_index]).distance_to(world.point(dispatcher))<=3.0
		var start=button("Open Tavi's specialty route · 5 seconds",func():close_popup();world.data.paused=false;execute(world.order_depot(selected,"start",queue_mode));_refresh(),56,true)
		start.disabled=not tavi_ready;col.add_child(start)
		if not tavi_ready:col.add_child(text_label("Move Tavi within three tiles of Jun before accepting the recovery.",17,"d7b978"))
	elif state=="assigned":
		var threats=world.floor_at(23).enemies.filter(func(enemy):return enemy.hp>0).size();var carriers=world._depot_carriers(world.point(dispatcher));var carrier_text=""
		if carriers.size()==2:carrier_text=str(world.data.pawns[carriers[0]].name)+" carries the traction drive; "+str(world.data.pawns[carriers[1]].name)+" carries the brake drum."
		else:carrier_text="Search both cases, then bring the traction drive and brake drum beside Jun in two different packs."
		var active=text_label("The "+route+" freight lanes are open.\n\n"+carrier_text+"\n\n"+str(threats)+" route threat"+(" remains." if threats==1 else "s remain."),19)
		active.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(active)
		var finish=button("Install separately carried mechanisms",func():close_popup();world.data.paused=false;execute(world.order_depot(selected,"finish",queue_mode));_refresh(),56,true)
		finish.disabled=carriers.size()!=2 or threats>0;col.add_child(finish)
	else:
		var outcome="Resident crews reopen passenger freight; 4 rations and 2 medkits remain physical cargo." if state=="resident" else "Contractors reopen industrial freight; 6 scrap and 3 glowstone remain physical cargo." if state=="service" else "The public line reopens with 2 rations, 1 medkit, 3 scrap, and 1 glowstone as physical cargo."
		var result=text_label(outcome+"\n\nThe two mechanisms were consumed from separate colonist packs. The connected lower platform and recovery history persist.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the lower Clockline platform",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_refuge():
	var keeper=world.refuge_landmark()
	if keeper.is_empty():feedback("Switchyard Refuge has not been reached.");return
	world.data.paused=true
	var col=make_popup("SWITCHYARD REFUGE · RESIDENT EVACUATION",920)
	popup_kind="refuge"
	var pawn=world.data.pawns[selected];var state=str(world.data.refuge_state);var route=str(keeper.get("route","public"))
	if state=="":
		var threats=world.floor_at(24).enemies.filter(func(enemy):return enemy.hp>0).size()
		var route_warning="The passenger line drew a Gloam stalker into the departure hall." if route=="resident" else "The industrial line woke a burrower beneath the switches." if route=="service" else "The public line drew both a Gloam stalker and a burrower into the refuge."
		var intro=text_label("The reopened Clockline reaches residents stranded at a failed switch tower. Secure the hall, then make one permanent commitment.\n\nFOOTHOLD · 3 rations, 2 medkits, 1 timber. Staff a strong recovery sanctuary with local pressure shelter; receive physical tool stores.\n\nMOBILE CORRIDOR · 4 scrap, 2 glowstone, 1 timber. Moving caches suppress pressure at the deepest reached level; receive physical survival surplus.\n\n"+route_warning,16)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var foothold_cost=world._refuge_cost("foothold");var corridor_cost=world._refuge_cost("corridor")
		var can_foothold=threats==0;var can_corridor=threats==0
		for item in foothold_cost:can_foothold=can_foothold and int(pawn.inventory.get(item,0))>=int(foothold_cost[item])
		for item in corridor_cost:can_corridor=can_corridor and int(pawn.inventory.get(item,0))>=int(corridor_cost[item])
		var anchor=button("Anchor sanctuary · 3 rations + 2 medkits + 1 timber",func():close_popup();world.data.paused=false;execute(world.order_refuge(selected,"foothold",queue_mode));_refresh(),50,true)
		anchor.disabled=not can_foothold;col.add_child(anchor)
		var corridor=button("Launch corridor · 4 scrap + 2 glowstone + 1 timber",func():close_popup();world.data.paused=false;execute(world.order_refuge(selected,"corridor",queue_mode));_refresh(),50)
		corridor.disabled=not can_corridor;col.add_child(corridor)
		if threats>0:col.add_child(text_label("Secure the hall first: "+str(threats)+" threat"+(" remains." if threats==1 else "s remain."),15,"e2a178"))
		elif not can_foothold or not can_corridor:col.add_child(text_label("Carry one plan's exact supplies in the selected pack. Nothing is consumed before completion.",15,"d7b978"))
	else:
		var outcome="The evacuees anchored a staffed sanctuary. Safe idle colonists recover fatigue here, local pressure is strongly sheltered, and the physical tool stores remain until hauled." if state=="foothold" else "The evacuees launched a mobile supply train. Its moving caches suppress pressure at the deepest reached level, and physical survival surplus remains until hauled."
		var result=text_label(outcome+"\n\nThe alternative is permanently closed. Resident safety, exact item ownership, and the connected outbound stair persist.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the outbound switch stair",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_ashrail():
	var steward=world.ashrail_landmark()
	if steward.is_empty():feedback("Ashrail Interchange has not been reached.");return
	world.data.paused=true
	var col=make_popup("ASHRAIL INTERCHANGE · PROVISIONING RUN",900)
	popup_kind="ashrail"
	var pawn=world.data.pawns[selected];var state=str(world.data.ashrail_state);var route=str(steward.get("route","corridor"));var threats=world.floor_at(25).enemies.filter(func(enemy):return enemy.hp>0).size()
	if state=="":
		var story="Switchyard's fixed sanctuary sends a food-and-medicine convoy across a lit cinder gantry. Two burrowers feel every moving step. Carry exactly 3 rations and 1 medkit; the far exchange returns 4 scrap and 2 glowstone." if route=="sanctuary" else "Switchyard's mobile corridor reaches a dark convoy bypass, but its hardware is failing. Two Gloam stalkers hunt lantern light and work noise. Carry exactly 3 scrap and 1 glowstone; the far platform returns 4 rations and 2 medkits."
		var intro=text_label(story+"\n\nThe opened lane and both threats are visible before anything is spent. Supplies remain in the selected pack until the 5.5-second stocking job finishes.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var cost=world._ashrail_cost(route);var ready=threats==0
		for item in cost:ready=ready and int(pawn.inventory.get(item,0))>=int(cost[item])
		var label="Stock food convoy · 3 rations + 1 medkit" if route=="sanctuary" else "Repair mobile line · 3 scrap + 1 glowstone"
		var provision=button(label,func():close_popup();world.data.paused=false;execute(world.order_ashrail(selected,queue_mode));_refresh(),56,true)
		provision.disabled=not ready;col.add_child(provision)
		if threats>0:col.add_child(text_label("Secure the route first: "+str(threats)+" "+("burrowers remain." if route=="sanctuary" else "Gloam stalkers remain."),16,"e2a178"))
		elif not ready:col.add_child(text_label("Carry the exact route-shaped supplies in the selected colonist's pack.",16,"d7b978"))
	else:
		var outcome="The sanctuary convoy stocked the far platform; 4 scrap and 2 glowstone remain as physical exchange freight." if route=="sanctuary" else "The repaired mobile corridor stocked the far platform; 4 rations and 2 medkits remain as physical provisions."
		var result=text_label(outcome+"\n\nThe route, exact item history, and connected lower exchange stair persist.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the lower exchange stair",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_customs():
	var captain=world.customs_landmark()
	if captain.is_empty():feedback("Emberline Customs has not been reached.");return
	world.data.paused=true
	var col=make_popup("EMBERLINE CUSTOMS · DECLARE OR DISAPPEAR",920)
	popup_kind="customs"
	var pawn=world.data.pawns[selected];var state=str(world.data.customs_state);var cargo=str(captain.get("cargo","provisions"));var threats=world.floor_at(26).enemies.filter(func(enemy):return enemy.hp>0).size()
	if state=="":
		var provenance="Ashrail's sanctuary convoy arrives as industrial exchange freight." if cargo=="industrial" else "Ashrail's mobile corridor arrives carrying off-ledger food and medicine."
		var intro=text_label(provenance+" Captain Vara offers two permanent entries. Declare it through the lit authority platform for a patrol issue and lasting local pressure shelter, but one burrower breach blocks the track. Or pay the cheaper quiet tariff for a dark ghost siding with richer industrial freight and two Gloam stalkers.\n\nThe exact tariff stays in the selected pack until the 5.5-second decision completes. The chosen threats then block the lower gate until cleared.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var official_cost=world._customs_cost("security",cargo);var hidden_cost=world._customs_cost("smuggle",cargo);var can_official=true;var can_hidden=true
		for item in official_cost:can_official=can_official and int(pawn.inventory.get(item,0))>=int(official_cost[item])
		for item in hidden_cost:can_hidden=can_hidden and int(pawn.inventory.get(item,0))>=int(hidden_cost[item])
		var official_label="Declare industrial freight · 2 scrap + 1 glowstone" if cargo=="industrial" else "Declare provisions · 3 rations + 1 medkit"
		var official=button(official_label,func():close_popup();world.data.paused=false;execute(world.order_customs(selected,"security",queue_mode));_refresh(),54,true);official.disabled=not can_official;col.add_child(official)
		var hidden_label="Smuggle industrial freight · 1 scrap + 1 glowstone" if cargo=="industrial" else "Smuggle provisions · 2 rations"
		var hidden=button(hidden_label,func():close_popup();world.data.paused=false;execute(world.order_customs(selected,"smuggle",queue_mode));_refresh(),54);hidden.disabled=not can_hidden;col.add_child(hidden)
		if not can_official or not can_hidden:col.add_child(text_label("Carry one route's exact Ashrail-shaped tariff in the selected pack.",15,"d7b978"))
	else:
		var outcome="Vara recorded the cargo. The authority platform shelters local pressure and its physical patrol issue remains until hauled." if state=="security" else "Vara erased the cargo. The dark ghost siding and its physical hidden freight remain off the authority ledger."
		var danger=" One burrower still blocks the lower gate." if state=="security" and threats>0 else " Two Gloam stalkers still block the lower gate." if threats>0 else " The connected lower authority gate is clear."
		var result=text_label(outcome+danger+"\n\nThe alternative route is permanently closed; exact custody and the decision persist.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the lower authority gate",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_railcourt():
	var steward=world.railcourt_landmark()
	if steward.is_empty():feedback("Railcourt Concourse has not been reached.");return
	world.data.paused=true
	var col=make_popup("RAILCOURT CONCOURSE · WHO OWNS THE LINE",920)
	popup_kind="railcourt"
	var pawn=world.data.pawns[selected];var state=str(world.data.railcourt_state);var route=str(steward.get("route","authority"));var threats=world.floor_at(27).enemies.filter(func(enemy):return enemy.hp>0).size()
	if route=="authority" and state=="":
		var intro=text_label("Captain Vara's declaration reaches Magistrate Sera before the expedition does. Railcourt offers its first public contract: unseal a seized switchhouse, survive two vibration-sensing burrowers, search for the unique switch warrant, and physically return it.\n\nCertification opens staffed rest bunks, leaves a physical patrol issue, and reconnects the lower freight stair.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		col.add_child(button("Accept public switchhouse contract",func():close_popup();world.data.paused=false;execute(world.order_railcourt(selected,"start",queue_mode));_refresh(),54,true))
	elif route=="authority" and state=="assigned":
		var has_warrant=int(pawn.inventory.get("warrant",0))>0
		var report=text_label("The switchhouse is open. "+("Two burrowers still occupy the evidence line." if threats>0 else "The evidence line is secure.")+" The selected pack "+("holds" if has_warrant else "does not hold")+" the unique switch warrant.",19)
		report.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(report)
		var finish_contract=button("Return physical switch warrant",func():close_popup();world.data.paused=false;execute(world.order_railcourt(selected,"finish",queue_mode));_refresh(),54,true);finish_contract.disabled=threats>0 or not has_warrant;col.add_child(finish_contract)
	elif route=="resident" and state=="":
		var intro=text_label("The ghost siding bypasses public inspection and reaches Resident Factor Pell's undercroft. One Gloam stalker hunts its dark arcade. Once the route is safe, Pell will accept exactly 3 scrap and 2 glowstone from Emberline's hidden freight.\n\nThe compact opens resident stalls, leaves physical provisions, shelters local camp pressure, and reconnects the lower freight stair.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var can_trade=threats==0 and int(pawn.inventory.get("scrap",0))>=3 and int(pawn.inventory.get("crystal",0))>=2
		var trade=button("Post compact · 3 scrap + 2 glowstone",func():close_popup();world.data.paused=false;execute(world.order_railcourt(selected,"trade",queue_mode));_refresh(),54,true);trade.disabled=not can_trade;col.add_child(trade)
		if threats>0:col.add_child(text_label("Clear the Gloam stalker from the resident undercroft first.",15,"d7b978"))
		elif not can_trade:col.add_child(text_label("Carry the exact compact materials in the selected pack.",15,"d7b978"))
	else:
		var outcome="Sera certified the expedition. Staffed rest bunks and the physical Railcourt contract issue remain available." if state=="licensed" else "Pell recorded the resident compact. Its physical provisions and local pressure shelter remain available."
		var result=text_label(outcome+" The connected lower freight stair is open, and the alternative standing is permanently closed.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the lower freight stair",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_registry():
	var clerk=world.registry_landmark()
	if clerk.is_empty():feedback("Cinder Registry has not been reached.");return
	world.data.paused=true
	var col=make_popup("CINDER REGISTRY · WHERE THE TRAINS GO",920)
	popup_kind="registry"
	var pawn=world.data.pawns[selected];var state=str(world.data.registry_state);var route=str(clerk.get("route","official"));var threats=world.floor_at(28).enemies.filter(func(enemy):return enemy.hp>0).size()
	if route=="official" and state=="":
		var intro=text_label("Railcourt's public license reaches Registrar Kade. He offers an audit contract: open the charred plate vault, survive two vibration-sensing burrowers, search for the unique Cinder registry plate, and physically return it.\n\nKade will issue one physical Morrow freight waybill naming the lower authority's deepest active destination, leave exact supplies, and open the dispatch stair.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		col.add_child(button("Accept public plate audit",func():close_popup();world.data.paused=false;execute(world.order_registry(selected,"start",queue_mode));_refresh(),54,true))
	elif route=="official" and state=="assigned":
		var has_plate=int(pawn.inventory.get("plate",0))>0
		var report=text_label("The audit vault is open. "+("Two burrowers still occupy the plate stacks." if threats>0 else "The plate stacks are secure.")+" The selected pack "+("holds" if has_plate else "does not hold")+" the unique Cinder registry plate.",19)
		report.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(report)
		var finish_audit=button("Return physical registry plate",func():close_popup();world.data.paused=false;execute(world.order_registry(selected,"finish",queue_mode));_refresh(),54,true);finish_audit.disabled=threats>0 or not has_plate;col.add_child(finish_audit)
	elif route=="resident" and state=="":
		var intro=text_label("Railcourt's resident compact reaches Copyist Moss without entering the authority ledger. One Gloam stalker hunts the unlit copy room. Once it is safe, Moss accepts exactly 4 scrap and 1 glowstone to print one physical Morrow freight waybill.\n\nThe copy names the deepest active freight destination, leaves exact provisions, and opens the dark dispatch stair.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var can_copy=threats==0 and int(pawn.inventory.get("scrap",0))>=4 and int(pawn.inventory.get("crystal",0))>=1
		var copy=button("Print waybill · 4 scrap + 1 glowstone",func():close_popup();world.data.paused=false;execute(world.order_registry(selected,"copy",queue_mode));_refresh(),54,true);copy.disabled=not can_copy;col.add_child(copy)
		if threats>0:col.add_child(text_label("Clear the Gloam stalker from the resident copy room first.",15,"d7b978"))
		elif not can_copy:col.add_child(text_label("Carry the exact copy materials in the selected pack.",15,"d7b978"))
	else:
		var has_waybill=int(pawn.inventory.get("waybill",0))>0
		var outcome="Kade certified the audit and issued the physical Morrow freight waybill." if state=="official" else "Moss printed the off-ledger physical Morrow freight waybill."
		var result=text_label(outcome+" It names Morrow Exchange as the lower authority's deepest active destination. The selected pack "+("holds the waybill." if has_waybill else "does not currently hold the waybill—check another pack or a dropped inventory.")+" The connected dispatch stair is open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the Morrow dispatch stair",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_morrow():
	var dispatcher=world.morrow_landmark()
	if dispatcher.is_empty():feedback("Morrow Exchange has not been reached.");return
	world.data.paused=true
	var col=make_popup("MORROW EXCHANGE · LAST TRAIN DOWN",920)
	popup_kind="morrow"
	var pawn=world.data.pawns[selected];var state=str(world.data.morrow_state);var route=str(dispatcher.get("route","official"));var threats=world.floor_at(29).enemies.filter(func(enemy):return enemy.hp>0).size();var has_waybill=int(pawn.inventory.get("waybill",0))>0
	if state=="":
		var route_copy="The stamped original calls a lit authority consist. Two vibration-sensing burrowers have breached its loading lane." if route=="official" else "The off-ledger copy calls an unlisted ghost-line consist. Two Gloam stalkers hunt its dark siding."
		var intro=text_label("Morrow is the lower authority's deepest active exchange. "+route_copy+"\n\nCalling the train starts a visible, pauseable 30-second departure. Clear the lane and rally at least two living colonists beside the dispatcher. The waybill must remain in the selected pack, but it will not be consumed.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var call=button("Call "+("authority" if route=="official" else "ghost-line")+" freight train",func():close_popup();world.data.paused=false;execute(world.order_morrow(selected,"start",queue_mode));_refresh(),54,true);call.disabled=not has_waybill;col.add_child(call)
		if not has_waybill:col.add_child(text_label("Move the physical Morrow freight waybill into the selected colonist's pack first.",15,"d7b978"))
	elif state=="boarding":
		var gathered=world.morrow_gathered();var seconds=int(ceil(float(world.data.morrow_timer)))
		var report=text_label("DEPARTURE · "+str(seconds)+" seconds\n\n"+("The loading lane is secure." if threats==0 else str(threats)+" hostile creatures still hold the loading lane.")+" "+str(gathered)+" living colonist"+(" is" if gathered==1 else "s are")+" rallied beside the dispatcher. The selected pack "+("holds" if has_waybill else "does not hold")+" the physical waybill.\n\nTime is paused while this panel is open.",19)
		report.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(report)
		var board=button("Board together before departure",func():close_popup();world.data.paused=false;execute(world.order_morrow(selected,"depart",queue_mode));_refresh(),54,true);board.disabled=threats>0 or gathered<2 or not has_waybill;col.add_child(board)
		if threats>0:col.add_child(text_label("Clear the route-shaped loading-lane threats first.",15,"d7b978"))
		elif gathered<2:col.add_child(text_label("Move at least one more living colonist within four tiles of the dispatcher.",15,"d7b978"))
		elif not has_waybill:col.add_child(text_label("The boarding colonist must carry the physical waybill.",15,"d7b978"))
	else:
		var benefit="Staffed rest benches recover fatigue, and the authority issue remains physically on the platform." if state=="official" else "The ghost siding shelters local camp pressure, and its industrial salvage remains physically on the platform."
		var result=text_label("The expedition caught Morrow's "+("authority" if state=="official" else "ghost-line")+" freight train together. The physical waybill remains in its colonist's pack. "+benefit+" The connected deep freight line is permanently open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the deep freight line",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_terminus():
	var speaker=world.terminus_landmark()
	if speaker.is_empty():feedback("Morrow Terminus has not been reached.");return
	world.data.paused=true
	var col=make_popup("MORROW TERMINUS · CAIRN REACH",920)
	popup_kind="terminus"
	var pawn=world.data.pawns[selected];var state=str(world.data.terminus_state);var route=str(speaker.get("route","official"));var threats=world.floor_at(30).enemies.filter(func(enemy):return enemy.hp>0).size();var has_waybill=int(pawn.inventory.get("waybill",0))>0
	if route=="official" and state=="":
		var intro=text_label("The authority train reaches Cairn Reach, a living settlement beyond Meridian's direct jurisdiction. Speaker Nera recognizes the stamped waybill but will not let it define her people. She asks the expedition to open a breached witness hall, survive two burrowers, recover Cairn's unique physical ledger, and return it while keeping the waybill.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var accept=button("Accept Cairn witness request",func():close_popup();world.data.paused=false;execute(world.order_terminus(selected,"start",queue_mode));_refresh(),54,true);accept.disabled=not has_waybill;col.add_child(accept)
		if not has_waybill:col.add_child(text_label("Move the physical Morrow freight waybill into the selected colonist's pack first.",15,"d7b978"))
	elif route=="official" and state=="assigned":
		var has_ledger=int(pawn.inventory.get("ledger",0))>0
		var report=text_label("The witness hall is open. "+("Two burrowers still occupy Cairn's record vault." if threats>0 else "The record vault is secure.")+" The selected pack "+("holds" if has_ledger else "does not hold")+" the unique Cairn witness ledger. The physical waybill must remain in the same pack for return.",19)
		report.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(report)
		var finish_request=button("Return physical witness ledger",func():close_popup();world.data.paused=false;execute(world.order_terminus(selected,"finish",queue_mode));_refresh(),54,true);finish_request.disabled=threats>0 or not has_ledger or not has_waybill;col.add_child(finish_request)
	elif route=="resident" and state=="":
		var intro=text_label("The ghost train arrives through Cairn Reach's free siding. Its residents ask no tariff, but one Gloam stalker blocks their communal lift works. Once the siding is safe, they need exactly 4 scrap and 2 glowstone from one physical pack to reopen the far lift. The copied waybill remains with the expedition.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var can_pledge=threats==0 and has_waybill and int(pawn.inventory.get("scrap",0))>=4 and int(pawn.inventory.get("crystal",0))>=2
		var pledge=button("Repair far lift · 4 scrap + 2 glowstone",func():close_popup();world.data.paused=false;execute(world.order_terminus(selected,"pledge",queue_mode));_refresh(),54,true);pledge.disabled=not can_pledge;col.add_child(pledge)
		if threats>0:col.add_child(text_label("Clear the Gloam stalker from the free siding first.",15,"d7b978"))
		elif not has_waybill:col.add_child(text_label("The selected colonist must carry the physical copied waybill.",15,"d7b978"))
		elif not can_pledge:col.add_child(text_label("Carry exactly 4 scrap and 2 glowstone in the selected pack.",15,"d7b978"))
	else:
		var benefit="Cairn's staffed witness hall safely recovers idle fatigue, and exact charter supplies remain physical." if state=="chartered" else "The repaired free siding shelters local camp pressure, and exact settlement stores remain physical."
		var result=text_label("Cairn Reach recognizes the expedition without surrendering its independence. The Morrow waybill remains in its colonist's pack. "+benefit+" The connected far lift is permanently open toward settlements omitted from Meridian's maps.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the Cairn far lift",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_farline():
	var steward=world.farline_landmark()
	if steward.is_empty():feedback("Farline Commons has not been reached.");return
	world.data.paused=true
	var col=make_popup("FARLINE COMMONS · SETTLEMENT ROAD",920)
	popup_kind="farline"
	var pawn=world.data.pawns[selected];var state=str(world.data.farline_state);var route=str(steward.get("route","accord"));var threats=world.floor_at(31).enemies.filter(func(enemy):return enemy.hp>0).size();var gathered=world.farline_gathered();var has_braid=int(pawn.inventory.get("braid",0))>0
	if state=="":
		var intro=text_label("Farline Commons belongs to no single city. "+("Cairn's charter is recognized at the delegates' table, opening a lit witness road where two burrowers feel every footfall." if route=="accord" else "Cairn's free standing is recognized by the cachekeepers, opening an unlit road where two Gloam stalkers hunt light and work noise.")+" Recover the network's unique physical route braid, clear the chosen road, then bring it back with at least two living colonists gathered beside the steward.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		col.add_child(button("Open "+("witness lantern road" if route=="accord" else "free cacheway"),func():close_popup();world.data.paused=false;execute(world.order_farline(selected,"start",queue_mode));_refresh(),54,true))
	elif state=="assigned":
		var report=text_label(("The lit witness road is open." if route=="accord" else "The dark cacheway is open.")+" "+(str(threats)+" hostile creatures still hold the waymarks." if threats>0 else "The chosen road is secure.")+" The selected pack "+("holds" if has_braid else "does not hold")+" Farline's physical route braid. "+str(gathered)+" living colonist"+(" is" if gathered==1 else "s are")+" gathered beside the steward.",19)
		report.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(report)
		var bind=button("Bind route braid with gathered crew",func():close_popup();world.data.paused=false;execute(world.order_farline(selected,"finish",queue_mode));_refresh(),54,true);bind.disabled=threats>0 or not has_braid or gathered<2;col.add_child(bind)
		if threats>0:col.add_child(text_label("Clear the route-shaped threats before returning to the Commons.",15,"d7b978"))
		elif not has_braid:col.add_child(text_label("Search the far waymark and carry its unique route braid in the selected pack.",15,"d7b978"))
		elif gathered<2:col.add_child(text_label("Move at least one more living colonist within four tiles of the steward.",15,"d7b978"))
	else:
		var benefit="Farline's delegates staff a safe fatigue-recovery shelter, and their exact relief issue remains physical." if state=="accord" else "Farline's hidden stores shelter local camp pressure, and their exact industrial goods remain physical."
		var result=text_label("The gathered expedition binds Farline's route braid into the independent settlement network. "+benefit+" The connected settlement descent is permanently open beyond Cairn Reach.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the settlement descent",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_thimble():
	var bell=world.thimble_landmark()
	if bell.is_empty():feedback("Thimble Crossing has not been reached.");return
	world.data.paused=true
	var col=make_popup("THIMBLE CROSSING · SURFACE WARNING",920)
	popup_kind="thimble"
	var pawn=world.data.pawns[selected];var state=str(world.data.thimble_state);var route=str(bell.get("route","accord"))
	var threats=world.floor_at(32).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("thimble_guard")).size()
	if state=="":
		var approach="Farline's public road gives Thimble two armed tripwire alarms, but three surface husks are already following its warm markers." if route=="accord" else "Farline's hidden cacheway masks Thimble from all but two surface husks, but the settlement has no prepared alarms."
		var intro=text_label(approach+" The warning bell offers one permanent choice. Defend the homes by clearing the incursion and rallying two colonists here, or evacuate by recovering the unique physical resident cord and rallying two colonists at the lift. Either plan has 28 pauseable seconds once begun.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		col.add_child(button("Defend Thimble Crossing",func():close_popup();world.data.paused=false;execute(world.order_thimble(selected,"defend",queue_mode));_refresh(),54,true))
		col.add_child(button("Evacuate Thimble residents",func():close_popup();world.data.paused=false;execute(world.order_thimble(selected,"evacuate",queue_mode));_refresh(),54,true))
	elif state=="defending":
		var gathered=world.thimble_gathered();var seconds=int(ceil(float(world.data.thimble_timer)))
		var report=text_label("WARNING · "+str(seconds)+" seconds\n\n"+(str(threats)+" surface husk"+(" remains" if threats==1 else "s remain")+" in the breach." if threats>0 else "The breach is clear.")+" "+str(gathered)+" living colonist"+(" is" if gathered==1 else "s are")+" gathered at the bell.\n\nTime is paused while this panel is open.",19)
		report.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(report)
		var hold=button("Seal breach with gathered defenders",func():close_popup();world.data.paused=false;execute(world.order_thimble(selected,"hold",queue_mode));_refresh(),54,true);hold.disabled=threats>0 or gathered<2;col.add_child(hold)
		if threats>0:col.add_child(text_label("Clear every warned surface husk before sealing the breach.",15,"d7b978"))
		elif gathered<2:col.add_child(text_label("Move at least one more living colonist within four tiles of the warning bell.",15,"d7b978"))
	elif state=="evacuating":
		var gathered=world.thimble_gathered(true);var seconds=int(ceil(float(world.data.thimble_timer)));var has_roster=int(pawn.inventory.get("roster",0))>0
		var report=text_label("WARNING · "+str(seconds)+" seconds\n\nThe selected pack "+("holds" if has_roster else "does not hold")+" Thimble's unique resident cord. "+str(gathered)+" living colonist"+(" is" if gathered==1 else "s are")+" gathered at the evacuation lift. Surface husks may be bypassed.\n\nTime is paused while this panel is open.",19)
		report.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(report)
		var depart=button("Send gathered residents down lift",func():close_popup();world.data.paused=false;execute(world.order_thimble(selected,"depart",queue_mode));_refresh(),54,true);depart.disabled=not has_roster or gathered<2;col.add_child(depart)
		if not has_roster:col.add_child(text_label("Search the cord case and carry the physical resident cord in the selected pack.",15,"d7b978"))
		elif gathered<2:col.add_child(text_label("Move at least one more living colonist within four tiles of the evacuation lift.",15,"d7b978"))
	else:
		var result_text="The breach held. Thimble's residents staff a safe fatigue-recovery hall, and exact defender supplies remain physical." if state=="defended" else "The residents escaped with their cord. The cold crossing now shelters local camp pressure, and exact evacuation stores remain physical." if state=="evacuated" else "The warning expired. Exposed colonists were hurt, Thimble scattered, and no settlement benefit remains—but the campaign is not trapped."
		var result=text_label(result_text+" The lower settlement road is permanently open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the lower settlement road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_latchwater():
	var keeper=world.latchwater_landmark()
	if keeper.is_empty():feedback("Latchwater Ward has not been reached.");return
	world.data.paused=true
	var col=make_popup("LATCHWATER WARD · SHARED HEATER",920)
	popup_kind="latchwater"
	var pawn=world.data.pawns[selected];var state=str(world.data.latchwater_state);var route=str(keeper.get("route","public"))
	var threats=world.floor_at(33).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("latchwater_guard")).size()
	if state=="":
		var reception="Thimble's defenders vouched for the expedition, so residents open a lit service gallery occupied by two burrowers." if route=="resident" else "Thimble's evacuees reached the ward first, opening a dark spillway watched by one Gloam stalker." if route=="refugee" else "News of Thimble's fall leaves only a public scavenger duct, where two surface husks have descended."
		var intro=text_label(reception+" Recover one physical 2 kg heat exchanger, then make a permanent choice.\n\nFULL WARMTH · consume the exchanger, gain safe idle fatigue recovery plus 4 rations and 2 medkits, but add lasting surface pressure here.\n\nCOLD BAFFLE · consume the exchanger, gain 5 scrap, 3 timber, and 1 glowstone while sharply suppressing local pressure, but no recovery ward.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		col.add_child(button("Open heater recovery route",func():close_popup();world.data.paused=false;execute(world.order_latchwater(selected,"start",queue_mode));_refresh(),54,true))
	elif state=="assigned":
		var has_exchanger=int(pawn.inventory.get("exchanger",0))>0
		var report=text_label((str(threats)+" route threat"+(" remains." if threats==1 else "s remain.") if threats>0 else "The heater route is secure.")+" The selected pack "+("holds" if has_exchanger else "does not hold")+" Latchwater's unique heat exchanger.\n\nThe choice consumes that exact physical part and permanently changes this floor.",19)
		report.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(report)
		var warm=button("Install for full warmth · recovery + pressure",func():close_popup();world.data.paused=false;execute(world.order_latchwater(selected,"warm",queue_mode));_refresh(),54,true);warm.disabled=threats>0 or not has_exchanger;col.add_child(warm)
		var cold=button("Baffle for cold shelter · low pressure",func():close_popup();world.data.paused=false;execute(world.order_latchwater(selected,"cold",queue_mode));_refresh(),54);cold.disabled=threats>0 or not has_exchanger;col.add_child(cold)
		if threats>0:col.add_child(text_label("Clear every route threat before setting the heater.",15,"d7b978"))
		elif not has_exchanger:col.add_child(text_label("Search the exchanger case and carry the physical part in the selected pack.",15,"d7b978"))
	else:
		var outcome="The restored heater makes Latchwater a safe fatigue-recovery ward. Exactly 4 rations and 2 medkits remain physical, while the warm shaft permanently adds local surface pressure." if state=="warm" else "The baffled heater leaves Latchwater cold but difficult to trace. Exactly 5 scrap, 3 timber, and 1 glowstone remain physical, while local camp pressure is sharply suppressed."
		var result=text_label(outcome+" The connected lower settlement road is permanently open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the lower settlement road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_driftglass():
	var keeper=world.driftglass_landmark()
	if keeper.is_empty():feedback("Driftglass Hall has not been reached.");return
	world.data.paused=true
	var col=make_popup("DRIFTGLASS HALL · BURIED LENS",920)
	popup_kind="driftglass"
	var pawn=world.data.pawns[selected];var state=str(world.data.driftglass_state);var route=str(keeper.get("route","shaded"))
	var threats=world.floor_at(34).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("driftglass_guard")).size()
	if state=="":
		var reception="Latchwater's full warmth feeds a heated cutting gallery with fixed work lights and two Gloam stalkers." if route=="powered" else "Latchwater's cold baffle preserves an unlit mirror seam watched by one Gloam stalker."
		var intro=text_label(reception+" Recover one physical 1.6 kg focusing prism, then make a permanent choice.\n\nPOWERED CUTTERS · consume the prism, gain 6 scrap, 3 glowstone, and two Building ranks. Fixed lights raise local pressure and wake two new Gloam stalkers on the lower seam.\n\nSHADED ROAD · consume the prism, gain 4 rations, 2 medkits, and 2 timber. The hall stays dark, wakes nothing new, and sharply suppresses local pressure.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		col.add_child(button("Open prism recovery route",func():close_popup();world.data.paused=false;execute(world.order_driftglass(selected,"start",queue_mode));_refresh(),54,true))
	elif state=="assigned":
		var has_prism=int(pawn.inventory.get("prism",0))>0
		var report=text_label((str(threats)+" route threat"+(" remains." if threats==1 else "s remain.") if threats>0 else "The excavation route is secure.")+" The selected pack "+("holds" if has_prism else "does not hold")+" Driftglass's unique focusing prism.\n\nThe choice consumes that exact physical lens and permanently changes this floor.",19)
		report.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(report)
		var powered=button("Power cutters · rich salvage + awakened Gloam",func():close_popup();world.data.paused=false;execute(world.order_driftglass(selected,"powered",queue_mode));_refresh(),54,true);powered.disabled=threats>0 or not has_prism;col.add_child(powered)
		var shaded=button("Shade lower seam · provisions + low pressure",func():close_popup();world.data.paused=false;execute(world.order_driftglass(selected,"shaded",queue_mode));_refresh(),54);shaded.disabled=threats>0 or not has_prism;col.add_child(shaded)
		if threats>0:col.add_child(text_label("Clear every route threat before setting the focusing prism.",15,"d7b978"))
		elif not has_prism:col.add_child(text_label("Search the prism casket and carry the physical lens in the selected pack.",15,"d7b978"))
	else:
		var awakened=world.floor_at(34).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("driftglass_awakened")).size()
		var outcome="The powered cutters leave exactly 6 scrap and 3 glowstone, raise the installer by two Building ranks, and fix bright work lights throughout the hall. "+str(awakened)+" awakened Gloam stalker"+(" remains." if awakened==1 else "s remain.") if state=="powered" else "The shaded lens leaves exactly 4 rations, 2 medkits, and 2 timber. The lower seam stays dark, wakes no new threats, and sharply suppresses local pressure."
		var result=text_label(outcome+" The connected lower seam is permanently open"+(" after its awakened Gloam are cleared." if state=="powered" and awakened>0 else "."),20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the lower seam",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_bellhome():
	var warden=world.bellhome_landmark()
	if warden.is_empty():feedback("Bellhome Gate has not been reached.");return
	world.data.paused=true
	var col=make_popup("BELLHOME GATE · CONVOY WARNING",940)
	popup_kind="bellhome"
	var pawn=world.data.pawns[selected];var state=str(world.data.bellhome_state);var route=str(warden.get("route","darkway"))
	var threats=world.floor_at(35).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("bellhome_guard")).size()
	if state=="":
		var reception="Powered Driftglass sends Bellhome a bright convoy over a fixed-light cutter road. Three surface husks follow its heat." if route=="lampline" else "Shaded Driftglass brings Bellhome's convoy through an unlit glass road. Two Gloam stalkers wait in its darkness."
		var intro=text_label(reception+" Opening the gate starts a visible, pauseable 32-second warning and issues one physical convoy charter.\n\nESCORT · carry the charter, clear every route threat, and rally two colonists at the convoy. The charter remains physical; Bellhome grants route-shaped freight and safe idle recovery.\n\nDIVERT · carry and consume the charter with exactly 2 timber and 2 scrap, then rally two colonists at the culvert. The convoy avoids combat, leaves mixed stores, and the sealed culvert suppresses local pressure.\n\nRETREAT · missing the warning opens the road without rewards, but colonists outside marked safe rooms may be injured.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		col.add_child(button("Open convoy gate · begin 32-second warning",func():close_popup();world.data.paused=false;execute(world.order_bellhome(selected,"start",queue_mode));_refresh(),56,true))
	elif state=="warning":
		var has_charter=int(pawn.inventory.get("charter",0))>0;var has_diversion=int(pawn.inventory.get("timber",0))>=2 and int(pawn.inventory.get("scrap",0))>=2
		var status=text_label("%d PAUSEABLE SECONDS · %d route threat%s remain.\n\nSelected pack: %s charter · %s 2 timber + 2 scrap.\nConvoy muster: %d / 2 colonists · diversion culvert: %d / 2 colonists."%[int(ceil(float(world.data.bellhome_timer))),threats,"" if threats==1 else "s","carries" if has_charter else "missing","holds" if has_diversion else "missing",world.bellhome_gathered(),world.bellhome_gathered(true)],19)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var escort=button("Escort convoy · secure route + two colonists",func():close_popup();world.data.paused=false;execute(world.order_bellhome(selected,"escort",queue_mode));_refresh(),56,true);escort.disabled=not has_charter or threats>0 or world.bellhome_gathered()<2;col.add_child(escort)
		var divert=button("Divert convoy · charter + 2 timber + 2 scrap",func():close_popup();world.data.paused=false;execute(world.order_bellhome(selected,"divert",queue_mode));_refresh(),56);divert.disabled=not has_charter or not has_diversion or world.bellhome_gathered(true)<2;col.add_child(divert)
		col.add_child(button("Resume warning · move, fight, or regroup",func():close_popup();world.data.paused=false;_refresh(),50))
	else:
		var outcome="The convoy arrived under escort. Its route-shaped freight remains physical, Bellhome provides safe idle recovery, and the charter remains in its carrier's pack." if state=="escorted" else "The convoy passed through the braced culvert. Four scrap, 2 timber, and 1 medkit remain physical; the charter and exact bracing materials were consumed, every route threat was bypassed, and local pressure is strongly suppressed." if state=="diverted" else "The convoy withdrew when the warning expired. Bellhome grants no convoy stores, but the settlement road remains open so failure cannot end the campaign."
		var result=text_label(outcome,20);result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the Bellhome settlement road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_commons():
	var steward=world.commons_landmark()
	if steward.is_empty():feedback("Bellhome Commons has not been reached.");return
	world.data.paused=true
	var col=make_popup("BELLHOME COMMONS · OCCUPIED HOMES",940)
	popup_kind="commons"
	var pawn=world.data.pawns[selected];var state=str(world.data.commons_state);var route=str(steward.get("route","public"));var cost=world._commons_cost(route)
	var threats=world.floor_at(36).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("commons_guard")).size()
	if state=="":
		var reception="The escorted convoy earns a lamp-lit resident court guarded by one burrower. Repair requires the wall brace, 3 timber and 2 scrap; staffed homes provide strong recovery and survival stores." if route=="resident" else "The quiet diversion earns access through a dark culvert row guarded by one Gloam stalker. Repair requires the wall brace, 2 timber and 3 scrap; sealed homes provide industrial stores and strong pressure shelter." if route=="culvert" else "After the convoy retreat, Bellhome opens a wary public ward occupied by two surface husks. Repair requires the wall brace, 4 timber and 2 scrap; the shared ward provides mixed stores and modest shelter."
		var intro=text_label("Bellhome's convoy history changes who receives the expedition and which occupied housing route opens. Every route contains one physical four-kilogram wall brace that must be searched, carried and installed with exact materials after the threats are cleared.\n\n"+reception,18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		col.add_child(button("Accept Bellhome housing repair",func():close_popup();world.data.paused=false;execute(world.order_commons(selected,"start",queue_mode));_refresh(),56,true))
	elif state=="assigned":
		var has_brace=int(pawn.inventory.get("brace",0))>0;var materials=true
		for item in cost:materials=materials and int(pawn.inventory.get(item,0))>=int(cost[item])
		var status=text_label("%d route threat%s remain.\n\nSelected pack: %s physical wall brace · %s %d timber + %d scrap. Goods remain physical until the repair finishes."%[threats,"" if threats==1 else "s","carries" if has_brace else "missing","holds" if materials else "missing",int(cost.timber),int(cost.scrap)],19)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var finish=button("Install brace · %d timber + %d scrap"%[int(cost.timber),int(cost.scrap)],func():close_popup();world.data.paused=false;execute(world.order_commons(selected,"finish",queue_mode));_refresh(),56,true)
		finish.disabled=not has_brace or not materials or threats>0;col.add_child(finish)
	else:
		var outcome="Bellhome's resident homes are safe. Five rations, 3 medkits and 1 timber remain physical beside a strongly staffed recovery court." if state=="resident" else "Bellhome's culvert row is safe. Six scrap, 2 glowstone and 1 medkit remain physical beside strong pressure shelter." if state=="culvert" else "Bellhome's public ward is safe. Three rations, 2 medkits, 3 scrap and 2 timber remain physical beside modest recovery and pressure shelter."
		var result=text_label(outcome+" The heavy brace and exact route-shaped contribution were consumed only when work completed; prior evidence remains in its carrier's pack.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the lower dwellings road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_yard():
	var yardmaster=world.yard_landmark()
	if yardmaster.is_empty():feedback("Hearthline Yard has not been reached.");return
	world.data.paused=true
	var col=make_popup("HEARTHLINE YARD · SHARED LOAD",940)
	popup_kind="yard"
	var state=str(world.data.yard_state);var route=str(yardmaster.get("route","public"));var threats=world.floor_at(37).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("yard_guard")).size()
	if state=="":
		var reception="Bellhome's resident repair opens a lamp-lit thermal lane guarded by one burrower; Pell joins with practiced scavenging." if route=="resident" else "Bellhome's culvert repair opens a dark winch lane watched by one Gloam stalker; Pell joins with practiced building." if route=="culvert" else "Bellhome's public repair opens split lanes held by a burrower and a Gloam stalker; Pell joins as a balanced hand."
		var intro=text_label("Hearthline can reopen the independent lower line, but its thermal core and lift winch each weigh seven kilograms. They cannot fit together in one 12 kg pack. Accepting recruits Pell as a fifth independently selectable colonist with a separate pack.\n\n"+reception+" Recover both mechanisms, keep them with two different carriers, clear the lane threats, then gather three living colonists including Pell at the expansion gantry.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		col.add_child(button("Accept Hearthline expansion · recruit Pell",func():close_popup();world.data.paused=false;execute(world.order_yard(selected,"start",queue_mode));_refresh(),56,true))
	elif state=="assigned":
		var gantry=world.yard_gantry();var target=world.point(gantry) if not gantry.is_empty() else Vector2i(-99,-99);var carriers=world._yard_carriers(target);var pell_index=world._pell_index()
		var pell_ready=pell_index>=0 and int(world.data.pawns[pell_index].z)==37 and world.point(world.data.pawns[pell_index]).distance_to(target)<=4.0
		var status=text_label("%d route threat%s remain.\n\nSeparate cargo carriers: %d / 2 · gathered colonists: %d / 3 · Pell at gantry: %s. Both mechanisms remain physical until every condition is met."%[threats,"" if threats==1 else "s",carriers.size(),world.yard_gathered(),"ready" if pell_ready else "missing"],19)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var finish=button("Install separately carried core + winch",func():close_popup();world.data.paused=false;execute(world.order_yard(selected,"finish",queue_mode));_refresh(),56,true)
		finish.disabled=threats>0 or carriers.size()!=2 or world.yard_gathered()<3 or not pell_ready;col.add_child(finish)
	else:
		var outcome="Hearthline's resident lift runs beside a staffed recovery yard. Five rations, 3 medkits and 2 timber remain physical." if state=="resident" else "Hearthline's culvert lift runs under strong pressure shelter. Seven scrap, 3 glowstone and 1 medkit remain physical." if state=="culvert" else "Hearthline's public lift runs beside shared shelter. Three rations, 2 medkits, 4 scrap and 2 timber remain physical."
		var result=text_label(outcome+" Pell remains a separate colonist with route-shaped practiced skills. The core and winch were consumed only after distinct carriers and the gathered crew reached the gantry.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the independent lower line",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_kiln():
	var console=world.kiln_landmark()
	if console.is_empty():feedback("Kilnreach Works has not been reached.");return
	world.data.paused=true
	var col=make_popup("KILNREACH WORKS · COLD FURNACE",940)
	popup_kind="kiln"
	var pawn=world.data.pawns[selected];var state=str(world.data.kiln_state);var route=str(console.get("route","shared"));var pell_index=world._pell_index()
	var threats=world.floor_at(38).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("kiln_guard")).size()
	if state=="":
		var reception="Hearthline's resident line leaves Pell practiced at scavenging; the survey opens a lit slag gallery with two burrowers." if route=="forage" else "Hearthline's culvert line leaves Pell practiced at building; the survey opens a dark flue with one Gloam stalker." if route=="works" else "Hearthline's public line leaves Pell balanced; the survey opens split works with one burrower and one Gloam stalker."
		var intro=text_label(reception+" Pell must personally read the dead controls. Recover one physical 2 kg ignition spindle, then choose a permanent plan.\n\nREBUILD · exact route-shaped scrap and timber, productive ingots, warm recovery and +2 Building for Pell. Fixed lights and heat raise pressure and draw two surface husks.\n\nCONCEAL · exact route-shaped timber and scrap, physical provisions, no new threats, and strong pressure shelter.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var survey=button("Pell surveys the abandoned works",func():close_popup();world.data.paused=false;execute(world.order_kiln(selected,"start",queue_mode));_refresh(),56,true);survey.disabled=selected!=pell_index;col.add_child(survey)
		if selected!=pell_index:col.add_child(text_label("Select Pell from the colonist bar to begin the specialty survey.",15,"d7b978"))
	elif state=="assigned":
		var has_spindle=int(pawn.inventory.get("kiln_igniter",0))>0;var build_cost=world._kiln_cost("build");var conceal_cost=world._kiln_cost("conceal");var can_build=has_spindle;var can_conceal=has_spindle
		for item in build_cost:can_build=can_build and int(pawn.inventory.get(item,0))>=int(build_cost[item])
		for item in conceal_cost:can_conceal=can_conceal and int(pawn.inventory.get(item,0))>=int(conceal_cost[item])
		var status=text_label("%d route threat%s remain. Selected pack %s the physical spindle.\n\nREBUILD COST · %d scrap + %d timber. CONCEAL COST · %d timber + %d scrap. The spindle and materials remain physical until work completes."%[threats,"" if threats==1 else "s","holds" if has_spindle else "does not hold",int(build_cost.scrap),int(build_cost.timber),int(conceal_cost.timber),int(conceal_cost.scrap)],19)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var build=button("Rebuild kiln · productive heat + warned husks",func():close_popup();world.data.paused=false;execute(world.order_kiln(selected,"build",queue_mode));_refresh(),56,true);build.disabled=threats>0 or not can_build;col.add_child(build)
		var conceal=button("Conceal flues · provisions + low pressure",func():close_popup();world.data.paused=false;execute(world.order_kiln(selected,"conceal",queue_mode));_refresh(),56);conceal.disabled=threats>0 or not can_conceal;col.add_child(conceal)
	else:
		var awakened=world.floor_at(38).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("kiln_awakened")).size()
		var outcome="Kilnreach's fired works leave route-shaped ingots, raise Pell by two Building ranks, and provide warm idle recovery. Fixed lights and furnace heat raise pressure; %d drawn surface husk%s remain."%[awakened,"" if awakened==1 else "s"] if state=="built" else "Kilnreach's hidden works leave route-shaped provisions. The dark tram wakes no new threats and strongly suppresses local pressure."
		var result=text_label(outcome+" The physical spindle and exact materials were consumed only when work completed.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the lower tram",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_junction():
	var keeper=world.junction_landmark()
	if keeper.is_empty():feedback("Embervault Junction has not been reached.");return
	world.data.paused=true
	var col=make_popup("EMBERVAULT JUNCTION · INDEPENDENT FREIGHT",940)
	popup_kind="junction"
	var pawn=world.data.pawns[selected];var state=str(world.data.junction_state);var route=str(keeper.get("route","shadowline"))
	var threats=world.floor_at(39).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("junction_guard")).size()
	if state=="":
		var approach="Kilnreach's rebuilt furnace sends the train along a lamp-lit approach that draws three surface husks." if route=="hotline" else "Kilnreach's concealed flues send the train along a dark approach watched by two Gloam stalkers."
		var intro=text_label("Signalkeeper Ren answers from beyond Meridian's authority. "+approach+" Once Ren opens the signal, a pauseable 30-second arrival begins. Recover the physical signal seal and choose:

RECEIVE · clear the approach and gather two colonists at the platform. The seal remains carried proof and route-shaped freight arrives.

SHUNT · gather two colonists at the refuge shunt with the seal, exactly 2 timber and 2 scrap. This avoids the route threats, consumes the commitment, and creates strong pressure shelter.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		col.add_child(button("Answer Ren · begin 30-second warning",func():close_popup();world.data.paused=false;execute(world.order_junction(selected,"start",queue_mode));_refresh(),56,true))
	elif state=="warning":
		var has_seal=int(pawn.inventory.get("junction_seal",0))>0;var materials=int(pawn.inventory.get("timber",0))>=2 and int(pawn.inventory.get("scrap",0))>=2
		var status=text_label("%.0f SECONDS · %d route threat%s remain.

Selected pack: %s physical signal seal · %s 2 timber + 2 scrap. Platform crew: %d / 2 · refuge-shunt crew: %d / 2. The timer stops while paused."%[ceil(float(world.data.junction_timer)),threats,"" if threats==1 else "s","holds" if has_seal else "missing","holds" if materials else "missing",world.junction_gathered(),world.junction_gathered(true)],19)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var receive=button("Receive freight · secure route + 2 crew",func():close_popup();world.data.paused=false;execute(world.order_junction(selected,"receive",queue_mode));_refresh(),56,true);receive.disabled=not has_seal or threats>0 or world.junction_gathered()<2;col.add_child(receive)
		var shunt=button("Shunt freight · seal + 2 timber + 2 scrap",func():close_popup();world.data.paused=false;execute(world.order_junction(selected,"shunt",queue_mode));_refresh(),56);shunt.disabled=not has_seal or not materials or world.junction_gathered(true)<2;col.add_child(shunt)
	else:
		var outcome="Ren received the independent freight. Route-shaped cargo remains physical, the carrier keeps the signal seal as proof, and gathered crews recover safely here." if state=="received" else "The refuge shunt saved mixed stores and strongly shelters local pressure. The signal seal and exact materials were consumed only when the diversion completed." if state=="shunted" else "The train was missed. Exposed colonists were hurt, but Ren opened the settlement road so the campaign cannot dead-end."
		var result=text_label(outcome,20);result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the Embervault settlement road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_ember_commons():
	var keeper=world.ember_commons_landmark()
	if keeper.is_empty():feedback("Embervault Commons has not been reached.");return
	world.data.paused=true
	var col=make_popup("EMBERVAULT COMMONS · SIGNAL HOUSE",940)
	popup_kind="ember_commons"
	var pawn=world.data.pawns[selected];var state=str(world.data.ember_commons_state);var route=str(keeper.get("route","public"));var cost=world._ember_commons_cost(route)
	var threats=world.floor_at(40).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("ember_commons_guard")).size()
	if state=="":
		var reception="Receiving the train earns a lamp-lit freight court guarded by one burrower. The restored house provides strong recovery and resident provisions." if route=="freight" else "Sheltering the train earns a dark cablewalk watched by one Gloam stalker. The restored house provides industrial stores and strong pressure shelter." if route=="refuge" else "Missing the train leaves a wary public arcade occupied by two surface husks. The restored house provides mixed stores and modest shelter."
		var intro=text_label("Embervault's freight history changes the settlement's reception. "+reception+" Accept the work, clear the route, recover one physical three-kilogram signal breaker, and install it with exactly %d timber and %d scrap. Prior evidence remains in its carrier's pack."%[int(cost.timber),int(cost.scrap)],18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		col.add_child(button("Accept Embervault signal-house repair",func():close_popup();world.data.paused=false;execute(world.order_ember_commons(selected,"start",queue_mode));_refresh(),56,true))
	elif state=="assigned":
		var has_breaker=int(pawn.inventory.get("signal_breaker",0))>0;var materials=true
		for item in cost:materials=materials and int(pawn.inventory.get(item,0))>=int(cost[item])
		var status=text_label("%d route threat%s remain.\n\nSelected pack: %s physical signal breaker · %s %d timber + %d scrap. Goods remain physical until the repair finishes."%[threats,"" if threats==1 else "s","carries" if has_breaker else "missing","holds" if materials else "missing",int(cost.timber),int(cost.scrap)],19)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var finish=button("Install breaker · %d timber + %d scrap"%[int(cost.timber),int(cost.scrap)],func():close_popup();world.data.paused=false;execute(world.order_ember_commons(selected,"finish",queue_mode));_refresh(),56,true)
		finish.disabled=not has_breaker or not materials or threats>0;col.add_child(finish)
	else:
		var outcome="The freight court signal house is restored. Five rations, 3 medkits and 1 timber remain physical beside strong staffed recovery." if state=="freight" else "The refuge signal house is restored. Six scrap, 2 glowstone and 1 medkit remain physical beside strong pressure shelter." if state=="refuge" else "The public signal house is restored. Three rations, 2 medkits, 3 scrap and 2 timber remain physical beside modest shared shelter."
		var result=text_label(outcome+" The physical breaker and exact route-shaped contribution were consumed only when work completed; the connected lower stair is open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the Embervault lower stair",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_deepcoil():
	var caller=world.deepcoil_landmark()
	if caller.is_empty():feedback("Deepcoil Relay has not been reached.");return
	world.data.paused=true
	var col=make_popup("DEEPCOIL RELAY · PAIRED CALL",940)
	popup_kind="deepcoil"
	var state=str(world.data.deepcoil_state);var route=str(caller.get("route","echo"));var sync=world.deepcoil_sync();var target=world.point(sync) if not sync.is_empty() else Vector2i(-99,-99)
	var threats=world.floor_at(41).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("deepcoil_guard")).size()
	if state=="":
		var answer="Embervault's staffed freight house reaches Keeper Vey. Two burrowers hold lamp-lit crown and root galleries; a synchronized call provides strong recovery stores." if route=="keepers" else "Embervault's refuge signal reaches Freeband Tern. Two Gloam stalkers watch dark split galleries; a synchronized call provides industrial freight and strong pressure shelter." if route=="freeband" else "Embervault's public signal reaches an unidentified voice. A burrower and Gloam stalker divide the mixed-light galleries; a synchronized call provides balanced stores and shelter."
		var intro=text_label(answer+"\n\nThe crown coil and root coil each weigh 6.5 kg, so they cannot fit together in one 12 kg pack. Clear both galleries, recover each physical coil with a different colonist, then gather both carriers beside the synchronizer before tuning the pair.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		col.add_child(button("Answer Deepcoil · open both relay galleries",func():close_popup();world.data.paused=false;execute(world.order_deepcoil(selected,"start",queue_mode));_refresh(),56,true))
	elif state=="assigned":
		var carriers=world._deepcoil_carriers(target)
		var crown_carriers=world.data.pawns.filter(func(pawn):return int(pawn.z)==41 and world.point(pawn).distance_to(target)<=4.0 and int(pawn.inventory.get("relay_crown",0))>0).size()
		var root_carriers=world.data.pawns.filter(func(pawn):return int(pawn.z)==41 and world.point(pawn).distance_to(target)<=4.0 and int(pawn.inventory.get("relay_root",0))>0).size()
		var status=text_label("%d gallery threat%s remain.\n\nCrown-coil carrier at synchronizer: %s · root-coil carrier: %s · distinct paired carriers: %d / 2. Both 6.5 kg coils remain physical until synchronized work completes."%[threats,"" if threats==1 else "s","ready" if crown_carriers>0 else "missing","ready" if root_carriers>0 else "missing",carriers.size()],19)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var finish=button("Synchronize separately carried relay coils",func():close_popup();world.data.paused=false;execute(world.order_deepcoil(selected,"finish",queue_mode));_refresh(),56,true)
		finish.disabled=threats>0 or carriers.size()!=2;col.add_child(finish)
	else:
		var outcome="Keeper Vey answers on the staffed line. Four rations, 3 medkits and 2 timber remain physical beside strong safe recovery." if state=="keepers" else "Freeband Tern answers on the dark line. Seven scrap, 3 glowstone and 1 medkit remain physical beside strong pressure shelter." if state=="freeband" else "The unknown echo remains part of Deepcoil's route history. Three rations, 2 medkits, 4 scrap and 1 timber remain physical beside modest mixed shelter."
		var result=text_label(outcome+" The crown and root coils were consumed only after two distinct carriers reached the synchronizer; the answered descent is open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the answered descent",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_coilward():
	var caller=world.coilward_landmark()
	if caller.is_empty():feedback("Coilward Commons has not been reached.");return
	world.data.paused=true
	var col=make_popup("COILWARD COMMONS · COMMUNITY CHARTER",940)
	popup_kind="coilward"
	var pawn=world.data.pawns[selected];var state=str(world.data.coilward_state);var route=str(caller.get("route","echo"));var cost=world._coilward_cost(route)
	var threats=world.floor_at(42).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("coilward_guard")).size()
	var cost_copy="2 rations + 1 medkit" if route=="keepers" else "3 scrap + 1 glowstone" if route=="freeband" else "2 timber + 2 scrap"
	if state=="":
		var reception="Steward Oris receives Deepcoil's keeper answer through a lamp-lit hall. One burrower guards the charter; the contribution funds strong staffed recovery." if route=="keepers" else "Speaker Wren receives Deepcoil's freeband answer through a dark cableway. One Gloam stalker guards the charter; the contribution funds strong pressure shelter." if route=="freeband" else "The Open Assembly receives Deepcoil's unknown echo through a wary public arcade. Two surface husks guard the charter; the contribution funds balanced communal shelter."
		var intro=text_label(reception+"\n\nRecover the physical 0.8 kg community charter, clear the route, and carry it with exactly "+cost_copy+" to the council seal. Materials are consumed only when ratification finishes. The signed charter remains in its carrier's pack as evidence for settlements below.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		col.add_child(button("Accept Coilward community charter",func():close_popup();world.data.paused=false;execute(world.order_coilward(selected,"start",queue_mode));_refresh(),56,true))
	elif state=="assigned":
		var has_charter=int(pawn.inventory.get("ward_charter",0))>0;var materials=true
		for item in cost:materials=materials and int(pawn.inventory.get(item,0))>=int(cost[item])
		var status=text_label("%d route threat%s remain.\n\nSelected pack: %s physical community charter · %s %s. The signed charter will remain physical after ratification."%[threats,"" if threats==1 else "s","carries" if has_charter else "missing","holds" if materials else "missing",cost_copy],19)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var finish=button("Ratify charter · "+cost_copy,func():close_popup();world.data.paused=false;execute(world.order_coilward(selected,"finish",queue_mode));_refresh(),56,true)
		finish.disabled=not has_charter or not materials or threats>0;col.add_child(finish)
	else:
		var outcome="Steward Oris ratifies the keeper charter. Five rations, 3 medkits and 1 timber remain physical beside strong safe recovery." if state=="keepers" else "Speaker Wren ratifies the freeband charter. Six scrap, 3 glowstone and 1 medkit remain physical beside strong pressure shelter." if state=="freeband" else "The Open Assembly ratifies the public charter. Three rations, 2 medkits, 3 scrap and 2 timber remain physical beside modest mixed shelter."
		var result=text_label(outcome+" The exact contribution was consumed only when work completed; the signed community charter remains in its carrier's pack and the connected lower road is open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the chartered lower road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_charterwell():
	var caller=world.charterwell_landmark()
	if caller.is_empty():feedback("Charterwell Station has not been reached.");return
	world.data.paused=true
	var col=make_popup("CHARTERWELL STATION · DELEGATION BELL",940)
	popup_kind="charterwell"
	var pawn=world.data.pawns[selected];var state=str(world.data.charterwell_state);var route=str(caller.get("route","public"));var cost=world._charterwell_cost(route)
	var threats=world.floor_at(43).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("charterwell_guard")).size()
	var has_charter=int(pawn.inventory.get("ward_charter",0))>0
	var cost_copy="2 rations + 1 medkit" if route=="council" else "3 scrap + 1 glowstone" if route=="underroad" else "2 timber + 2 rations"
	if state=="":
		var reception="Coilward's keeper charter reaches Delegate Mara. Two burrowers hold a lamp-lit council road." if route=="council" else "Coilward's freeband charter reaches Courier Fen. Two Gloam stalkers watch the dark underroad." if route=="underroad" else "Coilward's public charter reaches Caller Nine. Three surface husks occupy the mixed-light arcade."
		var intro=text_label(reception+"\n\nThe selected colonist must physically carry the signed community charter to ring the departure bell. Then clear the approach and rally three colonists at the platform for an escort, or gather two colonists at the supply gate with exactly "+cost_copy+". The pauseable window lasts 30 seconds; marked station rooms protect occupants if it expires, and missing the delegation never blocks the lower road.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var start=button("Present charter · ring delegation bell",func():close_popup();world.data.paused=false;execute(world.order_charterwell(selected,"start",queue_mode));_refresh(),56,true)
		start.disabled=not has_charter;col.add_child(start)
	elif state=="warning":
		var materials=true
		for item in cost:materials=materials and int(pawn.inventory.get(item,0))>=int(cost[item])
		var status=text_label("%d seconds remain · %d route threat%s.\n\nSelected pack: %s signed charter · %s %s. Platform crew: %d / 3 · supply-gate crew: %d / 2. Supplies are consumed only when safe passage completes; the charter always remains physical."%[int(ceil(float(world.data.charterwell_timer))),threats,"" if threats==1 else "s","carries" if has_charter else "missing","holds" if materials else "missing",cost_copy,world.charterwell_gathered(),world.charterwell_gathered(true)],19)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var escort=button("Escort delegation · secure route + 3 crew",func():close_popup();world.data.paused=false;execute(world.order_charterwell(selected,"escort",queue_mode));_refresh(),56,true)
		escort.disabled=not has_charter or threats>0 or world.charterwell_gathered()<3;col.add_child(escort)
		var supply=button("Fund passage · "+cost_copy+" + 2 crew",func():close_popup();world.data.paused=false;execute(world.order_charterwell(selected,"supply",queue_mode));_refresh(),56,true)
		supply.disabled=not has_charter or not materials or world.charterwell_gathered(true)<2;col.add_child(supply)
	else:
		var outcome="The delegation departs under three-colonist escort. A route-shaped issue and physical signed writ wait beside strong recovery." if state=="escorted" else "The exact passage supplies were spent with two colonists at the gate. Guards withdraw; a signed writ and material stores remain beside strong pressure shelter." if state=="supplied" else "The delegation departed without the expedition. Exposed colonists were hurt, but an emergency writ and ration remain and the road stays open."
		var result=text_label(outcome+" Coilward's community charter remains in its carrier's pack, and the connected lower road is open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the delegation lower road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_writwell():
	var speaker=world.writwell_landmark()
	if speaker.is_empty():feedback("Writwell Assembly has not been reached.");return
	world.data.paused=true
	var col=make_popup("WRITWELL ASSEMBLY · SHARED-SUPPLY VOTE",940)
	popup_kind="writwell"
	var pawn=world.data.pawns[selected];var state=str(world.data.writwell_state);var route=str(speaker.get("route","commons"));var cost=world._writwell_cost(route)
	var threats=world.floor_at(44).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("writwell_guard")).size()
	var has_writ=int(pawn.inventory.get("delegate_writ",0))>0
	var cost_copy="4 rations + 2 medkits" if route=="delegates" else "5 scrap + 2 glowstone" if route=="exchange" else "3 timber + 3 rations"
	if state=="":
		var reception="Charterwell's escorted delegation brings Convener Ilex to a lamp-lit hall guarded by two burrowers." if route=="delegates" else "Charterwell's funded passage brings Quartermaster Brin through a dark exchange cloister guarded by two Gloam stalkers." if route=="exchange" else "Charterwell's emergency writ reaches Open-chair Moss through a mixed-light aisle occupied by three surface husks."
		var intro=text_label(reception+"\n\nThe selected colonist must physically carry the 0.4 kg delegation writ to convene the vote. Clear the gallery, rally three colonists at the common table, and jointly provide exactly "+cost_copy+" across at least two separate packs. Supplies remain with their owners until the vote completes; the writ remains physical afterward.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var start=button("Present writ · convene assembly",func():close_popup();world.data.paused=false;execute(world.order_writwell(selected,"start",queue_mode));_refresh(),56,true)
		start.disabled=not has_writ;col.add_child(start)
	elif state=="assigned":
		var materials=true;var holdings:Array=[]
		for item in cost:
			var available=world.writwell_available(item);materials=materials and available>=int(cost[item]);holdings.append(str(available)+" / "+str(cost[item])+" "+World.ITEMS[item].name.to_lower())
		var status=text_label("%d route threat%s remain.\n\nSelected pack: %s physical delegation writ. Common-table crew: %d / 3 · contributing packs: %d / 2. Gathered supplies: %s. Exact goods are consumed across their separate owners only when the vote completes."%[threats,"" if threats==1 else "s","carries" if has_writ else "missing",world.writwell_crew().size(),world.writwell_contributors(),", ".join(holdings)],19)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var pledge=button("Ratify shared pledge · "+cost_copy,func():close_popup();world.data.paused=false;execute(world.order_writwell(selected,"pledge",queue_mode));_refresh(),56,true)
		pledge.disabled=not has_writ or threats>0 or world.writwell_crew().size()<3 or world.writwell_contributors()<2 or not materials;col.add_child(pledge)
	else:
		var outcome="The escorted delegates ratify a staffed compact. Five rations, 3 medkits, 2 timber and a physical assembly mandate remain beside strong recovery." if state=="delegates" else "The exchange wards ratify a distributed freight pledge. Seven scrap, 3 glowstone, 1 medkit and a physical mandate remain beside strong pressure shelter." if state=="exchange" else "The open assembly ratifies a public compact. Four rations, 2 medkits, 3 scrap, 2 timber and a physical mandate remain beside balanced shelter."
		var result=text_label(outcome+" The exact pledge was drawn from at least two gathered packs only when the three-colonist vote completed. Charterwell's delegation writ remains carried and the mandated lower road is open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the mandated lower road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_concordance():
	var speaker=world.concordance_landmark()
	if speaker.is_empty():feedback("Concordance Gate has not been reached.");return
	world.data.paused=true
	var col=make_popup("CONCORDANCE GATE · COORDINATED DEFENSE",940)
	popup_kind="concordance"
	var pawn=world.data.pawns[selected];var state=str(world.data.concordance_state);var route=str(speaker.get("route","public"))
	var threats=world.floor_at(45).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("concordance_guard")).size()
	var has_mandate=int(pawn.inventory.get("assembly_mandate",0))>0
	if state=="":
		var reception="Writwell's delegate mandate reaches Gatewarden Sable through a lamp-lit council guardline held by two burrowers." if route=="council" else "Writwell's exchange mandate reaches Runner Ibis through a dark shadow approach watched by two Gloam stalkers." if route=="shadow" else "Writwell's public mandate reaches Marshal Reed through a mixed-light breach occupied by three surface husks."
		var intro=text_label(reception+"\n\nThe selected colonist must physically carry the 0.5 kg assembly mandate. Once the gate opens, clear its threats and rally three colonists with exactly 4 timber + 3 scrap to anchor a warm fixed bastion, or rally two with exactly 4 rations + 2 medkits to withdraw into a mobile reserve. Supplies remain owned until work completes; the mandate is never consumed.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var start=button("Present mandate · open Concordance",func():close_popup();world.data.paused=false;execute(world.order_concordance(selected,"start",queue_mode));_refresh(),56,true)
		start.disabled=not has_mandate;col.add_child(start)
	elif state=="assigned":
		var bastion_cost=world._concordance_cost("bastion");var reserve_cost=world._concordance_cost("reserve");var bastion_goods=true;var reserve_goods=true
		for item in bastion_cost:bastion_goods=bastion_goods and int(pawn.inventory.get(item,0))>=int(bastion_cost[item])
		for item in reserve_cost:reserve_goods=reserve_goods and int(pawn.inventory.get(item,0))>=int(reserve_cost[item])
		var status=text_label("%d route threat%s remain.\n\nSelected pack: %s physical assembly mandate · %s 4 timber + 3 scrap · %s 4 rations + 2 medkits. Bastion crew: %d / 3 · reserve crew: %d / 2. The bastion requires a clear approach and adds recovery plus heat; the reserve may bypass live guards and shelters pressure on the deepest reached road."%[threats,"" if threats==1 else "s","carries" if has_mandate else "missing","holds" if bastion_goods else "missing","holds" if reserve_goods else "missing",world.concordance_gathered(),world.concordance_gathered(true)],19)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var bastion=button("Build fixed bastion · 3 crew + exact materials",func():close_popup();world.data.paused=false;execute(world.order_concordance(selected,"bastion",queue_mode));_refresh(),58,true)
		bastion.disabled=not has_mandate or threats>0 or world.concordance_gathered()<3 or not bastion_goods;col.add_child(bastion)
		var reserve=button("Provision mobile reserve · 2 crew + exact supplies",func():close_popup();world.data.paused=false;execute(world.order_concordance(selected,"reserve",queue_mode));_refresh(),58,true)
		reserve.disabled=not has_mandate or world.concordance_gathered(true)<2 or not reserve_goods;col.add_child(reserve)
	else:
		var outcome="Three colonists anchored the fixed bastion. Exact construction stores were consumed; three barricades, strong recovery, five rations, 3 medkits and a physical response token remain, while heat raises pressure." if state=="bastion" else "Two colonists provisioned the mobile reserve. Exact medical stores were consumed, remaining guards withdrew, and its route shelters surface pressure at the deepest reached floor beside 6 scrap, 3 glowstone, 2 timber and a physical response token."
		var result=text_label(outcome+" Writwell's assembly mandate remains in its carrier's pack and the coordinated lower road is open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the coordinated lower road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_reservefall():
	var speaker=world.reservefall_landmark()
	if speaker.is_empty():feedback("Reservefall Junction has not been reached.");return
	world.data.paused=true
	var col=make_popup("RESERVEFALL JUNCTION · SURFACE INCURSION",940)
	popup_kind="reservefall"
	var pawn=world.data.pawns[selected];var state=str(world.data.reservefall_state);var route=str(speaker.get("route","reserve"))
	var threats=world.floor_at(46).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("reservefall_guard")).size()
	var has_token=int(pawn.inventory.get("concordance_token",0))>0
	if state=="":
		var reception="Concordance's fixed bastion lights the hot tram, drawing a stronger four-husk incursion toward the lower quarter." if route=="bastion" else "Concordance's mobile reserve intercepts the dark tram, leaving two surface husks at the junction."
		var intro=text_label(reception+"\n\nThe selected colonist must physically carry the 0.6 kg response token. Presenting it starts a pauseable 30-second warning. Clear the incursion and rally three colonists to hold, or rally two at the fallback with exactly 2 timber + 2 scrap. A timeout injures exposed colonists but never blocks the lower road.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var start=button("Present response token · sound warning",func():close_popup();world.data.paused=false;execute(world.order_reservefall(selected,"start",queue_mode));_refresh(),56,true)
		start.disabled=not has_token;col.add_child(start)
	elif state=="warning":
		var goods=true
		for item in world._reservefall_cost():goods=goods and int(pawn.inventory.get(item,0))>=int(world._reservefall_cost()[item])
		var status=text_label("%d seconds · %d surface husk%s remain.\n\nSelected pack: %s physical response token · %s 2 timber + 2 scrap. Hold crew: %d / 3 · fallback crew: %d / 2. The hold requires a clear approach; withdrawal may bypass living husks and consumes materials only when complete."%[int(ceil(float(world.data.reservefall_timer))),threats,"" if threats==1 else "s","carries" if has_token else "missing","holds" if goods else "missing",world.reservefall_gathered(),world.reservefall_gathered(true)],19)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var hold=button("Hold defense line · clear + 3 crew",func():close_popup();world.data.paused=false;execute(world.order_reservefall(selected,"hold",queue_mode));_refresh(),58,true)
		hold.disabled=not has_token or threats>0 or world.reservefall_gathered()<3;col.add_child(hold)
		var withdraw=button("Withdraw residents · 2 crew + exact materials",func():close_popup();world.data.paused=false;execute(world.order_reservefall(selected,"withdraw",queue_mode));_refresh(),58,true)
		withdraw.disabled=not has_token or world.reservefall_gathered(true)<2 or not goods;col.add_child(withdraw)
	else:
		var outcome="Three colonists held the line. Route-shaped resident stores, strong recovery, barricades and a physical quarter pass remain." if state=="held" else "Two colonists completed the material-backed withdrawal. Live husks dispersed, fallback stores and a physical quarter pass remain beside strong pressure shelter." if state=="withdrawn" else "The warning expired. Exposed colonists were injured, but the safe rooms held and an emergency quarter pass keeps progression open."
		var result=text_label(outcome+" Concordance's response token remains in its carrier's pack and the inhabited lower road is open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the inhabited lower road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_reserve_commons():
	var steward=world.reserve_commons_landmark()
	if steward.is_empty():feedback("Reservefall Commons has not been reached.");return
	world.data.paused=true
	var col=make_popup("RESERVEFALL COMMONS · COMMUNAL DEFENSE",940)
	popup_kind="reserve_commons"
	var pawn=world.data.pawns[selected];var state=str(world.data.reserve_commons_state);var route=str(steward.get("route","public"))
	var has_pass=int(pawn.inventory.get("quarter_pass",0))>0;var has_shield=int(pawn.inventory.get("quarter_shield",0))>0
	var cost=world._reserve_commons_cost(route);var goods=true
	for item in cost:goods=goods and int(pawn.inventory.get(item,0))>=int(cost[item])
	if state=="":
		var reception="The held junction earns a lamp-lit resident court guarded by one burrower and the lightest repair contribution." if route=="guarded" else "The withdrawal opens a dark refuge culvert watched by one Gloam stalker and a pressure-sheltering repair." if route=="sheltered" else "The breach leaves a wary public arcade occupied by two surface husks and the heaviest communal contribution."
		var intro=text_label(reception+"\n\nPresent the physical 0.5 kg quarter pass to open the district. Search for one 4 kg communal shield, clear the reception route, then carry the shield, pass and exactly "+str(cost.timber)+" timber + "+str(cost.scrap)+" scrap to the repair court. The pass remains with its carrier.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var start=button("Present quarter pass · enter commons",func():close_popup();world.data.paused=false;execute(world.order_reserve_commons(selected,"start",queue_mode));_refresh(),56,true)
		start.disabled=not has_pass;col.add_child(start)
		if start.disabled:col.add_child(text_label("The selected colonist does not carry Reservefall's physical quarter pass.",16,"e2a178"))
	elif state=="assigned":
		var threats=world.floor_at(47).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("reserve_commons_guard")).size()
		var weight=world.weight(pawn.inventory)
		var status=text_label("Reception threats: "+str(threats)+". Selected pack: "+("quarter pass" if has_pass else "missing pass")+", "+("4 kg communal shield" if has_shield else "missing shield")+", "+("exact materials" if goods else "missing "+str(cost.timber)+" timber + "+str(cost.scrap)+" scrap")+".\n\nCurrent load: %.1f / 12.0 kg. Supplies remain physically owned until the six-second repair completes."%weight,19)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var repair=button("Repair communal defense · shield + exact materials",func():close_popup();world.data.paused=false;execute(world.order_reserve_commons(selected,"finish",queue_mode));_refresh(),58,true)
		repair.disabled=not has_pass or not has_shield or not goods or threats>0;col.add_child(repair)
	else:
		var outcome="The guarded shield court now provides strong recovery and resident medical stores." if state=="guarded" else "The repaired refuge row strongly shelters local pressure beside industrial stores." if state=="sheltered" else "The wary public quarter now has a shared movable defense and mixed stores."
		var result=text_label(outcome+" The 4 kg shield and exact materials were consumed; the quarter pass remains in its carrier's pack and Shieldline descent is open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use Shieldline descent",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_shieldline():
	var master=world.shieldline_landmark()
	if master.is_empty():feedback("Shieldline Works has not been reached.");return
	world.data.paused=true
	var col=make_popup("SHIELDLINE WORKS · WALKING WALL",960)
	popup_kind="shieldline"
	var pawn=world.data.pawns[selected];var state=str(world.data.shieldline_state);var route=str(master.get("route","public"))
	var has_pass=int(pawn.inventory.get("quarter_pass",0))>0
	if state=="":
		var approach="Reservefall's guarded repair opens three lamp-lit work bays held by two burrowers." if route=="guarded" else "Reservefall's shelter opens dark component lanes watched by two Gloam stalkers." if route=="sheltered" else "Reservefall's public defense opens split lanes held by a burrower and a Gloam stalker."
		var intro=text_label(approach+"\n\nPresent the physical quarter pass to accept the mobile-defense contract. Kest joins as a sixth colonist with an independent pack and route-shaped skills. Recover a 6 kg folding frame and 6 kg carriage axle in two different packs, clear the lanes, then rally three colonists including Kest at the assembly carriage.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var start=button("Present quarter pass · recruit Kest",func():close_popup();world.data.paused=false;execute(world.order_shieldline(selected,"start",queue_mode));_refresh(),58,true)
		start.disabled=not has_pass;col.add_child(start)
		if start.disabled:col.add_child(text_label("The selected colonist does not carry Reservefall's physical quarter pass.",16,"e2a178"))
	elif state=="assigned":
		var threats=world.floor_at(48).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("shieldline_guard")).size()
		var carriage=world.shieldline_carriage();var target=world.point(carriage) if not carriage.is_empty() else Vector2i(-99,-99);var carriers=world._shieldline_carriers(target)
		var kest_ready=false;var kest_index=world._kest_index()
		if kest_index>=0:kest_ready=int(world.data.pawns[kest_index].z)==48 and world.point(world.data.pawns[kest_index]).distance_to(target)<=4.0
		var status=text_label("Route threats: "+str(threats)+". Heavy-part carriers: "+str(carriers.size())+" / 2. Crew at carriage: "+str(world.shieldline_gathered())+" / 3. Kest: "+("ready" if kest_ready else "not at carriage")+".\n\nThe frame and axle must remain in separate physical packs until the 6.5-second assembly completes.",19)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var finish=button("Assemble walking wall · 2 carriers + 3 crew",func():close_popup();world.data.paused=false;execute(world.order_shieldline(selected,"finish",queue_mode));_refresh(),60,true)
		finish.disabled=threats>0 or carriers.size()!=2 or world.shieldline_gathered()<3 or not kest_ready;col.add_child(finish)
	else:
		var outcome="The guarded carriage supports strong recovery and resident issue." if state=="guarded" else "The concealed carriage shelters local pressure beside industrial freight." if state=="sheltered" else "The public walking wall leaves mixed communal stores and a flexible lower road."
		var result=text_label(outcome+" Both heavy parts were consumed, but the quarter pass remains carried. Kest remains a separately equipped colonist, the lower works road is open, and folding shieldwalls can now be built on any explored level.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use the lower works road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_marchhold():
	var speaker=world.marchhold_landmark()
	if speaker.is_empty():feedback("Marchhold Crossing has not been reached.");return
	world.data.paused=true
	var col=make_popup("MARCHHOLD CROSSING · MOBILE CAMP",980)
	popup_kind="marchhold"
	var pawn=world.data.pawns[selected];var state=str(world.data.marchhold_state);var route=str(speaker.get("route","public"))
	var threats=world.floor_at(49).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("marchhold_guard")).size()
	if state=="":
		var approach="The guarded carriage reaches a lamp-lit bridge where four surface husks are descending." if route=="guarded" else "The concealed carriage reaches a dark service span where two husks are closing in." if route=="sheltered" else "The public carriage reaches a broken mixed-light crossing where three husks are descending."
		var intro=text_label(approach+"\n\nSound the 32-second warning with Kest present. Recover the physical 4 kg folded wall. Clear the crossing and deploy it with exactly 2 timber, 2 scrap, Kest and three colonists—or carry it through the retreat ramp with exactly 2 rations, 1 medkit and two colonists while threats remain.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var start=button("Sound crossing warning · 32 seconds",func():close_popup();world.data.paused=false;execute(world.order_marchhold(selected,"start",queue_mode));_refresh(),58,true)
		start.disabled=world._kest_index()<0;col.add_child(start)
	elif state=="warning":
		var has_wall=int(pawn.inventory.get("march_wall",0))>0;var deploy_goods=true;var retreat_goods=true
		for item in world._marchhold_deploy_cost():deploy_goods=deploy_goods and int(pawn.inventory.get(item,0))>=int(world._marchhold_deploy_cost()[item])
		for item in world._marchhold_retreat_cost():retreat_goods=retreat_goods and int(pawn.inventory.get(item,0))>=int(world._marchhold_retreat_cost()[item])
		var line=world.floor_at(49).landmarks.filter(func(mark):return mark.kind=="marchhold_line");var kest_ready=not line.is_empty() and world._marchhold_kest_ready(world.point(line[0]))
		var status=text_label("%d seconds · %d surface husk%s remain.\n\nSelected pack: %s folded wall · %s deployment materials · %s retreat provisions. Deploy crew: %d / 3 · Kest: %s · retreat crew: %d / 2. Deployment requires a clear span; retreat bypasses live threats and preserves the wall in its carrier's pack."%[int(ceil(float(world.data.marchhold_timer))),threats,"" if threats==1 else "s","carries" if has_wall else "missing","ready" if deploy_goods else "missing","ready" if retreat_goods else "missing",world.marchhold_gathered(),"ready" if kest_ready else "not at line",world.marchhold_gathered(true)],18)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var deploy=button("Deploy folded wall · clear + Kest + 3 crew",func():close_popup();world.data.paused=false;execute(world.order_marchhold(selected,"deploy",queue_mode));_refresh(),60,true)
		deploy.disabled=not has_wall or not deploy_goods or threats>0 or world.marchhold_gathered()<3 or not kest_ready;col.add_child(deploy)
		var retreat=button("Retreat with wall · provisions + 2 crew",func():close_popup();world.data.paused=false;execute(world.order_marchhold(selected,"retreat",queue_mode));_refresh(),60,true)
		retreat.disabled=not has_wall or not retreat_goods or world.marchhold_gathered(true)<2;col.add_child(retreat)
	else:
		var outcome="Kest's deployed wall now forms three durable shield sections, protects recovery and leaves a guarded issue." if state=="deployed" else "The mobile camp withdrew with its folded wall still in one pack, sheltering pressure and leaving retreat stores." if state=="retreated" else "The camp was overrun, but the refuge alcoves protected their occupants and the road remains open."
		var result=text_label(outcome+" Every outcome leaves a physical crossing seal for the next settlement route.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use Marchhold lower road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_march_refuge():
	var keeper=world.march_refuge_landmark()
	if keeper.is_empty():feedback("Marchhold Refuge has not been reached.");return
	world.data.paused=true
	var col=make_popup("MARCHHOLD REFUGE · WALL-KEEPERS",980)
	popup_kind="march_refuge"
	var pawn=world.data.pawns[selected];var state=str(world.data.march_refuge_state);var route=str(keeper.get("route","public"))
	var has_seal=int(pawn.inventory.get("crossing_seal",0))>0
	if state=="":
		var approach="Marchhold's deployed defense earns a guarded, lamp-lit welcome court." if route=="guarded" else "Marchhold's retreat opens a dark wagon row where the folded wall can remain mobile or become communal." if route=="sheltered" else "Marchhold's overrun opens a damaged public gallery that needs the heaviest repair."
		var intro=text_label(approach+"\n\nPresent the physical crossing seal to enter. Recover a 4 kg refuge brace, clear the reception road and bring exact route-shaped timber and scrap to the communal yard. The crossing seal remains carried through every outcome.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var start=button("Present crossing seal · enter refuge",func():close_popup();world.data.paused=false;execute(world.order_march_refuge(selected,"start",queue_mode));_refresh(),58,true)
		start.disabled=not has_seal;col.add_child(start)
		if start.disabled:col.add_child(text_label("The selected colonist does not carry Marchhold's physical crossing seal.",16,"e2a178"))
	elif state=="assigned":
		var threats=world.floor_at(50).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("march_refuge_guard")).size();var cost=world._march_refuge_cost(route)
		var repair_ready=has_seal and int(pawn.inventory.get("refuge_brace",0))>=1
		for item in cost:repair_ready=repair_ready and int(pawn.inventory.get(item,0))>=int(cost[item])
		var status=text_label("Route threats: %d. Selected pack: %s crossing seal · %s 4 kg refuge brace · repair cost %d timber + %d scrap.\n\nThe brace repair preserves any folded wall in its carrier's pack."%[threats,"carries" if has_seal else "missing","carries" if int(pawn.inventory.get("refuge_brace",0))>0 else "missing",int(cost.timber),int(cost.scrap)],18)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var repair=button("Install refuge brace · preserve folded wall",func():close_popup();world.data.paused=false;execute(world.order_march_refuge(selected,"repair",queue_mode));_refresh(),60,true)
		repair.disabled=threats>0 or not repair_ready;col.add_child(repair)
		if route=="sheltered":
			var donate_ready=has_seal and int(pawn.inventory.get("march_wall",0))>=1 and int(pawn.inventory.get("timber",0))>=1 and int(pawn.inventory.get("scrap",0))>=1
			var donate=button("Donate folded wall · 1 timber + 1 scrap",func():close_popup();world.data.paused=false;execute(world.order_march_refuge(selected,"donate",queue_mode));_refresh(),60,true)
			donate.disabled=threats>0 or not donate_ready;col.add_child(donate)
			col.add_child(text_label("Donation consumes the mobile wall to create three durable communal shield sections and the strongest refuge shelter.",16,"a8c8b0"))
	else:
		var outcome="The donated folded wall now forms three communal shield sections and strongly shelters the refuge." if state=="walled" else "The guarded brace repair supports strong recovery and resident stores." if state=="guarded" else "The dark brace repair shelters pressure while the folded wall remains expedition-owned." if state=="sheltered" else "The public brace repair restores a flexible defense and mixed resident stores."
		var result=text_label(outcome+" The physical crossing seal remains in its carrier's pack, and the deep resident road is open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use deep refuge road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_wallward():
	var post=world.wallward_landmark()
	if post.is_empty():feedback("Wallward Descent has not been reached.");return
	world.data.paused=true
	var col=make_popup("WALLWARD DESCENT · CONVOY WINDOW",980)
	popup_kind="wallward"
	var pawn=world.data.pawns[selected];var state=str(world.data.wallward_state);var route=str(post.get("route","public"))
	var has_seal=int(pawn.inventory.get("crossing_seal",0))>0
	if state=="":
		var approach="A guarded lantern descent carries three surface husks." if route=="guarded" else "The refuge wall-keepers reduce the approach to two surface husks." if route=="walled" else "A dark convoy cut is watched by two Gloam stalkers." if route=="sheltered" else "A broken public descent carries three surface husks."
		var intro=text_label(approach+"\n\nPresent Marchhold's physical crossing seal to begin a pauseable 30-second rendezvous. Recover the 3 kg convoy beacon, then escort with three colonists after clearing the road—or screen the convoy with two colonists, 2 timber and 2 scrap.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var start=button("Present crossing seal · signal convoy",func():close_popup();world.data.paused=false;execute(world.order_wallward(selected,"start",queue_mode));_refresh(),58,true)
		start.disabled=not has_seal;col.add_child(start)
		if start.disabled:col.add_child(text_label("The selected colonist does not carry Marchhold's physical crossing seal.",16,"e2a178"))
	elif state=="warning":
		var threats=world.floor_at(51).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("wallward_guard")).size()
		var has_beacon=int(pawn.inventory.get("wallward_beacon",0))>0
		var escort_ready=has_seal and has_beacon and threats==0 and world.wallward_gathered()>=3
		var screen_ready=has_seal and has_beacon and int(pawn.inventory.get("timber",0))>=2 and int(pawn.inventory.get("scrap",0))>=2 and world.wallward_gathered(true)>=2
		var status=text_label("%d sec · %d threats · seal %s · beacon %s · %d timber · %d scrap\nCrews: %d at rally · %d at bypass. Pause freezes time; timeout spares marked alcoves."%[int(ceil(float(world.data.wallward_timer))),threats,"carried" if has_seal else "missing","carried" if has_beacon else "missing",int(pawn.inventory.get("timber",0)),int(pawn.inventory.get("scrap",0)),world.wallward_gathered(),world.wallward_gathered(true)],16)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var escort=button("Escort convoy · clear + beacon + 3 crew",func():close_popup();world.data.paused=false;execute(world.order_wallward(selected,"escort",queue_mode));_refresh(),50,true)
		escort.disabled=not escort_ready;col.add_child(escort)
		var screen=button("Screen convoy · beacon + materials + 2 crew",func():close_popup();world.data.paused=false;execute(world.order_wallward(selected,"screen",queue_mode));_refresh(),50,true)
		screen.disabled=not screen_ready;col.add_child(screen)
	else:
		var outcome="Three colonists escorted the convoy and opened its recovery issue." if state=="escorted" else "Two colonists screened the convoy with exact materials, bypassing threats and sheltering pressure." if state=="screened" else "The convoy window closed, but refuge alcoves protected occupants and a missed-convoy cache keeps the road open."
		var result=text_label(outcome+" The crossing seal remains physical, and a convoy tally records the route below.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use Wayfarer road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_wayfarer():
	var keeper=world.wayfarer_landmark()
	if keeper.is_empty():feedback("Wayfarer Commons has not been reached.");return
	world.data.paused=true
	var col=make_popup("WAYFARER COMMONS · SHARED ROADSTEAD",980)
	popup_kind="wayfarer"
	var pawn=world.data.pawns[selected];var state=str(world.data.wayfarer_state);var route=str(keeper.get("route","public"))
	var has_tally=int(pawn.inventory.get("convoy_tally",0))>0;var cost=world.wayfarer_cost(route)
	if state=="":
		var approach="An escorted convoy earns a lit welcome arcade, watched by a burrower." if route=="resident" else "The screened convoy keeps a dark wagon lane, watched by a Gloam stalker." if route=="hidden" else "The missed convoy leaves a damaged public court with two surface husks."
		var intro=text_label(approach+"\n\nPresent the physical convoy tally to Senn. Recover a 6 kg roadstead jack and bring %d timber + %d scrap in separate packs. Two fit colonists must gather at the repair court; the tally stays carried."%[int(cost.timber),int(cost.scrap)],18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var start=button("Present convoy tally · enter commons",func():close_popup();world.data.paused=false;execute(world.order_wayfarer(selected,"start",queue_mode));_refresh(),58,true)
		start.disabled=not has_tally;col.add_child(start)
		if start.disabled:col.add_child(text_label("The selected colonist must carry Wallward's physical convoy tally.",16,"e2a178"))
	elif state=="assigned":
		var threats=world.floor_at(52).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("wayfarer_guard")).size()
		var status=text_label("%d reception threats · selected tally %s · %d fit crew at court\nNearby packs: jack %d/1 · timber %d/%d · scrap %d/%d\n\nAt least two packs must contribute. Supplies stay owned until the whole repair finishes; distant or incapacitated carriers cannot donate."%[threats,"carried" if has_tally else "missing",world.wayfarer_crew().size(),world.wayfarer_available("roadstead_jack"),world.wayfarer_available("timber"),int(cost.timber),world.wayfarer_available("scrap"),int(cost.scrap)],17)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		var problem=world.wayfarer_repair_error(selected)
		var repair=button("Repair roadstead · use shared supplies",func():close_popup();world.data.paused=false;execute(world.order_wayfarer(selected,"repair",queue_mode));_refresh(),60,true)
		repair.disabled=problem!="";col.add_child(repair)
		if problem!="":
			var warning=text_label(problem,16,"e2a178");warning.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(warning)
	else:
		var outcome="The resident roadstead supports strong recovery and provisions." if state=="resident" else "The concealed roadstead shelters pressure and opens industrial freight." if state=="hidden" else "The public roadstead supports modest recovery, pressure shelter and mixed supplies."
		var result=text_label(outcome+" The jack is installed, exact materials came from their owners, and the convoy tally stays carried. The Underway road is open.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use Underway road",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_underway():
	var post=world.underway_landmark()
	if post.is_empty():feedback("Underway Fork has not been reached.");return
	world.data.paused=true
	var col=make_popup("UNDERWAY FORK · ROAD SURVEY",980)
	popup_kind="underway"
	var pawn=world.data.pawns[selected];var state=str(world.data.underway_state);var route=str(post.get("route","public"))
	var has_tally=int(pawn.inventory.get("convoy_tally",0))>0
	if state=="":
		var approach="Wayfarer's resident road reaches a lamp-marked bridge with one burrower." if route=="resident" else "Wayfarer's concealed road reaches a dark cartway watched by one Gloam stalker." if route=="hidden" else "Wayfarer's public road reaches a rubble fork held by two surface husks."
		var intro=text_label(approach+"

Present the carried convoy tally to open the survey. Clear the approach and recover a physical 2 kg survey kit before committing exact supplies.",18)
		intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(intro)
		var start=button("Present convoy tally · open survey",func():close_popup();world.data.paused=false;execute(world.order_underway(selected,"start",queue_mode));_refresh(),58,true)
		start.disabled=not has_tally;col.add_child(start)
		if start.disabled:col.add_child(text_label("The selected colonist must carry Wayfarer's physical convoy tally.",16,"e2a178"))
	elif state=="assigned":
		var threats=world.floor_at(53).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("underway_guard")).size()
		var status=text_label("%d approach threats · selected tally %s · survey kit %d/1
Selected pack: scrap %d · glowstone %d · timber %d · rations %d

LIT BRIDGE · kit + 3 scrap + 2 glowstone. Strong recovery and useful stores; two surface husks are visibly drawn into the lower gallery.

SHROUDED BYPASS · kit + 2 timber + 3 rations. Strong pressure shelter and no new incursion."%[threats,"carried" if has_tally else "missing",int(pawn.inventory.get("survey_kit",0)),int(pawn.inventory.get("scrap",0)),int(pawn.inventory.get("crystal",0)),int(pawn.inventory.get("timber",0)),int(pawn.inventory.get("rations",0))],17)
		status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(status)
		for choice in ["lit","hidden"]:
			var problem=world.underway_error(selected,choice)
			var label="Install waylights · spend kit + 3 scrap + 2 glowstone" if choice=="lit" else "Conceal bypass · spend kit + 2 timber + 3 rations"
			var route_button=button(label,func(c=choice):close_popup();world.data.paused=false;execute(world.order_underway(selected,c,queue_mode));_refresh(),60,true)
			route_button.disabled=problem!="";col.add_child(route_button)
		var lit_error=world.underway_error(selected,"lit");var hidden_error=world.underway_error(selected,"hidden")
		if lit_error!="" and lit_error==hidden_error:
			var warning=text_label(lit_error,16,"e2a178");warning.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(warning)
	else:
		var outcome="Waylights mark a recoverable road, and the warned husks are now visible in the lower gallery." if state=="lit" else "The bypass stays dark, avoids a new incursion and shelters this floor from pressure."
		var result=text_label(outcome+" Exact supplies were consumed only on completion. The installed kit became one physical route token in its surveyor's pack, and the deeper Underway is connected.",20)
		result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(result)
		col.add_child(button("Use deeper Underway",func():close_popup();world.data.paused=false;_refresh(),52,true))

func show_blueprint():
	var p=world.data.pawns[selected]
	var plan=world.container_by_id(int(p.z),int(selection.get("id",-1)))
	if plan.is_empty() or plan.get("kind","")!="blueprint":return
	var col=make_popup(plan.name.to_upper(),720)
	popup_kind="blueprint"
	var parts:Array=[]
	for item in World.RECIPES[plan.recipe].cost:
		parts.append("%s: %d / %d"%[World.ITEMS[item].name,int(plan.items.get(item,0)),int(World.RECIPES[plan.recipe].cost[item])])
	col.add_child(text_label("Delivered supplies\n"+"\n".join(parts)+"\n\nIdle colonists supply and build this plan when the level is safe.",19))
	var build=button("Construct with delivered supplies",func():close_popup();execute(world.issue(selected,"construct",world.point(plan),{"blueprint":int(plan.id),"recipe":str(plan.recipe)})),50,true)
	build.disabled=not world.blueprint_ready(plan)
	col.add_child(build)
	col.add_child(button("Cancel blueprint · leave supplies",func():close_popup();context_action(),48))

func show_structure():
	var pawn=world.data.pawns[selected]
	var structure=world.structure_by_id(int(pawn.z),int(selection.get("id",-1)))
	if structure.is_empty():selection.clear();feedback("That camp structure is gone.");_refresh();return
	var recipe=str(structure.kind);var recovered=World.DISMANTLE_RETURNS[recipe];var parts:Array=[]
	for item in recovered:parts.append(str(recovered[item])+" "+World.ITEMS[item].name.to_lower())
	world.data.paused=true
	var col=make_popup("PACK UP "+str(World.RECIPES[recipe].name).to_upper(),720)
	popup_kind="structure"
	var alarm_state=str(structure.get("state","armed"))
	var alarm_copy=""
	if recipe=="tripwire":
		if alarm_state=="ringing":alarm_copy="\n\nRINGING · "+str(structure.get("triggered_by","Threat"))+" crossed here. Nearby husks hear it; burrowers feel its vibration. %.1f seconds remain."%float(structure.get("ring",0))
		elif alarm_state=="spent":alarm_copy="\n\nSPENT · the line must be reset by a colonist before it can warn you again."
		else:alarm_copy="\n\nARMED · the first creature crossing this tile identifies itself and pauses the expedition."
	var story=text_label("A colonist must reach the structure and dismantle it. Cancellation leaves it intact.\n\nRecovered: "+", ".join(parts)+". Materials remain on the floor until someone hauls them."+alarm_copy,19)
	story.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;col.add_child(story)
	if recipe=="bed":col.add_child(button("Rest at bedroll",func():close_popup();world.data.paused=false;execute(world.order_rest(selected,world.point(structure),queue_mode));_refresh(),50))
	if recipe=="tripwire" and alarm_state=="spent":col.add_child(button("Reset alarm · physical work",func():close_popup();world.data.paused=false;execute(world.order_reset_alarm(selected,int(structure.id),queue_mode));_refresh(),52,true))
	col.add_child(button("Dismantle · recover materials",func():close_popup();world.data.paused=false;execute(world.order_dismantle(selected,int(structure.id),queue_mode));_refresh(),52,true))
	col.add_child(button("Leave it standing",func():close_popup();world.data.paused=false;_refresh(),48))

func show_build():
	if building != "": building=""; map.building=""; _refresh(); return
	var col = make_popup("MAKE A FOOTHOLD",860)
	popup_kind="build"
	col.add_child(button("COLONY BLUEPRINT" if building_colony else "SELECTED COLONIST",func():building_colony=not building_colony;show_build(),44,true))
	col.add_child(text_label("Place a ghost plan. Safe idle colonists fetch exact materials and construct it." if building_colony else "Materials come from the selected colonist's pack. Choose, then tap a floor tile.",17,"a6c0b3"))
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation",8)
	grid.add_theme_constant_override("v_separation",8)
	var recipes_scroll=scroll_list()
	recipes_scroll.custom_minimum_size.y=min(352.0,max(140.0,size.y-280.0))
	col.add_child(recipes_scroll)
	grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	recipes_scroll.add_child(grid)
	for key in World.RECIPES:
		if not world.recipe_available(key):continue
		var r = World.RECIPES[key]
		var cost: Array = []
		for item in r.cost: cost.append(str(r.cost[item])+" "+item)
		var b = button(r.name+"\n"+", ".join(cost),func(): building=key; map.building=key; close_popup(); _refresh(),82)
		b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size",17)
		b.disabled = not building_colony and not queue_mode and not world.can_build(world.data.pawns[selected],key)
		grid.add_child(b)
	var shieldwall_copy="  ·  Folding shieldwall: durable mobile cover" if world.recipe_available("shieldwall") else ""
	var details=text_label("Lantern: light + heat  ·  Chest: filtered storage + idle hauling  ·  Bedroll: rest or receive rescued colonists\nWorkbench: faster nearby building  ·  Barricade: delay pursuit"+shieldwall_copy+"\nTripwire: crossing warning + temporary noise  ·  Clatter beacon: lures husks  ·  Relay: listens for the city",16,"a5c2b7")
	col.add_child(details)

func open_inventory(container_id: int = -1):
	var col = make_popup(world.data.pawns[selected].name.to_upper()+" / INVENTORY",870)
	popup_kind="inventory"
	inv_id=container_id; inv_direction="take"; inv_item="timber"; inv_quantity=1; inv_error=""; inv_rows.clear()
	var p = world.data.pawns[selected]
	inv_picker = OptionButton.new()
	inv_picker.custom_minimum_size.y = 40
	inv_picker.add_theme_font_size_override("font_size",18)
	inv_picker.add_theme_stylebox_override("normal",box("223a3e","44625d"))
	inv_picker.get_popup().add_theme_font_size_override("font_size",18)
	var chosen = 0
	var distance = INF
	for c in world.floor_at(p.z).containers:
		if c.get("kind","")=="blueprint":continue
		if not world.floor_at(p.z).seen.has(world.cell_key(world.point(c))): continue
		inv_picker.add_item(c.name+(" · unsearched" if not c.searched else ""),c.id)
		var d = world.point(p).distance_squared_to(world.point(c))
		if c.id == container_id: chosen = inv_picker.item_count-1; distance=-1
		elif container_id < 0 and d < distance: chosen=inv_picker.item_count-1; distance=d
	if inv_picker.item_count > 0:
		inv_picker.select(chosen); inv_id=inv_picker.get_item_id(chosen)
	else:
		inv_picker.add_item("No storage discovered here",-1); inv_id=-1
	inv_picker.item_selected.connect(func(index): inv_id=inv_picker.get_item_id(index); inv_quantity=1; inv_error=""; refresh_inventory())
	var storage_bar=HBoxContainer.new()
	storage_bar.add_theme_constant_override("separation",8)
	col.add_child(storage_bar)
	inv_picker.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	storage_bar.add_child(inv_picker)
	inv_auto=button("Haul ON",toggle_auto_haul,40)
	storage_bar.add_child(inv_auto)
	inv_filter=button("Timber ✓",toggle_stockpile_filter,40)
	storage_bar.add_child(inv_filter)
	inv_pack=button("Pack empty",pack_stockpile,40)
	storage_bar.add_child(inv_pack)
	var panes = HBoxContainer.new()
	panes.add_theme_constant_override("separation",14)
	col.add_child(panes)
	for source in ["take","store"]:
		var pane = VBoxContainer.new()
		pane.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		pane.custom_minimum_size.x=330
		panes.add_child(pane)
		var title=text_label("FROM STORAGE → "+p.name.to_upper()+" PACK" if source=="take" else "FROM "+p.name.to_upper()+" PACK → STORAGE",17,"d1bc91")
		pane.add_child(title)
		var scroll=scroll_list()
		scroll.custom_minimum_size.y=154
		scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
		pane.add_child(scroll)
		var list=VBoxContainer.new()
		list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		scroll.add_child(list)
		for item in World.ITEMS:
			var b=button(item,func(): inv_direction=source; inv_item=item; inv_quantity=1; inv_error=""; refresh_inventory(),44)
			b.alignment=HORIZONTAL_ALIGNMENT_LEFT
			list.add_child(b)
			inv_rows[source+":"+item]=b
	inv_count=text_label("",15,"a2beb2")
	col.add_child(inv_count)
	var quantity=HBoxContainer.new()
	quantity.add_theme_constant_override("separation",10)
	col.add_child(quantity)
	var label=text_label("Quantity",18)
	label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	quantity.add_child(label)
	inv_minus=button("−",func(): inv_quantity=max(1,inv_quantity-1); refresh_inventory(),44)
	quantity.add_child(inv_minus)
	inv_amount=text_label("1",22,"e4c697")
	inv_amount.custom_minimum_size.x=35
	inv_amount.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	quantity.add_child(inv_amount)
	inv_plus=button("+",func(): inv_quantity+=1; refresh_inventory(),44)
	quantity.add_child(inv_plus)
	inv_max=button("Max",func(): inv_quantity=999; refresh_inventory(),44)
	quantity.add_child(inv_max)
	var actions=HBoxContainer.new()
	col.add_child(actions)
	inv_action=button("Take",inventory_action,48,true)
	inv_action.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	actions.add_child(inv_action)
	inv_drop=button("Drop",func(): execute(world.drop(selected,inv_item,inv_quantity)); refresh_inventory(),48)
	actions.add_child(inv_drop)
	inv_use=button("Use",func(): execute(world.use_item(selected,inv_item)); refresh_inventory(),48)
	actions.add_child(inv_use)
	inv_equip=button("Equip coat",func(): execute(world.toggle_armor(selected)); refresh_inventory(),48)
	actions.add_child(inv_equip)
	actions.add_child(button("Pause / Play",toggle_pause,48))
	inv_status=text_label("",15,"a8c5b9")
	inv_status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	col.add_child(inv_status)
	refresh_inventory()

func refresh_inventory():
	if popup_kind != "inventory": return
	var p=world.data.pawns[selected]
	var c=world.container_by_id(p.z,inv_id)
	var searched=not c.is_empty() and c.searched
	var stockpile=not c.is_empty() and c.get("kind","")=="stockpile"
	inv_auto.visible=stockpile
	inv_filter.visible=stockpile
	inv_pack.visible=stockpile
	if stockpile:
		inv_auto.text="Haul ON" if c.get("auto_haul",true) else "Haul OFF"
		inv_filter.text=World.ITEMS[inv_item].name+(" ✓" if c.get("filters",{}).get(inv_item,true) else " ×")
		inv_pack.disabled=world.container_has_items(c) or (not p.job.is_empty() and not queue_mode)
		inv_pack.text="Empty chest first" if world.container_has_items(c) else "Pack empty"
	for item in World.ITEMS:
		for direction in ["take","store"]:
			var b=inv_rows[direction+":"+item]
			var amount = int(p.inventory.get(item,0)) if direction=="store" else int(c.get("items",{}).get(item,0)) if searched else 0
			b.text=("● " if inv_direction==direction and inv_item==item else "")+World.ITEMS[item].name+" · owned "+(str(amount) if direction=="store" or searched else "?")+" · %.1f kg each" % World.ITEMS[item].weight
			b.disabled=amount==0
	var amount=int(p.inventory.get(inv_item,0)) if inv_direction=="store" else int(c.get("items",{}).get(inv_item,0)) if searched else 0
	var limit=amount if inv_direction=="store" else min(amount,world.free_units(p,inv_item))
	inv_quantity=clampi(inv_quantity,1,max(1,limit))
	inv_amount.text=str(inv_quantity)
	inv_minus.disabled=inv_quantity<=1
	inv_plus.disabled=inv_quantity>=limit
	inv_max.disabled=limit<=0
	inv_count.text="Pack: %.1f / 12 kg · Body: %s · %s\nFatigue %d%% %s · Morale %d%% %s\n%s\nLast: %s\nSkills: search %d · build %d · combat %d" % [world.weight(p.inventory),"reinforced coat" if p.equipment.body=="armor" else "unprotected",World.INJURY_LEVELS[int(p.injury)].capitalize(),int(p.fatigue),world.fatigue_state(p).capitalize(),int(p.morale),world.morale_state(p).capitalize(),world.social_summary(selected),world.latest_memory(p),p.skills.scavenge,p.skills.build,p.skills.combat]
	inv_drop.visible=inv_direction=="store"
	inv_drop.disabled=amount<inv_quantity or not p.job.is_empty()
	inv_use.visible=inv_direction=="store" and inv_item in ["rations","medkit"]
	inv_use.disabled=amount<1 or not p.job.is_empty()
	inv_equip.text="Remove coat" if p.equipment.body=="armor" else "Equip coat"
	inv_equip.visible=p.equipment.body=="armor" or int(p.inventory.get("armor",0))>0
	inv_equip.disabled=not p.job.is_empty() or (p.equipment.body=="armor" and world.free_units(p,"armor")<1)
	if not p.job.is_empty() and not queue_mode: inv_action.text="Busy · turn Queue on"; inv_action.disabled=true
	elif not c.is_empty() and not c.searched: inv_action.text=("Queue search" if queue_mode else "Search this container"); inv_action.disabled=false
	else:
		inv_action.text=("Queue " if queue_mode else "")+("Move " if inv_direction=="take" else "Return ")+str(inv_quantity)+" "+World.ITEMS[inv_item].name.to_lower()+(" → "+p.name+" pack" if inv_direction=="take" else " → "+str(c.get("name","storage")))
		inv_action.disabled=limit<1 or c.is_empty()
	if not p.job.is_empty(): inv_status.text=("Queue mode is on; add this after current work." if queue_mode else p.name+" is working. Turn Queue on to add another order.")
	elif not searched: inv_status.text="Contents stay hidden until this container is searched."
	elif stockpile and limit<1: inv_status.text="Idle colonists haul accepted items here. Toggle the selected item above."
	elif limit<1: inv_status.text="Select an item on either side. Put something away if the pack is full."
	else:
		var pack_before=world.weight(p.inventory)
		var move_weight=float(World.ITEMS[inv_item].weight)*inv_quantity
		var pack_after=pack_before+(move_weight if inv_direction=="take" else -move_weight)
		var destination_before=int(p.inventory.get(inv_item,0)) if inv_direction=="take" else int(c.get("items",{}).get(inv_item,0))
		var source_name=str(c.get("name","Storage")) if inv_direction=="take" else p.name+" pack"
		var destination_name=p.name+" pack" if inv_direction=="take" else str(c.get("name","Storage"))
		inv_status.text="MOVE %d %s · %.1f kg total\n%s %d → %d   ⟶   %s %d → %d · pack %.1f → %.1f / 12 kg\nItems stay owned until %s reaches the container." % [inv_quantity,World.ITEMS[inv_item].name.to_lower(),move_weight,source_name,amount,amount-inv_quantity,destination_name,destination_before,destination_before+inv_quantity,pack_before,pack_after,p.name]
	if inv_error!="": inv_status.text=inv_error

func toggle_auto_haul():
	var p=world.data.pawns[selected]
	var c=world.container_by_id(p.z,inv_id)
	if c.is_empty() or c.get("kind","")!="stockpile":return
	c.auto_haul=not bool(c.get("auto_haul",true))
	inv_error="Idle hauling enabled for this chest." if c.auto_haul else "This chest is manual storage only."
	refresh_inventory();save_game()

func toggle_stockpile_filter():
	var p=world.data.pawns[selected]
	var c=world.container_by_id(p.z,inv_id)
	if c.is_empty() or c.get("kind","")!="stockpile":return
	if not c.has("filters"):c.filters={}
	c.filters[inv_item]=not bool(c.filters.get(inv_item,true))
	inv_error=c.name+(" accepts " if c.filters[inv_item] else " ignores ")+World.ITEMS[inv_item].name.to_lower()+"."
	refresh_inventory();save_game()

func pack_stockpile():
	var p=world.data.pawns[selected];var c=world.container_by_id(int(p.z),inv_id)
	if c.is_empty() or c.get("kind","")!="stockpile":return
	if world.container_has_items(c):inv_error="Empty the supply chest before packing it up.";refresh_inventory();return
	var structure_id=int(c.id);close_popup();execute(world.order_dismantle(selected,structure_id,queue_mode));_refresh()

func inventory_action():
	var p=world.data.pawns[selected]
	var c=world.container_by_id(p.z,inv_id)
	if not c.is_empty() and not c.searched: execute(world.order_search(selected,inv_id,queue_mode))
	else: execute(world.order_transfer(selected,inv_id,inv_direction,inv_item,inv_quantity,queue_mode))
	refresh_inventory()

func expedition_text(parent:Control,text:String,font_size:int=16,color:String="aec0b4"):
	var label=text_label(text,font_size,color)
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label

func show_expedition(tab:String="crew"):
	var col=make_popup("CREW & CARGO",820)
	popup_kind="expedition"
	world.data.paused=true
	var anchor=world.data.pawns[selected]
	expedition_text(col,"Paused to plan · Rally toward %s on depth %d. Press Play after closing."%[anchor.name,int(anchor.z)+1])
	var tabs=HBoxContainer.new();col.add_child(tabs)
	for section in ["crew","cargo"]:
		var tab_button=button(section.capitalize(),func():show_expedition(section),44,tab==section)
		tab_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL;tabs.add_child(tab_button)
	if tab=="cargo":
		var filter_row=HBoxContainer.new();col.add_child(filter_row)
		filter_row.add_child(button("Essential cargo" if expedition_essentials else "All cargo",func():expedition_essentials=not expedition_essentials;show_expedition("cargo"),44))
		var search=LineEdit.new();search.name="CargoSearch";search.placeholder_text="Find item or owner";search.text=expedition_query
		search.size_flags_horizontal=Control.SIZE_EXPAND_FILL;search.custom_minimum_size.y=44;search.add_theme_font_size_override("font_size",18)
		filter_row.add_child(search)
		search.text_changed.connect(func(value):expedition_query=value;refresh_expedition_cargo())
	var scroll=scroll_list();scroll.name="ExpeditionScroll"
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size.y=clampf(size.y-(244 if tab=="cargo" else 196),120,390)
	col.add_child(scroll)
	expedition_list=VBoxContainer.new();expedition_list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	expedition_list.add_theme_constant_override("separation",12);scroll.add_child(expedition_list)
	if tab=="cargo":refresh_expedition_cargo()
	else:
		for index in world.data.pawns.size():
			var pawn=world.data.pawns[index]
			var card=VBoxContainer.new();expedition_list.add_child(card)
			expedition_text(card,"%s · D%d · %s"%[pawn.name,int(pawn.z)+1,world.floor_at(int(pawn.z)).name],19,"ecd4a4")
			var condition="Lost" if pawn.hp<=0 else "Needs rescue" if world.incapacitated(pawn) else "Drafted" if pawn.drafted else "Ready"
			var task="Idle" if pawn.job.is_empty() else describe_order(pawn.job)
			expedition_text(card,"%s · HP %d · Fatigue %d%% · Pack %.1f / 12 kg\n%s · %d queued"%[condition,int(pawn.hp),int(pawn.fatigue),world.weight(pawn.inventory),task,pawn.orders.size()])
			var important:Array=[]
			for cargo in world.expedition_cargo():
				if int(cargo.pawn)==index:important.append("%s ×%d"%[World.ITEMS[cargo.item].name,cargo.quantity])
			if not important.is_empty():expedition_text(card," · ".join(important),15,"c9b987")
			var actions=HBoxContainer.new();card.add_child(actions)
			actions.add_child(button("Find "+str(pawn.name),func():close_popup();select_pawn(index),44))
			var pack_button=button("Pack",func():close_popup();select_pawn(index);open_inventory(),44)
			pack_button.disabled=pawn.hp<=0;actions.add_child(pack_button)
			var error=world.regroup_error(index,selected)
			var rally=button("Join depth %d"%(int(anchor.z)+1) if int(pawn.z)!=int(anchor.z) else "Rally by "+str(anchor.name),func():
				var result=world.order_regroup(index,selected)
				feedback(result if result!="" else str(world.data.pawns[index].name)+" has a physical rally order. Press Play to move.")
				save_game();show_expedition(),44)
			rally.size_flags_horizontal=Control.SIZE_EXPAND_FILL;rally.disabled=error!="";actions.add_child(rally)
			if error!="":expedition_text(card,error,14)
			elif int(pawn.z)!=int(anchor.z):expedition_text(card,"Uses connected stairs; stops at blocked routes or gates. Rally again after arrival to walk to the group.",14)
	_refresh()

func refresh_expedition_cargo():
	if not is_instance_valid(expedition_list) or popup_kind!="expedition":return
	for child in expedition_list.get_children():expedition_list.remove_child(child);child.queue_free()
	var cargo=world.expedition_cargo(expedition_essentials,expedition_query)
	if cargo.is_empty():expedition_text(expedition_list,"No matching known cargo. Search containers to learn what they hold.")
	for entry in cargo:
		var card=VBoxContainer.new();expedition_list.add_child(card)
		expedition_text(card,"%s ×%d · %.1f kg"%[World.ITEMS[entry.item].name,entry.quantity,float(World.ITEMS[entry.item].weight)*int(entry.quantity)],18,"ecd4a4")
		expedition_text(card,"%s · D%d · %s"%[entry.owner,int(entry.z)+1,world.floor_at(int(entry.z)).name])
		card.add_child(button("Find owner" if int(entry.pawn)>=0 else "Locate storage",func():locate_cargo(entry),44))

func locate_cargo(entry:Dictionary):
	if int(entry.pawn)>=0:
		close_popup();select_pawn(int(entry.pawn));return
	var z=int(entry.z)
	var container=world.container_by_id(z,int(entry.container))
	if container.is_empty() or not container.searched or not world.floor_at(z).seen.has(world.cell_key(world.point(container))):return
	close_popup();selection.clear();building="";map.building=""
	map.depth=z;map.follow=false;map.focus=Vector2(container.x+.5,container.y+.5)
	feedback("%s · depth %d. Cargo stays here until a colonist carries it."%[container.name,z+1])
	_refresh()

func show_journal():
	var col=make_popup("FIELD JOURNAL",820)
	popup_kind="journal"
	col.add_child(text_label("Seed %d · Deepest level %d · Structures %d · Threats stopped %d" % [world.data.seed,world.data.deepest+1,world.data.built_total,world.data.kills],16,"a8c4b8"))
	var scroll=scroll_list()
	scroll.custom_minimum_size.y=280
	col.add_child(scroll)
	var log_text=text_label("\n\n".join(world.data.log),18)
	log_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	log_text.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	scroll.add_child(log_text)
	col.add_child(button("Back to the colony",close_popup,48,true))

func show_menu():
	var col=make_popup("EXPEDITION",760)
	popup_kind="menu"
	col.add_child(text_label("Hollow · native prototype "+str(ProjectSettings.get_setting("application/config/version"))+"\nAn underground colony, original art and sound.\n\nSelect: click / tap a colonist, or number keys\nInteract: tap an object to walk over and use it; choices open on arrival\nLists: press and drag up or down; a short tap selects a row\nCamera: drag · wheel or + / − to zoom · F to follow\nSpace pauses · Q queues orders · I inventory · B build · D draft · Esc clears\nTap a downed colonist while another is selected to rescue or tend them.",18))
	var row=HBoxContainer.new(); col.add_child(row)
	row.add_child(button("Save expedition",func(): save_game(); feedback("Expedition saved." if save_problem=="" else save_problem); close_popup(),48,true))
	row.add_child(button("Sound: "+("off" if muted else "on"),func(): muted=not muted; AudioServer.set_bus_mute(0,muted); show_menu(),48))
	row.add_child(button("New expedition",confirm_restart,48))
	col.add_child(text_label("Built with Godot Engine (MIT). Engine notices are included with the download.\nEarly build: more colony life, places and story are in development.",14,"9cb2a7"))

func confirm_restart():
	var col=make_popup("START A NEW EXPEDITION?",680)
	popup_kind="restart"
	col.add_child(text_label("This replaces the current expedition on this device.\nThe world will generate from a new seed.",19))
	col.add_child(button("Keep this colony",close_popup,48,true))
	col.add_child(button("Start new world",func():
		world=World.new(randi_range(10000,99999999)); selected=0; current_depth=0; map.world=world; map.selected=0; map.depth=0; map.follow=true; selection.clear(); building=""; map.building=""; started=false; show_intro(); _refresh()
	,48))

func sound(kind: String):
	if muted or sound_players.is_empty() or DisplayServer.get_name() == "headless": return
	var file={"search":"find","transfer":"pick","build":"build","hit":"hit","stairs":"step","alarm":"alarm"}.get(kind,"pick")
	var player=sound_players[sound_cursor%sound_players.size()]
	sound_cursor+=1
	player.stream=load("res://assets/"+file+".wav")
	player.play()

func save_game():
	if not started: return
	var file=FileAccess.open("user://hollow-save.tmp",FileAccess.WRITE)
	if not file: save_problem="Saving failed: storage is unavailable."; return
	file.store_string(world.serialize()); file.flush(); file.close()
	var path=ProjectSettings.globalize_path(SAVE_PATH)
	if FileAccess.file_exists(SAVE_PATH): DirAccess.copy_absolute(path,path+".bak")
	var error=DirAccess.rename_absolute(ProjectSettings.globalize_path("user://hollow-save.tmp"),path)
	save_problem="" if error==OK else "Saving failed. Keep the game open."

func load_game() -> bool:
	for path in [SAVE_PATH,SAVE_PATH+".bak"]:
		if not FileAccess.file_exists(path): continue
		var text=FileAccess.get_file_as_string(path)
		if world.restore(text): return true
	return false

func _notification(what):
	if what==NOTIFICATION_WM_CLOSE_REQUEST:
		save_game(); get_tree().quit()
	if what==NOTIFICATION_APPLICATION_PAUSED or what==NOTIFICATION_APPLICATION_FOCUS_OUT:
		if world: save_game(); world.data.paused=true

func _exit_tree():
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null

func _unhandled_key_input(event):
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.keycode:
		KEY_ESCAPE:
			if popup: close_popup()
			elif building!="": building=""; map.building=""
			else: world.cancel(selected)
		KEY_SPACE: toggle_pause()
		KEY_Q: if not popup: toggle_queue()
		KEY_1: if not popup: select_pawn(0)
		KEY_2: if not popup: select_pawn(1)
		KEY_3: if not popup and world.data.pawns.size()>2: select_pawn(2)
		KEY_I: if not popup: open_inventory()
		KEY_B: if not popup: show_build()
		KEY_D: if not popup: toggle_draft()
		KEY_F: map.follow=true
