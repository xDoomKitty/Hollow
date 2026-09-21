class_name HollowWorld
extends RefCounted

const W = 56
const H = 38
const SAVE_VERSION = 1
const ITEMS = {"armor": {"name": "Reinforced coat", "weight": 2.5}, "timber": {"name": "Timber", "weight": 1.5}, "scrap": {"name": "Scrap", "weight": 1.0}, "rations": {"name": "Rations", "weight": 0.5}, "medkit": {"name": "Medkit", "weight": 0.5}, "crystal": {"name": "Glowstone", "weight": 0.7}, "filter": {"name": "Purifier cartridge", "weight": 1.5}, "coil": {"name": "Foundry regulator", "weight": 1.5}, "dossier": {"name": "Traveler dossier", "weight": 0.3}, "compass": {"name": "Survey compass", "weight": 0.8}, "tape": {"name": "Traveler signal tape", "weight": 0.2}, "seal": {"name": "Cistern gate seal", "weight": 1.2}, "docket": {"name": "Tidecourt water docket", "weight": 0.4}, "impeller": {"name": "Sump pump impeller", "weight": 1.4}, "drive": {"name": "Clockline traction drive", "weight": 6.5}, "brake": {"name": "Clockline brake drum", "weight": 6.5}, "warrant": {"name": "Railcourt switch warrant", "weight": 0.4}, "plate": {"name": "Cinder registry plate", "weight": 0.7}, "waybill": {"name": "Morrow freight waybill", "weight": 0.3}, "ledger": {"name": "Cairn witness ledger", "weight": 0.6}, "braid": {"name": "Farline route braid", "weight": 0.5}, "roster": {"name": "Thimble resident cord", "weight": 0.4}, "exchanger": {"name": "Latchwater heat exchanger", "weight": 2.0}, "prism": {"name": "Driftglass focusing prism", "weight": 1.6}, "charter": {"name": "Bellhome convoy charter", "weight": 0.5}, "brace": {"name": "Bellhome wall brace", "weight": 4.0}, "hearth_core": {"name": "Hearthline thermal core", "weight": 7.0}, "yard_winch": {"name": "Hearthline lift winch", "weight": 7.0}, "kiln_igniter": {"name": "Kilnreach ignition spindle", "weight": 2.0}, "junction_seal": {"name": "Embervault signal seal", "weight": 1.0}, "signal_breaker": {"name": "Embervault signal breaker", "weight": 3.0}, "relay_crown": {"name": "Deepcoil crown coil", "weight": 6.5}, "relay_root": {"name": "Deepcoil root coil", "weight": 6.5}, "ward_charter": {"name": "Coilward community charter", "weight": 0.8}, "delegate_writ": {"name": "Charterwell delegation writ", "weight": 0.4}, "assembly_mandate": {"name": "Writwell assembly mandate", "weight": 0.5}, "concordance_token": {"name": "Concordance response token", "weight": 0.6}, "quarter_pass": {"name": "Reservefall quarter pass", "weight": 0.5}, "quarter_shield": {"name": "Reservefall communal shield", "weight": 4.0}, "shield_frame": {"name": "Shieldline folding frame", "weight": 6.0}, "shield_axle": {"name": "Shieldline carriage axle", "weight": 6.0}, "march_wall": {"name": "Marchhold folded wall", "weight": 4.0}, "crossing_seal": {"name": "Marchhold crossing seal", "weight": 0.6}, "refuge_brace": {"name": "Marchhold refuge brace", "weight": 4.0}, "wallward_beacon": {"name": "Wallward convoy beacon", "weight": 3.0}, "convoy_tally": {"name": "Wallward convoy tally", "weight": 0.5}, "roadstead_jack": {"name": "Wayfarer roadstead jack", "weight": 6.0}, "survey_kit": {"name": "Underway survey kit", "weight": 2.0}, "route_token": {"name": "Underway route token", "weight": 0.4}}
const RECIPES = {"lamp": {"name": "Camp lantern", "cost": {"timber": 2, "scrap": 1}, "time": 3.0}, "stockpile": {"name": "Supply chest", "cost": {"timber": 2}, "time": 3.0}, "bench": {"name": "Workbench", "cost": {"timber": 4, "scrap": 2}, "time": 5.0}, "bed": {"name": "Bedroll", "cost": {"timber": 2, "rations": 1}, "time": 3.0}, "barricade": {"name": "Barricade", "cost": {"timber": 2, "scrap": 1}, "time": 3.0}, "shieldwall": {"name": "Folding shieldwall", "cost": {"timber": 1, "scrap": 2}, "time": 3.5}, "tripwire": {"name": "Tripwire alarm", "cost": {"timber": 1, "scrap": 2}, "time": 3.0}, "decoy": {"name": "Clatter beacon", "cost": {"timber": 1, "scrap": 3}, "time": 4.0}, "relay": {"name": "Signal relay", "cost": {"scrap": 4, "crystal": 2}, "time": 6.0}}
const DISMANTLE_RETURNS = {"lamp":{"timber":1,"scrap":1},"stockpile":{"timber":1},"bench":{"timber":2,"scrap":1},"bed":{"timber":1},"barricade":{"timber":1,"scrap":1},"shieldwall":{"timber":1,"scrap":1},"tripwire":{"timber":1,"scrap":1},"decoy":{"timber":1,"scrap":1},"relay":{"scrap":2,"crystal":1}}
const WORK_LEVELS = ["OFF","NORMAL","HIGH"]
const INJURY_LEVELS = ["FIT","BRUISED","WOUNDED","CRITICAL"]
const FATIGUE_LEVELS = ["FRESH","TIRED","EXHAUSTED","SPENT"]
const MORALE_LEVELS = ["SHAKEN","STEADY","HOPEFUL"]
const MEMORY_KINDS = ["scavenge","build","retreat","discovery","survival","recruit","rescue","loss"]
const CAPACITY = 12.0
const DECOY_RADIUS = 10.0
const TRIPWIRE_RADIUS = 9.0
const TRIPWIRE_RING_TIME = 8.0
const HUSK_SIGHT_RADIUS = 10.0
const HUSK_HEARING_RADIUS = 6.0
const BURROWER_VIBRATION_RADIUS = 12.0
const DIRS = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
var data: Dictionary
var visible_cells: Dictionary = {}
var events: Array = []
var visibility_clock = 0.0
var navigation_cache: Dictionary = {}

func _init(world_seed: int = 704219):
	data = {"version": SAVE_VERSION, "seed": world_seed, "seconds": 0.0, "floors": {}, "pawns": [], "next_id": 1, "traveler": false, "rumor": false, "signal": false, "station_met":false, "recruit_joined":false, "outpost_choice":"", "bellwether_choice":"", "spindle_contact":"", "ashline_state":"", "service_choice":"", "foundry_state":"", "archive_choice":"", "wake_state":"", "quiet_state":"", "stillworks_choice":"", "cistern_state":"", "drowned_state":"", "drowned_timer":0.0, "tidecourt_state":"", "sump_state":"", "market_state":"", "market_recruit_joined":false, "depot_state":"", "refuge_state":"", "ashrail_state":"", "customs_state":"", "railcourt_state":"", "registry_state":"", "morrow_state":"", "morrow_timer":0.0, "terminus_state":"", "farline_state":"", "thimble_state":"", "thimble_timer":0.0, "latchwater_state":"", "driftglass_state":"", "bellhome_state":"", "bellhome_timer":0.0, "commons_state":"", "yard_state":"", "yard_recruit_joined":false, "kiln_state":"", "junction_state":"", "junction_timer":0.0, "ember_commons_state":"", "deepcoil_state":"", "coilward_state":"", "charterwell_state":"", "charterwell_timer":0.0, "writwell_state":"", "concordance_state":"", "reservefall_state":"", "reservefall_timer":0.0, "reserve_commons_state":"", "shieldline_state":"", "shieldline_recruit_joined":false, "marchhold_state":"", "marchhold_timer":0.0, "march_refuge_state":"", "wallward_state":"", "wallward_timer":0.0, "paused": true, "log": [], "deepest": 0, "built_total": 0, "kills": 0}
	ensure_floor(0)
	data.wayfarer_state=""
	data.underway_state=""
	data.pawns = [make_pawn("Ash", 6, 6, "amber"), make_pawn("Iona", 7, 6, "teal")]
	note("The surface drove you below. A stranger is waiting by the old shelter.")
	reveal_all()

func make_pawn(pawn_name: String, x: int, y: int, color: String) -> Dictionary:
	return {"name": pawn_name, "x": x, "y": y, "z": 0, "hp": 100.0, "hunger": 0.0, "fatigue":0.0, "morale":60.0, "bonds":{}, "memories":[], "injury":0, "bed_id":-1, "equipment":{"body":""}, "inventory": {"rations": 2, "medkit": 1}, "skills": {"scavenge": 0, "build": 0, "combat": 0}, "work": {"haul":1,"build":1}, "drafted": false, "job": {}, "orders": [], "move_clock": 0.0, "attack_clock": 0.0, "color": color, "facing": 1}

func next_id() -> int:
	var id = int(data.next_id)
	data.next_id = id + 1
	return id

func floor_at(z: int) -> Dictionary:
	return data.floors[str(z)]

func point(d: Dictionary) -> Vector2i:
	return Vector2i(int(d.x), int(d.y))

func arr(p: Vector2i) -> Array:
	return [p.x, p.y]

func vec(a: Array) -> Vector2i:
	return Vector2i(int(a[0]), int(a[1]))

func cell_key(p: Vector2i) -> String:
	return str(p.x) + ":" + str(p.y)

func theme_for(z: int) -> String:
	if z==5:return "Low Lantern outpost"
	if z==7:return "Bellwether Lift"
	if z==9:return "Spindle Gate"
	if z==11:return "Ashline checkpoint"
	if z==12:return "Meridian service ring"
	if z==13:return "Foundry Ward"
	if z==14:return "Archive Junction"
	if z==15:return "Surveyor's Wake"
	if z==16:return "Quiet Mile"
	if z==17:return "Stillworks"
	if z==18:return "Cistern Spine"
	if z==19:return "Drowned Gallery"
	if z==20:return "Tidecourt"
	if z==21:return "Sump Commons"
	if z==22:return "Mainspring Market"
	if z==23:return "Clockline Depot"
	if z==24:return "Switchyard Refuge"
	if z==25:return "Ashrail Interchange"
	if z==26:return "Emberline Customs"
	if z==27:return "Railcourt Concourse"
	if z==28:return "Cinder Registry"
	if z==29:return "Morrow Exchange"
	if z==30:return "Morrow Terminus"
	if z==31:return "Farline Commons"
	if z==32:return "Thimble Crossing"
	if z==33:return "Latchwater Ward"
	if z==34:return "Driftglass Hall"
	if z==35:return "Bellhome Gate"
	if z==36:return "Bellhome Commons"
	if z==37:return "Hearthline Yard"
	if z==38:return "Kilnreach Works"
	if z==39:return "Embervault Junction"
	if z==40:return "Embervault Commons"
	if z==41:return "Deepcoil Relay"
	if z==42:return "Coilward Commons"
	if z==43:return "Charterwell Station"
	if z==44:return "Writwell Assembly"
	if z==45:return "Concordance Gate"
	if z==46:return "Reservefall Junction"
	if z==47:return "Reservefall Commons"
	if z==48:return "Shieldline Works"
	if z==49:return "Marchhold Crossing"
	if z==50:return "Marchhold Refuge"
	if z==51:return "Wallward Descent"
	if z==52:return "Wayfarer Commons"
	if z==53:return "Underway Fork"
	return ["Buried shelter", "Transit ruins", "Old mines", "Limestone caverns", "Sunken quarter"][z % 5]

func carve(grid: Array, p: Vector2i):
	if p.x > 0 and p.y > 0 and p.x < W - 1 and p.y < H - 1:
		grid[p.y][p.x] = 1

func corridor(grid: Array, a: Vector2i, b: Vector2i, wide: int = 1):
	var p = a
	while p != b:
		for dx in range(-wide, wide + 1):
			for dy in range(-wide, wide + 1):
				carve(grid, p + Vector2i(dx, dy))
		if p.x != b.x: p.x += 1 if b.x > p.x else -1
		else: p.y += 1 if b.y > p.y else -1
	carve(grid, b)

func _transit_rooms() -> Array:
	# A collapsed two-platform station with Cinder Waystation in its concourse.
	return [
		Rect2i(3,3,10,8), Rect2i(10,8,8,5), Rect2i(16,7,34,6),
		Rect2i(44,3,8,5), Rect2i(8,14,12,10), Rect2i(21,13,16,12),
		Rect2i(38,15,14,8), Rect2i(16,25,34,6), Rect2i(4,27,12,7),
		Rect2i(45,29,8,6)
	]

func _connect_transit(grid: Array, rooms: Array):
	var links = [[0,1],[1,2],[2,3],[0,4],[4,5],[5,6],[5,7],[7,8],[7,9]]
	for link in links: corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _mine_rooms() -> Array:
	# Narrow drifts join the old hoist, main haulage level, side workings and
	# the deep blasting store. The macro plan stays legible while loot varies.
	return [
		Rect2i(3,3,10,8), Rect2i(14,3,9,12), Rect2i(24,7,28,5),
		Rect2i(31,3,8,5), Rect2i(24,12,7,17), Rect2i(7,24,18,6),
		Rect2i(31,23,20,7), Rect2i(45,30,8,5), Rect2i(8,31,10,4),
		Rect2i(35,31,8,4)
	]

func _connect_mines(grid: Array, rooms: Array):
	var links = [[0,1],[1,2],[2,3],[1,4],[4,5],[4,6],[6,7],[5,8],[6,9]]
	for link in links: corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),0)

func _cavern_rooms(rng:RandomNumberGenerator)->Array:
	var rooms:Array=[Rect2i(3,3,10,9)]
	var anchors=[Vector2i(15,4),Vector2i(28,3),Vector2i(41,7),Vector2i(36,16),Vector2i(45,26),Vector2i(30,27),Vector2i(17,24),Vector2i(6,16),Vector2i(8,29)]
	for anchor in anchors:
		var position=anchor+Vector2i(rng.randi_range(-1,1),rng.randi_range(-1,1))
		var size=Vector2i(rng.randi_range(7,10),rng.randi_range(6,9))
		position=position.clamp(Vector2i(2,2),Vector2i(W-size.x-2,H-size.y-2))
		rooms.append(Rect2i(position,size))
	return rooms

func _carve_cavern(grid:Array,room:Rect2i):
	var center=Vector2(room.get_center())
	var radii=Vector2(max(2.0,room.size.x/2.0),max(2.0,room.size.y/2.0))
	for y in range(room.position.y,room.end.y):
		for x in range(room.position.x,room.end.x):
			var delta=(Vector2(x+.5,y+.5)-center)/radii
			if delta.length_squared()<=1.0:carve(grid,Vector2i(x,y))
	carve(grid,room.get_center())

func _cave_tunnel(grid:Array,a:Vector2i,b:Vector2i,rng:RandomNumberGenerator):
	var p=a
	for step in 500:
		for dx in range(-1,2):
			for dy in range(-1,2):carve(grid,p+Vector2i(dx,dy))
		if p==b:return
		var delta=b-p
		if rng.randf()<.18:
			p+=Vector2i(0,1 if rng.randf()<.5 else -1) if abs(delta.x)>abs(delta.y) else Vector2i(1 if rng.randf()<.5 else -1,0)
		elif abs(delta.x)>abs(delta.y) or (delta.x!=0 and rng.randf()<.5):p.x+=1 if delta.x>0 else -1
		elif delta.y!=0:p.y+=1 if delta.y>0 else -1
		p=p.clamp(Vector2i(2,2),Vector2i(W-3,H-3))
	corridor(grid,p,b,1)

func _connect_caverns(grid:Array,rooms:Array,rng:RandomNumberGenerator):
	for i in range(1,rooms.size()):_cave_tunnel(grid,rooms[i-1].get_center(),rooms[i].get_center(),rng)

func _sunken_rooms()->Array:
	# A drowned civic quarter. Rooms 7 and 8 begin submerged and one can be
	# recovered by the emergency pump without blocking the main descent.
	return [
		Rect2i(3,3,10,8), Rect2i(14,4,28,7), Rect2i(44,3,9,9),
		Rect2i(21,13,14,8), Rect2i(5,23,46,6), Rect2i(4,13,12,8),
		Rect2i(37,13,15,8), Rect2i(37,30,16,6), Rect2i(4,30,17,5),
		Rect2i(24,30,10,6)
	]

func _connect_sunken(grid:Array,rooms:Array):
	var links=[[0,1],[1,2],[1,3],[3,4],[3,5],[3,6],[4,9]]
	for link in links:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _outpost_rooms()->Array:
	# A fortified settlement grown around an old freight junction. The entry,
	# gatehouse, commons, ward, market and deep lift read as one inhabited place.
	return [
		Rect2i(3,3,10,8),Rect2i(14,5,9,5),Rect2i(25,3,8,10),
		Rect2i(35,3,18,10),Rect2i(34,15,19,8),Rect2i(21,14,10,10),
		Rect2i(5,14,13,8),Rect2i(4,25,14,9),Rect2i(22,27,12,8),
		Rect2i(40,26,13,9)
	]

func _connect_outpost(grid:Array,rooms:Array):
	var links=[[0,1],[1,2],[2,3],[2,5],[3,4],[5,4],[5,6],[6,7],[5,8],[8,9]]
	for link in links:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _bellwether_rooms()->Array:
	# Bellwether is an old vertical interchange. The two lower landings begin
	# sealed; the lift control permanently opens one expedition route.
	return [
		Rect2i(3,3,10,8),Rect2i(15,4,10,8),Rect2i(27,3,11,10),
		Rect2i(41,4,11,9),Rect2i(22,15,14,10),Rect2i(4,16,15,9),
		Rect2i(39,16,14,9),Rect2i(21,27,15,8),Rect2i(40,29,13,7),
		Rect2i(4,29,14,7)
	]

func _connect_bellwether(grid:Array,rooms:Array):
	var links=[[0,1],[1,2],[2,3],[2,4],[4,5],[4,6],[4,7]]
	for link in links:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _spindle_rooms()->Array:
	# Two approaches converge on a sealed perimeter gate. The threshold and
	# route-specific stores are opened only after the Gate Watch answers.
	return [
		Rect2i(3,3,11,9),Rect2i(16,4,10,8),Rect2i(28,3,15,10),
		Rect2i(45,4,8,9),Rect2i(21,15,15,10),Rect2i(3,16,15,9),
		Rect2i(39,16,14,9),Rect2i(22,28,14,7),Rect2i(40,29,13,7),
		Rect2i(4,29,14,7)
	]

func _connect_spindle(grid:Array,rooms:Array):
	# Rooms 7–9 remain sealed until contact. Both Bellwether approaches still
	# meet at the same gatehouse, so the floor cannot strand an expedition.
	var links=[[0,1],[1,2],[2,3],[2,4],[4,5],[4,6]]
	for link in links:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _ashline_rooms()->Array:
	# A staffed screening complex surrounding two sealed areas: the damaged
	# scrubber wing and Meridian's lower service threshold.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,11,10),
		Rect2i(41,3,12,10),Rect2i(22,15,14,10),Rect2i(4,16,15,9),
		Rect2i(4,28,17,7),Rect2i(39,16,14,9),Rect2i(39,28,14,7),
		Rect2i(22,29,14,7)
	]

func _connect_ashline(grid:Array,rooms:Array):
	# The purifier vault (6) and lower threshold (9) open through the request.
	var links=[[0,1],[1,2],[2,3],[2,4],[4,5],[4,7],[7,8]]
	for link in links:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _service_rooms()->Array:
	# An inhabited utility district wrapped around a central registry. The city
	# dormitory, independent field berth and lower service lock begin sealed.
	return [
		Rect2i(3,3,11,9),Rect2i(16,3,10,9),Rect2i(28,3,11,10),
		Rect2i(42,3,11,10),Rect2i(21,15,15,10),Rect2i(4,16,14,9),
		Rect2i(3,29,16,7),Rect2i(39,16,14,9),Rect2i(39,29,14,7),
		Rect2i(22,29,14,7)
	]

func _connect_service(grid:Array,rooms:Array):
	# Rooms 6 and 8 are the mutually exclusive settlement offers. Room 9 is
	# the city-side descent unlocked only after the expedition accepts terms.
	var links=[[0,1],[1,2],[2,3],[2,4],[4,5],[4,7]]
	for link in links:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _foundry_rooms()->Array:
	# Foundry Ward surrounds a live casting hall. The damaged municipal line and
	# lower freight gate remain sealed until the standing-specific contract.
	return [
		Rect2i(3,3,11,9),Rect2i(16,3,10,9),Rect2i(28,3,11,10),
		Rect2i(42,3,11,10),Rect2i(21,15,15,10),Rect2i(4,16,14,9),
		Rect2i(3,29,16,7),Rect2i(39,16,14,9),Rect2i(39,29,14,7),
		Rect2i(22,29,14,7)
	]

func _connect_foundry(grid:Array,rooms:Array):
	# Room 6 is the municipal repair line and room 9 is the lower freight gate.
	var links=[[0,1],[1,2],[2,3],[2,4],[4,5],[4,7],[7,8]]
	for link in links:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _archive_rooms()->Array:
	# Archive Junction wraps a staffed index hall around sealed expedition
	# records. The evidence vault and lower catalog gate open through its choice.
	return [
		Rect2i(3,3,11,9),Rect2i(16,3,10,9),Rect2i(28,3,11,10),
		Rect2i(42,3,11,10),Rect2i(21,15,15,10),Rect2i(4,16,14,9),
		Rect2i(3,29,16,7),Rect2i(39,16,14,9),Rect2i(39,29,14,7),
		Rect2i(22,29,14,7)
	]

func _connect_archive(grid:Array,rooms:Array):
	# Room 6 contains the sealed dossier; room 8 holds the outcome cache and
	# room 9 is the connected descent opened only after the evidence decision.
	var links=[[0,1],[1,2],[2,3],[2,4],[4,5],[4,7]]
	for link in links:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _wake_rooms()->Array:
	# The wake is a failed survey staging post with two sealed approaches. The
	# archive decision determines whether Meridian or the traveler's notes help.
	return [
		Rect2i(3,3,11,9),Rect2i(16,3,10,9),Rect2i(28,3,11,10),
		Rect2i(42,3,11,10),Rect2i(21,15,15,10),Rect2i(4,16,14,9),
		Rect2i(3,29,16,7),Rect2i(39,16,14,9),Rect2i(39,29,14,7),
		Rect2i(22,29,14,7)
	]

func _connect_wake(grid:Array,rooms:Array):
	# Rooms 6 and 8 are archive-shaped alternatives; room 9 is the final route.
	var links=[[0,1],[1,2],[2,3],[2,4],[4,5],[4,7]]
	for link in links:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _quiet_rooms()->Array:
	# An acoustic service conduit. Each tuned listening post opens only the next
	# section, keeping light, noise and stillness legible on the map.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,11,8),
		Rect2i(42,3,11,8),Rect2i(42,15,11,8),Rect2i(26,15,12,8),
		Rect2i(4,15,15,8),Rect2i(4,28,15,7),Rect2i(25,28,13,7),
		Rect2i(42,28,11,7)
	]

func _connect_quiet(grid:Array,rooms:Array):
	# The entry, receiver and first listening bay are open. Later links are
	# carved by successful calibrations so the route itself records progress.
	for link in [[0,1],[1,2],[2,3]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _stillworks_rooms()->Array:
	# A deliberately dark life-support intake. The central manifold can open a
	# lit restoration loop or the traveler's quieter overflow bypass, never both.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_stillworks(grid:Array,rooms:Array):
	# Only the intake and decision manifold exist before the permanent choice.
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _cistern_rooms()->Array:
	# A reservoir control spine with two mutually exclusive service circuits.
	# The Stillworks outcome decides which circuit the keepers can unseal.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_cistern(grid:Array,rooms:Array):
	# The keeper station is reachable; the pressure gallery or spillway is
	# carved only after its physical recovery request is accepted.
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _drowned_rooms()->Array:
	# A dry vestibule and sluice control split into two long flooded wings. The
	# pressure route favors the east rescue wing; the dark route favors salvage.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_drowned(grid:Array,rooms:Array):
	# Only the dry arrival route exists until the player deliberately cycles the
	# sluice. Both objectives then open at once under a persistent surge clock.
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _tidecourt_rooms()->Array:
	# Meridian's lower water court branches according to what survived the
	# Drowned Gallery. Only the public hearing chamber is initially reachable.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_tidecourt(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _sump_rooms()->Array:
	# A resident waterworks wrapped around a communal pump hall. Tidecourt
	# standing opens one service branch; the lower stair stays sealed until repair.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_sump(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _market_rooms()->Array:
	# A lower-city bazaar around an old freight clock. The completed Commons
	# foothold determines which sealed arcade and material exchange residents offer.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_market(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _depot_rooms()->Array:
	# A split freight depot whose two heavy mechanisms cannot fit in one pack.
	# Tavi's Mainspring specialty reveals a different pair of recovery lanes.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_depot(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _refuge_rooms()->Array:
	# A stranded rail settlement around a switch tower. One side can become a
	# fixed sanctuary; the other can launch a mobile supply corridor.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_refuge(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _ashrail_rooms()->Array:
	# A soot-choked junction below Switchyard. The prior refuge plan opens one
	# provisioning lane; the far platform stays sealed until its cache is stocked.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_ashrail(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _customs_rooms()->Array:
	# A lower-rail border post with an official inspection platform and a
	# concealed freight bypass. Only the chosen route is opened.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_customs(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _railcourt_rooms()->Array:
	# A lived-in rail tribunal with an official switchhouse above and a resident
	# arcade below. Customs standing determines which half opens first.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_railcourt(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _registry_rooms()->Array:
	# A staffed records hall split between a sealed public audit vault and an
	# unlit resident copy room. Railcourt standing selects the available lane.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_registry(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _morrow_rooms()->Array:
	# A live freight exchange split between the lit authority consist and an
	# unlisted ghost-line train. The physical waybill chooses the callable lane.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_morrow(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _terminus_rooms()->Array:
	# A lived-in terminus beyond Meridian's direct authority. The public arrival
	# hall and the free siding lead to different obligations before the far lift.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_terminus(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _farline_rooms()->Array:
	# An inhabited crossroads maintained by several independent settlements.
	# Cairn standing selects the public witness road or the dark cacheway.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_farline(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _thimble_rooms()->Array:
	# A living settlement straddling a deep shaft. Farline standing determines
	# which approach the warned surface incursion follows.
	return [
		Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),
		Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),
		Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),
		Rect2i(42,29,11,7)
	]

func _connect_thimble(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _latchwater_rooms()->Array:
	return [Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),Rect2i(42,29,11,7)]

func _connect_latchwater(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _driftglass_rooms()->Array:
	return [Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),Rect2i(42,29,11,7)]

func _connect_driftglass(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _bellhome_rooms()->Array:
	# A guarded independent gate with two history-shaped approaches, a central
	# convoy court, a diversion culvert and the road into Bellhome territory.
	return [Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),Rect2i(42,29,11,7)]

func _connect_bellhome(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _commons_rooms()->Array:
	# An inhabited district of communal homes. Prior convoy trust selects the
	# resident court, quiet culvert row or damaged public ward repair route.
	return [Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),Rect2i(42,29,11,7)]

func _connect_commons(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _yard_rooms()->Array:
	# A communal expansion yard with two heavy-cargo branches and a lower-line gantry.
	return [Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),Rect2i(42,29,11,7)]

func _connect_yard(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _kiln_rooms()->Array:
	# An abandoned heatworks whose slag road and chimney flues are opened by
	# Hearthline's route and Pell's practiced specialty.
	return [Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),Rect2i(42,29,11,7)]

func _connect_kiln(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _junction_rooms()->Array:
	# A signal house feeding a hot freight platform and a concealed shunt.
	return [Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),Rect2i(42,29,11,7)]

func _connect_junction(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _ember_commons_rooms()->Array:
	# An inhabited signal district whose reception follows the resolved freight arrival.
	return [Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),Rect2i(42,29,11,7)]

func _connect_ember_commons(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _deepcoil_rooms()->Array:
	# A paired signal vault. The crown and root galleries stay sealed until
	# Embervault's repaired signal house identifies who answers from below.
	return [Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),Rect2i(42,29,11,7)]

func _connect_deepcoil(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _coilward_rooms()->Array:
	# A community court whose route and civic obligations are shaped by the
	# keeper, freeband, or echo that answered through Deepcoil.
	return [Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),Rect2i(42,29,11,7)]

func _connect_coilward(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _charterwell_rooms()->Array:
	# A delegation station with route-shaped approaches, a public platform,
	# a supply gate, protected rooms, and a connected lower road.
	return [Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),Rect2i(42,29,11,7)]

func _connect_charterwell(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _writwell_rooms()->Array:
	# A multi-settlement chamber with a route-shaped gallery, three delegate
	# benches, a shared pledge table, resident stores, and a lower assembly road.
	return [Rect2i(3,3,10,8),Rect2i(15,3,10,8),Rect2i(27,3,12,9),Rect2i(42,3,11,9),Rect2i(42,16,11,9),Rect2i(24,16,13,9),Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(24,29,13,7),Rect2i(42,29,11,7)]

func _connect_writwell(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _concordance_rooms()->Array:
	# A fortified settlement gate with a mandate court, contested approach,
	# fixed bastion, reserve yard, response stores, and the road below.
	return [Rect2i(3,4,10,8),Rect2i(16,3,11,9),Rect2i(30,3,11,9),Rect2i(44,4,9,8),Rect2i(43,16,10,9),Rect2i(27,16,12,9),Rect2i(4,16,16,9),Rect2i(4,29,16,7),Rect2i(27,29,12,7),Rect2i(44,29,9,7)]

func _connect_concordance(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _reservefall_rooms()->Array:
	# A lower-quarter junction with a signal court, route-shaped approach,
	# defense line, fallback gate, protected rooms, and the inhabited road below.
	return [Rect2i(3,4,10,8),Rect2i(16,3,11,9),Rect2i(30,3,11,9),Rect2i(44,4,9,8),Rect2i(43,16,10,9),Rect2i(27,16,12,9),Rect2i(4,16,16,9),Rect2i(4,29,16,7),Rect2i(27,29,12,7),Rect2i(44,29,9,7)]

func _connect_reservefall(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _reserve_commons_rooms()->Array:
	# An inhabited lower-quarter district with a history-shaped reception road,
	# communal shield cache, repair court, resident stores and a deeper road.
	return [Rect2i(3,4,10,8),Rect2i(16,3,11,9),Rect2i(30,3,11,9),Rect2i(44,4,9,8),Rect2i(43,16,10,9),Rect2i(27,16,12,9),Rect2i(4,16,16,9),Rect2i(4,29,16,7),Rect2i(27,29,12,7),Rect2i(44,29,9,7)]

func _connect_reserve_commons(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _shieldline_rooms()->Array:
	# A mobile-defense workshop with two heavy component lanes, a resident
	# shieldwright, assembly carriage and the road into the lower works.
	return [Rect2i(3,4,10,8),Rect2i(16,3,11,9),Rect2i(30,3,11,9),Rect2i(44,4,9,8),Rect2i(43,16,10,9),Rect2i(27,16,12,9),Rect2i(4,16,16,9),Rect2i(4,29,16,7),Rect2i(27,29,12,7),Rect2i(44,29,9,7)]

func _connect_shieldline(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _marchhold_rooms()->Array:
	# A broad crossing with a warning bell, contested span, deployment line,
	# fallback ramp, protected alcoves and the road to the next settlement.
	return [Rect2i(3,4,10,8),Rect2i(16,3,11,9),Rect2i(30,3,11,9),Rect2i(44,4,9,8),Rect2i(43,16,10,9),Rect2i(27,16,12,9),Rect2i(4,16,16,9),Rect2i(4,29,16,7),Rect2i(27,29,12,7),Rect2i(44,29,9,7)]

func _connect_marchhold(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _march_refuge_rooms()->Array:
	# A mobile settlement with a seal court, outcome-shaped reception road,
	# brace cache, communal repair yard and a road into deeper refuge territory.
	return [Rect2i(3,4,10,8),Rect2i(16,3,11,9),Rect2i(30,3,11,9),Rect2i(44,4,9,8),Rect2i(43,16,10,9),Rect2i(27,16,12,9),Rect2i(4,16,16,9),Rect2i(4,29,16,7),Rect2i(27,29,12,7),Rect2i(44,29,9,7)]

func _connect_march_refuge(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _wallward_rooms()->Array:
	# A convoy descent with a seal post, outcome-shaped approach, beacon cache,
	# escort rally, screened bypass, refuge alcoves and the open road below.
	return [Rect2i(3,4,10,8),Rect2i(16,3,11,9),Rect2i(30,3,11,9),Rect2i(44,4,9,8),Rect2i(43,16,10,9),Rect2i(27,16,12,9),Rect2i(4,16,16,9),Rect2i(4,29,16,7),Rect2i(27,29,12,7),Rect2i(44,29,9,7)]

func _connect_wallward(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _wayfarer_rooms()->Array:
	# A roadstead built around a shared repair court, with three distinct
	# reception lanes and a freight jack that must be carried to the crew.
	return [Rect2i(3,3,10,8),Rect2i(16,3,10,8),Rect2i(30,3,11,9),Rect2i(44,3,9,9),Rect2i(43,16,10,9),Rect2i(26,16,13,10),Rect2i(4,16,15,9),Rect2i(4,29,15,7),Rect2i(26,29,13,7),Rect2i(43,29,10,7)]

func _connect_wayfarer(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _underway_rooms()->Array:
	# A buried road fork with a survey post, route-shaped approach, physical
	# survey cache, bright and concealed branches, and a deeper road.
	return [Rect2i(3,4,10,8),Rect2i(16,3,11,9),Rect2i(30,3,11,9),Rect2i(44,4,9,8),Rect2i(43,16,10,9),Rect2i(27,16,12,9),Rect2i(4,16,16,9),Rect2i(4,29,16,7),Rect2i(27,29,12,7),Rect2i(44,29,9,7)]

func _connect_underway(grid:Array,rooms:Array):
	for link in [[0,1],[1,2]]:corridor(grid,rooms[link[0]].get_center(),rooms[link[1]].get_center(),1)

func _room_from_data(room:Array)->Rect2i:
	return Rect2i(int(room[0]),int(room[1]),int(room[2]),int(room[3]))

func _drain_sunken_branch(f:Dictionary,choice:String):
	var room_index=7 if choice=="residences" else 8
	var room=_room_from_data(f.rooms[room_index])
	for y in range(room.position.y,room.end.y):
		for x in range(room.position.x,room.end.x):carve(f.grid,Vector2i(x,y))
	var avenue=Vector2i(44,27) if choice=="residences" else Vector2i(12,27)
	corridor(f.grid,avenue,room.get_center(),1)
	for mark in f.landmarks:
		if mark.get("kind","")=="pump_console":mark.state=choice
		elif mark.get("kind","")=="flooded_route":mark.state="drained" if mark.get("branch","")==choice else "sealed"
	var target=room.get_center()+Vector2i(1,0)
	var items={"rations":4,"medkit":2,"armor":1} if choice=="residences" else {"scrap":6,"crystal":4,"timber":2}
	var name="Residential emergency cache" if choice=="residences" else "Substation parts cage"
	f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":name,"searched":false,"items":items,"kind":"salvage"})
	navigation_cache.erase(str(int(f.z)))

func ensure_floor(z: int):
	if data.floors.has(str(z)): return
	var rng = RandomNumberGenerator.new()
	rng.seed = int(data.seed) + z * 104729
	var grid: Array = []
	for y in H:
		var row: Array = []
		row.resize(W)
		row.fill(0)
		grid.append(row)
	var rooms = _outpost_rooms() if z==5 else _bellwether_rooms() if z==7 else _spindle_rooms() if z==9 else _ashline_rooms() if z==11 else _service_rooms() if z==12 else _foundry_rooms() if z==13 else _archive_rooms() if z==14 else _wake_rooms() if z==15 else _quiet_rooms() if z==16 else _stillworks_rooms() if z==17 else _cistern_rooms() if z==18 else _drowned_rooms() if z==19 else _tidecourt_rooms() if z==20 else _sump_rooms() if z==21 else _market_rooms() if z==22 else _depot_rooms() if z==23 else _refuge_rooms() if z==24 else _ashrail_rooms() if z==25 else _customs_rooms() if z==26 else _railcourt_rooms() if z==27 else _registry_rooms() if z==28 else _morrow_rooms() if z==29 else _terminus_rooms() if z==30 else _farline_rooms() if z==31 else _thimble_rooms() if z==32 else _latchwater_rooms() if z==33 else _driftglass_rooms() if z==34 else _bellhome_rooms() if z==35 else _commons_rooms() if z==36 else _yard_rooms() if z==37 else _kiln_rooms() if z==38 else _junction_rooms() if z==39 else _ember_commons_rooms() if z==40 else _deepcoil_rooms() if z==41 else _coilward_rooms() if z==42 else _charterwell_rooms() if z==43 else _writwell_rooms() if z==44 else _concordance_rooms() if z==45 else _reservefall_rooms() if z==46 else _reserve_commons_rooms() if z==47 else _shieldline_rooms() if z==48 else _marchhold_rooms() if z==49 else _march_refuge_rooms() if z==50 else _wallward_rooms() if z==51 else _wayfarer_rooms() if z==52 else _underway_rooms() if z==53 else _transit_rooms() if z % 5 == 1 else _mine_rooms() if z % 5 == 2 else _cavern_rooms(rng) if z%5==3 else _sunken_rooms() if z%5==4 else [Rect2i(3, 3, 12, 11)]
	if z not in [5,7,9,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53] and not z % 5 in [1,2,3,4]:
		for i in 15:
			var rect = Rect2i(rng.randi_range(3, W - 13), rng.randi_range(3, H - 11), rng.randi_range(5, 10), rng.randi_range(5, 8))
			rooms.append(rect)
	for room in rooms:
		if (z%5==4 and z not in [9,14,19,24,29,34,39,44,49] and room in [rooms[7],rooms[8]]) or (z==7 and room in [rooms[8],rooms[9]]) or (z==9 and room in [rooms[7],rooms[8],rooms[9]]) or (z==11 and room in [rooms[6],rooms[9]]) or (z==12 and room in [rooms[6],rooms[8],rooms[9]]) or (z==13 and room in [rooms[6],rooms[8],rooms[9]]) or (z==14 and room in [rooms[6],rooms[8],rooms[9]]) or (z==15 and room in [rooms[6],rooms[8],rooms[9]]) or (z==16 and room in [rooms[4],rooms[5],rooms[6],rooms[7],rooms[8],rooms[9]]) or (z==17 and room in [rooms[3],rooms[4],rooms[5],rooms[6],rooms[7],rooms[8],rooms[9]]) or (z in [18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53] and room in [rooms[3],rooms[4],rooms[5],rooms[6],rooms[7],rooms[8],rooms[9]]):continue
		if z%5==3 and z not in [13,18,23,28,33,43,53]:_carve_cavern(grid,room)
		else:
			for y in range(room.position.y, room.end.y):
				for x in range(room.position.x, room.end.x): carve(grid, Vector2i(x, y))
	if z==5:_connect_outpost(grid,rooms)
	elif z==7:_connect_bellwether(grid,rooms)
	elif z==9:_connect_spindle(grid,rooms)
	elif z==11:_connect_ashline(grid,rooms)
	elif z==12:_connect_service(grid,rooms)
	elif z==13:_connect_foundry(grid,rooms)
	elif z==14:_connect_archive(grid,rooms)
	elif z==15:_connect_wake(grid,rooms)
	elif z==16:_connect_quiet(grid,rooms)
	elif z==17:_connect_stillworks(grid,rooms)
	elif z==18:_connect_cistern(grid,rooms)
	elif z==19:_connect_drowned(grid,rooms)
	elif z==20:_connect_tidecourt(grid,rooms)
	elif z==21:_connect_sump(grid,rooms)
	elif z==22:_connect_market(grid,rooms)
	elif z==23:_connect_depot(grid,rooms)
	elif z==24:_connect_refuge(grid,rooms)
	elif z==25:_connect_ashrail(grid,rooms)
	elif z==26:_connect_customs(grid,rooms)
	elif z==27:_connect_railcourt(grid,rooms)
	elif z==28:_connect_registry(grid,rooms)
	elif z==29:_connect_morrow(grid,rooms)
	elif z==30:_connect_terminus(grid,rooms)
	elif z==31:_connect_farline(grid,rooms)
	elif z==32:_connect_thimble(grid,rooms)
	elif z==33:_connect_latchwater(grid,rooms)
	elif z==34:_connect_driftglass(grid,rooms)
	elif z==35:_connect_bellhome(grid,rooms)
	elif z==36:_connect_commons(grid,rooms)
	elif z==37:_connect_yard(grid,rooms)
	elif z==38:_connect_kiln(grid,rooms)
	elif z==39:_connect_junction(grid,rooms)
	elif z==40:_connect_ember_commons(grid,rooms)
	elif z==41:_connect_deepcoil(grid,rooms)
	elif z==42:_connect_coilward(grid,rooms)
	elif z==43:_connect_charterwell(grid,rooms)
	elif z==44:_connect_writwell(grid,rooms)
	elif z==45:_connect_concordance(grid,rooms)
	elif z==46:_connect_reservefall(grid,rooms)
	elif z==47:_connect_reserve_commons(grid,rooms)
	elif z==48:_connect_shieldline(grid,rooms)
	elif z==49:_connect_marchhold(grid,rooms)
	elif z==50:_connect_march_refuge(grid,rooms)
	elif z==51:_connect_wallward(grid,rooms)
	elif z==52:_connect_wayfarer(grid,rooms)
	elif z==53:_connect_underway(grid,rooms)
	elif z % 5 == 1: _connect_transit(grid,rooms)
	elif z % 5 == 2: _connect_mines(grid,rooms)
	elif z%5==3:_connect_caverns(grid,rooms,rng)
	elif z%5==4:_connect_sunken(grid,rooms)
	else:
		for i in range(1, rooms.size()):
			corridor(grid, rooms[i-1].get_center(), rooms[i].get_center(), 1 if z % 5 in [0,4] else 0)
	if z % 5 == 3 and z not in [13,18,23,28,33,43,53]:
		var p = Vector2i(10, 9)
		for i in 1600:
			p += DIRS[rng.randi_range(0, 3)]
			p = p.clamp(Vector2i(3,3), Vector2i(W-4,H-4))
			for dx in range(-1,2):
				for dy in range(-1,2): carve(grid, p + Vector2i(dx,dy))
	var entry = rooms[5].get_center() if z==9 and data.bellwether_choice=="maintenance" else rooms[0].get_center() if z in [9,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53] else Vector2i(6,6)
	var down = rooms[1].get_center() if z in [16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53] else rooms[4].get_center() if z in [9,11,12,13,14,15] else rooms[7].get_center() if z==7 else rooms[9].get_center() if z%5==4 or z==5 else entry
	if z%5!=4 and z not in [5,7,9,11,12,13,14,15,16,17,18,20,21,22,23,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,50,51,52,53]:
		for room in rooms:
			var center = room.get_center()
			if center.distance_squared_to(entry) > down.distance_squared_to(entry): down = center
	if down.distance_to(entry) < 25 and z not in [9,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,50,51,52,53]:
		down = Vector2i(47, 29)
		corridor(grid, entry, down)
	var f = {"z": z, "name": theme_for(z), "grid": grid, "up": arr(entry), "down": arr(down), "seen": {}, "containers": [], "structures": [], "enemies": [], "heat": 0.0, "alarm": -1.0, "waves": 0, "rooms": [], "landmarks": []}
	data.floors[str(z)] = f
	for room in rooms: f.rooms.append([room.position.x, room.position.y, room.size.x, room.size.y])
	var occupied = {cell_key(entry): true, cell_key(down): true}
	for i in range(rooms.size()):
		if (z%5==4 and z not in [9,14,19,24,29,34,39,44] and i in [7,8]) or (z==7 and i in [8,9]) or (z==9 and i in [7,8,9]) or (z==11 and i in [6,9]) or (z==12 and i in [6,8,9]) or (z==13 and i in [6,8,9]) or (z==14 and i in [6,8,9]) or (z==15 and i in [6,8,9]) or (z==16 and i in [4,5,6,7,8,9]) or (z==17 and i in [3,4,5,6,7,8,9]) or (z in [18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53] and i in [3,4,5,6,7,8,9]):continue
		var p = rooms[i].get_center() + Vector2i(1,0)
		if occupied.has(cell_key(p)): continue
		occupied[cell_key(p)] = true
		var loot = {"timber": rng.randi_range(2, 5), "scrap": rng.randi_range(2, 5), "rations": rng.randi_range(1, 3)}
		if z >= 2: loot.crystal = rng.randi_range(1, 2)
		if i % 4 == 0: loot.medkit = 1
		if z > 0 and i == 0:loot.armor=1
		var container_name=["Emergency locker", "Transit cabinet", "Miner's chest", "Forgotten satchel", "Apartment cupboard"][z % 5]
		if z==5:container_name=["Compact locker","Gate stores","Market crate","Ward cabinet"][i%4]
		elif z==7:container_name=["Lift locker","Dispatch cage","Cable cabinet","Courier bin"][i%4]
		elif z==9:container_name=["Quarantine locker","Watch cabinet","Sealed manifest box","Intake parts cage"][i%4]
		elif z==11:container_name=["Screening locker","Ward cabinet","Checkpoint stores","Watch ration crate"][i%4]
		elif z==12:container_name=["Crew locker","Conduit cabinet","Service cart","Market stores"][i%4]
		elif z==13:container_name=["Foundry locker","Casting bin","Tool cage","Cooling stores"][i%4]
		elif z==14:container_name=["Index drawer","Archive satchel","Reader cabinet","Catalog stores"][i%4]
		elif z==15:container_name=["Survey locker","Waymark cache","Field cabinet","Wake stores"][i%4]
		elif z==16:container_name=["Acoustic locker","Darkway cache","Signal cabinet","Mile stores"][i%4]
		elif z==17:container_name=["Intake locker","Bell cabinet","Scrubber stores","Overflow cache"][i%4]
		elif z==18:container_name=["Keeper locker","Valve cabinet","Water ration cage","Spine stores"][i%4]
		elif z==19:container_name=["Dry locker","Sluice cabinet","Keeper satchel","Gallery stores"][i%4]
		elif z==20:container_name=["Court locker","Water tally cabinet","Keeper stores","Lower-district cache"][i%4]
		elif z==21:container_name=["Commons locker","Pump shelf","Resident stores","Sump cache"][i%4]
		elif z==22:container_name=["Market lockbox","Freight stall","Resident basket","Mainspring cache"][i%4]
		elif z==23:container_name=["Depot locker","Clockline cabinet","Freight cage","Dispatch cache"][i%4]
		elif z==24:container_name=["Refuge locker","Switch cabinet","Evacuation basket","Rail cache"][i%4]
		elif z==25:container_name=["Ashrail locker","Soot cabinet","Provision basket","Interchange cache"][i%4]
		elif z==26:container_name=["Customs locker","Tariff cabinet","Rail authority stores","Emberline cache"][i%4]
		elif z==27:container_name=["Concourse locker","Resident basket","Court cabinet","Switchhouse cache"][i%4]
		elif z==28:container_name=["Registry drawer","Clerk satchel","Plate cabinet","Cinder archive cache"][i%4]
		elif z==29:container_name=["Exchange locker","Train cabinet","Waybill cage","Morrow freight cache"][i%4]
		elif z==30:container_name=["Terminus locker","Cairn basket","Arrival cabinet","Far-line cache"][i%4]
		elif z==31:container_name=["Commons locker","Waymark basket","Delegate cabinet","Farline cache"][i%4]
		elif z==32:container_name=["Crossing locker","Resident basket","Bell cabinet","Thimble cache"][i%4]
		elif z==33:container_name=["Ward locker","Heater cabinet","Resident basket","Latchwater cache"][i%4]
		elif z==34:container_name=["Hall locker","Lens cabinet","Excavation basket","Driftglass cache"][i%4]
		elif z==35:container_name=["Gate locker","Convoy basket","Bellhome cabinet","Road cache"][i%4]
		elif z==36:container_name=["Commons locker","Roof basket","Resident cabinet","Bellhome stores"][i%4]
		elif z==37:container_name=["Yard locker","Thermal cabinet","Lift cage","Hearthline stores"][i%4]
		elif z==38:container_name=["Works locker","Slag cabinet","Flue cage","Kilnreach cache"][i%4]
		elif z==39:container_name=["Signal locker","Freight cabinet","Shunt cage","Embervault cache"][i%4]
		elif z==40:container_name=["Commons locker","Signal cabinet","Resident basket","Embervault stores"][i%4]
		elif z==41:container_name=["Relay locker","Coil cabinet","Listener basket","Deepcoil stores"][i%4]
		elif z==42:container_name=["Commons locker","Charter cabinet","Resident basket","Coilward stores"][i%4]
		elif z==43:container_name=["Station locker","Delegate cabinet","Passage basket","Charterwell stores"][i%4]
		elif z==47:container_name=["Commons locker","Shield cabinet","Resident basket","Reservefall stores"][i%4]
		elif z==48:container_name=["Works locker","Frame cabinet","Carriage basket","Shieldline stores"][i%4]
		elif z==49:container_name=["Crossing locker","Wall cradle","Refuge basket","Marchhold stores"][i%4]
		elif z==50:container_name=["Refuge locker","Brace cabinet","Resident basket","Marchhold stores"][i%4]
		elif z==51:container_name=["Descent locker","Beacon cabinet","Convoy basket","Wallward stores"][i%4]
		elif z==52:container_name=["Roadstead locker","Convoy trunk","Resident basket","Wayfarer stores"][i%4]
		elif z==53:container_name=["Survey locker","Waymark cabinet","Road basket","Underway cache"][i%4]
		elif z % 5 == 2:
			container_name=["Foreman's lockbox","Tool cage","Ore cart","Blasting locker"][i%4]
			if i in [2,6,7]:loot.scrap=int(loot.scrap)+3;loot.crystal=int(loot.crystal)+2
		elif z%5==3:container_name=["Calcified pack","Root cache","Flooded bundle"][i%3]
		elif z%5==4:container_name=["Evacuation locker","Market cage","Clinic cabinet","Maintenance bin"][i%4]
		f.containers.append({"id": next_id(), "x": p.x, "y": p.y, "name": container_name, "searched": false, "items": loot, "kind": "salvage"})
	if z == 0:
		f.containers[0].x = 9
		f.containers[0].y = 6
		f.containers[0].name = "Shelter supplies"
		f.containers[0].items = {"timber": 10, "scrap": 8, "rations": 6, "medkit": 2, "armor":1}
		f.landmarks.append({"x": 9, "y": 9, "name": "The traveler", "kind": "traveler"})
	if z == 2: f.landmarks.append({"x": down.x - 1, "y": down.y, "name": "A city beneath the stone", "kind": "inscription"})
	if z==1:
		_add_waystation(f,false)
		f.landmarks.append({"x":18,"y":9,"name":"Eastbound board","kind":"transit_sign","description":"EASTBOUND · LAST SERVICE 03:17. Every destination has been scratched away except DOWN."})
		f.landmarks.append({"x":43,"y":28,"name":"Last train","kind":"train_wreck","description":"The last train stopped with its doors open. Bedroll marks suggest the passengers lived here for months."})
		f.landmarks.append({"x":12,"y":31,"name":"Soot memorial","kind":"memorial","description":"Names cover the service-room wall in soot. Someone still leaves fresh lamp wicks beneath them."})
	if z==2:
		f.landmarks.append({"x":34,"y":5,"name":"Split roof beam","kind":"unstable_roof","description":"The roof beam is splitting. Crossing nearby will start a cave-in.","state":"armed","timer":0.0})
		f.landmarks.append({"x":20,"y":27,"name":"Shifting shale","kind":"unstable_roof","description":"Loose shale clicks under pressure. Keep a retreat route open.","state":"armed","timer":0.0})
		f.landmarks.append({"x":36,"y":33,"name":"Sagging supports","kind":"unstable_roof","description":"Old pit props bow beneath the stone. The valuable seam beyond was abandoned in a hurry.","state":"armed","timer":0.0})
	if z%5==3 and z not in [13,18,23,28,33,43,53]:
		var spring=rooms[4].get_center();var fossil=rooms[2].get_center();var roots=rooms[6].get_center()
		f.landmarks.append({"x":spring.x,"y":spring.y,"name":"Luminous spring","kind":"spring","description":"Mineral water glows beneath a skin of crystal. It may heal one colonist, or be drained for glowstone.","state":"untouched"})
		f.landmarks.append({"x":fossil.x,"y":fossil.y,"name":"Spiral fossil wall","kind":"fossil","description":"Vast spiral shells fill the limestone. Whatever sea formed this place vanished before the first tunnel was dug."})
		f.landmarks.append({"x":roots.x,"y":roots.y,"name":"Root breach","kind":"roots","description":"Pale roots descend farther than the surface trees should reach. Their cut ends are warm."})
	if z%5==4 and z not in [9,14,19,24,29,34,39]:
		var pump=rooms[3].get_center()
		f.landmarks.append({"x":pump.x,"y":pump.y,"name":"Emergency pump console","kind":"pump_console","description":"The old civic pump has enough power to reclaim one flooded branch before its windings burn out.","state":"idle"})
		f.landmarks.append({"x":44,"y":27,"name":"Flooded residences","kind":"flooded_route","branch":"residences","state":"flooded","description":"Black water fills the residential shelter stairs. Emergency supplies are marked below."})
		f.landmarks.append({"x":12,"y":27,"name":"Flooded substation","kind":"flooded_route","branch":"substation","state":"flooded","description":"The utility tunnel is submerged. Its parts cages may still hold grid hardware and glowstone."})
		f.landmarks.append({"x":48,"y":7,"name":"Evacuation ledger","kind":"quarter_lore","description":"The final ledger lists every apartment twice: once under EVACUATED, then again under WATER UNACCOUNTED."})
		f.landmarks.append({"x":10,"y":17,"name":"High-water clinic","kind":"quarter_lore","description":"Bed frames hang from ceiling hooks above the old flood line. Empty medicine wrappers form a careful tally."})
	if z==5:_add_outpost(f,"")
	if z==7:_add_bellwether(f,"")
	if z==9:
		_add_spindle(f,"",data.bellwether_choice)
		if data.bellwether_choice=="maintenance":
			spawn_enemy(z,_spindle_center(f,5)+Vector2i(3,0),"Burrower")
			spawn_enemy(z,_spindle_center(f,6)+Vector2i(-3,0),"Burrower")
	if z==11:_add_ashline(f,"")
	if z==12:_add_service_ring(f,"")
	if z==13:_add_foundry(f,"",data.service_choice)
	if z==14:_add_archive(f,"")
	if z==15:_add_wake(f,"",data.archive_choice)
	if z==16:_add_quiet(f,"")
	if z==17:_add_stillworks(f,"")
	if z==18:_add_cistern(f,"")
	if z==19:_add_drowned(f,"")
	if z==20:_add_tidecourt(f,"")
	if z==21:_add_sump(f,"")
	if z==22:_add_market(f,"",data.sump_state,data.market_recruit_joined)
	if z==23:_add_depot(f,"",data.market_state)
	if z==24:_add_refuge(f,"",data.depot_state);_seed_refuge_guards(f)
	if z==25:_add_ashrail(f,"",data.refuge_state);_seed_ashrail_guards(f)
	if z==26:_add_customs(f,"",data.refuge_state)
	if z==27:_add_railcourt(f,"",data.customs_state);_seed_railcourt_guards(f)
	if z==28:_add_registry(f,"",data.railcourt_state);_seed_registry_guards(f)
	if z==29:_add_morrow(f,"",data.registry_state)
	if z==30:_add_terminus(f,"",data.morrow_state);_seed_terminus_guards(f)
	if z==31:_add_farline(f,"",data.terminus_state)
	if z==32:_add_thimble(f,"",data.farline_state)
	if z==33:_add_latchwater(f,"",data.thimble_state)
	if z==34:_add_driftglass(f,"",data.latchwater_state)
	if z==35:_add_bellhome(f,"",data.driftglass_state)
	if z==36:_add_commons(f,"",data.bellhome_state)
	if z==37:_add_yard(f,"",data.commons_state,data.yard_recruit_joined)
	if z==38:_add_kiln(f,"",data.yard_state)
	if z==39:_add_junction(f,"",data.kiln_state)
	if z==40:_add_ember_commons(f,"",data.junction_state)
	if z==41:_add_deepcoil(f,"",data.ember_commons_state)
	if z==42:_add_coilward(f,"",data.deepcoil_state)
	if z==43:_add_charterwell(f,"",data.coilward_state)
	if z==44:_add_writwell(f,"",data.charterwell_state)
	if z==45:_add_concordance(f,"",data.writwell_state)
	if z==46:_add_reservefall(f,"",data.concordance_state)
	if z==47:_add_reserve_commons(f,"",data.reservefall_state)
	if z==48:_add_shieldline(f,"",data.reserve_commons_state,data.shieldline_recruit_joined)
	if z==49:_add_marchhold(f,"",data.shieldline_state)
	if z==50:_add_march_refuge(f,"",data.marchhold_state)
	if z==51:_add_wallward(f,"",data.march_refuge_state)
	if z==52:_add_wayfarer(f,"",data.wallward_state)
	if z==53:_add_underway(f,"",data.wayfarer_state)
	if z >= 2 and z not in [5,9,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53]:
		var enemy_rooms=[7,6,5,4,3] if z==7 else [9,6,5,2] if z%5==4 else range(rooms.size()-1,-1,-1)
		for i in range(min(2 + z / 2, 5)):
			var p = rooms[int(enemy_rooms[i])].get_center()
			if p.distance_to(entry) > 15: spawn_enemy(z, p, "Burrower")
	data.deepest = max(int(data.deepest), z)

func _add_waystation(f:Dictionary,joined:bool):
	if f.rooms.is_empty():return
	var room=f.rooms[min(5,f.rooms.size()-1)]
	var center=Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="station"):f.landmarks.append({"x":center.x-1,"y":center.y,"name":"Cinder Waystation","kind":"station"})
	if not joined and not f.landmarks.any(func(mark):return mark.get("kind","")=="recruit"):f.landmarks.append({"x":center.x,"y":center.y,"name":"Vale","kind":"recruit"})

func _add_outpost(f:Dictionary,choice:String):
	if f.rooms.is_empty():return
	var council_room=f.rooms[min(4,f.rooms.size()-1)]
	var council=Vector2i(int(council_room[0])+int(council_room[2])/2,int(council_room[1])+int(council_room[3])/2)
	var state=choice if choice in ["aid","trade"] else "waiting"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="outpost"):
		f.landmarks.append({"x":council.x,"y":council.y,"name":"Low Lantern council","kind":"outpost","state":state,"description":"The Lantern Compact holds this freight junction behind patched steel and disciplined light."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="outpost":mark.state=state
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="outpost_lore"):
		var gate_room=f.rooms[min(2,f.rooms.size()-1)];var ward_room=f.rooms[min(6,f.rooms.size()-1)]
		var gate=Vector2i(int(gate_room[0])+int(gate_room[2])/2,int(gate_room[1])+int(gate_room[3])/2)
		var ward=Vector2i(int(ward_room[0])+int(ward_room[2])/2,int(ward_room[1])+int(ward_room[3])/2)
		f.landmarks.append({"x":gate.x,"y":gate.y,"name":"Three-bar gate","kind":"outpost_lore","description":"Three white bars mark the Compact gate. The same sign appears on courier scraps pointing deeper."})
		f.landmarks.append({"x":ward.x,"y":ward.y,"name":"Fever ward","kind":"outpost_lore","description":"Cots fill an old ticket hall. Low Lantern has people to spare for watch duty, but not medicine."})

func _bellwether_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _add_bellwether(f:Dictionary,choice:String):
	if f.rooms.is_empty():return
	var control=_bellwether_center(f,4)
	var state=choice if choice in ["courier","maintenance"] else "waiting"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="bellwether"):
		f.landmarks.append({"x":control.x,"y":control.y,"name":"Bellwether lift control","kind":"bellwether","state":state,"description":"Two descent systems remain: a three-bar courier cage and an unmarked maintenance counterweight."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="bellwether":mark.state=state
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="bellwether_evidence"):
		var manifest=_bellwether_center(f,1);var camp=_bellwether_center(f,3)
		f.landmarks.append({"x":manifest.x,"y":manifest.y,"name":"Fresh transfer manifest","kind":"bellwether_evidence","description":"A grease-pencil manifest records three unreturned courier cages. The newest entry is only two shifts old and carries the safe-city water seal."})
		f.landmarks.append({"x":camp.x,"y":camp.y,"name":"Three-bar courier camp","kind":"bellwether_evidence","description":"Warm wax, fresh boot mud and a water wrapper marked SPINDLE GATE confirm that Compact couriers passed here recently."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="bellwether_route"):
		var service=_bellwether_center(f,5);var courier=_bellwether_center(f,6)
		f.landmarks.append({"x":courier.x,"y":courier.y,"name":"Three-bar courier cage","kind":"bellwether_route","route":"courier","state":"open" if choice=="courier" else "locked" if choice=="maintenance" else "sealed","description":"The marked cage follows the Compact chart toward Spindle Gate."})
		f.landmarks.append({"x":service.x,"y":service.y,"name":"Counterweight crawl","kind":"bellwether_route","route":"maintenance","state":"open" if choice=="maintenance" else "locked" if choice=="courier" else "sealed","description":"An unmarked service descent avoids the courier machinery. Something has burrowed beside its cable trench."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="bellwether_route":mark.state="open" if mark.get("route","")==choice else "locked" if choice!="" else "sealed"

func _open_bellwether_route(f:Dictionary,choice:String):
	var room_index=8 if choice=="courier" else 9
	var room=_room_from_data(f.rooms[room_index]);var junction=_bellwether_center(f,7);var landing=room.get_center()
	for y in range(room.position.y,room.end.y):
		for x in range(room.position.x,room.end.x):carve(f.grid,Vector2i(x,y))
	corridor(f.grid,junction,landing,1)
	f.down=arr(landing)
	for mark in f.landmarks:
		if mark.get("kind","")=="bellwether":mark.state=choice
		elif mark.get("kind","")=="bellwether_route":mark.state="open" if mark.get("route","")==choice else "locked"
	var cache_target=landing+Vector2i(1,0);var cache=container_at(int(f.z),cache_target)
	var cache_name="Fresh courier satchel" if choice=="courier" else "Counterweight salvage"
	var items={"rations":2,"medkit":1} if choice=="courier" else {"scrap":4,"crystal":2}
	if cache.is_empty():f.containers.append({"id":next_id(),"x":cache_target.x,"y":cache_target.y,"name":cache_name,"searched":true,"items":items,"kind":"ground"})
	if choice=="maintenance":spawn_enemy(int(f.z),landing+Vector2i(-2,0),"Burrower")
	navigation_cache.erase(str(int(f.z)))

func _spindle_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _add_spindle(f:Dictionary,contact:String,route_choice:String):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Spindle Gate"
	var watch=_spindle_center(f,4) if bespoke else vec(f.down)
	var state=contact if contact in ["recognized","breach"] else "waiting"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="spindle"):
		f.landmarks.append({"x":watch.x,"y":watch.y,"name":"Gate Watch Mara","kind":"spindle","state":state,"description":"A living voice answers behind Spindle's armored quarantine glass. The gate belongs to a city called Meridian."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="spindle":mark.state=state
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="spindle_lore"):
		var seal=_spindle_center(f,2);var watch_post=_spindle_center(f,3)
		f.landmarks.append({"x":seal.x,"y":seal.y,"name":"Meridian water seal","kind":"spindle_lore","description":"The Bellwether seal repeats on a live pressure gauge: MERIDIAN OUTER QUARANTINE · SPINDLE GATE."})
		f.landmarks.append({"x":watch_post.x,"y":watch_post.y,"name":"Occupied watch post","kind":"spindle_lore","description":"Warm food, clean bandages and a rifle port prove that the city beyond the wall is inhabited now."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="spindle_route"):
		var courier=_spindle_center(f,0);var maintenance=_spindle_center(f,5)
		f.landmarks.append({"x":courier.x,"y":courier.y,"name":"Marked quarantine lane","kind":"spindle_route","route":"courier","state":"arrived" if route_choice=="courier" else "closed","description":"The three-bar route reaches a staffed screening lane. Its seals match the Compact chart."})
		f.landmarks.append({"x":maintenance.x,"y":maintenance.y,"name":"Breached service intake","kind":"spindle_route","route":"maintenance","state":"arrived" if route_choice=="maintenance" else "closed","description":"The unmarked counterweight opens inside a torn utility intake. Burrower fur and fresh blood streak the grating."})

func _open_spindle_gate(f:Dictionary,contact:String):
	var bespoke=str(f.get("name",""))=="Spindle Gate" and f.rooms.size()>=10
	var cache_target=vec(f.down)
	if bespoke:
		var threshold=_room_from_data(f.rooms[7]);var reward_index=8 if contact=="recognized" else 9;var reward_room=_room_from_data(f.rooms[reward_index])
		for room in [threshold,reward_room]:
			for y in range(room.position.y,room.end.y):
				for x in range(room.position.x,room.end.x):carve(f.grid,Vector2i(x,y))
		corridor(f.grid,_spindle_center(f,4),threshold.get_center(),1)
		corridor(f.grid,threshold.get_center(),reward_room.get_center(),1)
		f.down=arr(threshold.get_center());cache_target=reward_room.get_center()+Vector2i(1,0)
	else:
		for direction in DIRS:
			if walkable(int(f.z),cache_target+direction) and container_at(int(f.z),cache_target+direction).is_empty():cache_target+=direction;break
	for mark in f.landmarks:
		if mark.get("kind","")=="spindle":mark.state=contact
	var cache_name="Meridian relief locker" if contact=="recognized" else "Intake repair cache"
	var items={"rations":3,"medkit":2} if contact=="recognized" else {"scrap":3,"crystal":2,"medkit":1}
	if container_at(int(f.z),cache_target).is_empty():f.containers.append({"id":next_id(),"x":cache_target.x,"y":cache_target.y,"name":cache_name,"searched":true,"items":items,"kind":"ground"})
	navigation_cache.erase(str(int(f.z)))

func _ashline_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _add_ashline(f:Dictionary,state:String):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Ashline checkpoint" and f.rooms.size()>=10
	var officer=_ashline_center(f,4) if bespoke else vec(f.down)
	var mark_state=state if state in ["assigned","cleared"] else "waiting"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="ashline"):
		f.landmarks.append({"x":officer.x,"y":officer.y,"name":"Screening Officer Tamsin","kind":"ashline","state":mark_state,"description":"Ashline is Meridian's staffed quarantine checkpoint. Officer Tamsin compares every wound, pack and name against a slate."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="ashline":mark.state=mark_state
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="ashline_lore"):
		var wash=_ashline_center(f,2) if bespoke else officer+Vector2i(-1,0)
		var roster=_ashline_center(f,3) if bespoke else officer+Vector2i(1,0)
		f.landmarks.append({"x":wash.x,"y":wash.y,"name":"Dry decontamination arch","kind":"ashline_lore","description":"The nozzles are clean but silent. A maintenance seal names the missing part: PURIFIER CARTRIDGE 7-C."})
		f.landmarks.append({"x":roster.x,"y":roster.y,"name":"Quarantine roster","kind":"ashline_lore","description":"Fresh names continue down the slate. Meridian is admitting people, but every line carries a destination, duty and sponsor."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="ashline_route"):
		var purifier=_ashline_center(f,5) if bespoke else officer+Vector2i(-1,1)
		var threshold=_ashline_center(f,9) if bespoke else vec(f.down)
		f.landmarks.append({"x":purifier.x,"y":purifier.y,"name":"Scrubber service wing","kind":"ashline_route","route":"purifier","state":"open" if state in ["assigned","cleared"] else "sealed","description":"A failed scrubber has sealed this service wing. Meridian needs its intact purifier cartridge recovered."})
		f.landmarks.append({"x":threshold.x,"y":threshold.y,"name":"Meridian service threshold","kind":"ashline_route","route":"threshold","state":"open" if state=="cleared" else "sealed","description":"This pressure door leads into Meridian's service ring. Ashline controls its quarantine interlock."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="ashline_route":
				mark.state="open" if mark.get("route","")=="purifier" and state in ["assigned","cleared"] or mark.get("route","")=="threshold" and state=="cleared" else "sealed"

func _open_ashline_wing(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Ashline checkpoint" and f.rooms.size()>=10
	var cache_target=vec(f.down)+Vector2i(1,0)
	var enemy_target=vec(f.down)+Vector2i(-2,0)
	if bespoke:
		var vault=_room_from_data(f.rooms[6])
		for y in range(vault.position.y,vault.end.y):
			for x in range(vault.position.x,vault.end.x):carve(f.grid,Vector2i(x,y))
		corridor(f.grid,_ashline_center(f,5),vault.get_center(),1)
		cache_target=vault.get_center()+Vector2i(1,0);enemy_target=vault.get_center()+Vector2i(-3,0)
	for mark in f.landmarks:
		if mark.get("kind","")=="ashline":mark.state="assigned"
		elif mark.get("kind","")=="ashline_route" and mark.get("route","")=="purifier":mark.state="open"
	var existing=f.containers.filter(func(c):return c.get("name","")=="Ashline scrubber case")
	if existing.is_empty():f.containers.append({"id":next_id(),"x":cache_target.x,"y":cache_target.y,"name":"Ashline scrubber case","searched":false,"items":{"filter":1},"kind":"salvage"})
	if not f.enemies.any(func(enemy):return enemy.get("ashline_guard",false)):
		var enemy_id=next_id()
		f.enemies.append({"id":enemy_id,"x":enemy_target.x,"y":enemy_target.y,"name":"Burrower","hp":80.0,"clock":0.0,"attack":0.0,"ashline_guard":true})
	navigation_cache.erase(str(int(f.z)))

func _clear_ashline(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Ashline checkpoint" and f.rooms.size()>=10
	var cache_target=vec(f.down)
	if bespoke:
		var threshold=_room_from_data(f.rooms[9])
		for y in range(threshold.position.y,threshold.end.y):
			for x in range(threshold.position.x,threshold.end.x):carve(f.grid,Vector2i(x,y))
		corridor(f.grid,_ashline_center(f,4),threshold.get_center(),1)
		f.down=arr(threshold.get_center());cache_target=threshold.get_center()+Vector2i(1,0)
	else:
		for direction in DIRS:
			if walkable(int(f.z),cache_target+direction) and container_at(int(f.z),cache_target+direction).is_empty():cache_target+=direction;break
	for mark in f.landmarks:
		if mark.get("kind","")=="ashline":mark.state="cleared"
		elif mark.get("kind","")=="ashline_route" and mark.get("route","")=="threshold":mark.state="open"
	if not f.containers.any(func(c):return c.get("name","")=="Ashline field payment"):
		f.containers.append({"id":next_id(),"x":cache_target.x,"y":cache_target.y,"name":"Ashline field payment","searched":true,"items":{"rations":2,"medkit":1},"kind":"ground"})
	navigation_cache.erase(str(int(f.z)))

func _service_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _add_service_ring(f:Dictionary,choice:String):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Meridian service ring" and f.rooms.size()>=10
	var registrar=_service_center(f,4) if bespoke else vec(f.down)
	var state=choice if choice in ["city","field"] else "waiting"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="service_ring"):
		f.landmarks.append({"x":registrar.x,"y":registrar.y,"name":"Service Registrar Rook","kind":"service_ring","state":state,"description":"Rook assigns every admitted outsider a place in Meridian's machinery—or a costly license to remain beyond it."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="service_ring":mark.state=state
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="service_lore"):
		var exchange=_service_center(f,2) if bespoke else registrar+Vector2i(-1,0)
		var pipes=_service_center(f,3) if bespoke else registrar+Vector2i(1,0)
		f.landmarks.append({"x":exchange.x,"y":exchange.y,"name":"Shift exchange","kind":"service_lore","description":"Hundreds of stamped tabs trade hands at every bell. Meridian measures belonging in completed shifts, sponsors and useful skills."})
		f.landmarks.append({"x":pipes.x,"y":pipes.y,"name":"Living utility wall","kind":"service_lore","description":"Warm water, air and power pulse behind labeled valves. The safe city survives because someone is always working on it."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="service_option"):
		var city_desk=_service_center(f,5) if bespoke else registrar+Vector2i(-1,1)
		var field_desk=_service_center(f,7) if bespoke else registrar+Vector2i(1,1)
		f.landmarks.append({"x":city_desk.x,"y":city_desk.y,"name":"Municipal crew desk","kind":"service_option","option":"city","state":"chosen" if choice=="city" else "closed" if choice=="field" else "available","description":"A full maintenance shift earns city quarters, a worker allotment and quiet recovery inside the ring."})
		f.landmarks.append({"x":field_desk.x,"y":field_desk.y,"name":"Independent field desk","kind":"service_option","option":"field","state":"chosen" if choice=="field" else "closed" if choice=="city" else "available","description":"Three scrap and two glowstone purchase an independent berth whose shielding sharply reduces camp heat."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="service_option":mark.state="chosen" if mark.get("option","")==choice else "closed" if choice!="" else "available"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="service_route"):
		var threshold=_service_center(f,9) if bespoke else vec(f.down)
		f.landmarks.append({"x":threshold.x,"y":threshold.y,"name":"Lower service lock","kind":"service_route","state":"open" if choice!="" else "sealed","description":"The service ring controls the next Meridian descent. Rook opens it only after the expedition accepts standing terms."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="service_route":mark.state="open" if choice!="" else "sealed"

func _open_service_choice(f:Dictionary,choice:String):
	var bespoke=str(f.get("name",""))=="Meridian service ring" and f.rooms.size()>=10
	var cache_target=vec(f.down)
	if bespoke:
		var branch_index=6 if choice=="city" else 8
		var branch_from=5 if choice=="city" else 7
		var branch=_room_from_data(f.rooms[branch_index]);var threshold=_room_from_data(f.rooms[9])
		for room in [branch,threshold]:
			for y in range(room.position.y,room.end.y):
				for x in range(room.position.x,room.end.x):carve(f.grid,Vector2i(x,y))
		corridor(f.grid,_service_center(f,branch_from),branch.get_center(),1)
		corridor(f.grid,_service_center(f,4),threshold.get_center(),1)
		f.down=arr(threshold.get_center());cache_target=branch.get_center()+Vector2i(1,0)
	else:
		for direction in DIRS:
			if walkable(int(f.z),cache_target+direction) and container_at(int(f.z),cache_target+direction).is_empty():cache_target+=direction;break
	for mark in f.landmarks:
		if mark.get("kind","")=="service_ring":mark.state=choice
		elif mark.get("kind","")=="service_option":mark.state="chosen" if mark.get("option","")==choice else "closed"
		elif mark.get("kind","")=="service_route":mark.state="open"
	var cache_name="Municipal worker allotment" if choice=="city" else "Independent berth stores"
	var items={"rations":2,"medkit":1} if choice=="city" else {"timber":4,"rations":1}
	if not f.containers.any(func(c):return c.get("name","")==cache_name):f.containers.append({"id":next_id(),"x":cache_target.x,"y":cache_target.y,"name":cache_name,"searched":true,"items":items,"kind":"ground"})
	navigation_cache.erase(str(int(f.z)))

func _foundry_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _add_foundry(f:Dictionary,state:String,standing:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Foundry Ward" and f.rooms.size()>=10
	var forewoman=_foundry_center(f,4) if bespoke else vec(f.down)
	var mark_state=state if state in ["assigned","municipal","independent"] else "waiting"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="foundry"):
		f.landmarks.append({"x":forewoman.x,"y":forewoman.y,"name":"Foundry Forewoman Kes","kind":"foundry","state":mark_state,"description":"Kes controls Foundry Ward's work slate and the freight gate below. Rook's standing determines which contract the expedition receives."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="foundry":mark.state=mark_state
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="foundry_lore"):
		var casting=_foundry_center(f,2) if bespoke else forewoman+Vector2i(-1,0)
		var tally=_foundry_center(f,3) if bespoke else forewoman+Vector2i(1,0)
		f.landmarks.append({"x":casting.x,"y":casting.y,"name":"Living casting hall","kind":"foundry_lore","description":"Open molds glow behind heat glass. Meridian recasts scavenged surface metal into valves, braces and pressure doors."})
		f.landmarks.append({"x":tally.x,"y":tally.y,"name":"Furnace duty tally","kind":"foundry_lore","description":"Municipal crews owe dangerous repair shifts. Independent crews owe material bonds before the freight gates open."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="foundry_contract"):
		var municipal=_foundry_center(f,5) if bespoke else forewoman+Vector2i(-1,1)
		var independent=_foundry_center(f,7) if bespoke else forewoman+Vector2i(1,1)
		var municipal_state="open" if state=="assigned" else "complete" if state=="municipal" else "closed" if state=="independent" else "available" if standing=="city" else "closed"
		var independent_state="complete" if state=="independent" else "closed" if state in ["assigned","municipal"] else "available" if standing=="field" else "closed"
		f.landmarks.append({"x":municipal.x,"y":municipal.y,"name":"Municipal furnace line","kind":"foundry_contract","contract":"municipal","state":municipal_state,"description":"Municipal standing assigns a dangerous regulator recovery. The city supplies the part, but the broken line is occupied."})
		f.landmarks.append({"x":independent.x,"y":independent.y,"name":"Independent casting broker","kind":"foundry_contract","contract":"independent","state":independent_state,"description":"Independent standing avoids city duty but requires exactly 5 scrap and 2 glowstone as a material bond."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")!="foundry_contract":continue
			if mark.get("contract","")=="municipal":mark.state="open" if state=="assigned" else "complete" if state=="municipal" else "closed" if state=="independent" else "available" if standing=="city" else "closed"
			else:mark.state="complete" if state=="independent" else "closed" if state in ["assigned","municipal"] else "available" if standing=="field" else "closed"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="foundry_route"):
		var gate=_foundry_center(f,9) if bespoke else vec(f.down)
		f.landmarks.append({"x":gate.x,"y":gate.y,"name":"Lower freight gate","kind":"foundry_route","state":"open" if state in ["municipal","independent"] else "sealed","description":"Kes opens this connected descent only after Foundry Ward's standing-specific contract is complete."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="foundry_route":mark.state="open" if state in ["municipal","independent"] else "sealed"

func _open_foundry_line(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Foundry Ward" and f.rooms.size()>=10
	var cache_target=vec(f.down)
	if bespoke:
		var line=_room_from_data(f.rooms[6])
		for y in range(line.position.y,line.end.y):
			for x in range(line.position.x,line.end.x):carve(f.grid,Vector2i(x,y))
		corridor(f.grid,_foundry_center(f,5),line.get_center(),1)
		cache_target=line.get_center()+Vector2i(1,0)
	else:
		for direction in DIRS:
			if walkable(int(f.z),cache_target+direction) and container_at(int(f.z),cache_target+direction).is_empty():cache_target+=direction;break
	if not f.containers.any(func(c):return c.get("name","")=="Regulator service case"):
		f.containers.append({"id":next_id(),"x":cache_target.x,"y":cache_target.y,"name":"Regulator service case","searched":false,"items":{"coil":1},"kind":"salvage"})
	if not f.enemies.any(func(enemy):return enemy.get("foundry_guard",false)):
		var guard_target=cache_target+Vector2i(-2,0)
		f.enemies.append({"id":next_id(),"x":guard_target.x,"y":guard_target.y,"name":"Burrower","hp":80.0,"clock":0.0,"attack":0.0,"foundry_guard":true})
	navigation_cache.erase(str(int(f.z)))

func _complete_foundry(f:Dictionary,outcome:String):
	var bespoke=str(f.get("name",""))=="Foundry Ward" and f.rooms.size()>=10
	var reward_target=vec(f.down)
	if bespoke:
		var gate=_room_from_data(f.rooms[9]);var stores=_room_from_data(f.rooms[8])
		for y in range(gate.position.y,gate.end.y):
			for x in range(gate.position.x,gate.end.x):carve(f.grid,Vector2i(x,y))
		corridor(f.grid,_foundry_center(f,4),gate.get_center(),1)
		f.down=arr(gate.get_center());reward_target=stores.get_center()+Vector2i(1,0)
	else:
		for direction in DIRS:
			if walkable(int(f.z),reward_target+direction) and container_at(int(f.z),reward_target+direction).is_empty():reward_target+=direction;break
	for mark in f.landmarks:
		if mark.get("kind","")=="foundry":mark.state=outcome
		elif mark.get("kind","")=="foundry_contract":mark.state="complete" if mark.get("contract","")==outcome else "closed"
		elif mark.get("kind","")=="foundry_route":mark.state="open"
	var cache_name="Municipal tool issue" if outcome=="municipal" else "Contractor surplus"
	var items={"scrap":3,"armor":1} if outcome=="municipal" else {"timber":3,"rations":2,"medkit":1}
	if not f.containers.any(func(c):return c.get("name","")==cache_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":cache_name,"searched":true,"items":items,"kind":"ground"})
	navigation_cache.erase(str(int(f.z)))

func _archive_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _add_archive(f:Dictionary,state:String):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Archive Junction" and f.rooms.size()>=10
	var archivist=_archive_center(f,4) if bespoke else vec(f.down)
	var mark_state=state if state in ["assigned","shared","preserved"] else "waiting"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="archive"):
		f.landmarks.append({"x":archivist.x,"y":archivist.y,"name":"Archivist Sen","kind":"archive","state":mark_state,"description":"Sen holds Meridian's sealed route survey index. One missing surveyor's file matches the traveler who sent the expedition below."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="archive":mark.state=mark_state
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="archive_lore"):
		var dispatch=_archive_center(f,2) if bespoke else archivist+Vector2i(-1,0)
		var memorial=_archive_center(f,3) if bespoke else archivist+Vector2i(1,0)
		f.landmarks.append({"x":dispatch.x,"y":dispatch.y,"name":"Rumor dispatch ledger","kind":"archive_lore","description":"Meridian deliberately sent route surveyors outward with the same promise: warm lights, clean water, a safe city below. Most return lines are blank."})
		f.landmarks.append({"x":memorial.x,"y":memorial.y,"name":"Missing couriers wall","kind":"archive_lore","description":"A charcoal silhouette matches the passing traveler. Their last instruction reads: IF I VANISH, LET THE RUMOR KEEP MOVING."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="archive_choice"):
		var official=_archive_center(f,5) if bespoke else archivist+Vector2i(-1,1)
		var private=_archive_center(f,7) if bespoke else archivist+Vector2i(1,1)
		f.landmarks.append({"x":official.x,"y":official.y,"name":"Public accession desk","kind":"archive_choice","choice":"shared","state":"chosen" if state=="shared" else "closed" if state=="preserved" else "available" if state=="assigned" else "sealed","description":"Sharing the physical dossier adds the vanished surveyor to Meridian's public record and returns the original to city custody."})
		f.landmarks.append({"x":private.x,"y":private.y,"name":"Unindexed reading bay","kind":"archive_choice","choice":"preserved","state":"chosen" if state=="preserved" else "closed" if state=="shared" else "available" if state=="assigned" else "sealed","description":"Preserving the dossier keeps the only physical record in the expedition's pack and exposes a route Meridian left unindexed."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")!="archive_choice":continue
			mark.state="chosen" if mark.get("choice","")==state else "closed" if state in ["shared","preserved"] else "available" if state=="assigned" else "sealed"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="archive_route"):
		var gate=_archive_center(f,9) if bespoke else vec(f.down)
		f.landmarks.append({"x":gate.x,"y":gate.y,"name":"Lower catalog gate","kind":"archive_route","state":"open" if state in ["shared","preserved"] else "sealed","description":"The archive's connected descent opens only after the expedition decides who owns the traveler's record."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="archive_route":mark.state="open" if state in ["shared","preserved"] else "sealed"

func _open_archive_vault(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Archive Junction" and f.rooms.size()>=10
	var case_target=vec(f.down)
	if bespoke:
		var vault=_room_from_data(f.rooms[6])
		for y in range(vault.position.y,vault.end.y):
			for x in range(vault.position.x,vault.end.x):carve(f.grid,Vector2i(x,y))
		corridor(f.grid,_archive_center(f,5),vault.get_center(),1)
		case_target=vault.get_center()+Vector2i(1,0)
	for mark in f.landmarks:
		if mark.get("kind","")=="archive":mark.state="assigned"
		elif mark.get("kind","")=="archive_choice":mark.state="available"
	if not f.containers.any(func(c):return c.get("name","")=="Sealed survey file"):
		f.containers.append({"id":next_id(),"x":case_target.x,"y":case_target.y,"name":"Sealed survey file","searched":false,"items":{"dossier":1},"kind":"salvage"})
	navigation_cache.erase(str(int(f.z)))

func _complete_archive(f:Dictionary,choice:String):
	var bespoke=str(f.get("name",""))=="Archive Junction" and f.rooms.size()>=10
	var reward_target=vec(f.down)
	if bespoke:
		var stores=_room_from_data(f.rooms[8]);var gate=_room_from_data(f.rooms[9])
		for room in [stores,gate]:
			for y in range(room.position.y,room.end.y):
				for x in range(room.position.x,room.end.x):carve(f.grid,Vector2i(x,y))
		corridor(f.grid,_archive_center(f,7),stores.get_center(),1)
		corridor(f.grid,_archive_center(f,4),gate.get_center(),1)
		f.down=arr(gate.get_center());reward_target=stores.get_center()+Vector2i(1,0)
	for mark in f.landmarks:
		if mark.get("kind","")=="archive":mark.state=choice
		elif mark.get("kind","")=="archive_choice":mark.state="chosen" if mark.get("choice","")==choice else "closed"
		elif mark.get("kind","")=="archive_route":mark.state="open"
	var cache_name="Archive witness allotment" if choice=="shared" else "Unindexed survey cache"
	var items={"rations":2,"medkit":1,"crystal":1} if choice=="shared" else {"scrap":3,"crystal":2}
	if not f.containers.any(func(c):return c.get("name","")==cache_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":cache_name,"searched":true,"items":items,"kind":"ground"})
	navigation_cache.erase(str(int(f.z)))

func _wake_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _add_wake(f:Dictionary,state:String,custody:String):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Surveyor's Wake" and f.rooms.size()>=10
	var contact=_wake_center(f,4) if bespoke else vec(f.down)
	var helper="Rescue Marshal Rell" if custody=="shared" else "Traveler's annotated waymark"
	var mark_state=state if state in ["assigned","marshal","waymark"] else "waiting"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="wake"):
		f.landmarks.append({"x":contact.x,"y":contact.y,"name":helper,"kind":"wake","state":mark_state,"description":"The last survey staging post is silent. "+("Meridian sent Rell after the dossier entered the public archive." if custody=="shared" else "Margins in the preserved dossier identify a route Meridian never indexed.")})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="wake":mark.state=mark_state;mark.name=helper
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="wake_lore"):
		var bunks=_wake_center(f,2) if bespoke else contact+Vector2i(-1,0)
		var board=_wake_center(f,3) if bespoke else contact+Vector2i(1,0)
		f.landmarks.append({"x":bunks.x,"y":bunks.y,"name":"Abandoned survey bunks","kind":"wake_lore","description":"Three bedrolls are neatly tied. A fourth remains open beside a mug that dried days ago."})
		f.landmarks.append({"x":board.x,"y":board.y,"name":"Last route board","kind":"wake_lore","description":"The vanished traveler's hand marks a destination beyond the Wake: QUIET MILE · LISTEN BEFORE LIGHT."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="wake_route"):
		var official=_wake_center(f,6) if bespoke else contact+Vector2i(-1,1)
		var hidden=_wake_center(f,8) if bespoke else contact+Vector2i(1,1)
		var open_route="official" if custody=="shared" else "unindexed"
		f.landmarks.append({"x":official.x,"y":official.y,"name":"Marked recovery gallery","kind":"wake_route","route":"official","state":"open" if state=="assigned" and open_route=="official" or state=="marshal" else "closed" if open_route!="official" or state in ["marshal","waymark"] else "sealed","description":"Meridian's rescue marshal can open this reinforced gallery and hold one flank."})
		f.landmarks.append({"x":hidden.x,"y":hidden.y,"name":"Unindexed survey crawl","kind":"wake_route","route":"unindexed","state":"open" if state=="assigned" and open_route=="unindexed" or state=="waymark" else "closed" if open_route!="unindexed" or state in ["marshal","waymark"] else "sealed","description":"The preserved dossier maps a hidden crawl with richer salvage and no city escort."})
	else:
		var chosen="official" if custody=="shared" else "unindexed"
		for mark in f.landmarks:
			if mark.get("kind","")!="wake_route":continue
			mark.state="open" if mark.get("route","")==chosen and state in ["assigned","marshal","waymark"] else "closed" if state!="" or mark.get("route","")!=chosen else "sealed"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="wake_exit"):
		var exit=_wake_center(f,9) if bespoke else vec(f.down)
		f.landmarks.append({"x":exit.x,"y":exit.y,"name":"Quiet Mile descent","kind":"wake_exit","state":"open" if state in ["marshal","waymark"] else "sealed","description":"The recovered survey compass aligns this connected route with the traveler's final waymark."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="wake_exit":mark.state="open" if state in ["marshal","waymark"] else "sealed"

func _open_wake_route(f:Dictionary,custody:String):
	var bespoke=str(f.get("name",""))=="Surveyor's Wake" and f.rooms.size()>=10
	var branch_index=6 if custody=="shared" else 8
	var branch_from=5 if custody=="shared" else 7
	var case_target=vec(f.down)
	if bespoke:
		var branch=_room_from_data(f.rooms[branch_index])
		for y in range(branch.position.y,branch.end.y):
			for x in range(branch.position.x,branch.end.x):carve(f.grid,Vector2i(x,y))
		corridor(f.grid,_wake_center(f,branch_from),branch.get_center(),1)
		case_target=branch.get_center()+Vector2i(1,0)
	for mark in f.landmarks:
		if mark.get("kind","")=="wake":mark.state="assigned"
		elif mark.get("kind","")=="wake_route":mark.state="open" if mark.get("route","")==("official" if custody=="shared" else "unindexed") else "closed"
	var case_name="Missing survey team's field case"
	if not f.containers.any(func(c):return c.get("name","")==case_name):f.containers.append({"id":next_id(),"x":case_target.x,"y":case_target.y,"name":case_name,"searched":false,"items":{"compass":1},"kind":"salvage"})
	var threat_count=1 if custody=="shared" else 2
	for i in threat_count:
		var guard_target=case_target+Vector2i(-2-i*2,0)
		f.enemies.append({"id":next_id(),"x":guard_target.x,"y":guard_target.y,"name":"Burrower","hp":80.0,"clock":0.0,"attack":0.0,"wake_guard":true})
	navigation_cache.erase(str(int(f.z)))

func _complete_wake(f:Dictionary,outcome:String):
	var bespoke=str(f.get("name",""))=="Surveyor's Wake" and f.rooms.size()>=10
	var reward_target=vec(f.down)
	if bespoke:
		var exit=_room_from_data(f.rooms[9])
		for y in range(exit.position.y,exit.end.y):
			for x in range(exit.position.x,exit.end.x):carve(f.grid,Vector2i(x,y))
		corridor(f.grid,_wake_center(f,4),exit.get_center(),1)
		f.down=arr(exit.get_center());reward_target=exit.get_center()+Vector2i(1,0)
	for mark in f.landmarks:
		if mark.get("kind","")=="wake":mark.state=outcome
		elif mark.get("kind","")=="wake_exit":mark.state="open"
	var cache_name="Meridian recovery allotment" if outcome=="marshal" else "Traveler's hidden field cache"
	var items={"rations":3,"medkit":2} if outcome=="marshal" else {"scrap":4,"crystal":3}
	if not f.containers.any(func(c):return c.get("name","")==cache_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":cache_name,"searched":true,"items":items,"kind":"ground"})
	navigation_cache.erase(str(int(f.z)))

func _quiet_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _quiet_rank(state:String)->int:
	return {"":0,"one":1,"two":2,"open":3,"heard":4}.get(state,0)

func _add_quiet(f:Dictionary,state:String):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Quiet Mile" and f.rooms.size()>=10
	var receiver=_quiet_center(f,1) if bespoke else vec(f.up)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="quiet_receiver"):
		f.landmarks.append({"x":receiver.x,"y":receiver.y,"name":"Quiet Mile receiver","kind":"quiet_receiver","state":"heard" if state=="heard" else "ready","description":"The traveler's receiver can replay the recovered signal tape without consuming it."})
	var room_indices=[3,5,7]
	for stage in range(1,4):
		var target=_quiet_center(f,room_indices[stage-1]) if bespoke else _quiet_center(f,min(stage,f.rooms.size()-1))
		var status="complete" if _quiet_rank(state)>=stage else "available" if _quiet_rank(state)==stage-1 else "locked"
		var existing=f.landmarks.filter(func(mark):return mark.get("kind","")=="quiet_post" and int(mark.get("stage",0))==stage)
		if existing.is_empty():
			f.landmarks.append({"x":target.x,"y":target.y,"name":"Listening post "+str(stage),"kind":"quiet_post","stage":stage,"state":status,"description":"Tune this acoustic post in darkness while nearby companions remain still. The work itself may be heard."})
		else:existing[0].state=status
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="quiet_lore"):
		var warning=_quiet_center(f,2) if bespoke else receiver+Vector2i(1,0)
		f.landmarks.append({"x":warning.x,"y":warning.y,"name":"Black-glass warning","kind":"quiet_lore","description":"LISTEN BEFORE LIGHT. The shapes beyond the glass wake for lanterns and work, but lose a motionless body in darkness."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="quiet_exit"):
		var exit=_quiet_center(f,9) if bespoke else vec(f.down)
		f.landmarks.append({"x":exit.x,"y":exit.y,"name":"Lower signal stair","kind":"quiet_exit","state":"open" if state=="heard" else "sealed","description":"The traveler's final transmission aligns the connected route below."})
	else:
		for mark in f.landmarks:
			if mark.get("kind","")=="quiet_exit":mark.state="open" if state=="heard" else "sealed"
	for mark in f.landmarks:
		if mark.get("kind","")=="quiet_receiver":mark.state="heard" if state=="heard" else "ready"

func _open_quiet_section(f:Dictionary,state:String):
	var bespoke=str(f.get("name",""))=="Quiet Mile" and f.rooms.size()>=10
	if bespoke:
		var indices=[]
		var links=[]
		if state=="one":indices=[4,5];links=[[3,4],[4,5]]
		elif state=="two":indices=[6,7];links=[[5,6],[6,7]]
		elif state=="open":indices=[8];links=[[7,8]]
		elif state=="heard":indices=[9];links=[[8,9]]
		for index in indices:
			var room=_room_from_data(f.rooms[index])
			for y in range(room.position.y,room.end.y):
				for x in range(room.position.x,room.end.x):carve(f.grid,Vector2i(x,y))
		for link in links:corridor(f.grid,_quiet_center(f,link[0]),_quiet_center(f,link[1]),1)
	if state in ["one","two"]:
		var guard_stage=1 if state=="one" else 2
		if not f.enemies.any(func(enemy):return int(enemy.get("quiet_guard",0))==guard_stage):
			var guard_target=_quiet_center(f,4 if state=="one" else 6) if bespoke else vec(f.down)
			f.enemies.append({"id":next_id(),"x":guard_target.x,"y":guard_target.y,"name":"Gloam stalker","hp":36.0,"clock":0.0,"attack":0.0,"quiet_guard":guard_stage})
	if state=="open":
		var case_target=_quiet_center(f,8)+Vector2i(1,0) if bespoke else vec(f.down)
		if not f.containers.any(func(c):return c.get("name","")=="Traveler's last recorder"):
			f.containers.append({"id":next_id(),"x":case_target.x,"y":case_target.y,"name":"Traveler's last recorder","searched":false,"items":{"tape":1},"kind":"salvage"})
	if state=="heard" and bespoke:f.down=arr(_quiet_center(f,9))
	_add_quiet(f,state)
	navigation_cache.erase(str(int(f.z)))

func quiet_error(index:int,target:Vector2i)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var pawn=data.pawns[index];var z=int(pawn.z)
	if lantern_lit(z,target):return "Extinguish or move nearby camp lanterns. The listening post needs darkness."
	if not active_decoy(z,target).is_empty() or not active_tripwire(z,target).is_empty():return "Let nearby lures and ringing alarms fall silent first."
	for other_index in data.pawns.size():
		if other_index==index:continue
		var other=data.pawns[other_index]
		if other.hp>0 and int(other.z)==z and point(other).distance_to(target)<=8.0 and not other.job.is_empty():return str(other.name)+" must remain still near the listening post."
	return ""

func _stillworks_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _add_stillworks(f:Dictionary,choice:String):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Stillworks" and f.rooms.size()>=10
	var console=_stillworks_center(f,2) if bespoke else vec(f.up)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="stillworks"):
		f.landmarks.append({"x":console.x,"y":console.y,"name":"Bell manifold","kind":"stillworks","state":choice if choice!="" else "waiting","description":"The traveler's tape identifies two mutually exclusive life-support routes: relight the scrubbers or keep the overflow bypass dark."})
	var restore_target=_stillworks_center(f,3) if bespoke else console+Vector2i(1,0)
	var dark_target=_stillworks_center(f,5) if bespoke else console+Vector2i(-1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="stillworks_option" and mark.get("choice","")=="restore"):
		f.landmarks.append({"x":restore_target.x,"y":restore_target.y,"name":"Scrubber restoration loop","kind":"stillworks_option","choice":"restore","state":"chosen" if choice=="restore" else "closed" if choice=="dark" else "available","description":"Install four scrap and two glowstone. Restored air gives safe idle recovery, but fixed work lights wake the Gloam."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="stillworks_option" and mark.get("choice","")=="dark"):
		f.landmarks.append({"x":dark_target.x,"y":dark_target.y,"name":"Dark overflow bypass","kind":"stillworks_option","choice":"dark","state":"chosen" if choice=="dark" else "closed" if choice=="restore" else "available","description":"Fit two timber and two scrap as acoustic baffles. The route stays dark and suppresses camp pressure, but the scrubbers remain dead."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="stillworks_lore"):
		var warning=_stillworks_center(f,1) if bespoke else console+Vector2i(0,1)
		f.landmarks.append({"x":warning.x,"y":warning.y,"name":"Maintenance bell ledger","kind":"stillworks_lore","description":"The traveler's recorded bell pattern marks a dark overflow route beside Meridian's failed intake. Restoring the main scrubbers will light the machinery hall."})
	var restore_exit=_stillworks_center(f,9)+Vector2i(1,0) if bespoke else vec(f.down)+Vector2i(1,0)
	var dark_exit=_stillworks_center(f,7)+Vector2i(1,0) if bespoke else vec(f.down)+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="stillworks_exit" and mark.get("route","")=="restore"):
		f.landmarks.append({"x":restore_exit.x,"y":restore_exit.y,"name":"Restored intake stair","kind":"stillworks_exit","route":"restore","state":"open" if choice=="restore" else "closed" if choice=="dark" else "sealed","description":"A powered pressure lock descends through Meridian's restored life-support intake."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="stillworks_exit" and mark.get("route","")=="dark"):
		f.landmarks.append({"x":dark_exit.x,"y":dark_exit.y,"name":"Dark overflow stair","kind":"stillworks_exit","route":"dark","state":"open" if choice=="dark" else "closed" if choice=="restore" else "sealed","description":"The traveler's muffled overflow route descends without city light."})
	for mark in f.landmarks:
		if mark.get("kind","")=="stillworks":mark.state=choice if choice!="" else "waiting"
		elif mark.get("kind","")=="stillworks_option":mark.state="chosen" if mark.choice==choice else "closed" if choice!="" else "available"
		elif mark.get("kind","")=="stillworks_exit":mark.state="open" if mark.route==choice else "closed" if choice!="" else "sealed"

func _resolve_stillworks(f:Dictionary,choice:String):
	var bespoke=str(f.get("name",""))=="Stillworks" and f.rooms.size()>=10
	if bespoke:
		var indices=[3,4,9] if choice=="restore" else [5,6,7]
		var links=[[2,3],[3,4],[4,9]] if choice=="restore" else [[2,5],[5,6],[6,7]]
		for index in indices:
			var room=_room_from_data(f.rooms[index])
			for y in range(room.position.y,room.end.y):
				for x in range(room.position.x,room.end.x):carve(f.grid,Vector2i(x,y))
		for link in links:corridor(f.grid,_stillworks_center(f,link[0]),_stillworks_center(f,link[1]),1)
		f.down=arr(_stillworks_center(f,9 if choice=="restore" else 7))
	if choice=="restore":
		var light_rooms=[3,4,9] if bespoke else [0]
		for index in light_rooms:
			var light_target=_stillworks_center(f,index) if bespoke else vec(f.up)
			if not f.landmarks.any(func(mark):return mark.get("kind","")=="stillworks_light" and point(mark)==light_target):
				f.landmarks.append({"x":light_target.x,"y":light_target.y,"name":"Fixed intake light","kind":"stillworks_light","state":"lit","description":"Restored grid light. Gloam stalkers can follow anyone crossing its reach."})
		for guard_index in [4,9]:
			var guard_target=_stillworks_center(f,guard_index) if bespoke else vec(f.down)
			if not f.enemies.any(func(enemy):return int(enemy.get("stillworks_guard",0))==guard_index):
				f.enemies.append({"id":next_id(),"x":guard_target.x,"y":guard_target.y,"name":"Gloam stalker","hp":36.0,"clock":0.0,"attack":0.0,"stillworks_guard":guard_index})
	else:
		var cache_target=_stillworks_center(f,6)+Vector2i(1,0) if bespoke else vec(f.down)
		if not f.containers.any(func(c):return c.get("name","")=="Traveler's darkway cache"):
			f.containers.append({"id":next_id(),"x":cache_target.x,"y":cache_target.y,"name":"Traveler's darkway cache","searched":false,"items":{"crystal":2,"medkit":1},"kind":"salvage"})
	_add_stillworks(f,choice)
	navigation_cache.erase(str(int(f.z)))

func _cistern_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _cistern_route()->String:
	return "pressure" if data.stillworks_choice=="restore" else "spillway"

func _add_cistern(f:Dictionary,state:String):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Cistern Spine" and f.rooms.size()>=10
	var keeper=_cistern_center(f,2) if bespoke else vec(f.up)
	var route=_cistern_route()
	var complete=state in ["pressure","spillway"]
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="cistern"):
		f.landmarks.append({"x":keeper.x,"y":keeper.y,"name":"Water Keeper Nera","kind":"cistern","state":state if state!="" else "waiting","route":route,"description":"Nera watches a failing reservoir gate. The Stillworks outcome determines which service circuit can reach its missing physical seal."})
	var pressure_target=_cistern_center(f,3) if bespoke else keeper+Vector2i(1,0)
	var spillway_target=_cistern_center(f,5) if bespoke else keeper+Vector2i(-1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="cistern_route" and mark.get("route","")=="pressure"):
		f.landmarks.append({"x":pressure_target.x,"y":pressure_target.y,"name":"Powered pressure gallery","kind":"cistern_route","route":"pressure","state":"complete" if state=="pressure" else "open" if state=="assigned" and route=="pressure" else "closed" if route=="spillway" or complete else "sealed","description":"Restored scrubber power can drive this flooded gallery, but the water hammer carries movement vibration to burrowers."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="cistern_route" and mark.get("route","")=="spillway"):
		f.landmarks.append({"x":spillway_target.x,"y":spillway_target.y,"name":"Unlit keeper spillway","kind":"cistern_route","route":"spillway","state":"complete" if state=="spillway" else "open" if state=="assigned" and route=="spillway" else "closed" if route=="pressure" or complete else "sealed","description":"The baffled Stillworks leaves this overflow quiet and dark. One Gloam stalker nests where the missing seal was stored."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="cistern_lore"):
		var ledger=_cistern_center(f,1) if bespoke else keeper+Vector2i(0,1)
		f.landmarks.append({"x":ledger.x,"y":ledger.y,"name":"Water ration tally","kind":"cistern_lore","description":"Meridian measures drinking water by the cup. The lower reservoir is full, but a missing gate seal leaves it one tremor from contamination."})
	var exit_target=_cistern_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="cistern_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Lower reservoir stair","kind":"cistern_exit","state":"open" if complete else "sealed","description":"The water keepers open this connected descent only after the recovered seal secures Cistern Spine."})
	for mark in f.landmarks:
		if mark.get("kind","")=="cistern":mark.state=state if state!="" else "waiting";mark.route=route
		elif mark.get("kind","")=="cistern_route":
			mark.state="complete" if state==mark.route else "open" if state=="assigned" and route==mark.route else "closed" if route!=mark.route or complete else "sealed"
		elif mark.get("kind","")=="cistern_exit":mark.state="open" if complete else "sealed"

func _open_cistern_route(f:Dictionary):
	var route=_cistern_route();var bespoke=str(f.get("name",""))=="Cistern Spine" and f.rooms.size()>=10
	if bespoke:
		var indices=[3,4,8,9] if route=="pressure" else [5,6,7,9]
		var links=[[2,3],[3,4],[4,8],[8,9]] if route=="pressure" else [[2,5],[5,6],[6,7],[7,9]]
		for index in indices:
			var room=_room_from_data(f.rooms[index])
			for y in range(room.position.y,room.end.y):
				for x in range(room.position.x,room.end.x):carve(f.grid,Vector2i(x,y))
		for link in links:corridor(f.grid,_cistern_center(f,link[0]),_cistern_center(f,link[1]),1)
	var seal_target=_cistern_center(f,8 if route=="pressure" else 7)+Vector2i(1,0) if bespoke else vec(f.down)
	if not f.containers.any(func(c):return c.get("name","")=="Floodgate seal cradle"):
		f.containers.append({"id":next_id(),"x":seal_target.x,"y":seal_target.y,"name":"Floodgate seal cradle","searched":false,"items":{"seal":1},"kind":"salvage"})
	if route=="pressure":
		for guard_index in [4,8]:
			var guard_target=_cistern_center(f,guard_index) if bespoke else seal_target+Vector2i(-1 if guard_index==4 else 1,0)
			if not f.enemies.any(func(enemy):return int(enemy.get("cistern_guard",0))==guard_index):
				f.enemies.append({"id":next_id(),"x":guard_target.x,"y":guard_target.y,"name":"Burrower","hp":24.0,"clock":0.0,"attack":0.0,"cistern_guard":guard_index})
	else:
		var guard_target=_cistern_center(f,6) if bespoke else seal_target+Vector2i(-1,0)
		if not f.enemies.any(func(enemy):return int(enemy.get("cistern_guard",0))==6):
			f.enemies.append({"id":next_id(),"x":guard_target.x,"y":guard_target.y,"name":"Gloam stalker","hp":36.0,"clock":0.0,"attack":0.0,"cistern_guard":6})
	_add_cistern(f,"assigned")
	navigation_cache.erase(str(int(f.z)))

func _complete_cistern(f:Dictionary,outcome:String):
	var bespoke=str(f.get("name",""))=="Cistern Spine" and f.rooms.size()>=10
	if bespoke:f.down=arr(_cistern_center(f,9))
	var keeper=_cistern_center(f,2) if bespoke else vec(f.up)
	var reward={"rations":3,"medkit":2} if outcome=="pressure" else {"scrap":4,"crystal":3}
	var cache_name="Keeper water allotment" if outcome=="pressure" else "Spillway salvage issue"
	var target=keeper+Vector2i(0,1);var cache=container_at(int(f.z),target)
	if cache.is_empty():
		cache={"id":next_id(),"x":target.x,"y":target.y,"name":cache_name,"searched":true,"items":{},"kind":"ground"};f.containers.append(cache)
	for item in reward:cache.items[item]=int(cache.items.get(item,0))+int(reward[item])
	_add_cistern(f,outcome)
	navigation_cache.erase(str(int(f.z)))

func _drowned_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _add_drowned(f:Dictionary,state:String):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Drowned Gallery" and f.rooms.size()>=10
	var control=_drowned_center(f,2) if bespoke else vec(f.up)
	var rescue=_drowned_center(f,8) if bespoke else control+Vector2i(1,0)
	var salvage=_drowned_center(f,7) if bespoke else control+Vector2i(-1,0)
	var exit_target=_drowned_center(f,9) if bespoke else vec(f.down)
	var resolved=state in ["rescued","salvaged","flooded"]
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="drowned_control"):
		f.landmarks.append({"x":control.x,"y":control.y,"name":"Gallery sluice control","kind":"drowned_control","state":state if state!="" else "waiting","description":"Cycling this sluice opens both flooded wings and starts a visible reservoir surge. The dry vestibule behind it is the safe retreat line."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="drowned_rescue"):
		f.landmarks.append({"x":rescue.x,"y":rescue.y,"name":"Trapped Keeper Olan","kind":"drowned_rescue","state":"safe" if state=="rescued" else "lost" if state in ["salvaged","flooded"] else "available" if state=="warning" else "sealed","description":"Olan is pinned behind the eastern inspection rail. Releasing them saves a life but leaves the regulator cage to the surge."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="drowned_salvage"):
		f.landmarks.append({"x":salvage.x,"y":salvage.y,"name":"Pressure regulator cage","kind":"drowned_salvage","state":"claimed" if state=="salvaged" else "washed" if state in ["rescued","flooded"] else "available" if state=="warning" else "sealed","description":"The regulator cage can be cut free before the surge. Doing so abandons Olan's rescue route."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="drowned_safe"):
		var safe=_drowned_center(f,1) if bespoke else vec(f.up)
		f.landmarks.append({"x":safe.x,"y":safe.y,"name":"Dry retreat line","kind":"drowned_safe","state":"safe","description":"The sealed vestibule remains above the surge line. Colonists here avoid the wave if the warning expires."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="drowned_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Drained gallery stair","kind":"drowned_exit","state":"open" if resolved else "sealed","description":"The connected descent clears after the surge is resolved, regardless of what the expedition chose to save."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"drowned_control":mark.state=state if state!="" else "waiting"
			"drowned_rescue":mark.state="safe" if state=="rescued" else "lost" if state in ["salvaged","flooded"] else "available" if state=="warning" else "sealed"
			"drowned_salvage":mark.state="claimed" if state=="salvaged" else "washed" if state in ["rescued","flooded"] else "available" if state=="warning" else "sealed"
			"drowned_exit":mark.state="open" if resolved else "sealed"

func _open_drowned_gallery(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Drowned Gallery" and f.rooms.size()>=10
	if bespoke:
		for index in [3,4,5,6,7,8,9]:
			var room=_room_from_data(f.rooms[index])
			for y in range(room.position.y,room.end.y):
				for x in range(room.position.x,room.end.x):carve(f.grid,Vector2i(x,y))
		for link in [[2,3],[3,4],[4,8],[8,9],[2,5],[5,6],[6,7],[7,9]]:
			corridor(f.grid,_drowned_center(f,link[0]),_drowned_center(f,link[1]),1)
	var guard_index=6 if data.cistern_state=="pressure" else 4
	if not f.enemies.any(func(enemy):return bool(enemy.get("drowned_guard",false))):
		var guard_target=_drowned_center(f,guard_index) if bespoke else vec(f.down)
		var guard_name="Burrower" if data.cistern_state=="pressure" else "Gloam stalker"
		var guard_hp=24.0 if guard_name=="Burrower" else 36.0
		f.enemies.append({"id":next_id(),"x":guard_target.x,"y":guard_target.y,"name":guard_name,"hp":guard_hp,"clock":0.0,"attack":0.0,"drowned_guard":true})
	_add_drowned(f,"warning")
	navigation_cache.erase(str(int(f.z)))

func _resolve_drowned(f:Dictionary,outcome:String,index:int=-1):
	var bespoke=str(f.get("name",""))=="Drowned Gallery" and f.rooms.size()>=10
	if bespoke:f.down=arr(_drowned_center(f,9))
	data.drowned_state=outcome;data.drowned_timer=0.0
	for pawn in data.pawns:
		if int(pawn.z)!=int(f.z):continue
		if pawn.get("job",{}).get("kind","")=="drowned":pawn.job={}
		pawn.orders=pawn.orders.filter(func(order):return order.get("kind","")!="drowned")
	if outcome in ["rescued","salvaged"]:
		var target=_drowned_center(f,2)+Vector2i(0,1) if bespoke else vec(f.up)
		var cache=container_at(int(f.z),target)
		if cache.is_empty():
			cache={"id":next_id(),"x":target.x,"y":target.y,"name":"Keeper rescue allotment" if outcome=="rescued" else "Recovered regulator salvage","searched":true,"items":{},"kind":"ground"};f.containers.append(cache)
		var reward={"rations":3,"medkit":2} if outcome=="rescued" else {"scrap":6,"crystal":3}
		for item in reward:cache.items[item]=int(cache.items.get(item,0))+int(reward[item])
	if outcome=="rescued":
		for colonist in data.pawns:
			if colonist.hp>0:colonist.morale=min(100.0,float(colonist.morale)+7.0)
	if index>=0 and index<data.pawns.size():_remember_nearby(index,"rescue" if outcome=="rescued" else "discovery","Beat the Drowned Gallery surge with {other}.",8.0,7)
	_add_drowned(f,outcome)
	navigation_cache.erase(str(int(f.z)))

func _drowned_safe(f:Dictionary,p:Vector2i)->bool:
	if f.rooms.size()<3:return p.distance_to(vec(f.up))<=8.0
	for index in [0,1,2]:
		if _room_from_data(f.rooms[index]).grow(1).has_point(p):return true
	return false

func _drowned_surge(dt:float):
	if data.drowned_state!="warning" or not data.floors.has("19"):return
	data.drowned_timer=max(0.0,float(data.drowned_timer)-dt)
	if data.drowned_timer>0:return
	var f=floor_at(19);var caught:Array=[]
	for pawn in data.pawns:
		if pawn.hp<=0 or int(pawn.z)!=19 or _drowned_safe(f,point(pawn)):continue
		caught.append(str(pawn.name));_hurt_pawn(pawn,28.0)
	_resolve_drowned(f,"flooded")
	note("The reservoir surge tears through both gallery wings. "+("The dry vestibule held." if caught.is_empty() else ", ".join(caught)+" were caught in the wave."))
	events.append({"kind":"drowned"})

func _tidecourt_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _tidecourt_route(history:String="")->String:
	var outcome=history if history!="" else str(data.drowned_state)
	if outcome=="rescued":return "sponsor"
	if outcome=="salvaged":return "contract"
	return "recovery"

func _add_tidecourt(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Tidecourt" and f.rooms.size()>=10
	var clerk=_tidecourt_center(f,2) if bespoke else vec(f.down)
	var route=_tidecourt_route(history);var complete=state in ["sponsored","contracted","recovered"]
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="tidecourt"):
		f.landmarks.append({"x":clerk.x,"y":clerk.y,"name":"Lower Court Clerk Sable","kind":"tidecourt","state":state if state!="" else "waiting","route":route,"description":"Sable controls Meridian's lower water district. Tidecourt remembers whether the Gallery yielded a keeper, a regulator, or only flood damage."})
	var sponsor_target=_tidecourt_center(f,3) if bespoke else clerk+Vector2i(1,0)
	var contract_target=_tidecourt_center(f,6) if bespoke else clerk+Vector2i(-1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="tidecourt_route" and mark.get("route","")=="sponsor"):
		f.landmarks.append({"x":sponsor_target.x,"y":sponsor_target.y,"name":"Keeper-sponsored ward","kind":"tidecourt_route","route":"sponsor","state":"open" if state=="sponsored" else "available" if state=="" and route=="sponsor" else "closed","description":"Keeper Olan's testimony can sponsor the expedition into a staffed recovery ward with food, medicine, and clean rest air."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="tidecourt_route" and mark.get("route","")=="contract"):
		f.landmarks.append({"x":contract_target.x,"y":contract_target.y,"name":"Regulator exchange","kind":"tidecourt_route","route":"contract","state":"open" if state=="contracted" else "available" if state=="" and route=="contract" else "closed","description":"The recovered regulator proves a salvage claim. Posting 3 scrap and 2 glowstone funds a quiet exchange that suppresses this district's camp pressure."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="tidecourt_lore"):
		var tally=_tidecourt_center(f,1) if bespoke else vec(f.up)
		f.landmarks.append({"x":tally.x,"y":tally.y,"name":"Lower district water board","kind":"tidecourt_lore","description":"Three columns govern entry: SPONSOR, MATERIAL BOND, and PUBLIC RECOVERY. Even a failed Gallery rescue leaves a lawful route forward."})
	var exit_target=_tidecourt_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="tidecourt_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Lower water district stair","kind":"tidecourt_exit","state":"open" if complete else "sealed","description":"Tidecourt opens this connected descent after the expedition earns a sponsor, posts its regulator bond, or recovers the lost water docket."})
	for mark in f.landmarks:
		if mark.get("kind","")=="tidecourt":mark.state=state if state!="" else "waiting";mark.route=route
		elif mark.get("kind","")=="tidecourt_route":mark.state="open" if mark.get("route","")==route and complete else "available" if state=="" and mark.get("route","")==route else "closed"
		elif mark.get("kind","")=="tidecourt_exit":mark.state="open" if complete else "sealed"

func _open_tidecourt_recovery(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Tidecourt" and f.rooms.size()>=10
	var target=vec(f.up);var guard_target=target
	if bespoke:
		for link in [[2,3],[3,4],[4,5]]:corridor(f.grid,_tidecourt_center(f,link[0]),_tidecourt_center(f,link[1]),1)
		target=_tidecourt_center(f,5)+Vector2i(1,0);guard_target=_tidecourt_center(f,4)
	elif not f.containers.is_empty():target=point(f.containers[0]);guard_target=target
	if not f.containers.any(func(c):return c.get("name","")=="Silted water court case"):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Silted water court case","searched":false,"items":{"docket":1},"kind":"salvage"})
	if not f.enemies.any(func(enemy):return bool(enemy.get("tidecourt_guard",false))):f.enemies.append({"id":next_id(),"x":guard_target.x,"y":guard_target.y,"name":"Burrower","hp":24.0,"clock":0.0,"attack":0.0,"tidecourt_guard":true})
	_add_tidecourt(f,"assigned");navigation_cache.erase(str(int(f.z)))

func _complete_tidecourt(f:Dictionary,outcome:String):
	var bespoke=str(f.get("name",""))=="Tidecourt" and f.rooms.size()>=10
	var clerk=_tidecourt_center(f,2) if bespoke else vec(f.down);var reward_target=clerk+Vector2i(0,1)
	if bespoke:
		var links=[[2,3],[3,4],[4,5],[5,9]] if outcome in ["sponsored","recovered"] else [[2,6],[6,7],[7,8],[8,9]]
		for link in links:corridor(f.grid,_tidecourt_center(f,link[0]),_tidecourt_center(f,link[1]),1)
		f.down=arr(_tidecourt_center(f,9));reward_target=_tidecourt_center(f,5)+Vector2i(1,0) if outcome in ["sponsored","recovered"] else _tidecourt_center(f,8)+Vector2i(1,0)
	var reward_name="Olan's Tidecourt allotment" if outcome=="sponsored" else "Tidecourt contractor cache" if outcome=="contracted" else "Public recovery allotment"
	var items={"rations":2,"medkit":2} if outcome=="sponsored" else {"timber":4,"armor":1} if outcome=="contracted" else {"rations":2,"medkit":1}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	_add_tidecourt(f,outcome);navigation_cache.erase(str(int(f.z)))

func _sump_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _sump_route(standing:String="")->String:
	var history=standing if standing!="" else str(data.tidecourt_state)
	if history=="sponsored":return "resident"
	if history=="contracted":return "service"
	return "public"

func _add_sump(f:Dictionary,state:String,standing:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Sump Commons" and f.rooms.size()>=10
	var keeper=_sump_center(f,2) if bespoke else vec(f.down)
	var route=_sump_route(standing);var complete=state in ["resident","service","public"]
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="sump"):
		f.landmarks.append({"x":keeper.x,"y":keeper.y,"name":"Pumpwright Edda","kind":"sump","state":state if state!="" else "waiting","route":route,"description":"Edda keeps Sump Commons alive around a failing communal pump. Tidecourt standing decides which residents will unseal the missing impeller route."})
	var route_target=_sump_center(f,3 if route=="resident" else 6 if route=="service" else 5) if bespoke else keeper+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="sump_route"):
		var route_name="Resident pump gallery" if route=="resident" else "Independent service crawl" if route=="service" else "Public silt channel"
		var route_description="Olan's sponsorship brings two residents to hold the gallery gates. One burrower remains around the seized impeller." if route=="resident" else "The contractor exchange opens an unlit maintenance crawl. A Gloam stalker nests beside the stripped pump rotor." if route=="service" else "Public access opens the old silt channel. Two burrowers feel every movement around the abandoned impeller case."
		f.landmarks.append({"x":route_target.x,"y":route_target.y,"name":route_name,"kind":"sump_route","route":route,"state":"complete" if complete else "open" if state=="assigned" else "sealed","description":route_description})
	var foothold_target=_sump_center(f,8) if bespoke else keeper+Vector2i(0,1)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="sump_foothold"):
		f.landmarks.append({"x":foothold_target.x,"y":foothold_target.y,"name":"Commons expedition berth","kind":"sump_foothold","state":"active" if complete else "sealed","route":route,"description":"A durable lower-city foothold. Once the pump runs, safe idle colonists recover fatigue here and local camp pressure grows more slowly."})
	var exit_target=_sump_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="sump_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Lower mains stair","kind":"sump_exit","state":"open" if complete else "sealed","description":"The repaired pump drains this connected descent below Sump Commons."})
	for mark in f.landmarks:
		if mark.get("kind","")=="sump":mark.state=state if state!="" else "waiting";mark.route=route
		elif mark.get("kind","")=="sump_route":mark.state="complete" if complete else "open" if state=="assigned" else "sealed";mark.route=route
		elif mark.get("kind","")=="sump_foothold":mark.state="active" if complete else "sealed";mark.route=route
		elif mark.get("kind","")=="sump_exit":mark.state="open" if complete else "sealed"

func _open_sump_route(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Sump Commons" and f.rooms.size()>=10
	var route=_sump_route();var target=vec(f.up);var guards:Array=[]
	if bespoke:
		var links=[[2,3],[3,4],[4,8]] if route=="resident" else [[2,6],[6,7],[7,8]] if route=="service" else [[2,5],[5,4],[4,8]]
		for link in links:corridor(f.grid,_sump_center(f,link[0]),_sump_center(f,link[1]),1)
		target=_sump_center(f,8)+Vector2i(1,0)
		if route=="resident":guards=[[_sump_center(f,4),"Burrower"]]
		elif route=="service":guards=[[_sump_center(f,7),"Gloam stalker"]]
		else:guards=[[_sump_center(f,5),"Burrower"],[_sump_center(f,4),"Burrower"]]
	elif not f.containers.is_empty():target=point(f.containers[0])
	if not f.containers.any(func(c):return c.get("name","")=="Seized pump rotor"):
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Seized pump rotor","searched":false,"items":{"impeller":1},"kind":"salvage"})
	for i in guards.size():
		var guard=guards[i]
		if not f.enemies.any(func(enemy):return int(enemy.get("sump_guard",-1))==i):
			var hp=36.0 if guard[1]=="Gloam stalker" else 24.0
			f.enemies.append({"id":next_id(),"x":guard[0].x,"y":guard[0].y,"name":guard[1],"hp":hp,"clock":0.0,"attack":0.0,"sump_guard":i})
	_add_sump(f,"assigned");navigation_cache.erase(str(int(f.z)))

func _complete_sump(f:Dictionary,outcome:String):
	var bespoke=str(f.get("name",""))=="Sump Commons" and f.rooms.size()>=10
	var keeper=_sump_center(f,2) if bespoke else vec(f.down);var reward_target=keeper+Vector2i(0,1)
	if bespoke:
		for link in [[8,9]]:corridor(f.grid,_sump_center(f,link[0]),_sump_center(f,link[1]),1)
		f.down=arr(_sump_center(f,9));reward_target=_sump_center(f,8)+Vector2i(1,0)
	var reward_name="Resident pump allotment" if outcome=="resident" else "Independent pumpwright cache" if outcome=="service" else "Commons public stores"
	var items={"rations":3,"medkit":2} if outcome=="resident" else {"scrap":5,"crystal":2} if outcome=="service" else {"rations":2,"medkit":1,"scrap":2}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	_add_sump(f,outcome);navigation_cache.erase(str(int(f.z)))

func _market_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _market_route(standing:String="")->String:
	var history=standing if standing!="" else str(data.sump_state)
	return history if history in ["resident","service","public"] else "public"

func _market_cost(route:String)->Dictionary:
	if route=="resident":return {"rations":2,"medkit":1}
	if route=="service":return {"scrap":4,"crystal":2}
	return {"scrap":2,"rations":1}

func _add_market(f:Dictionary,state:String,standing:String="",joined:bool=false):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Mainspring Market" and f.rooms.size()>=10
	var broker=_market_center(f,2) if bespoke else vec(f.down)
	var route=_market_route(standing);var complete=state in ["resident","service","public"]
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="market"):
		f.landmarks.append({"x":broker.x,"y":broker.y,"name":"Broker Ysra","kind":"market","state":state if state!="" else "waiting","route":route,"description":"Ysra matches Mainspring's physical barter and a resident guide to the expedition's Sump Commons standing."})
	var arcade_target=_market_center(f,3 if route=="resident" else 6 if route=="service" else 5) if bespoke else broker+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="market_arcade"):
		var arcade_name="Resident makers' arcade" if route=="resident" else "Independent freight arcade" if route=="service" else "Public exchange arcade"
		var terms="Provision the shared table with exactly 2 rations and 1 medkit." if route=="resident" else "Restore the freight hoist with exactly 4 scrap and 2 glowstone." if route=="service" else "Post exactly 2 scrap and 1 ration at the public counter."
		f.landmarks.append({"x":arcade_target.x,"y":arcade_target.y,"name":arcade_name,"kind":"market_arcade","state":"open" if complete else "sealed","route":route,"description":terms+" Completion opens this arcade and keeps all received goods physical."})
	var recruit_target=_market_center(f,8) if bespoke else broker+Vector2i(0,1)
	if not complete and not joined and not f.landmarks.any(func(mark):return mark.get("kind","")=="market_recruit"):
		f.landmarks.append({"x":recruit_target.x,"y":recruit_target.y,"name":"Tavi","kind":"market_recruit","state":"waiting","route":route,"description":"A Mainspring resident willing to join once Ysra's standing-shaped exchange is complete. Tavi keeps a separate physical pack."})
	var exit_target=_market_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="market_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Clockline stair","kind":"market_exit","state":"open" if complete else "sealed","description":"Mainspring's lower freight stair opens after the exchange is honored."})
	for mark in f.landmarks:
		if mark.get("kind","")=="market":mark.state=state if state!="" else "waiting";mark.route=route
		elif mark.get("kind","")=="market_arcade":mark.state="open" if complete else "sealed";mark.route=route
		elif mark.get("kind","")=="market_exit":mark.state="open" if complete else "sealed"

func _complete_market(f:Dictionary,outcome:String,index:int):
	var bespoke=str(f.get("name",""))=="Mainspring Market" and f.rooms.size()>=10
	var broker=_market_center(f,2) if bespoke else vec(f.down);var reward_target=broker+Vector2i(0,1)
	if bespoke:
		var links=[[2,3],[3,4],[4,8],[8,9]] if outcome=="resident" else [[2,6],[6,7],[7,8],[8,9]] if outcome=="service" else [[2,5],[5,4],[4,8],[8,9]]
		for link in links:corridor(f.grid,_market_center(f,link[0]),_market_center(f,link[1]),1)
		f.down=arr(_market_center(f,9));reward_target=_market_center(f,8)+Vector2i(1,0)
	var reward_name="Resident makers' exchange" if outcome=="resident" else "Independent survival allotment" if outcome=="service" else "Public market wages"
	var items={"timber":4,"scrap":2} if outcome=="resident" else {"rations":3,"medkit":2,"armor":1} if outcome=="service" else {"timber":2,"medkit":1,"crystal":1}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	if not data.market_recruit_joined:
		data.market_recruit_joined=true
		var recruit=make_pawn("Tavi",reward_target.x-1,reward_target.y,"violet");recruit.z=22
		if outcome=="resident":recruit.inventory={"rations":1,"medkit":1};recruit.skills={"scavenge":6,"build":1,"combat":1}
		elif outcome=="service":recruit.inventory={"timber":2,"scrap":1};recruit.skills={"scavenge":1,"build":6,"combat":1}
		else:recruit.inventory={"rations":1,"medkit":1,"scrap":1};recruit.skills={"scavenge":3,"build":3,"combat":3}
		data.pawns.append(recruit)
		record_shared_memory(index,data.pawns.size()-1,"recruit","Joined {other} after the Mainspring exchange.",7.0,6)
	f.landmarks=f.landmarks.filter(func(mark):return mark.get("kind","")!="market_recruit")
	_add_market(f,outcome,data.sump_state,true);navigation_cache.erase(str(int(f.z)))

func _depot_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _depot_route(standing:String="")->String:
	var history=standing if standing!="" else str(data.market_state)
	return history if history in ["resident","service","public"] else "public"

func _add_depot(f:Dictionary,state:String,standing:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Clockline Depot" and f.rooms.size()>=10
	var dispatcher=_depot_center(f,2) if bespoke else vec(f.down);var route=_depot_route(standing);var complete=state in ["resident","service","public"]
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="depot"):
		f.landmarks.append({"x":dispatcher.x,"y":dispatcher.y,"name":"Dispatcher Jun","kind":"depot","state":state if state!="" else "waiting","route":route,"description":"Jun can reopen the Clockline only if Tavi identifies the route and two colonists return its oversized traction drive and brake drum in separate packs."})
	var drive_target=_depot_center(f,4 if route!="service" else 7) if bespoke else dispatcher+Vector2i(1,0)
	var brake_target=_depot_center(f,6 if route=="resident" else 4 if route=="service" else 7) if bespoke else dispatcher+Vector2i(-1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="depot_lane" and mark.get("cargo","")=="drive"):
		f.landmarks.append({"x":drive_target.x,"y":drive_target.y,"name":"Traction-drive lane","kind":"depot_lane","cargo":"drive","route":route,"state":"complete" if complete else "open" if state=="assigned" else "sealed","description":"A 6.5 kg traction drive waits in this lane. It cannot share one 12 kg pack with the brake drum."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="depot_lane" and mark.get("cargo","")=="brake"):
		f.landmarks.append({"x":brake_target.x,"y":brake_target.y,"name":"Brake-drum lane","kind":"depot_lane","cargo":"brake","route":route,"state":"complete" if complete else "open" if state=="assigned" else "sealed","description":"A 6.5 kg brake drum waits in this lane. A second colonist must carry it back beside the first carrier."})
	var exit_target=_depot_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="depot_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Lower Clockline platform","kind":"depot_exit","state":"open" if complete else "sealed","description":"The depot platform opens after both heavy mechanisms arrive in separate packs."})
	for mark in f.landmarks:
		if mark.get("kind","")=="depot":mark.state=state if state!="" else "waiting";mark.route=route
		elif mark.get("kind","")=="depot_lane":mark.state="complete" if complete else "open" if state=="assigned" else "sealed";mark.route=route
		elif mark.get("kind","")=="depot_exit":mark.state="open" if complete else "sealed"

func _tavi_index()->int:
	for i in data.pawns.size():
		if data.pawns[i].name=="Tavi" and data.pawns[i].hp>0:return i
	return -1

func _depot_carriers(target:Vector2i)->Array:
	var drives:Array=[];var brakes:Array=[]
	for i in data.pawns.size():
		var pawn=data.pawns[i]
		if pawn.hp<=0 or int(pawn.z)!=23 or point(pawn).distance_to(target)>2.5:continue
		if int(pawn.inventory.get("drive",0))>0:drives.append(i)
		if int(pawn.inventory.get("brake",0))>0:brakes.append(i)
	for drive_index in drives:
		for brake_index in brakes:
			if drive_index!=brake_index:return [drive_index,brake_index]
	return []

func _open_depot(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Clockline Depot" and f.rooms.size()>=10;var route=_depot_route();var drive_target=vec(f.up);var brake_target=vec(f.down);var guards:Array=[]
	if bespoke:
		var links=[[2,3],[3,4],[2,5],[5,6]] if route=="resident" else [[2,6],[6,7],[2,5],[5,4]] if route=="service" else [[2,3],[3,4],[2,6],[6,7]]
		for link in links:corridor(f.grid,_depot_center(f,link[0]),_depot_center(f,link[1]),1)
		drive_target=_depot_center(f,4 if route!="service" else 7)+Vector2i(1,0);brake_target=_depot_center(f,6 if route=="resident" else 4 if route=="service" else 7)+Vector2i(-1,0)
		if route=="resident":guards=[[_depot_center(f,4),"Gloam stalker"]]
		elif route=="service":guards=[[_depot_center(f,4),"Burrower"]]
		else:guards=[[_depot_center(f,4),"Gloam stalker"],[_depot_center(f,7),"Burrower"]]
	if not f.containers.any(func(c):return c.get("name","")=="Clockline traction case"):f.containers.append({"id":next_id(),"x":drive_target.x,"y":drive_target.y,"name":"Clockline traction case","searched":false,"items":{"drive":1},"kind":"salvage"})
	if not f.containers.any(func(c):return c.get("name","")=="Clockline brake cradle"):f.containers.append({"id":next_id(),"x":brake_target.x,"y":brake_target.y,"name":"Clockline brake cradle","searched":false,"items":{"brake":1},"kind":"salvage"})
	for i in guards.size():
		var guard=guards[i]
		if not f.enemies.any(func(enemy):return int(enemy.get("depot_guard",-1))==i):
			f.enemies.append({"id":next_id(),"x":guard[0].x,"y":guard[0].y,"name":guard[1],"hp":36.0 if guard[1]=="Gloam stalker" else 24.0,"clock":0.0,"attack":0.0,"depot_guard":i})
	_add_depot(f,"assigned");navigation_cache.erase(str(int(f.z)))

func _complete_depot(f:Dictionary,outcome:String):
	var bespoke=str(f.get("name",""))=="Clockline Depot" and f.rooms.size()>=10;var dispatcher=_depot_center(f,2) if bespoke else vec(f.down);var reward_target=dispatcher+Vector2i(0,1)
	if bespoke:
		for link in [[4,8],[7,8],[8,9]]:corridor(f.grid,_depot_center(f,link[0]),_depot_center(f,link[1]),1)
		f.down=arr(_depot_center(f,9));reward_target=_depot_center(f,8)+Vector2i(1,0)
	var reward_name="Scouted passenger freight" if outcome=="resident" else "Repaired industrial freight" if outcome=="service" else "Public Clockline allotment"
	var items={"rations":4,"medkit":2} if outcome=="resident" else {"scrap":6,"crystal":3} if outcome=="service" else {"rations":2,"medkit":1,"scrap":3,"crystal":1}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	_add_depot(f,outcome);navigation_cache.erase(str(int(f.z)))

func _refuge_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _refuge_route(history:String="")->String:
	var standing=history if history!="" else str(data.depot_state)
	return standing if standing in ["resident","service","public"] else "public"

func _refuge_cost(choice:String)->Dictionary:
	if choice=="foothold":return {"rations":3,"medkit":2,"timber":1}
	if choice=="corridor":return {"scrap":4,"crystal":2,"timber":1}
	return {}

func _add_refuge(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Switchyard Refuge" and f.rooms.size()>=10
	var keeper=_refuge_center(f,2) if bespoke else vec(f.down);var route=_refuge_route(history);var complete=state in ["foothold","corridor"]
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="refuge"):
		f.landmarks.append({"x":keeper.x,"y":keeper.y,"name":"Signal Keeper Esi","kind":"refuge","state":state if state!="" else "waiting","route":route,"description":"Esi is evacuating residents stranded beyond the reopened Clockline. Secure the switch hall, then choose whether their supplies anchor a sanctuary or travel with a mobile corridor."})
	var foothold_target=_refuge_center(f,4) if bespoke else keeper+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="refuge_option" and mark.get("choice","")=="foothold"):
		f.landmarks.append({"x":foothold_target.x,"y":foothold_target.y,"name":"Resident sanctuary","kind":"refuge_option","choice":"foothold","state":"active" if state=="foothold" else "closed" if complete else "available","description":"Anchor the evacuees here with exactly 3 rations, 2 medkits and 1 timber. The staffed sanctuary grants strong safe fatigue recovery and local pressure shelter."})
	var corridor_target=_refuge_center(f,7) if bespoke else keeper+Vector2i(-1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="refuge_option" and mark.get("choice","")=="corridor"):
		f.landmarks.append({"x":corridor_target.x,"y":corridor_target.y,"name":"Mobile supply corridor","kind":"refuge_option","choice":"corridor","state":"active" if state=="corridor" else "closed" if complete else "available","description":"Outfit the evacuation train with exactly 4 scrap, 2 glowstone and 1 timber. Its moving caches reduce positive camp pressure at the expedition's deepest reached level."})
	var exit_target=_refuge_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="refuge_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Outbound switch stair","kind":"refuge_exit","state":"open" if complete else "sealed","description":"The evacuees clear this connected lower route once their permanent plan is supplied."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="refuge_lore"):
		var lore_target=_refuge_center(f,1) if bespoke else keeper+Vector2i(0,-1)
		f.landmarks.append({"x":lore_target.x,"y":lore_target.y,"name":"Departure board","kind":"refuge_lore","description":"The board lists families instead of destinations. Each name has a hand-painted mark for STAY or KEEP MOVING."})
	for mark in f.landmarks:
		if mark.get("kind","")=="refuge":mark.state=state if state!="" else "waiting";mark.route=route
		elif mark.get("kind","")=="refuge_option":mark.state="active" if mark.get("choice","")==state else "closed" if complete else "available"
		elif mark.get("kind","")=="refuge_exit":mark.state="open" if complete else "sealed"

func _seed_refuge_guards(f:Dictionary):
	if f.enemies.any(func(enemy):return enemy.has("refuge_guard")):return
	var route=_refuge_route();var guards:Array=[[_refuge_center(f,1),"Gloam stalker"]] if route=="resident" else [[_refuge_center(f,1),"Burrower"]] if route=="service" else [[_refuge_center(f,1),"Gloam stalker"],[_refuge_center(f,2)+Vector2i(-2,0),"Burrower"]]
	for i in guards.size():
		var guard=guards[i]
		f.enemies.append({"id":next_id(),"x":guard[0].x,"y":guard[0].y,"name":guard[1],"hp":36.0 if guard[1]=="Gloam stalker" else 24.0,"clock":0.0,"attack":0.0,"refuge_guard":i})

func _complete_refuge(f:Dictionary,choice:String):
	var bespoke=str(f.get("name",""))=="Switchyard Refuge" and f.rooms.size()>=10;var reward_target=vec(f.down)
	if bespoke:
		var links=[[2,3],[3,4],[4,8],[8,9]] if choice=="foothold" else [[2,6],[6,7],[7,8],[8,9]]
		for link in links:corridor(f.grid,_refuge_center(f,link[0]),_refuge_center(f,link[1]),1)
		f.down=arr(_refuge_center(f,9));reward_target=_refuge_center(f,8)+Vector2i(1,0)
	var reward_name="Sanctuary tool stores" if choice=="foothold" else "Evacuation train surplus"
	var items={"scrap":3,"crystal":1} if choice=="foothold" else {"rations":4,"medkit":2}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	_add_refuge(f,choice);navigation_cache.erase(str(int(f.z)))

func _ashrail_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _ashrail_route(history:String="")->String:
	var source=history if history!="" else str(data.refuge_state)
	return "sanctuary" if source=="foothold" else "corridor"

func _ashrail_cost(route:String)->Dictionary:
	return {"rations":3,"medkit":1} if route=="sanctuary" else {"scrap":3,"crystal":1} if route=="corridor" else {}

func _add_ashrail(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Ashrail Interchange" and f.rooms.size()>=10
	var route=_ashrail_route(history);var stocked=state=="stocked"
	var steward=_ashrail_center(f,2) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="ashrail"):
		f.landmarks.append({"x":steward.x,"y":steward.y,"name":"Rail Steward Niko","kind":"ashrail","state":"stocked" if stocked else "waiting","route":route,"description":"Niko keeps Meridian's lowest working exchange alive through falling ash. The Switchyard plan determines which physical provisioning run can reach the far platform."})
	var lane=_ashrail_center(f,4 if route=="sanctuary" else 7) if bespoke else steward+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="ashrail_route"):
		var lane_name="Cinder service gantry" if route=="sanctuary" else "Black-rail convoy bypass"
		var lane_description="The fixed sanctuary must send 3 rations and 1 medkit through a lit gantry where two burrowers feel every moving step." if route=="sanctuary" else "The mobile corridor must spend 3 scrap and 1 glowstone repairing a dark convoy line hunted by two Gloam stalkers."
		f.landmarks.append({"x":lane.x,"y":lane.y,"name":lane_name,"kind":"ashrail_route","state":"complete" if stocked else "open","route":route,"description":lane_description})
	var exit_target=_ashrail_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="ashrail_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Lower exchange stair","kind":"ashrail_exit","state":"open" if stocked else "sealed","description":"The far platform clears this connected descent only after its route-shaped cache is physically provisioned."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="ashrail_lore"):
		var lore=_ashrail_center(f,1) if bespoke else steward+Vector2i(-1,0)
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Ashfall service clock","kind":"ashrail_lore","description":"Its face has no hours—only OPEN, ASH and BREATHE. The hand is fixed between ASH and BREATHE."})
	for mark in f.landmarks:
		if mark.get("kind","")=="ashrail":mark.state="stocked" if stocked else "waiting";mark.route=route
		elif mark.get("kind","")=="ashrail_route":mark.state="complete" if stocked else "open";mark.route=route
		elif mark.get("kind","")=="ashrail_exit":mark.state="open" if stocked else "sealed"

func _seed_ashrail_guards(f:Dictionary):
	if f.enemies.any(func(enemy):return enemy.has("ashrail_guard")):return
	var route=_ashrail_route();var name="Burrower" if route=="sanctuary" else "Gloam stalker"
	var positions=[_ashrail_center(f,3),_ashrail_center(f,4)] if route=="sanctuary" else [_ashrail_center(f,6),_ashrail_center(f,7)]
	for i in positions.size():
		f.enemies.append({"id":next_id(),"x":positions[i].x,"y":positions[i].y,"name":name,"hp":24.0 if name=="Burrower" else 36.0,"clock":0.0,"attack":0.0,"ashrail_guard":i})

func _complete_ashrail(f:Dictionary,route:String):
	var bespoke=str(f.get("name",""))=="Ashrail Interchange" and f.rooms.size()>=10
	var reward_target=vec(f.down)
	if bespoke:
		var links=[[2,3],[3,4],[4,8],[8,9]] if route=="sanctuary" else [[2,6],[6,7],[7,8],[8,9]]
		for link in links:corridor(f.grid,_ashrail_center(f,link[0]),_ashrail_center(f,link[1]),1)
		f.down=arr(_ashrail_center(f,9));reward_target=_ashrail_center(f,8)+Vector2i(1,0)
	var reward_name="Sanctuary exchange freight" if route=="sanctuary" else "Mobile corridor provisions"
	var items={"scrap":4,"crystal":2} if route=="sanctuary" else {"rations":4,"medkit":2}
	if not f.containers.any(func(c):return c.name==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	_add_ashrail(f,"stocked",data.refuge_state);navigation_cache.erase(str(int(f.z)))

func _customs_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _customs_cargo(history:String="")->String:
	var source=history if history!="" else str(data.refuge_state)
	return "industrial" if source=="foothold" else "provisions"

func _customs_cost(choice:String,cargo:String="")->Dictionary:
	var freight=_customs_cargo() if cargo=="" else cargo
	if choice=="security":return {"scrap":2,"crystal":1} if freight=="industrial" else {"rations":3,"medkit":1}
	if choice=="smuggle":return {"scrap":1,"crystal":1} if freight=="industrial" else {"rations":2}
	return {}

func _add_customs(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Emberline Customs" and f.rooms.size()>=10
	var cargo=_customs_cargo(history);var complete=state in ["security","smuggle"]
	var captain=_customs_center(f,2) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="customs"):
		f.landmarks.append({"x":captain.x,"y":captain.y,"name":"Customs Captain Vara","kind":"customs","state":state if complete else "waiting","cargo":cargo,"description":"Vara controls the lower rail border. Ashrail's exchange cargo determines the declaration and bribe she will accept."})
	var official=_customs_center(f,4) if bespoke else captain+Vector2i(1,0)
	var hidden=_customs_center(f,7) if bespoke else captain+Vector2i(-1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="customs_route" and mark.get("choice","")=="security"):
		f.landmarks.append({"x":official.x,"y":official.y,"name":"Authority inspection platform","kind":"customs_route","choice":"security","state":"open" if state=="security" else "closed" if complete else "available","description":"Declare the Ashrail cargo. Vara opens a lit patrol route with one burrower breach and permanent local pressure shelter."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="customs_route" and mark.get("choice","")=="smuggle"):
		f.landmarks.append({"x":hidden.x,"y":hidden.y,"name":"Emberline ghost siding","kind":"customs_route","choice":"smuggle","state":"open" if state=="smuggle" else "closed" if complete else "available","description":"Pay the quiet tariff. The unlit siding holds richer freight, but two Gloam stalkers wake along the bypass."})
	var exit_target=_customs_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="customs_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Lower authority gate","kind":"customs_exit","state":"open" if complete else "sealed","description":"The chosen customs route reconnects this descent after its threats are cleared."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="customs_lore"):
		var lore=_customs_center(f,1) if bespoke else captain+Vector2i(0,-1)
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Confiscation wall","kind":"customs_lore","description":"Seized packs hang beneath dates older than Meridian. Several still carry fresh Ashrail soot."})
	for mark in f.landmarks:
		if mark.get("kind","")=="customs":mark.state=state if complete else "waiting";mark.cargo=cargo
		elif mark.get("kind","")=="customs_route":mark.state="open" if mark.get("choice","")==state else "closed" if complete else "available"
		elif mark.get("kind","")=="customs_exit":mark.state="open" if complete else "sealed"

func _complete_customs(f:Dictionary,choice:String):
	var bespoke=str(f.get("name",""))=="Emberline Customs" and f.rooms.size()>=10
	var reward_target=vec(f.down)
	if bespoke:
		var links=[[2,3],[3,4],[4,8],[8,9]] if choice=="security" else [[2,6],[6,7],[7,8],[8,9]]
		for link in links:corridor(f.grid,_customs_center(f,link[0]),_customs_center(f,link[1]),1)
		f.down=arr(_customs_center(f,9));reward_target=_customs_center(f,8)+Vector2i(1,0)
	var reward_name="Customs patrol issue" if choice=="security" else "Emberline hidden freight"
	var items={"rations":2,"medkit":1,"armor":1} if choice=="security" else {"scrap":4,"crystal":2}
	if not f.containers.any(func(c):return c.name==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	var positions=[_customs_center(f,4)] if choice=="security" else [_customs_center(f,6),_customs_center(f,7)]
	var enemy_name="Burrower" if choice=="security" else "Gloam stalker"
	for i in positions.size():f.enemies.append({"id":next_id(),"x":positions[i].x,"y":positions[i].y,"name":enemy_name,"hp":24.0 if enemy_name=="Burrower" else 36.0,"clock":0.0,"attack":0.0,"customs_guard":i})
	_add_customs(f,choice,data.refuge_state);navigation_cache.erase(str(int(f.z)))

func _railcourt_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _railcourt_route(history:String="")->String:
	var source=history if history!="" else str(data.customs_state)
	return "authority" if source=="security" else "resident"

func _add_railcourt(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Railcourt Concourse" and f.rooms.size()>=10
	var route=_railcourt_route(history);var complete=state in ["licensed","resident"]
	var steward=_railcourt_center(f,2) if bespoke else vec(f.down)
	var steward_name="Magistrate Sera" if route=="authority" else "Resident Factor Pell"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="railcourt"):
		f.landmarks.append({"x":steward.x,"y":steward.y,"name":steward_name,"kind":"railcourt","state":state if state!="" else "waiting","route":route,"description":"Railcourt controls the last inhabited interchange below Emberline. Customs standing decides whether the expedition receives public authority work or enters through the resident compact."})
	var lane=_railcourt_center(f,4 if route=="authority" else 7) if bespoke else steward+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="railcourt_route"):
		var lane_name="Seized switchhouse" if route=="authority" else "Resident undercroft"
		var lane_description="Sera will unseal the switchhouse. Recover its unique warrant through two burrowers and return it for public clearance." if route=="authority" else "Pell's unlit arcade is blocked by one Gloam stalker. Once safe, residents accept exactly 3 scrap and 2 glowstone for a lower-city compact."
		f.landmarks.append({"x":lane.x,"y":lane.y,"name":lane_name,"kind":"railcourt_route","state":"complete" if complete else "open" if state=="assigned" or route=="resident" else "sealed","route":route,"description":lane_description})
	var exit_target=_railcourt_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="railcourt_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Lower freight court stair","kind":"railcourt_exit","state":"open" if complete else "sealed","description":"Public clearance or a resident compact reconnects this descent into the lower freight wards."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="railcourt_lore"):
		var lore=_railcourt_center(f,1) if bespoke else steward+Vector2i(0,-1)
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Split jurisdiction mosaic","kind":"railcourt_lore","description":"Old tiles show rails shared by a stamped hand and an open palm. New authority paint covers only half the design."})
	for mark in f.landmarks:
		if mark.get("kind","")=="railcourt":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=steward_name
		elif mark.get("kind","")=="railcourt_route":mark.state="complete" if complete else "open" if state=="assigned" or route=="resident" else "sealed";mark.route=route
		elif mark.get("kind","")=="railcourt_exit":mark.state="open" if complete else "sealed"

func _seed_railcourt_guards(f:Dictionary):
	if _railcourt_route()!="resident" or f.enemies.any(func(enemy):return enemy.has("railcourt_guard")):return
	var p=_railcourt_center(f,6)
	f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":"Gloam stalker","hp":36.0,"clock":0.0,"attack":0.0,"railcourt_guard":0})

func _open_railcourt_contract(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Railcourt Concourse" and f.rooms.size()>=10
	var target=vec(f.down)
	if bespoke:
		for link in [[2,3],[3,4]]:corridor(f.grid,_railcourt_center(f,link[0]),_railcourt_center(f,link[1]),1)
		target=_railcourt_center(f,4)+Vector2i(1,0)
	if not f.containers.any(func(c):return c.get("name","")=="Seized switch warrant case"):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Seized switch warrant case","searched":false,"items":{"warrant":1},"kind":"salvage"})
	if not f.enemies.any(func(enemy):return enemy.has("railcourt_guard")):
		for i in 2:
			var p=_railcourt_center(f,3+i)
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":"Burrower","hp":24.0,"clock":0.0,"attack":0.0,"railcourt_guard":i})
	_add_railcourt(f,"assigned",data.customs_state);navigation_cache.erase(str(int(f.z)))

func _complete_railcourt(f:Dictionary,outcome:String):
	var bespoke=str(f.get("name",""))=="Railcourt Concourse" and f.rooms.size()>=10;var reward_target=vec(f.down)
	if bespoke:
		var links=[[4,8],[8,9]] if outcome=="licensed" else [[2,6],[6,7],[7,8],[8,9]]
		for link in links:corridor(f.grid,_railcourt_center(f,link[0]),_railcourt_center(f,link[1]),1)
		f.down=arr(_railcourt_center(f,9));reward_target=_railcourt_center(f,8)+Vector2i(1,0)
	var reward_name="Railcourt contract issue" if outcome=="licensed" else "Resident compact provisions"
	var items={"rations":3,"medkit":2,"crystal":1} if outcome=="licensed" else {"rations":4,"medkit":2}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	_add_railcourt(f,outcome,data.customs_state);navigation_cache.erase(str(int(f.z)))

func _registry_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _registry_route(history:String="")->String:
	var source=history if history!="" else str(data.railcourt_state)
	return "official" if source=="licensed" else "resident"

func _add_registry(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Cinder Registry" and f.rooms.size()>=10
	var route=_registry_route(history);var complete=state in ["official","resident"]
	var clerk=_registry_center(f,2) if bespoke else vec(f.down)
	var clerk_name="Registrar Kade" if route=="official" else "Copyist Moss"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="registry"):
		f.landmarks.append({"x":clerk.x,"y":clerk.y,"name":clerk_name,"kind":"registry","state":state if state!="" else "waiting","route":route,"description":"Cinder Registry records every lower-authority freight movement. Railcourt standing decides whether the expedition audits the public plates or buys an off-ledger copy."})
	var lane=_registry_center(f,4 if route=="official" else 7) if bespoke else clerk+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="registry_route"):
		var lane_name="Charred audit vault" if route=="official" else "Resident copy room"
		var lane_description="Kade will open the burned plate vault. Recover its unique registry plate through two burrowers and return it for a physical deep-freight waybill." if route=="official" else "Moss's dark copy room is blocked by one Gloam stalker. Once safe, exactly 4 scrap and 1 glowstone buys a physical deep-freight waybill."
		f.landmarks.append({"x":lane.x,"y":lane.y,"name":lane_name,"kind":"registry_route","state":"complete" if complete else "open" if state=="assigned" or route=="resident" else "sealed","route":route,"description":lane_description})
	var exit_target=_registry_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="registry_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Morrow dispatch stair","kind":"registry_exit","state":"open" if complete else "sealed","description":"The recovered waybill names Morrow Exchange as the lower authority's deepest active freight destination."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="registry_lore"):
		var lore=_registry_center(f,1) if bespoke else clerk+Vector2i(0,-1)
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Erased destination board","kind":"registry_lore","description":"Every destination below Railcourt has been scorched away except MORROW, stamped again in fresh red wax."})
	for mark in f.landmarks:
		if mark.get("kind","")=="registry":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=clerk_name
		elif mark.get("kind","")=="registry_route":mark.state="complete" if complete else "open" if state=="assigned" or route=="resident" else "sealed";mark.route=route
		elif mark.get("kind","")=="registry_exit":mark.state="open" if complete else "sealed"

func _seed_registry_guards(f:Dictionary,history:String=""):
	if _registry_route(history)!="resident" or f.enemies.any(func(enemy):return enemy.has("registry_guard")):return
	var p=_registry_center(f,6)
	f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":"Gloam stalker","hp":36.0,"clock":0.0,"attack":0.0,"registry_guard":0})

func _open_registry_audit(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Cinder Registry" and f.rooms.size()>=10;var target=vec(f.down)
	if bespoke:
		for link in [[2,3],[3,4]]:corridor(f.grid,_registry_center(f,link[0]),_registry_center(f,link[1]),1)
		target=_registry_center(f,4)+Vector2i(1,0)
	if not f.containers.any(func(c):return c.get("name","")=="Charred registry plate case"):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Charred registry plate case","searched":false,"items":{"plate":1},"kind":"salvage"})
	if not f.enemies.any(func(enemy):return enemy.has("registry_guard")):
		for i in 2:
			var p=_registry_center(f,3+i)
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":"Burrower","hp":24.0,"clock":0.0,"attack":0.0,"registry_guard":i})
	_add_registry(f,"assigned",data.railcourt_state);navigation_cache.erase(str(int(f.z)))

func _complete_registry(f:Dictionary,outcome:String):
	var bespoke=str(f.get("name",""))=="Cinder Registry" and f.rooms.size()>=10;var reward_target=vec(f.down)
	if bespoke:
		var links=[[4,8],[8,9]] if outcome=="official" else [[2,6],[6,7],[7,8],[8,9]]
		for link in links:corridor(f.grid,_registry_center(f,link[0]),_registry_center(f,link[1]),1)
		f.down=arr(_registry_center(f,9));reward_target=_registry_center(f,8)+Vector2i(1,0)
	var reward_name="Registry audit issue" if outcome=="official" else "Copy-room provisions"
	var items={"rations":3,"medkit":2,"crystal":1} if outcome=="official" else {"rations":4,"medkit":2}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	_add_registry(f,outcome,data.railcourt_state);navigation_cache.erase(str(int(f.z)))

func _morrow_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _morrow_route(history:String="")->String:
	var source=history if history!="" else str(data.registry_state)
	return "official" if source=="official" else "resident"

func _add_morrow(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Morrow Exchange" and f.rooms.size()>=10
	var route=_morrow_route(history);var complete=state in ["official","resident"]
	var dispatcher=_morrow_center(f,2) if bespoke else vec(f.down)
	var dispatcher_name="Dispatcher Vey" if route=="official" else "Runner Sable"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="morrow"):
		f.landmarks.append({"x":dispatcher.x,"y":dispatcher.y,"name":dispatcher_name,"kind":"morrow","state":state if state!="" else "waiting","route":route,"description":"Morrow is the lower authority's deepest active exchange. The physical Registry waybill calls one train, but its provenance decides which platform answers."})
	var platform=_morrow_center(f,4 if route=="official" else 7) if bespoke else dispatcher+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="morrow_route"):
		var route_name="Authority freight consist" if route=="official" else "Ghost-line freight consist"
		var route_description="The stamped waybill calls a lit authority train. Two burrowers have breached its loading lane; clear them and rally at least two living colonists before departure." if route=="official" else "The copied waybill calls an unlisted train through a dark siding. Two Gloam stalkers hunt its loading lane; clear them and rally at least two living colonists before departure."
		f.landmarks.append({"x":platform.x,"y":platform.y,"name":route_name,"kind":"morrow_route","state":"complete" if complete else "boarding" if state=="boarding" else "sealed","route":route,"description":route_description})
	var exit_target=_morrow_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="morrow_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Deep freight train","kind":"morrow_exit","state":"open" if complete else "sealed","description":"A coordinated departure reconnects the expedition to the authority's deepest active freight line."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="morrow_lore"):
		var lore=_morrow_center(f,1) if bespoke else dispatcher+Vector2i(0,-1)
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Last arrivals slate","kind":"morrow_lore","description":"Fresh chalk lists trains arriving from settlements nobody in Meridian admits still exist. Every return column is blank."})
	for mark in f.landmarks:
		if mark.get("kind","")=="morrow":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=dispatcher_name
		elif mark.get("kind","")=="morrow_route":mark.state="complete" if complete else "boarding" if state=="boarding" else "sealed";mark.route=route
		elif mark.get("kind","")=="morrow_exit":mark.state="open" if complete else "sealed"

func _start_morrow_boarding(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Morrow Exchange" and f.rooms.size()>=10;var route=_morrow_route()
	if bespoke:
		var links=[[2,3],[3,4]] if route=="official" else [[2,6],[6,7]]
		for link in links:corridor(f.grid,_morrow_center(f,link[0]),_morrow_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("morrow_guard")):
		var rooms=[3,4] if route=="official" else [6,7]
		for i in 2:
			var p=_morrow_center(f,rooms[i])
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":"Burrower" if route=="official" else "Gloam stalker","hp":24.0 if route=="official" else 36.0,"clock":0.0,"attack":0.0,"morrow_guard":i})
	data.morrow_state="boarding";data.morrow_timer=30.0;_add_morrow(f,"boarding",data.registry_state);navigation_cache.erase(str(int(f.z)))

func morrow_gathered()->int:
	if not data.floors.has("29"):return 0
	var mark=morrow_landmark()
	if mark.is_empty():return 0
	var count=0
	for pawn in data.pawns:
		if pawn.hp>0 and not incapacitated(pawn) and int(pawn.z)==29 and point(pawn).distance_to(point(mark))<=4.0:count+=1
	return count

func _complete_morrow(f:Dictionary,outcome:String,index:int):
	var bespoke=str(f.get("name",""))=="Morrow Exchange" and f.rooms.size()>=10;var reward_target=vec(f.down)
	if bespoke:
		var links=[[4,8],[8,9]] if outcome=="official" else [[7,8],[8,9]]
		for link in links:corridor(f.grid,_morrow_center(f,link[0]),_morrow_center(f,link[1]),1)
		f.down=arr(_morrow_center(f,9));reward_target=_morrow_center(f,8)+Vector2i(1,0)
	var reward_name="Authority train issue" if outcome=="official" else "Ghost-line salvage"
	var items={"rations":4,"medkit":2,"crystal":1} if outcome=="official" else {"scrap":5,"crystal":3,"medkit":1}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.morrow_state=outcome;data.morrow_timer=0.0;_add_morrow(f,outcome,data.registry_state);navigation_cache.erase(str(int(f.z)))
	_remember_nearby(index,"discovery","Caught Morrow's deep freight train with {other}.",8.0,7)

func _morrow_departure(dt:float):
	if data.morrow_state!="boarding" or not data.floors.has("29"):return
	data.morrow_timer=max(0.0,float(data.morrow_timer)-dt)
	if data.morrow_timer>0:return
	data.morrow_state="";_add_morrow(floor_at(29),"",data.registry_state)
	note("Morrow's freight train departed without the expedition. The waybill remains physical; clear the lane, regroup, and call the next consist.")
	events.append({"kind":"morrow"})

func _terminus_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _terminus_route(history:String="")->String:
	var source=history if history!="" else str(data.morrow_state)
	return "official" if source=="official" else "resident"

func _add_terminus(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Morrow Terminus" and f.rooms.size()>=10
	var route=_terminus_route(history);var complete=state in ["chartered","free"]
	var speaker=_terminus_center(f,2) if bespoke else vec(f.down)
	var speaker_name="Speaker Nera" if route=="official" else "Free-Siding Keeper Ro"
	if bespoke and route=="resident":
		for link in [[2,6],[6,7]]:corridor(f.grid,_terminus_center(f,link[0]),_terminus_center(f,link[1]),1)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="terminus"):
		f.landmarks.append({"x":speaker.x,"y":speaker.y,"name":speaker_name,"kind":"terminus","state":state if state!="" else "waiting","route":route,"description":"Morrow Terminus serves Cairn Reach, a living settlement beyond Meridian's direct authority. The arriving train decides which promise its residents ask the expedition to keep."})
	var lane=_terminus_center(f,4 if route=="official" else 7) if bespoke else speaker+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="terminus_route"):
		var lane_name="Cairn witness hall" if route=="official" else "Free-siding lift works"
		var lane_description="The authority train's claim is not enough here. Open the breached witness hall, recover Cairn Reach's unique ledger through two burrowers, and physically return it without surrendering the waybill." if route=="official" else "The ghost line arrives among independent residents. Clear its Gloam stalker, then contribute exactly 4 scrap and 2 glowstone to repair their communal far lift."
		f.landmarks.append({"x":lane.x,"y":lane.y,"name":lane_name,"kind":"terminus_route","state":"complete" if complete else "open" if state=="assigned" or route=="resident" else "sealed","route":route,"description":lane_description})
	var exit_target=_terminus_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="terminus_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Cairn far lift","kind":"terminus_exit","state":"open" if complete else "sealed","description":"Cairn Reach maintains this descent without Meridian's crews. Its rails continue toward settlements absent from every city map."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="terminus_lore"):
		var lore=_terminus_center(f,1) if bespoke else speaker+Vector2i(0,-1)
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Cairn arrival wall","kind":"terminus_lore","description":"Dozens of settlement marks crowd the wall beyond MERIDIAN JURISDICTION. Cairn Reach has crossed out the word jurisdiction, but carefully preserved every route."})
	for mark in f.landmarks:
		if mark.get("kind","")=="terminus":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=speaker_name
		elif mark.get("kind","")=="terminus_route":mark.state="complete" if complete else "open" if state=="assigned" or route=="resident" else "sealed";mark.route=route
		elif mark.get("kind","")=="terminus_exit":mark.state="open" if complete else "sealed"

func _seed_terminus_guards(f:Dictionary,history:String=""):
	if _terminus_route(history)!="resident" or f.enemies.any(func(enemy):return enemy.has("terminus_guard")):return
	var p=_terminus_center(f,6)
	f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":"Gloam stalker","hp":36.0,"clock":0.0,"attack":0.0,"terminus_guard":0})

func _open_terminus_hall(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Morrow Terminus" and f.rooms.size()>=10;var target=vec(f.down)
	if bespoke:
		for link in [[2,3],[3,4]]:corridor(f.grid,_terminus_center(f,link[0]),_terminus_center(f,link[1]),1)
		target=_terminus_center(f,4)+Vector2i(1,0)
	if not f.containers.any(func(c):return c.get("name","")=="Cairn witness ledger case"):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Cairn witness ledger case","searched":false,"items":{"ledger":1},"kind":"salvage"})
	if not f.enemies.any(func(enemy):return enemy.has("terminus_guard")):
		for i in 2:
			var p=_terminus_center(f,3+i)
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":"Burrower","hp":24.0,"clock":0.0,"attack":0.0,"terminus_guard":i})
	_add_terminus(f,"assigned",data.morrow_state);navigation_cache.erase(str(int(f.z)))

func _complete_terminus(f:Dictionary,outcome:String,index:int):
	var bespoke=str(f.get("name",""))=="Morrow Terminus" and f.rooms.size()>=10;var reward_target=vec(f.down)
	if bespoke:
		var links=[[4,8],[8,9]] if outcome=="chartered" else [[7,8],[8,9]]
		for link in links:corridor(f.grid,_terminus_center(f,link[0]),_terminus_center(f,link[1]),1)
		f.down=arr(_terminus_center(f,9));reward_target=_terminus_center(f,8)+Vector2i(1,0)
	var reward_name="Cairn charter issue" if outcome=="chartered" else "Free-siding stores"
	var items={"rations":3,"medkit":2,"crystal":1} if outcome=="chartered" else {"rations":4,"medkit":2,"timber":2}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.terminus_state=outcome;_add_terminus(f,outcome,data.morrow_state);navigation_cache.erase(str(int(f.z)))
	_remember_nearby(index,"discovery","Earned Cairn Reach's trust with {other}.",8.0,7)

func _farline_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _farline_route(history:String="")->String:
	var source=history if history!="" else str(data.terminus_state)
	return "accord" if source=="chartered" else "cacheway"

func _add_farline(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Farline Commons" and f.rooms.size()>=10
	var route=_farline_route(history);var complete=state in ["accord","cacheway"]
	var steward=_farline_center(f,2) if bespoke else vec(f.down)
	var steward_name="Commons Warden Pell" if route=="accord" else "Cachekeeper Anik"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="farline"):
		f.landmarks.append({"x":steward.x,"y":steward.y,"name":steward_name,"kind":"farline","state":state if state!="" else "waiting","route":route,"description":"Farline Commons is a shared crossroads maintained by settlements outside Meridian's authority. Cairn Reach's standing decides which network road will answer."})
	var road=_farline_center(f,4 if route=="accord" else 7) if bespoke else steward+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="farline_route"):
		var road_name="Witness lantern road" if route=="accord" else "Free cacheway"
		var road_description="Cairn's charter opens the public lantern road. Two burrowers feel every footfall between the settlements' waymarks." if route=="accord" else "Cairn's free standing opens an unlit cacheway. Two Gloam stalkers hunt light and work noise around its hidden stores."
		f.landmarks.append({"x":road.x,"y":road.y,"name":road_name,"kind":"farline_route","state":"complete" if complete else "open" if state=="assigned" else "sealed","route":route,"description":road_description})
	var exit_target=_farline_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="farline_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Settlement descent","kind":"farline_exit","state":"open" if complete else "sealed","description":"The bound route braid records a living chain of independent settlements below Cairn Reach."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="farline_lore"):
		var lore=_farline_center(f,1) if bespoke else steward+Vector2i(0,-1)
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Commons cord wall","kind":"farline_lore","description":"Braided cords link Cairn Reach to Thimble, Latchwater, Bellhome and names with no Meridian translation. Cut cords remain displayed beside the living routes."})
	for mark in f.landmarks:
		if mark.get("kind","")=="farline":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=steward_name
		elif mark.get("kind","")=="farline_route":mark.state="complete" if complete else "open" if state=="assigned" else "sealed";mark.route=route
		elif mark.get("kind","")=="farline_exit":mark.state="open" if complete else "sealed"

func _open_farline_route(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Farline Commons" and f.rooms.size()>=10;var route=_farline_route();var target=vec(f.down)
	if bespoke:
		var links=[[2,3],[3,4]] if route=="accord" else [[2,6],[6,7]]
		for link in links:corridor(f.grid,_farline_center(f,link[0]),_farline_center(f,link[1]),1)
		target=_farline_center(f,4 if route=="accord" else 7)+Vector2i(1,0)
	if not f.containers.any(func(c):return c.get("name","")=="Farline route braid case"):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Farline route braid case","searched":false,"items":{"braid":1},"kind":"salvage"})
	if not f.enemies.any(func(enemy):return enemy.has("farline_guard")):
		var guard_rooms=[3,4] if route=="accord" else [6,7]
		for i in 2:
			var p=_farline_center(f,guard_rooms[i])
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":"Burrower" if route=="accord" else "Gloam stalker","hp":24.0 if route=="accord" else 36.0,"clock":0.0,"attack":0.0,"farline_guard":i})
	if route=="accord" and not f.structures.any(func(s):return s.kind=="lamp"):
		for room_index in [2,3,4]:f.structures.append(make_structure("lamp",_farline_center(f,room_index)+Vector2i(0,-2)))
	_add_farline(f,"assigned",data.terminus_state);navigation_cache.erase(str(int(f.z)))

func farline_gathered()->int:
	if not data.floors.has("31"):return 0
	var mark=farline_landmark()
	if mark.is_empty():return 0
	var count=0
	for pawn in data.pawns:
		if pawn.hp>0 and not incapacitated(pawn) and int(pawn.z)==31 and point(pawn).distance_to(point(mark))<=4.0:count+=1
	return count

func _complete_farline(f:Dictionary,outcome:String,index:int):
	var bespoke=str(f.get("name",""))=="Farline Commons" and f.rooms.size()>=10;var reward_target=vec(f.down)
	if bespoke:
		var links=[[4,8],[8,9]] if outcome=="accord" else [[7,8],[8,9]]
		for link in links:corridor(f.grid,_farline_center(f,link[0]),_farline_center(f,link[1]),1)
		f.down=arr(_farline_center(f,9));reward_target=_farline_center(f,8)+Vector2i(1,0)
	var reward_name="Farline delegate issue" if outcome=="accord" else "Cacheway settlement stores"
	var items={"rations":4,"medkit":2,"crystal":1} if outcome=="accord" else {"scrap":5,"crystal":3,"timber":2}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.farline_state=outcome;_add_farline(f,outcome,data.terminus_state);navigation_cache.erase(str(int(f.z)))
	_remember_nearby(index,"discovery","Bound Farline's settlement road with {other}.",8.0,7)

func _thimble_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _thimble_route(history:String="")->String:
	var source=history if history!="" else str(data.farline_state)
	return "accord" if source=="accord" else "cacheway"

func _add_thimble(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Thimble Crossing" and f.rooms.size()>=10
	var route=_thimble_route(history);var resolved=state in ["defended","evacuated","overrun"]
	var bell=_thimble_center(f,2) if bespoke else vec(f.down)
	var bell_name="Bellkeeper Sera" if route=="accord" else "Cordkeeper Sera"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="thimble"):
		f.landmarks.append({"x":bell.x,"y":bell.y,"name":bell_name,"kind":"thimble","state":state if state!="" else "waiting","route":route,"description":"Thimble Crossing is a living settlement around a warm shaft. Rising surface pressure gives its residents one fair warning: hold their homes or evacuate through the settlement road."})
	var breach=_thimble_center(f,4 if route=="accord" else 7) if bespoke else bell+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="thimble_breach"):
		f.landmarks.append({"x":breach.x,"y":breach.y,"name":"Marked upper breach" if route=="accord" else "Hidden warm vent","kind":"thimble_breach","state":"held" if state=="defended" else "lost" if state in ["evacuated","overrun"] else "warning" if state in ["defending","evacuating"] else "sealed","route":route,"description":"The Farline approach shapes the incursion: the public road has alarms but carries three husks; the hidden cacheway masks Thimble from all but two."})
	var evacuation=_thimble_center(f,8) if bespoke else bell+Vector2i(0,1)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="thimble_evacuation"):
		f.landmarks.append({"x":evacuation.x,"y":evacuation.y,"name":"Resident evacuation lift","kind":"thimble_evacuation","state":"safe" if state=="evacuated" else "closed" if state=="defended" else "lost" if state=="overrun" else "available" if state=="evacuating" else "fallback" if state=="defending" else "sealed","description":"The lift can carry Thimble's residents only if their unique cord roster and at least two expedition witnesses gather here before the warning expires."})
	var exit_target=_thimble_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="thimble_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Thimble lower road","kind":"thimble_exit","state":"open" if resolved else "sealed","description":"The lower settlement road opens after Thimble is defended, evacuated, or overrun; failure changes the history but never ends the campaign."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="thimble_lore"):
		var lore=_thimble_center(f,1) if bespoke else bell+Vector2i(0,-1)
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Thimble heat tally","kind":"thimble_lore","description":"Every warm-shaft reading is stitched into cloth beside a resident's name. The newest red thread climbs toward the surface faster than any earlier season."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"thimble":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=bell_name
			"thimble_breach":mark.state="held" if state=="defended" else "lost" if state in ["evacuated","overrun"] else "warning" if state in ["defending","evacuating"] else "sealed";mark.route=route
			"thimble_evacuation":mark.state="safe" if state=="evacuated" else "closed" if state=="defended" else "lost" if state=="overrun" else "available" if state=="evacuating" else "fallback" if state=="defending" else "sealed"
			"thimble_exit":mark.state="open" if resolved else "sealed"

func _open_thimble_choice(f:Dictionary,choice:String):
	var bespoke=str(f.get("name",""))=="Thimble Crossing" and f.rooms.size()>=10;var route=_thimble_route()
	if bespoke:
		var incursion_links=[[2,3],[3,4]] if route=="accord" else [[2,6],[6,7]]
		for link in incursion_links:corridor(f.grid,_thimble_center(f,link[0]),_thimble_center(f,link[1]),1)
		for link in [[2,5],[5,8]]:corridor(f.grid,_thimble_center(f,link[0]),_thimble_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("thimble_guard")):
		var guard_rooms=[3,4,4] if route=="accord" else [6,7]
		for i in guard_rooms.size():
			var p=_thimble_center(f,guard_rooms[i])+Vector2i(i-1 if route=="accord" else i,0)
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":"Surface husk","hp":30.0,"clock":0.0,"attack":0.0,"thimble_guard":i})
	if route=="accord" and not f.structures.any(func(s):return bool(s.get("thimble_alarm",false))):
		for room_index in [3,4]:
			var alarm=make_structure("tripwire",_thimble_center(f,room_index)+Vector2i(-2,0));alarm.thimble_alarm=true;f.structures.append(alarm)
	if choice=="evacuating" and not f.containers.any(func(c):return c.get("name","")=="Thimble resident cord case"):
		var target=_thimble_center(f,5)+Vector2i(1,0) if bespoke else vec(f.up)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Thimble resident cord case","searched":false,"items":{"roster":1},"kind":"salvage"})
	data.thimble_state=choice;data.thimble_timer=28.0;_add_thimble(f,choice,data.farline_state);navigation_cache.erase(str(int(f.z)))

func thimble_gathered(evacuation:bool=false)->int:
	if not data.floors.has("32"):return 0
	var target:Dictionary={}
	for mark in floor_at(32).landmarks:
		if mark.get("kind","")==("thimble_evacuation" if evacuation else "thimble"):target=mark;break
	if target.is_empty():return 0
	var count=0
	for pawn in data.pawns:
		if pawn.hp>0 and not incapacitated(pawn) and int(pawn.z)==32 and point(pawn).distance_to(point(target))<=4.0:count+=1
	return count

func _complete_thimble(f:Dictionary,outcome:String,index:int):
	var bespoke=str(f.get("name",""))=="Thimble Crossing" and f.rooms.size()>=10;var reward_target=vec(f.down)
	if bespoke:
		for link in [[8,9]]:corridor(f.grid,_thimble_center(f,link[0]),_thimble_center(f,link[1]),1)
		f.down=arr(_thimble_center(f,9));reward_target=_thimble_center(f,8)+Vector2i(1,0)
	var reward_name="Thimble defender allotment" if outcome=="defended" else "Evacuated crossing stores"
	var items={"rations":4,"medkit":3,"crystal":1} if outcome=="defended" else {"scrap":6,"timber":3,"medkit":1}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.thimble_state=outcome;data.thimble_timer=0.0
	for pawn in data.pawns:
		if int(pawn.z)==32 and pawn.get("job",{}).get("kind","")=="thimble":pawn.job={}
		pawn.orders=pawn.orders.filter(func(order):return order.get("kind","")!="thimble")
	_add_thimble(f,outcome,data.farline_state);navigation_cache.erase(str(int(f.z)))
	_remember_nearby(index,"survival","Faced Thimble's surface warning with {other}.",9.0,8)

func _thimble_safe(f:Dictionary,p:Vector2i)->bool:
	if f.rooms.size()<10:return p.distance_to(vec(f.up))<=8.0
	for index in [0,1,8,9]:
		if _room_from_data(f.rooms[index]).grow(1).has_point(p):return true
	return false

func _thimble_warning(dt:float):
	if not data.thimble_state in ["defending","evacuating"] or not data.floors.has("32"):return
	data.thimble_timer=max(0.0,float(data.thimble_timer)-dt)
	if data.thimble_timer>0:return
	var f=floor_at(32);var caught:Array=[]
	for pawn in data.pawns:
		if pawn.hp<=0 or int(pawn.z)!=32 or _thimble_safe(f,point(pawn)):continue
		caught.append(str(pawn.name));_hurt_pawn(pawn,30.0)
	if str(f.get("name",""))=="Thimble Crossing" and f.rooms.size()>=10:
		corridor(f.grid,_thimble_center(f,8),_thimble_center(f,9),1);f.down=arr(_thimble_center(f,9))
	data.thimble_state="overrun";data.thimble_timer=0.0
	for pawn in data.pawns:
		if int(pawn.z)==32 and pawn.get("job",{}).get("kind","")=="thimble":pawn.job={}
		pawn.orders=pawn.orders.filter(func(order):return order.get("kind","")!="thimble")
	_add_thimble(f,"overrun",data.farline_state);navigation_cache.erase("32")
	note("Surface creatures overrun Thimble Crossing. "+("The entry and evacuation lift held." if caught.is_empty() else ", ".join(caught)+" were caught beyond the safe rooms.")+" The residents scatter, but the lower road remains reachable.")
	events.append({"kind":"thimble"})

func _latchwater_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _latchwater_route(history:String="")->String:
	var source=history if history!="" else str(data.thimble_state)
	return "resident" if source=="defended" else "refugee" if source=="evacuated" else "public"

func _add_latchwater(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Latchwater Ward" and f.rooms.size()>=10
	var route=_latchwater_route(history);var resolved=state in ["warm","cold"]
	var keeper=_latchwater_center(f,2) if bespoke else vec(f.down)
	var keeper_name="Heater Keeper Miri" if route=="resident" else "Refugee Warden Miri" if route=="refugee" else "Ward Tender Miri"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="latchwater"):
		f.landmarks.append({"x":keeper.x,"y":keeper.y,"name":keeper_name,"kind":"latchwater","state":state if state!="" else "waiting","route":route,"description":"Latchwater's shared heater is failing. Recover its physical exchanger, then choose whether to restore full warmth or keep the ward cold and hard to trace."})
	var route_target=_latchwater_center(f,4 if route=="resident" else 7 if route=="refugee" else 6) if bespoke else keeper+Vector2i(2,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="latchwater_route"):
		var route_name="Resident service gallery" if route=="resident" else "Refugee spillway" if route=="refugee" else "Public scavenger duct"
		f.landmarks.append({"x":route_target.x,"y":route_target.y,"name":route_name,"kind":"latchwater_route","state":"complete" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"Thimble's history determines who opens this heater route and what has nested inside it."})
	var option_target=_latchwater_center(f,8) if bespoke else keeper+Vector2i(0,2)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="latchwater_option"):
		f.landmarks.append({"x":option_target.x,"y":option_target.y,"name":"Latchwater heater manifold","kind":"latchwater_option","state":state if resolved else "available" if state=="assigned" else "sealed","description":"Install the recovered exchanger for full warmth and more surface pressure, or baffle it for cold shelter and a quieter heat signature."})
	var exit_target=_latchwater_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="latchwater_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Latchwater lower road","kind":"latchwater_exit","state":"open" if resolved else "sealed","description":"The independent settlement road opens after the ward makes its permanent heater choice."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="latchwater_lore"):
		var lore=_latchwater_center(f,1) if bespoke else keeper+Vector2i(0,-1)
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Shared warmth ledger","kind":"latchwater_lore","description":"Families record every heater hour beside the names of settlements that shared fuel. Thimble's newest line is written in a different hand."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"latchwater":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=keeper_name
			"latchwater_route":mark.state="complete" if resolved else "open" if state=="assigned" else "sealed";mark.route=route
			"latchwater_option":mark.state=state if resolved else "available" if state=="assigned" else "sealed"
			"latchwater_exit":mark.state="open" if resolved else "sealed"

func _open_latchwater_route(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Latchwater Ward" and f.rooms.size()>=10;var route=_latchwater_route()
	var far_index=4 if route=="resident" else 7 if route=="refugee" else 6
	if bespoke:
		var links=[[2,3],[3,4]] if route=="resident" else [[2,6],[6,7]] if route=="refugee" else [[2,3],[3,6]]
		for link in links:corridor(f.grid,_latchwater_center(f,link[0]),_latchwater_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("latchwater_guard")):
		var guard_rooms=[3,4] if route=="resident" else [7] if route=="refugee" else [3,6]
		for i in guard_rooms.size():
			var p=_latchwater_center(f,guard_rooms[i])+Vector2i(i,0);var name="Burrower" if route=="resident" else "Gloam stalker" if route=="refugee" else "Surface husk"
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":name,"hp":34.0 if name=="Gloam stalker" else 30.0,"clock":0.0,"attack":0.0,"latchwater_guard":i})
	if route=="resident" and not f.structures.any(func(s):return bool(s.get("latchwater_lamp",false))):
		for room_index in [3,4]:var lamp=make_structure("lamp",_latchwater_center(f,room_index)+Vector2i(-2,0));lamp.latchwater_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Latchwater exchanger case"):
		var target=_latchwater_center(f,far_index)+Vector2i(1,0) if bespoke else vec(f.down)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Latchwater exchanger case","searched":false,"items":{"exchanger":1},"kind":"salvage"})
	data.latchwater_state="assigned";_add_latchwater(f,"assigned",data.thimble_state);navigation_cache.erase(str(int(f.z)))

func _complete_latchwater(f:Dictionary,outcome:String,index:int):
	var bespoke=str(f.get("name",""))=="Latchwater Ward" and f.rooms.size()>=10;var reward_target=vec(f.down)
	if bespoke:
		for link in [[2,5],[5,8],[8,9]]:corridor(f.grid,_latchwater_center(f,link[0]),_latchwater_center(f,link[1]),1)
		f.down=arr(_latchwater_center(f,9));reward_target=_latchwater_center(f,8)+Vector2i(1,0)
	var reward_name="Latchwater warm allotment" if outcome=="warm" else "Latchwater cold stores"
	var items={"rations":4,"medkit":2} if outcome=="warm" else {"scrap":5,"timber":3,"crystal":1}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.latchwater_state=outcome;_add_latchwater(f,outcome,data.thimble_state);navigation_cache.erase(str(int(f.z)))
	_remember_nearby(index,"discovery","Set Latchwater's shared heater with {other}.",9.0,8)

func latchwater_landmark()->Dictionary:
	if not data.floors.has("33"):return {}
	for mark in floor_at(33).landmarks:
		if mark.get("kind","")=="latchwater":return mark
	return {}

func order_latchwater(index:int,action:String,queued:bool=false)->String:
	var mark=latchwater_landmark()
	if mark.is_empty():return "Latchwater Ward is not reachable."
	return enqueue_order(index,"latchwater",point(mark),{"action":action}) if queued else issue(index,"latchwater",point(mark),{"action":action})

func _driftglass_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _driftglass_route(history:String="")->String:
	var source=history if history!="" else str(data.latchwater_state)
	return "powered" if source=="warm" else "shaded"

func _add_driftglass(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Driftglass Hall" and f.rooms.size()>=10
	var route=_driftglass_route(history);var resolved=state in ["powered","shaded"]
	var keeper=_driftglass_center(f,2) if bespoke else vec(f.down)
	var keeper_name="Glasswright Sela" if route=="powered" else "Shade Keeper Sela"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="driftglass"):
		f.landmarks.append({"x":keeper.x,"y":keeper.y,"name":keeper_name,"kind":"driftglass","state":state if state!="" else "waiting","route":route,"description":"Driftglass Hall's buried seam needs one physical focusing prism. Recover it, then decide whether to power the excavation or preserve a dark stealth road."})
	var route_target=_driftglass_center(f,4 if route=="powered" else 7) if bespoke else keeper+Vector2i(2,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="driftglass_route"):
		var route_name="Heated cutting gallery" if route=="powered" else "Cold mirror seam"
		f.landmarks.append({"x":route_target.x,"y":route_target.y,"name":route_name,"kind":"driftglass_route","state":"complete" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"Latchwater's heater choice determines whether the excavation starts brightly powered or cold and unlit."})
	var option_target=_driftglass_center(f,8) if bespoke else keeper+Vector2i(0,2)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="driftglass_option"):
		f.landmarks.append({"x":option_target.x,"y":option_target.y,"name":"Driftglass lens cradle","kind":"driftglass_option","state":state if resolved else "available" if state=="assigned" else "sealed","description":"Focus the recovered prism into powered cutters for rich material and practiced building, or shade it to keep the lower road dark and quiet."})
	var exit_target=_driftglass_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="driftglass_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Driftglass lower seam","kind":"driftglass_exit","state":"open" if resolved else "sealed","description":"The independent route continues after the hall commits its recovered prism."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="driftglass_lore"):
		var lore=_driftglass_center(f,1) if bespoke else keeper+Vector2i(0,-1)
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Black-glass witness wall","kind":"driftglass_lore","description":"Polished shards record every lamp lit beneath the hostile surface. Dark shards mark expeditions that passed without being followed."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"driftglass":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=keeper_name
			"driftglass_route":mark.state="complete" if resolved else "open" if state=="assigned" else "sealed";mark.route=route
			"driftglass_option":mark.state=state if resolved else "available" if state=="assigned" else "sealed"
			"driftglass_exit":mark.state="open" if resolved else "sealed"

func _open_driftglass_route(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Driftglass Hall" and f.rooms.size()>=10;var route=_driftglass_route()
	var far_index=4 if route=="powered" else 7
	if bespoke:
		var links=[[2,3],[3,4]] if route=="powered" else [[2,6],[6,7]]
		for link in links:corridor(f.grid,_driftglass_center(f,link[0]),_driftglass_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("driftglass_guard")):
		var guard_rooms=[3,4] if route=="powered" else [7]
		for i in guard_rooms.size():
			var p=_driftglass_center(f,guard_rooms[i])+Vector2i(i,0)
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":"Gloam stalker","hp":34.0,"clock":0.0,"attack":0.0,"driftglass_guard":i})
	if route=="powered" and not f.structures.any(func(s):return bool(s.get("driftglass_lamp",false))):
		for room_index in [3,4]:var lamp=make_structure("lamp",_driftglass_center(f,room_index)+Vector2i(-2,0));lamp.driftglass_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Driftglass prism casket"):
		var target=_driftglass_center(f,far_index)+Vector2i(1,0) if bespoke else vec(f.down)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Driftglass prism casket","searched":false,"items":{"prism":1},"kind":"salvage"})
	data.driftglass_state="assigned";_add_driftglass(f,"assigned",data.latchwater_state);navigation_cache.erase(str(int(f.z)))

func _complete_driftglass(f:Dictionary,outcome:String,index:int):
	var bespoke=str(f.get("name",""))=="Driftglass Hall" and f.rooms.size()>=10;var reward_target=vec(f.down)
	if bespoke:
		for link in [[2,5],[5,8],[8,9]]:corridor(f.grid,_driftglass_center(f,link[0]),_driftglass_center(f,link[1]),1)
		f.down=arr(_driftglass_center(f,9));reward_target=_driftglass_center(f,8)+Vector2i(1,0)
	var reward_name="Driftglass powered cuttings" if outcome=="powered" else "Driftglass shaded provisions"
	var items={"scrap":6,"crystal":3} if outcome=="powered" else {"rations":4,"medkit":2,"timber":2}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	if outcome=="powered":
		data.pawns[index].skills.build=int(data.pawns[index].skills.build)+2
		if not f.structures.any(func(s):return bool(s.get("driftglass_power_lamp",false))):
			for room_index in [5,8,9]:var lamp=make_structure("lamp",_driftglass_center(f,room_index)+Vector2i(-2,0));lamp.driftglass_power_lamp=true;f.structures.append(lamp)
		if not f.enemies.any(func(enemy):return enemy.has("driftglass_awakened")):
			for i in 2:
				var p=_driftglass_center(f,8+i)+Vector2i(i,0)
				f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":"Gloam stalker","hp":34.0,"clock":0.0,"attack":0.0,"driftglass_awakened":i})
	data.driftglass_state=outcome;_add_driftglass(f,outcome,data.latchwater_state);navigation_cache.erase(str(int(f.z)))
	_remember_nearby(index,"discovery","Set Driftglass Hall's lens with {other}.",9.0,8)

func driftglass_landmark()->Dictionary:
	if not data.floors.has("34"):return {}
	for mark in floor_at(34).landmarks:
		if mark.get("kind","")=="driftglass":return mark
	return {}

func order_driftglass(index:int,action:String,queued:bool=false)->String:
	var mark=driftglass_landmark()
	if mark.is_empty():return "Driftglass Hall is not reachable."
	return enqueue_order(index,"driftglass",point(mark),{"action":action}) if queued else issue(index,"driftglass",point(mark),{"action":action})

func _bellhome_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _bellhome_route(history:String="")->String:
	var source=history if history!="" else str(data.driftglass_state)
	return "lampline" if source=="powered" else "darkway"

func _add_bellhome(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Bellhome Gate" and f.rooms.size()>=10
	var route=_bellhome_route(history);var resolved=state in ["escorted","diverted","retreated"]
	var gate=_bellhome_center(f,2) if bespoke else vec(f.down)
	var gate_name="Lamp Warden Orra" if route=="lampline" else "Darkroad Warden Orra"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="bellhome"):
		f.landmarks.append({"x":gate.x,"y":gate.y,"name":gate_name,"kind":"bellhome","state":state if state!="" else "waiting","route":route,"description":"Bellhome is the next independent settlement beyond the glass roads. Its supply convoy will move only after the expedition answers a visible route warning."})
	var route_target=_bellhome_center(f,4 if route=="lampline" else 7) if bespoke else gate+Vector2i(2,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="bellhome_route"):
		f.landmarks.append({"x":route_target.x,"y":route_target.y,"name":"Lit cutter approach" if route=="lampline" else "Unlit glass approach","kind":"bellhome_route","state":"safe" if resolved else "warning" if state=="warning" else "sealed","route":route,"description":"Powered Driftglass sends a bright freight column that draws three surface husks. Shaded Driftglass hides the convoy from the surface but leaves two Gloam stalkers in its dark approach."})
	var convoy=_bellhome_center(f,5) if bespoke else gate+Vector2i(0,2)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="bellhome_convoy"):
		f.landmarks.append({"x":convoy.x,"y":convoy.y,"name":"Bellhome convoy muster","kind":"bellhome_convoy","state":"arrived" if state=="escorted" else "diverted" if state=="diverted" else "withdrawn" if state=="retreated" else "ready" if state=="warning" else "sealed","description":"A carried convoy charter, a secure approach and two gathered colonists can escort the freight through before the warning expires."})
	var diversion=_bellhome_center(f,8) if bespoke else convoy+Vector2i(0,2)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="bellhome_diversion"):
		f.landmarks.append({"x":diversion.x,"y":diversion.y,"name":"Bellhome diversion culvert","kind":"bellhome_diversion","state":"open" if state=="diverted" else "closed" if resolved else "available" if state=="warning" else "sealed","description":"Two timber, two scrap, the physical charter and two gathered colonists can divert the convoy through a closable culvert without defeating the approach threats."})
	var exit_target=_bellhome_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="bellhome_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Bellhome settlement road","kind":"bellhome_exit","state":"open" if resolved else "sealed","description":"Bellhome's road opens after the convoy is escorted, diverted or forced to retreat. A missed warning changes settlement trust but never blocks the descent."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="bellhome_lore"):
		var lore=_bellhome_center(f,1) if bespoke else gate+Vector2i(0,-1)
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Road-bell covenant","kind":"bellhome_lore","description":"Each convoy bell names the settlement that last sheltered it. Driftglass appears twice: once etched in bright brass, once wrapped in black cloth."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"bellhome":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=gate_name
			"bellhome_route":mark.state="safe" if resolved else "warning" if state=="warning" else "sealed";mark.route=route
			"bellhome_convoy":mark.state="arrived" if state=="escorted" else "diverted" if state=="diverted" else "withdrawn" if state=="retreated" else "ready" if state=="warning" else "sealed"
			"bellhome_diversion":mark.state="open" if state=="diverted" else "closed" if resolved else "available" if state=="warning" else "sealed"
			"bellhome_exit":mark.state="open" if resolved else "sealed"

func _open_bellhome_warning(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Bellhome Gate" and f.rooms.size()>=10;var route=_bellhome_route()
	if bespoke:
		var approach_links=[[2,3],[3,4]] if route=="lampline" else [[2,6],[6,7]]
		for link in approach_links:corridor(f.grid,_bellhome_center(f,link[0]),_bellhome_center(f,link[1]),1)
		for link in [[2,5],[5,8]]:corridor(f.grid,_bellhome_center(f,link[0]),_bellhome_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("bellhome_guard")):
		var guard_rooms=[3,4,4] if route=="lampline" else [6,7]
		for i in guard_rooms.size():
			var p=_bellhome_center(f,guard_rooms[i])+Vector2i(i-1 if route=="lampline" else i,0);var enemy_name="Surface husk" if route=="lampline" else "Gloam stalker"
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":enemy_name,"hp":30.0 if route=="lampline" else 34.0,"clock":0.0,"attack":0.0,"bellhome_guard":i})
	if route=="lampline" and not f.structures.any(func(s):return bool(s.get("bellhome_lamp",false))):
		for room_index in [3,4,5]:var lamp=make_structure("lamp",_bellhome_center(f,room_index)+Vector2i(-2,0));lamp.bellhome_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Bellhome charter case"):
		var target=_bellhome_center(f,5)+Vector2i(1,0) if bespoke else vec(f.up)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Bellhome charter case","searched":false,"items":{"charter":1},"kind":"salvage"})
	data.bellhome_state="warning";data.bellhome_timer=32.0;_add_bellhome(f,"warning",data.driftglass_state);navigation_cache.erase(str(int(f.z)))

func bellhome_gathered(diversion:bool=false)->int:
	if not data.floors.has("35"):return 0
	var target:Dictionary={}
	for mark in floor_at(35).landmarks:
		if mark.get("kind","")==("bellhome_diversion" if diversion else "bellhome_convoy"):target=mark;break
	if target.is_empty():return 0
	var count=0
	for pawn in data.pawns:
		if pawn.hp>0 and not incapacitated(pawn) and int(pawn.z)==35 and point(pawn).distance_to(point(target))<=4.0:count+=1
	return count

func _complete_bellhome(f:Dictionary,outcome:String,index:int):
	var bespoke=str(f.get("name",""))=="Bellhome Gate" and f.rooms.size()>=10;var reward_target=vec(f.down)
	if bespoke:
		corridor(f.grid,_bellhome_center(f,8),_bellhome_center(f,9),1);f.down=arr(_bellhome_center(f,9));reward_target=_bellhome_center(f,8)+Vector2i(1,0)
	if outcome=="diverted":f.enemies=f.enemies.filter(func(enemy):return not enemy.has("bellhome_guard"))
	if outcome!="retreated":
		var reward_name="Bellhome convoy freight" if outcome=="escorted" else "Bellhome culvert stores"
		var items=({"scrap":5,"crystal":2,"rations":2} if _bellhome_route()=="lampline" else {"rations":4,"medkit":2,"timber":2}) if outcome=="escorted" else {"scrap":4,"timber":2,"medkit":1}
		if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.bellhome_state=outcome;data.bellhome_timer=0.0
	for pawn in data.pawns:
		if int(pawn.z)==35 and pawn.get("job",{}).get("kind","")=="bellhome":pawn.job={}
		pawn.orders=pawn.orders.filter(func(order):return order.get("kind","")!="bellhome")
	_add_bellhome(f,outcome,data.driftglass_state);navigation_cache.erase(str(int(f.z)))
	if index>=0:_remember_nearby(index,"survival","Saw Bellhome's convoy through with {other}.",9.0,8)

func _bellhome_safe(f:Dictionary,p:Vector2i)->bool:
	if f.rooms.size()<10:return p.distance_to(vec(f.up))<=8.0
	for index in [0,1,8,9]:
		if _room_from_data(f.rooms[index]).grow(1).has_point(p):return true
	return false

func _bellhome_warning(dt:float):
	if data.bellhome_state!="warning" or not data.floors.has("35"):return
	data.bellhome_timer=max(0.0,float(data.bellhome_timer)-dt)
	if data.bellhome_timer>0:return
	var f=floor_at(35);var caught:Array=[]
	for pawn in data.pawns:
		if pawn.hp<=0 or int(pawn.z)!=35 or _bellhome_safe(f,point(pawn)):continue
		caught.append(str(pawn.name));_hurt_pawn(pawn,25.0)
	_complete_bellhome(f,"retreated",-1)
	note("Bellhome's convoy withdraws behind the inner gate. "+("The marked safe rooms held." if caught.is_empty() else ", ".join(caught)+" were caught outside the gate.")+" The settlement road remains open, but no convoy benefit was earned.")
	events.append({"kind":"bellhome"})

func bellhome_landmark()->Dictionary:
	if not data.floors.has("35"):return {}
	for mark in floor_at(35).landmarks:
		if mark.get("kind","")=="bellhome":return mark
	return {}

func order_bellhome(index:int,action:String,queued:bool=false)->String:
	var mark=bellhome_landmark()
	if mark.is_empty():return "Bellhome Gate is not reachable."
	var target=point(mark)
	if action in ["escort","divert"]:
		for candidate in floor_at(35).landmarks:
			if candidate.get("kind","")==(("bellhome_diversion") if action=="divert" else "bellhome_convoy"):target=point(candidate);break
	return enqueue_order(index,"bellhome",target,{"action":action}) if queued else issue(index,"bellhome",target,{"action":action})

func _commons_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _commons_route(history:String="")->String:
	var source=history if history!="" else str(data.bellhome_state)
	return "resident" if source=="escorted" else "culvert" if source=="diverted" else "public"

func _commons_cost(route:String="")->Dictionary:
	var chosen=route if route!="" else _commons_route()
	return {"timber":3,"scrap":2} if chosen=="resident" else {"timber":2,"scrap":3} if chosen=="culvert" else {"timber":4,"scrap":2}

func _add_commons(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Bellhome Commons" and f.rooms.size()>=10
	var route=_commons_route(history);var resolved=state in ["resident","culvert","public"]
	var steward=_commons_center(f,2) if bespoke else vec(f.down)
	var steward_name="Steward Orra" if route=="resident" else "Culvert Keeper Orra" if route=="culvert" else "Commons Tender Orra"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="commons"):
		f.landmarks.append({"x":steward.x,"y":steward.y,"name":steward_name,"kind":"commons","state":state if state!="" else "waiting","route":route,"description":"Bellhome's convoy history decides who receives the expedition. Recover the settlement's heavy wall brace and contribute exact materials to stabilize the inhabited homes."})
	var route_target=_commons_center(f,4 if route=="resident" else 7 if route=="culvert" else 6) if bespoke else steward+Vector2i(2,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="commons_route"):
		var route_name="Resident roof court" if route=="resident" else "Quiet culvert row" if route=="culvert" else "Shuttered public ward"
		f.landmarks.append({"x":route_target.x,"y":route_target.y,"name":route_name,"kind":"commons_route","state":"repaired" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"The convoy outcome changes Bellhome's welcome, threats, lighting, repair terms and lasting settlement benefit."})
	var repair=_commons_center(f,8) if bespoke else steward+Vector2i(0,2)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="commons_repair"):
		f.landmarks.append({"x":repair.x,"y":repair.y,"name":"Bellhome housing frame","kind":"commons_repair","state":"complete" if resolved else "available" if state=="assigned" else "sealed","description":"Install the physical four-kilogram wall brace with the route's exact timber and scrap contribution."})
	var exit_target=_commons_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="commons_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Bellhome lower dwellings","kind":"commons_exit","state":"open" if resolved else "sealed","description":"The lower settlement road opens after the occupied homes are made safe."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="commons_lore"):
		var lore=_commons_center(f,1) if bespoke else steward+Vector2i(0,-1)
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Brace-name lintel","kind":"commons_lore","description":"Every salvaged brace bears the name of the home it once held. Bellhome refuses to grind the names away before using them again."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"commons":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=steward_name
			"commons_route":mark.state="repaired" if resolved else "open" if state=="assigned" else "sealed";mark.route=route
			"commons_repair":mark.state="complete" if resolved else "available" if state=="assigned" else "sealed"
			"commons_exit":mark.state="open" if resolved else "sealed"

func _open_commons_route(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Bellhome Commons" and f.rooms.size()>=10;var route=_commons_route()
	var far_index=4 if route=="resident" else 7 if route=="culvert" else 6
	if bespoke:
		var links=[[2,3],[3,4]] if route=="resident" else [[2,6],[6,7]] if route=="culvert" else [[2,3],[3,6]]
		for link in links:corridor(f.grid,_commons_center(f,link[0]),_commons_center(f,link[1]),1)
		# The occupied route must reach the housing frame before it can be repaired;
		# only the final lower-dwellings road remains sealed until completion.
		for link in [[far_index,5],[5,8]]:corridor(f.grid,_commons_center(f,link[0]),_commons_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("commons_guard")):
		var guard_rooms=[4] if route=="resident" else [7] if route=="culvert" else [3,6]
		for i in guard_rooms.size():
			var p=_commons_center(f,guard_rooms[i])+Vector2i(i,0);var name="Burrower" if route=="resident" else "Gloam stalker" if route=="culvert" else "Surface husk"
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":name,"hp":34.0 if name=="Gloam stalker" else 30.0,"clock":0.0,"attack":0.0,"commons_guard":i})
	if route=="resident" and not f.structures.any(func(s):return bool(s.get("commons_lamp",false))):
		for room_index in [3,4]:var lamp=make_structure("lamp",_commons_center(f,room_index)+Vector2i(-2,0));lamp.commons_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Bellhome brace cradle"):
		var target=_commons_center(f,far_index)+Vector2i(1,0) if bespoke else vec(f.down)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Bellhome brace cradle","searched":false,"items":{"brace":1},"kind":"salvage"})
	data.commons_state="assigned";_add_commons(f,"assigned",data.bellhome_state);navigation_cache.erase(str(int(f.z)))

func _complete_commons(f:Dictionary,outcome:String,index:int):
	var bespoke=str(f.get("name",""))=="Bellhome Commons" and f.rooms.size()>=10;var reward_target=vec(f.down)
	if bespoke:
		for link in [[2,5],[5,8],[8,9]]:corridor(f.grid,_commons_center(f,link[0]),_commons_center(f,link[1]),1)
		f.down=arr(_commons_center(f,9));reward_target=_commons_center(f,8)+Vector2i(1,0)
	var reward_name="Bellhome resident allotment" if outcome=="resident" else "Bellhome culvert surplus" if outcome=="culvert" else "Bellhome public stores"
	var items={"rations":5,"medkit":3,"timber":1} if outcome=="resident" else {"scrap":6,"crystal":2,"medkit":1} if outcome=="culvert" else {"rations":3,"medkit":2,"scrap":3,"timber":2}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.commons_state=outcome;_add_commons(f,outcome,data.bellhome_state);navigation_cache.erase(str(int(f.z)))
	_remember_nearby(index,"building","Repaired Bellhome's occupied homes with {other}.",9.0,8)

func commons_landmark()->Dictionary:
	if not data.floors.has("36"):return {}
	for mark in floor_at(36).landmarks:
		if mark.get("kind","")=="commons":return mark
	return {}

func order_commons(index:int,action:String,queued:bool=false)->String:
	var mark=commons_landmark()
	if mark.is_empty():return "Bellhome Commons is not reachable."
	var target=point(mark)
	if action=="finish":
		for candidate in floor_at(36).landmarks:
			if candidate.get("kind","")=="commons_repair":target=point(candidate);break
	return enqueue_order(index,"commons",target,{"action":action}) if queued else issue(index,"commons",target,{"action":action})

func _yard_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _yard_route(history:String="")->String:
	var source=history if history!="" else str(data.commons_state)
	return source if source in ["resident","culvert","public"] else "public"

func _add_yard(f:Dictionary,state:String,history:String="",joined:bool=false):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Hearthline Yard" and f.rooms.size()>=10
	var route=_yard_route(history);var resolved=state in ["resident","culvert","public"]
	var yardmaster=_yard_center(f,2) if bespoke else vec(f.down)
	var yard_name="Resident Yardmaster Sori" if route=="resident" else "Culvert Yardmaster Sori" if route=="culvert" else "Public Yardmaster Sori"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="yard"):
		f.landmarks.append({"x":yardmaster.x,"y":yardmaster.y,"name":yard_name,"kind":"yard","state":state if state!="" else "waiting","route":route,"description":"Bellhome's repaired homes decide which Hearthline crew answers. Reopening the communal lower line needs two seven-kilogram mechanisms carried in separate packs, Pell, and three gathered colonists."})
	var core_target=_yard_center(f,4 if route=="resident" else 6 if route=="public" else 7) if bespoke else yardmaster+Vector2i(2,0)
	var winch_target=_yard_center(f,7 if route=="culvert" else 4 if route=="public" else 6) if bespoke else yardmaster+Vector2i(-2,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="yard_lane" and mark.get("cargo","")=="hearth_core"):
		f.landmarks.append({"x":core_target.x,"y":core_target.y,"name":"Thermal-core lane","kind":"yard_lane","cargo":"hearth_core","state":"recovered" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"A seven-kilogram thermal core waits beyond the route-shaped yard threat. It cannot share a standard pack with the lift winch."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="yard_lane" and mark.get("cargo","")=="yard_winch"):
		f.landmarks.append({"x":winch_target.x,"y":winch_target.y,"name":"Lift-winch lane","kind":"yard_lane","cargo":"yard_winch","state":"recovered" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"A seven-kilogram lift winch must reach the gantry in a second colonist's physical pack."})
	var gantry=_yard_center(f,8) if bespoke else yardmaster+Vector2i(0,3)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="yard_gantry"):
		f.landmarks.append({"x":gantry.x,"y":gantry.y,"name":"Hearthline expansion gantry","kind":"yard_gantry","state":"complete" if resolved else "ready" if state=="assigned" else "sealed","description":"Install the thermal core and winch from two separate packs while Pell and three living colonists are gathered here."})
	if not joined and not resolved and not f.landmarks.any(func(mark):return mark.get("kind","")=="yard_recruit"):
		var recruit_target=_yard_center(f,5) if bespoke else yardmaster+Vector2i(0,1)
		f.landmarks.append({"x":recruit_target.x,"y":recruit_target.y,"name":"Pell","kind":"yard_recruit","state":"waiting","route":route,"description":"A Hearthline specialist who joins when the expansion is accepted. Pell keeps a separate physical pack and route-shaped practiced skills."})
	var exit_target=_yard_center(f,9) if bespoke else vec(f.down)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="yard_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Hearthline lower line","kind":"yard_exit","state":"open" if resolved else "sealed","description":"The independent settlement network continues below once its communal lift is working."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="yard_lore"):
		var lore=_yard_center(f,1) if bespoke else yardmaster+Vector2i(0,-1)
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Shared-load tally","kind":"yard_lore","description":"The oldest marks assign every heavy lift to two names. Hearthline measures a settlement by whether anyone answers the second line."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"yard":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=yard_name
			"yard_lane":mark.state="recovered" if resolved else "open" if state=="assigned" else "sealed";mark.route=route
			"yard_gantry":mark.state="complete" if resolved else "ready" if state=="assigned" else "sealed"
			"yard_exit":mark.state="open" if resolved else "sealed"

func _pell_index()->int:
	for i in data.pawns.size():
		if data.pawns[i].name=="Pell" and data.pawns[i].hp>0:return i
	return -1

func yard_gantry()->Dictionary:
	if not data.floors.has("37"):return {}
	for mark in floor_at(37).landmarks:
		if mark.get("kind","")=="yard_gantry":return mark
	return {}

func yard_gathered()->int:
	var gantry=yard_gantry()
	if gantry.is_empty():return 0
	var total=0
	for pawn in data.pawns:
		if pawn.hp>0 and not incapacitated(pawn) and int(pawn.z)==37 and point(pawn).distance_to(point(gantry))<=4.0:total+=1
	return total

func _yard_carriers(target:Vector2i)->Array:
	var cores:Array=[];var winches:Array=[]
	for i in data.pawns.size():
		var pawn=data.pawns[i]
		if pawn.hp<=0 or incapacitated(pawn) or int(pawn.z)!=37 or point(pawn).distance_to(target)>4.0:continue
		if int(pawn.inventory.get("hearth_core",0))>0:cores.append(i)
		if int(pawn.inventory.get("yard_winch",0))>0:winches.append(i)
	for core_index in cores:
		for winch_index in winches:
			if core_index!=winch_index:return [core_index,winch_index]
	return []

func _open_yard(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Hearthline Yard" and f.rooms.size()>=10;var route=_yard_route()
	if bespoke:
		for link in [[2,3],[3,4],[2,6],[6,7],[4,5],[7,5],[5,8]]:corridor(f.grid,_yard_center(f,link[0]),_yard_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("yard_guard")):
		var guard_rooms=[4] if route=="resident" else [7] if route=="culvert" else [4,7]
		for i in guard_rooms.size():
			var p=_yard_center(f,guard_rooms[i]);var name="Burrower" if route=="resident" or route=="public" and i==0 else "Gloam stalker"
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":name,"hp":34.0 if name=="Gloam stalker" else 30.0,"clock":0.0,"attack":0.0,"yard_guard":i})
	if route=="resident" and not f.structures.any(func(s):return bool(s.get("yard_lamp",false))):
		for room_index in [3,4]:var lamp=make_structure("lamp",_yard_center(f,room_index)+Vector2i(-2,0));lamp.yard_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Hearthline core cradle"):
		var core_target=_yard_center(f,4 if route=="resident" else 6 if route=="public" else 7)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":core_target.x,"y":core_target.y,"name":"Hearthline core cradle","searched":false,"items":{"hearth_core":1},"kind":"salvage"})
	if not f.containers.any(func(c):return c.get("name","")=="Hearthline winch cage"):
		var winch_target=_yard_center(f,7 if route=="culvert" else 4 if route=="public" else 6)+Vector2i(-1,0)
		f.containers.append({"id":next_id(),"x":winch_target.x,"y":winch_target.y,"name":"Hearthline winch cage","searched":false,"items":{"yard_winch":1},"kind":"salvage"})
	if not data.yard_recruit_joined:
		data.yard_recruit_joined=true
		var recruit_target=_yard_center(f,5);var recruit=make_pawn("Pell",recruit_target.x,recruit_target.y,"copper");recruit.z=37
		if route=="resident":recruit.skills={"scavenge":4,"build":1,"combat":1};recruit.inventory={"rations":2,"medkit":1}
		elif route=="culvert":recruit.skills={"scavenge":1,"build":4,"combat":1};recruit.inventory={"timber":2,"scrap":2}
		else:recruit.skills={"scavenge":2,"build":2,"combat":2};recruit.inventory={"rations":1,"medkit":1,"scrap":1}
		data.pawns.append(recruit)
	f.landmarks=f.landmarks.filter(func(mark):return mark.get("kind","")!="yard_recruit")
	data.yard_state="assigned";_add_yard(f,"assigned",data.commons_state,true);navigation_cache.erase(str(int(f.z)))

func _complete_yard(f:Dictionary,outcome:String,index:int):
	var bespoke=str(f.get("name",""))=="Hearthline Yard" and f.rooms.size()>=10;var reward_target=vec(f.down)
	if bespoke:
		corridor(f.grid,_yard_center(f,8),_yard_center(f,9),1);f.down=arr(_yard_center(f,9));reward_target=_yard_center(f,8)+Vector2i(1,0)
	var reward_name="Hearthline resident issue" if outcome=="resident" else "Hearthline culvert freight" if outcome=="culvert" else "Hearthline public stores"
	var items={"rations":5,"medkit":3,"timber":2} if outcome=="resident" else {"scrap":7,"crystal":3,"medkit":1} if outcome=="culvert" else {"rations":3,"medkit":2,"scrap":4,"timber":2}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.yard_state=outcome;_add_yard(f,outcome,data.commons_state,true);navigation_cache.erase(str(int(f.z)))
	_remember_nearby(index,"building","Reopened Hearthline's communal lower line with {other}.",10.0,9)

func yard_landmark()->Dictionary:
	if not data.floors.has("37"):return {}
	for mark in floor_at(37).landmarks:
		if mark.get("kind","")=="yard":return mark
	return {}

func order_yard(index:int,action:String,queued:bool=false)->String:
	var mark=yard_landmark()
	if mark.is_empty():return "Hearthline Yard is not reachable."
	var target=point(mark)
	if action=="finish":
		var gantry=yard_gantry()
		if not gantry.is_empty():target=point(gantry)
	return enqueue_order(index,"yard",target,{"action":action}) if queued else issue(index,"yard",target,{"action":action})

func _kiln_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _kiln_route(history:String="")->String:
	var source=history if history!="" else str(data.yard_state)
	return "forage" if source=="resident" else "works" if source=="culvert" else "shared"

func _kiln_cost(action:String,history:String="")->Dictionary:
	var route=_kiln_route(history)
	if action=="build":return {"scrap":3,"timber":2} if route=="works" else {"scrap":4,"timber":2} if route=="forage" else {"scrap":4,"timber":3}
	return {"timber":2,"scrap":2} if route=="forage" else {"timber":3,"scrap":2} if route=="works" else {"timber":3,"scrap":3}

func _add_kiln(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Kilnreach Works" and f.rooms.size()>=10
	var route=_kiln_route(history);var resolved=state in ["built","concealed"]
	var console=_kiln_center(f,2) if bespoke else vec(f.down)
	var route_target=_kiln_center(f,4 if route=="forage" else 7 if route=="works" else 6) if bespoke else console+Vector2i(2,0)
	var option_target=_kiln_center(f,8) if bespoke else console+Vector2i(0,3)
	var exit_target=_kiln_center(f,9) if bespoke else vec(f.down)
	var lore=_kiln_center(f,1) if bespoke else console+Vector2i(0,-1)
	# Bespoke objectives own their room centers. Remove ambient landmarks that
	# procedural dressing may have placed there so touch selection is unambiguous.
	var reserved=[console,route_target,option_target,exit_target,lore]
	f.landmarks=f.landmarks.filter(func(mark):return str(mark.get("kind","")).begins_with("kiln") or not reserved.has(point(mark)))
	var console_name="Kilnreach Salvage Console" if route=="forage" else "Kilnreach Works Console" if route=="works" else "Kilnreach Shared Console"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="kiln"):
		f.landmarks.append({"x":console.x,"y":console.y,"name":console_name,"kind":"kiln","state":state if state!="" else "waiting","route":route,"description":"Pell can read the abandoned heatworks through the specialty learned at Hearthline. Survey the route, recover its physical ignition spindle, then rebuild the kiln or conceal its heat."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="kiln_route"):
		var route_name="Lit slag gallery" if route=="forage" else "Dark builder flue" if route=="works" else "Split communal works"
		f.landmarks.append({"x":route_target.x,"y":route_target.y,"name":route_name,"kind":"kiln_route","state":"complete" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"Hearthline's expansion and Pell's practiced specialty determine the salvage lane, light and resident threats."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="kiln_option"):
		f.landmarks.append({"x":option_target.x,"y":option_target.y,"name":"Kilnreach furnace crown","kind":"kiln_option","state":state if resolved else "available" if state=="assigned" else "sealed","description":"Install the spindle with exact materials to rebuild a productive but traceable kiln, or conceal its flues for supplies and strong pressure shelter."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="kiln_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Kilnreach lower tram","kind":"kiln_exit","state":"open" if resolved else "sealed","description":"The lower tram continues once Kilnreach's furnace crown has been committed."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="kiln_lore"):
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Cold-shift tablets","kind":"kiln_lore","description":"Every old shift ends with the same warning: a hot chimney feeds the settlement and tells the surface exactly where to dig."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"kiln":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=console_name
			"kiln_route":mark.state="complete" if resolved else "open" if state=="assigned" else "sealed";mark.route=route
			"kiln_option":mark.state=state if resolved else "available" if state=="assigned" else "sealed"
			"kiln_exit":mark.state="open" if resolved else "sealed"

func _open_kiln(f:Dictionary):
	var bespoke=str(f.get("name",""))=="Kilnreach Works" and f.rooms.size()>=10;var route=_kiln_route()
	if bespoke:
		var links=[[2,3],[3,4],[4,5]] if route=="forage" else [[2,6],[6,7],[7,5]] if route=="works" else [[2,3],[3,4],[2,6],[6,7],[4,5],[7,5]]
		for link in links:corridor(f.grid,_kiln_center(f,link[0]),_kiln_center(f,link[1]),1)
		corridor(f.grid,_kiln_center(f,5),_kiln_center(f,8),1)
	if not f.enemies.any(func(enemy):return enemy.has("kiln_guard")):
		var guard_rooms=[3,4] if route=="forage" else [7] if route=="works" else [4,7]
		for i in guard_rooms.size():
			var p=_kiln_center(f,guard_rooms[i]);var name="Burrower" if route=="forage" or route=="shared" and i==0 else "Gloam stalker"
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":name,"hp":34.0 if name=="Gloam stalker" else 30.0,"clock":0.0,"attack":0.0,"kiln_guard":i})
	if route=="forage" and not f.structures.any(func(s):return bool(s.get("kiln_route_lamp",false))):
		for room_index in [3,4]:var lamp=make_structure("lamp",_kiln_center(f,room_index)+Vector2i(-2,0));lamp.kiln_route_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Kilnreach spindle vault"):
		var spindle_room=4 if route=="forage" else 7 if route=="works" else 6
		var target=_kiln_center(f,spindle_room)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Kilnreach spindle vault","searched":false,"items":{"kiln_igniter":1},"kind":"salvage"})
	data.kiln_state="assigned";_add_kiln(f,"assigned",data.yard_state);navigation_cache.erase(str(int(f.z)))

func _complete_kiln(f:Dictionary,outcome:String,index:int):
	var bespoke=str(f.get("name",""))=="Kilnreach Works" and f.rooms.size()>=10;var reward_target=vec(f.down);var route=_kiln_route()
	if bespoke:
		for link in [[5,8],[8,9]]:corridor(f.grid,_kiln_center(f,link[0]),_kiln_center(f,link[1]),1)
		f.down=arr(_kiln_center(f,9));reward_target=_kiln_center(f,8)+Vector2i(1,0)
	var reward_name="Kilnreach fired ingots" if outcome=="built" else "Kilnreach hidden stores"
	var items={"scrap":7,"crystal":4} if outcome=="built" and route=="works" else {"scrap":6,"crystal":3} if outcome=="built" and route=="forage" else {"scrap":6,"crystal":3,"timber":2} if outcome=="built" else {"rations":5,"medkit":2} if route=="forage" else {"rations":4,"medkit":2,"timber":2} if route=="works" else {"rations":4,"medkit":2,"scrap":2}
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":reward_target.x,"y":reward_target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	if outcome=="built":
		var pell_index=_pell_index()
		if pell_index>=0:data.pawns[pell_index].skills.build=int(data.pawns[pell_index].skills.build)+2
		if not f.structures.any(func(s):return bool(s.get("kiln_power_lamp",false))):
			for room_index in [5,8,9]:var lamp=make_structure("lamp",_kiln_center(f,room_index)+Vector2i(-2,0));lamp.kiln_power_lamp=true;f.structures.append(lamp)
		if not f.enemies.any(func(enemy):return enemy.has("kiln_awakened")):
			for i in 2:
				var p=_kiln_center(f,8+i)+Vector2i(i,0)
				f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":"Surface husk","hp":42.0,"clock":0.0,"attack":0.0,"kiln_awakened":i})
	data.kiln_state=outcome;_add_kiln(f,outcome,data.yard_state);navigation_cache.erase(str(int(f.z)))
	_remember_nearby(index,"building","Committed Kilnreach's furnace crown with {other}.",10.0,9)

func kiln_landmark()->Dictionary:
	if not data.floors.has("38"):return {}
	for mark in floor_at(38).landmarks:
		if mark.get("kind","")=="kiln":return mark
	return {}

func order_kiln(index:int,action:String,queued:bool=false)->String:
	var mark=kiln_landmark()
	if mark.is_empty():return "Kilnreach Works is not reachable."
	var target=point(mark)
	if action in ["build","conceal"]:
		for candidate in floor_at(38).landmarks:
			if candidate.get("kind","")=="kiln_option":target=point(candidate);break
	return enqueue_order(index,"kiln",target,{"action":action}) if queued else issue(index,"kiln",target,{"action":action})

func _junction_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _junction_route(history:String="")->String:
	var source=history if history!="" else str(data.kiln_state)
	return "hotline" if source=="built" else "shadowline"

func _add_junction(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Embervault Junction" and f.rooms.size()>=10
	var route=_junction_route(history);var resolved=state in ["received","shunted","missed"]
	var keeper=_junction_center(f,2) if bespoke else vec(f.up)
	var approach=_junction_center(f,4 if route=="hotline" else 7) if bespoke else keeper+Vector2i(2,0)
	var platform=_junction_center(f,5) if bespoke else vec(f.down)
	var shunt=_junction_center(f,8) if bespoke else vec(f.down)+Vector2i(-2,0)
	var exit_target=_junction_center(f,9) if bespoke else vec(f.down)
	var lore=_junction_center(f,1) if bespoke else vec(f.up)+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="junction"):
		f.landmarks.append({"x":keeper.x,"y":keeper.y,"name":"Signalkeeper Ren","kind":"junction","state":state if state!="" else "waiting","route":route,"description":"Ren watches an unscheduled independent freight signal. Kilnreach's tram determines whether it arrives hot and loud or dark and close."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="junction_route"):
		f.landmarks.append({"x":approach.x,"y":approach.y,"name":"Hot freight approach" if route=="hotline" else "Shadow freight approach","kind":"junction_route","state":"complete" if resolved else "warning" if state=="warning" else "sealed","route":route,"description":"Kilnreach's furnace history has fixed this approach."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="junction_platform"):
		f.landmarks.append({"x":platform.x,"y":platform.y,"name":"Embervault freight platform","kind":"junction_platform","state":state if resolved else "warning" if state=="warning" else "sealed","description":"Two colonists can receive the freight here after securing its approach and carrying the signal seal."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="junction_shunt"):
		f.landmarks.append({"x":shunt.x,"y":shunt.y,"name":"Embervault refuge shunt","kind":"junction_shunt","state":state if resolved else "warning" if state=="warning" else "sealed","description":"The train can be diverted away from the exposed platform with its seal, two timber and two scrap."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="junction_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Embervault settlement road","kind":"junction_exit","state":"open" if resolved else "sealed","description":"The lower road opens after the freight warning resolves, even if the train is missed."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="junction_lore"):
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Independent signal slate","kind":"junction_lore","description":"The slate names Embervault without Meridian's seal. Someone beyond the authority is still running freight."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"junction":mark.state=state if state!="" else "waiting";mark.route=route
			"junction_route":mark.state="complete" if resolved else "warning" if state=="warning" else "sealed";mark.route=route
			"junction_platform","junction_shunt":mark.state=state if resolved else "warning" if state=="warning" else "sealed"
			"junction_exit":mark.state="open" if resolved else "sealed"

func _open_junction_warning(f:Dictionary):
	var route=_junction_route();var links=[[2,3],[3,4],[4,5],[2,5],[5,8]] if route=="hotline" else [[2,6],[6,7],[7,5],[2,5],[5,8]]
	if str(f.get("name",""))=="Embervault Junction" and f.rooms.size()>=10:
		for link in links:corridor(f.grid,_junction_center(f,link[0]),_junction_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("junction_guard")):
		var guard_rooms=[3,4,5] if route=="hotline" else [6,7]
		for i in guard_rooms.size():
			var p=_junction_center(f,guard_rooms[i]);var name="Surface husk" if route=="hotline" else "Gloam stalker"
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":name,"hp":42.0 if name=="Surface husk" else 34.0,"clock":0.0,"attack":0.0,"junction_guard":i})
	if route=="hotline" and not f.structures.any(func(s):return bool(s.get("junction_lamp",false))):
		for room_index in [3,4,5]:var lamp=make_structure("lamp",_junction_center(f,room_index)+Vector2i(-2,0));lamp.junction_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Embervault signal case"):
		var target=_junction_center(f,5)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Embervault signal case","searched":false,"items":{"junction_seal":1},"kind":"salvage"})
	data.junction_state="warning";data.junction_timer=30.0;_add_junction(f,"warning",data.kiln_state);navigation_cache.erase(str(int(f.z)))

func junction_gathered(shunt:bool=false)->int:
	if not data.floors.has("39"):return 0
	var target=Vector2i.ZERO
	for mark in floor_at(39).landmarks:
		if mark.get("kind","")==("junction_shunt" if shunt else "junction_platform"):target=point(mark);break
	return data.pawns.filter(func(pawn):return int(pawn.z)==39 and pawn.hp>0 and point(pawn).distance_to(target)<=4.0).size()

func _complete_junction(f:Dictionary,outcome:String,index:int=-1):
	if str(f.get("name",""))=="Embervault Junction" and f.rooms.size()>=10:
		for link in [[5,8],[8,9]]:corridor(f.grid,_junction_center(f,link[0]),_junction_center(f,link[1]),1)
		f.down=arr(_junction_center(f,9))
	if outcome=="shunted":f.enemies=f.enemies.filter(func(enemy):return not enemy.has("junction_guard"))
	if outcome in ["received","shunted"]:
		var items={"scrap":4,"timber":3,"rations":2} if outcome=="shunted" else {"scrap":6,"crystal":3,"medkit":1} if _junction_route()=="hotline" else {"rations":5,"medkit":3,"timber":2}
		var target=_junction_center(f,8)+Vector2i(1,0);var reward_name="Embervault shunted stores" if outcome=="shunted" else "Embervault received freight"
		if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.junction_state=outcome;data.junction_timer=0.0;_add_junction(f,outcome,data.kiln_state);navigation_cache.erase(str(int(f.z)))
	for pawn in data.pawns:
		if int(pawn.z)==39 and pawn.job.get("kind","")=="junction":pawn.job={};pawn.orders=pawn.orders.filter(func(order):return order.get("kind","")!="junction")
	if index>=0:_remember_nearby(index,"survival","Resolved Embervault's freight warning with {other}.",10.0,9)

func _junction_warning(dt:float):
	if data.junction_state!="warning":return
	data.junction_timer=max(0.0,float(data.junction_timer)-dt)
	if data.junction_timer>0:return
	var safe_rooms=[0,1,8,9]
	for pawn in data.pawns:
		if int(pawn.z)!=39 or pawn.hp<=0:continue
		var protected=false
		for room_index in safe_rooms:
			if _room_from_data(floor_at(39).rooms[room_index]).has_point(point(pawn)):protected=true;break
		if not protected:_hurt_pawn(pawn,25.0)
	_complete_junction(floor_at(39),"missed")
	note("The Embervault freight roars past. Exposed colonists are hurt, but Ren opens the settlement road rather than strand the expedition.")
	events.append({"kind":"junction","state":"missed"})

func junction_landmark()->Dictionary:
	if not data.floors.has("39"):return {}
	for mark in floor_at(39).landmarks:
		if mark.get("kind","")=="junction":return mark
	return {}

func order_junction(index:int,action:String,queued:bool=false)->String:
	var mark=junction_landmark()
	if mark.is_empty():return "Embervault Junction is not reachable."
	var target=point(mark);var expected="junction_platform" if action=="receive" else "junction_shunt" if action=="shunt" else "junction"
	for candidate in floor_at(39).landmarks:
		if candidate.get("kind","")==expected:target=point(candidate);break
	return enqueue_order(index,"junction",target,{"action":action}) if queued else issue(index,"junction",target,{"action":action})

func _ember_commons_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _ember_commons_route(history:String="")->String:
	var source=history if history!="" else str(data.junction_state)
	return "freight" if source=="received" else "refuge" if source=="shunted" else "public"

func _ember_commons_cost(route:String="")->Dictionary:
	var resolved=route if route!="" else _ember_commons_route()
	return {"timber":2,"scrap":3} if resolved=="freight" else {"timber":3,"scrap":2} if resolved=="refuge" else {"timber":3,"scrap":3}

func _add_ember_commons(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Embervault Commons" and f.rooms.size()>=10
	var route=_ember_commons_route(history);var resolved=state in ["freight","refuge","public"]
	var keeper=_ember_commons_center(f,2) if bespoke else vec(f.up)
	var route_target=_ember_commons_center(f,4 if route=="freight" else 7 if route=="refuge" else 6) if bespoke else keeper+Vector2i(2,0)
	var repair=_ember_commons_center(f,5) if bespoke else vec(f.down)
	var exit_target=_ember_commons_center(f,9) if bespoke else vec(f.down)
	var lore=_ember_commons_center(f,1) if bespoke else vec(f.up)+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="ember_commons"):
		f.landmarks.append({"x":keeper.x,"y":keeper.y,"name":"Keeper Sable","kind":"ember_commons","state":state if state!="" else "waiting","route":route,"description":"Sable remembers whether Embervault received, sheltered or missed the independent freight. That history fixes the district's reception and repair route."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="ember_commons_route"):
		var route_name="Lit freight court" if route=="freight" else "Refuge cablewalk" if route=="refuge" else "Wary public arcade"
		f.landmarks.append({"x":route_target.x,"y":route_target.y,"name":route_name,"kind":"ember_commons_route","state":"complete" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"The prior freight outcome determines the residents, lighting and threats along this signal-house route."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="ember_commons_repair"):
		f.landmarks.append({"x":repair.x,"y":repair.y,"name":"Embervault signal house","kind":"ember_commons_repair","state":state if resolved else "available" if state=="assigned" else "sealed","description":"Install the physical signal breaker with exact route-shaped materials to restore this communal signal house."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="ember_commons_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Embervault lower stair","kind":"ember_commons_exit","state":"open" if resolved else "sealed","description":"The connected lower stair opens after the settlement's signal house is repaired."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="ember_commons_lore"):
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Unsealed resident board","kind":"ember_commons_lore","description":"The notices name freight crews, refuge families and missed trains without any Meridian registry number."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"ember_commons":mark.state=state if state!="" else "waiting";mark.route=route
			"ember_commons_route":mark.state="complete" if resolved else "open" if state=="assigned" else "sealed";mark.route=route
			"ember_commons_repair":mark.state=state if resolved else "available" if state=="assigned" else "sealed"
			"ember_commons_exit":mark.state="open" if resolved else "sealed"

func _open_ember_commons_route(f:Dictionary):
	var route=_ember_commons_route();var route_room=4 if route=="freight" else 7 if route=="refuge" else 6
	if str(f.get("name",""))=="Embervault Commons" and f.rooms.size()>=10:
		for link in [[2,route_room],[route_room,5]]:corridor(f.grid,_ember_commons_center(f,link[0]),_ember_commons_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("ember_commons_guard")):
		var guards=[route_room] if route in ["freight","refuge"] else [route_room,5]
		for i in guards.size():
			var p=_ember_commons_center(f,guards[i]);var name="Burrower" if route=="freight" else "Gloam stalker" if route=="refuge" else "Surface husk"
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":name,"hp":48.0 if name=="Burrower" else 34.0 if name=="Gloam stalker" else 42.0,"clock":0.0,"attack":0.0,"ember_commons_guard":i})
	if route=="freight" and not f.structures.any(func(s):return bool(s.get("ember_commons_lamp",false))):
		for room_index in [2,route_room,5]:var lamp=make_structure("lamp",_ember_commons_center(f,room_index)+Vector2i(-2,0));lamp.ember_commons_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Embervault breaker case"):
		var target=_ember_commons_center(f,route_room)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Embervault breaker case","searched":false,"items":{"signal_breaker":1},"kind":"salvage"})
	data.ember_commons_state="assigned";_add_ember_commons(f,"assigned",data.junction_state);navigation_cache.erase(str(int(f.z)))

func _complete_ember_commons(f:Dictionary,outcome:String,index:int):
	if str(f.get("name",""))=="Embervault Commons" and f.rooms.size()>=10:
		for link in [[5,8],[8,9]]:corridor(f.grid,_ember_commons_center(f,link[0]),_ember_commons_center(f,link[1]),1)
		f.down=arr(_ember_commons_center(f,9))
	var items={"rations":5,"medkit":3,"timber":1} if outcome=="freight" else {"scrap":6,"crystal":2,"medkit":1} if outcome=="refuge" else {"rations":3,"medkit":2,"scrap":3,"timber":2}
	var reward_name="Embervault freight allotment" if outcome=="freight" else "Embervault refuge stores" if outcome=="refuge" else "Embervault public stores"
	var target=_ember_commons_center(f,8)+Vector2i(1,0)
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.ember_commons_state=outcome;_add_ember_commons(f,outcome,data.junction_state);navigation_cache.erase(str(int(f.z)))
	_remember_nearby(index,"building","Restored Embervault's communal signal house with {other}.",10.0,9)

func ember_commons_landmark()->Dictionary:
	if not data.floors.has("40"):return {}
	for mark in floor_at(40).landmarks:
		if mark.get("kind","")=="ember_commons":return mark
	return {}

func order_ember_commons(index:int,action:String,queued:bool=false)->String:
	var mark=ember_commons_landmark()
	if mark.is_empty():return "Embervault Commons is not reachable."
	var target=point(mark)
	if action=="finish":
		for candidate in floor_at(40).landmarks:
			if candidate.get("kind","")=="ember_commons_repair":target=point(candidate);break
	return enqueue_order(index,"ember_commons",target,{"action":action}) if queued else issue(index,"ember_commons",target,{"action":action})

func _deepcoil_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _deepcoil_route(history:String="")->String:
	var source=history if history!="" else str(data.ember_commons_state)
	return "keepers" if source=="freight" else "freeband" if source=="refuge" else "echo"

func _add_deepcoil(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Deepcoil Relay" and f.rooms.size()>=10
	var route=_deepcoil_route(history);var resolved=state in ["keepers","freeband","echo"]
	var caller=_deepcoil_center(f,2) if bespoke else vec(f.up)
	var crown=_deepcoil_center(f,4) if bespoke else caller+Vector2i(2,0)
	var root=_deepcoil_center(f,6) if bespoke else caller+Vector2i(0,2)
	var relay=_deepcoil_center(f,5) if bespoke else vec(f.down)
	var exit_target=_deepcoil_center(f,9) if bespoke else vec(f.down)
	var lore=_deepcoil_center(f,1) if bespoke else vec(f.up)+Vector2i(1,0)
	var caller_name="Keeper Vey" if route=="keepers" else "Freeband Tern" if route=="freeband" else "The unanswered voice"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="deepcoil"):
		f.landmarks.append({"x":caller.x,"y":caller.y,"name":caller_name,"kind":"deepcoil","state":state if state!="" else "waiting","route":route,"description":"Embervault's repaired signal determines whether a staffed keeper, a hidden freeband, or an unknown echo answers from below."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="deepcoil_crown"):
		f.landmarks.append({"x":crown.x,"y":crown.y,"name":"Crown-coil gallery","kind":"deepcoil_crown","state":"complete" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"One six-and-a-half-kilogram crown coil waits beyond this branch. It cannot share one twelve-kilogram pack with the root coil."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="deepcoil_root"):
		f.landmarks.append({"x":root.x,"y":root.y,"name":"Root-coil gallery","kind":"deepcoil_root","state":"complete" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"The second six-and-a-half-kilogram coil must return in another colonist's pack."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="deepcoil_sync"):
		f.landmarks.append({"x":relay.x,"y":relay.y,"name":"Deepcoil synchronizer","kind":"deepcoil_sync","state":state if resolved else "available" if state=="assigned" else "sealed","description":"Bring two separate carriers here and tune the paired physical coils together."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="deepcoil_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Answered descent","kind":"deepcoil_exit","state":"open" if resolved else "sealed","route":route,"description":"The signal answer names the settlement network below and opens this connected descent."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="deepcoil_lore"):
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Paired-call tablets","kind":"deepcoil_lore","description":"Every warning is carved twice: never energize one deep coil without a living hand at the other."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"deepcoil":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=caller_name
			"deepcoil_crown","deepcoil_root":mark.state="complete" if resolved else "open" if state=="assigned" else "sealed";mark.route=route
			"deepcoil_sync":mark.state=state if resolved else "available" if state=="assigned" else "sealed"
			"deepcoil_exit":mark.state="open" if resolved else "sealed";mark.route=route

func _open_deepcoil_route(f:Dictionary):
	var route=_deepcoil_route()
	if str(f.get("name",""))=="Deepcoil Relay" and f.rooms.size()>=10:
		for link in [[2,4],[2,6],[4,5],[6,5]]:corridor(f.grid,_deepcoil_center(f,link[0]),_deepcoil_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("deepcoil_guard")):
		var guards=[{"room":4,"name":"Burrower"},{"room":6,"name":"Burrower"}] if route=="keepers" else [{"room":4,"name":"Gloam stalker"},{"room":6,"name":"Gloam stalker"}] if route=="freeband" else [{"room":4,"name":"Burrower"},{"room":6,"name":"Gloam stalker"}]
		for i in guards.size():
			var guard=guards[i];var p=_deepcoil_center(f,int(guard.room));var name=str(guard.name)
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":name,"hp":48.0 if name=="Burrower" else 34.0,"clock":0.0,"attack":0.0,"deepcoil_guard":i})
	if route=="keepers" and not f.structures.any(func(s):return bool(s.get("deepcoil_lamp",false))):
		for room_index in [2,4,5,6]:var lamp=make_structure("lamp",_deepcoil_center(f,room_index)+Vector2i(-2,0));lamp.deepcoil_lamp=true;f.structures.append(lamp)
	if route=="echo" and not f.structures.any(func(s):return bool(s.get("deepcoil_lamp",false))):
		var lamp=make_structure("lamp",_deepcoil_center(f,2)+Vector2i(-2,0));lamp.deepcoil_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Deepcoil crown case"):
		var crown=_deepcoil_center(f,4)+Vector2i(1,0);f.containers.append({"id":next_id(),"x":crown.x,"y":crown.y,"name":"Deepcoil crown case","searched":false,"items":{"relay_crown":1},"kind":"salvage"})
	if not f.containers.any(func(c):return c.get("name","")=="Deepcoil root case"):
		var root=_deepcoil_center(f,6)+Vector2i(1,0);f.containers.append({"id":next_id(),"x":root.x,"y":root.y,"name":"Deepcoil root case","searched":false,"items":{"relay_root":1},"kind":"salvage"})
	data.deepcoil_state="assigned";_add_deepcoil(f,"assigned",data.ember_commons_state);navigation_cache.erase(str(int(f.z)))

func deepcoil_sync()->Dictionary:
	if not data.floors.has("41"):return {}
	for mark in floor_at(41).landmarks:
		if mark.get("kind","")=="deepcoil_sync":return mark
	return {}

func _deepcoil_carriers(target:Vector2i)->Array:
	var crown=-1;var root=-1
	for i in data.pawns.size():
		var pawn=data.pawns[i]
		if pawn.hp>0 and int(pawn.z)==41 and point(pawn).distance_to(target)<=4.0 and int(pawn.inventory.get("relay_crown",0))>=1:crown=i;break
	for i in data.pawns.size():
		var pawn=data.pawns[i]
		if i!=crown and pawn.hp>0 and int(pawn.z)==41 and point(pawn).distance_to(target)<=4.0 and int(pawn.inventory.get("relay_root",0))>=1:root=i;break
	return [crown,root] if crown>=0 and root>=0 else []

func _complete_deepcoil(f:Dictionary,outcome:String,index:int,carriers:Array):
	data.pawns[int(carriers[0])].inventory.relay_crown-=1
	data.pawns[int(carriers[1])].inventory.relay_root-=1
	if str(f.get("name",""))=="Deepcoil Relay" and f.rooms.size()>=10:
		for link in [[5,8],[8,9]]:corridor(f.grid,_deepcoil_center(f,link[0]),_deepcoil_center(f,link[1]),1)
		f.down=arr(_deepcoil_center(f,9))
	var items={"rations":4,"medkit":3,"timber":2} if outcome=="keepers" else {"scrap":7,"crystal":3,"medkit":1} if outcome=="freeband" else {"rations":3,"medkit":2,"scrap":4,"timber":1}
	var reward_name="Deepcoil keeper issue" if outcome=="keepers" else "Deepcoil freeband freight" if outcome=="freeband" else "Deepcoil echo cache"
	var target=_deepcoil_center(f,8)+Vector2i(1,0)
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.deepcoil_state=outcome;_add_deepcoil(f,outcome,data.ember_commons_state);navigation_cache.erase(str(int(f.z)))
	_remember_nearby(index,"discovery","Synchronized Deepcoil's paired relays with {other}.",10.0,10)

func deepcoil_landmark()->Dictionary:
	if not data.floors.has("41"):return {}
	for mark in floor_at(41).landmarks:
		if mark.get("kind","")=="deepcoil":return mark
	return {}

func order_deepcoil(index:int,action:String,queued:bool=false)->String:
	var mark=deepcoil_landmark()
	if mark.is_empty():return "Deepcoil Relay is not reachable."
	var target=point(mark)
	if action=="finish":
		var sync=deepcoil_sync()
		if not sync.is_empty():target=point(sync)
	return enqueue_order(index,"deepcoil",target,{"action":action}) if queued else issue(index,"deepcoil",target,{"action":action})

func _coilward_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _coilward_route(history:String="")->String:
	var source=history if history!="" else str(data.deepcoil_state)
	return source if source in ["keepers","freeband"] else "echo"

func _coilward_cost(route:String="")->Dictionary:
	var path=route if route!="" else _coilward_route()
	return {"rations":2,"medkit":1} if path=="keepers" else {"scrap":3,"crystal":1} if path=="freeband" else {"timber":2,"scrap":2}

func _add_coilward(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Coilward Commons" and f.rooms.size()>=10
	var route=_coilward_route(history);var resolved=state in ["keepers","freeband","echo"]
	var caller=_coilward_center(f,2) if bespoke else vec(f.up)
	var route_room=4 if route=="keepers" else 6 if route=="freeband" else 3
	var road=_coilward_center(f,route_room) if bespoke else caller+Vector2i(2,0)
	var seal=_coilward_center(f,5) if bespoke else vec(f.down)
	var exit_target=_coilward_center(f,9) if bespoke else vec(f.down)
	var lore=_coilward_center(f,1) if bespoke else vec(f.up)+Vector2i(1,0)
	var caller_name="Steward Oris" if route=="keepers" else "Speaker Wren" if route=="freeband" else "The Open Assembly"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="coilward"):
		f.landmarks.append({"x":caller.x,"y":caller.y,"name":caller_name,"kind":"coilward","state":state if state!="" else "waiting","route":route,"description":"Deepcoil's answer determines whether Coilward receives the crew through a keeper hall, freeband cableway, or wary public arcade."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="coilward_route"):
		f.landmarks.append({"x":road.x,"y":road.y,"name":"Keeper charter hall" if route=="keepers" else "Freeband cableway" if route=="freeband" else "Public charter arcade","kind":"coilward_route","state":"complete" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"A route-shaped threat guards the community's physical charter."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="coilward_seal"):
		f.landmarks.append({"x":seal.x,"y":seal.y,"name":"Coilward council seal","kind":"coilward_seal","state":state if resolved else "available" if state=="assigned" else "sealed","route":route,"description":"Carry the community charter and exact contribution here. The signed charter remains physical evidence in its carrier's pack."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="coilward_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Chartered lower road","kind":"coilward_exit","state":"open" if resolved else "sealed","route":route,"description":"A ratified community route connects Coilward to the settlements below."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="coilward_lore"):
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Common-table tablets","kind":"coilward_lore","description":"The old articles insist that every settlement keeps its own stores, chooses its own risks, and records every shared road."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"coilward":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=caller_name
			"coilward_route":mark.state="complete" if resolved else "open" if state=="assigned" else "sealed";mark.route=route
			"coilward_seal":mark.state=state if resolved else "available" if state=="assigned" else "sealed";mark.route=route
			"coilward_exit":mark.state="open" if resolved else "sealed";mark.route=route

func _open_coilward_route(f:Dictionary):
	var route=_coilward_route();var route_room=4 if route=="keepers" else 6 if route=="freeband" else 3
	if str(f.get("name",""))=="Coilward Commons" and f.rooms.size()>=10:
		for link in [[2,route_room],[route_room,5]]:corridor(f.grid,_coilward_center(f,link[0]),_coilward_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("coilward_guard")):
		var guards=[{"room":route_room,"name":"Burrower"}] if route=="keepers" else [{"room":route_room,"name":"Gloam stalker"}] if route=="freeband" else [{"room":route_room,"name":"Surface husk"},{"room":5,"name":"Surface husk"}]
		for i in guards.size():
			var guard=guards[i];var p=_coilward_center(f,int(guard.room));var name=str(guard.name)
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":name,"hp":48.0 if name=="Burrower" else 34.0 if name=="Gloam stalker" else 42.0,"clock":0.0,"attack":0.0,"coilward_guard":i})
	if route=="keepers" and not f.structures.any(func(s):return bool(s.get("coilward_lamp",false))):
		for room_index in [2,route_room,5]:var lamp=make_structure("lamp",_coilward_center(f,room_index)+Vector2i(-2,0));lamp.coilward_lamp=true;f.structures.append(lamp)
	if route=="echo" and not f.structures.any(func(s):return bool(s.get("coilward_lamp",false))):
		var lamp=make_structure("lamp",_coilward_center(f,2)+Vector2i(-2,0));lamp.coilward_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Coilward charter case"):
		var charter=_coilward_center(f,route_room)+Vector2i(1,0);f.containers.append({"id":next_id(),"x":charter.x,"y":charter.y,"name":"Coilward charter case","searched":false,"items":{"ward_charter":1},"kind":"salvage"})
	data.coilward_state="assigned";_add_coilward(f,"assigned",data.deepcoil_state);navigation_cache.erase(str(int(f.z)))

func _complete_coilward(f:Dictionary,outcome:String,index:int):
	if str(f.get("name",""))=="Coilward Commons" and f.rooms.size()>=10:
		for link in [[5,8],[8,9]]:corridor(f.grid,_coilward_center(f,link[0]),_coilward_center(f,link[1]),1)
		f.down=arr(_coilward_center(f,9))
	var items={"rations":5,"medkit":3,"timber":1} if outcome=="keepers" else {"scrap":6,"crystal":3,"medkit":1} if outcome=="freeband" else {"rations":3,"medkit":2,"scrap":3,"timber":2}
	var reward_name="Coilward keeper issue" if outcome=="keepers" else "Coilward freeband stores" if outcome=="freeband" else "Coilward public allotment"
	var target=_coilward_center(f,8)+Vector2i(1,0)
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.coilward_state=outcome;_add_coilward(f,outcome,data.deepcoil_state);navigation_cache.erase(str(int(f.z)))
	_remember_nearby(index,"discovery","Ratified Coilward's community charter with {other}.",10.0,10)

func coilward_landmark()->Dictionary:
	if not data.floors.has("42"):return {}
	for mark in floor_at(42).landmarks:
		if mark.get("kind","")=="coilward":return mark
	return {}

func order_coilward(index:int,action:String,queued:bool=false)->String:
	var mark=coilward_landmark()
	if mark.is_empty():return "Coilward Commons is not reachable."
	var target=point(mark)
	if action=="finish":
		for candidate in floor_at(42).landmarks:
			if candidate.get("kind","")=="coilward_seal":target=point(candidate);break
	return enqueue_order(index,"coilward",target,{"action":action}) if queued else issue(index,"coilward",target,{"action":action})

func _charterwell_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _charterwell_route(history:String="")->String:
	var source=history if history!="" else str(data.coilward_state)
	return "council" if source=="keepers" else "underroad" if source=="freeband" else "public"

func _charterwell_cost(route:String="")->Dictionary:
	var path=route if route!="" else _charterwell_route()
	return {"rations":2,"medkit":1} if path=="council" else {"scrap":3,"crystal":1} if path=="underroad" else {"timber":2,"rations":2}

func _add_charterwell(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Charterwell Station" and f.rooms.size()>=10
	var route=_charterwell_route(history);var resolved=state in ["escorted","supplied","missed"]
	var caller=_charterwell_center(f,2) if bespoke else vec(f.up)
	var route_room=4 if route=="council" else 6 if route=="underroad" else 3
	var approach=_charterwell_center(f,route_room) if bespoke else caller+Vector2i(2,0)
	var platform=_charterwell_center(f,5) if bespoke else vec(f.down)
	var supply=_charterwell_center(f,7) if bespoke else vec(f.down)+Vector2i(-2,0)
	var safe=_charterwell_center(f,8) if bespoke else vec(f.up)+Vector2i(-2,0)
	var exit_target=_charterwell_center(f,9) if bespoke else vec(f.down)
	var lore=_charterwell_center(f,1) if bespoke else vec(f.up)+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="charterwell"):
		f.landmarks.append({"x":caller.x,"y":caller.y,"name":"Delegate Mara" if route=="council" else "Courier Fen" if route=="underroad" else "Caller Nine","kind":"charterwell","state":state if state!="" else "waiting","route":route,"description":"The carried Coilward charter determines who recognizes this delegation and which station road opens."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="charterwell_route"):
		f.landmarks.append({"x":approach.x,"y":approach.y,"name":"Council receiving road" if route=="council" else "Freeband underroad" if route=="underroad" else "Public arrival arcade","kind":"charterwell_route","state":"complete" if resolved else "warning" if state=="warning" else "sealed","route":route,"description":"A route-shaped threat stands between the charter bearer and the departing delegation."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="charterwell_platform"):
		f.landmarks.append({"x":platform.x,"y":platform.y,"name":"Charterwell delegation platform","kind":"charterwell_platform","state":state if resolved else "warning" if state=="warning" else "sealed","description":"Three living colonists can escort the delegation from this platform once its approach is secure."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="charterwell_supply"):
		f.landmarks.append({"x":supply.x,"y":supply.y,"name":"Charterwell supply gate","kind":"charterwell_supply","state":state if resolved else "warning" if state=="warning" else "sealed","description":"Two colonists can fund safe passage here with the physical charter and exact route-shaped supplies."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="charterwell_safe"):
		f.landmarks.append({"x":safe.x,"y":safe.y,"name":"Delegation storm room","kind":"charterwell_safe","state":"open","description":"Colonists sheltering in marked station rooms are protected if the delegation departs without them."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="charterwell_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Delegation lower road","kind":"charterwell_exit","state":"open" if resolved else "sealed","description":"The connected lower road opens after the warning resolves, even if the delegation is missed."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="charterwell_lore"):
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Departure tablets","kind":"charterwell_lore","description":"Each delegation leaves a signed writ behind. No settlement may close the road on those who miss the bell."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"charterwell":mark.state=state if state!="" else "waiting";mark.route=route
			"charterwell_route":mark.state="complete" if resolved else "warning" if state=="warning" else "sealed";mark.route=route
			"charterwell_platform","charterwell_supply":mark.state=state if resolved else "warning" if state=="warning" else "sealed"
			"charterwell_exit":mark.state="open" if resolved else "sealed"

func _open_charterwell_warning(f:Dictionary):
	var route=_charterwell_route();var route_room=4 if route=="council" else 6 if route=="underroad" else 3
	if str(f.get("name",""))=="Charterwell Station" and f.rooms.size()>=10:
		for link in [[2,route_room],[route_room,5],[2,7],[7,5],[5,8]]:corridor(f.grid,_charterwell_center(f,link[0]),_charterwell_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("charterwell_guard")):
		var names=["Burrower","Burrower"] if route=="council" else ["Gloam stalker","Gloam stalker"] if route=="underroad" else ["Surface husk","Surface husk","Surface husk"]
		for i in names.size():
			var p=_charterwell_center(f,route_room)+Vector2i(i-1,0);var name=str(names[i])
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":name,"hp":48.0 if name=="Burrower" else 34.0 if name=="Gloam stalker" else 42.0,"clock":0.0,"attack":0.0,"charterwell_guard":i})
	if route=="council" and not f.structures.any(func(s):return bool(s.get("charterwell_lamp",false))):
		for room_index in [2,route_room,5]:var lamp=make_structure("lamp",_charterwell_center(f,room_index)+Vector2i(-2,0));lamp.charterwell_lamp=true;f.structures.append(lamp)
	if route=="public" and not f.structures.any(func(s):return bool(s.get("charterwell_lamp",false))):
		var lamp=make_structure("lamp",_charterwell_center(f,2)+Vector2i(-2,0));lamp.charterwell_lamp=true;f.structures.append(lamp)
	data.charterwell_state="warning";data.charterwell_timer=30.0;_add_charterwell(f,"warning",data.coilward_state);navigation_cache.erase(str(int(f.z)))

func charterwell_gathered(supply:bool=false)->int:
	if not data.floors.has("43"):return 0
	var target=Vector2i.ZERO
	for mark in floor_at(43).landmarks:
		if mark.get("kind","")==("charterwell_supply" if supply else "charterwell_platform"):target=point(mark);break
	return data.pawns.filter(func(pawn):return int(pawn.z)==43 and pawn.hp>0 and point(pawn).distance_to(target)<=4.0).size()

func _complete_charterwell(f:Dictionary,outcome:String,index:int=-1):
	if str(f.get("name",""))=="Charterwell Station" and f.rooms.size()>=10:
		for link in [[5,8],[8,9]]:corridor(f.grid,_charterwell_center(f,link[0]),_charterwell_center(f,link[1]),1)
		f.down=arr(_charterwell_center(f,9))
	if outcome in ["supplied","missed"]:f.enemies=f.enemies.filter(func(enemy):return not enemy.has("charterwell_guard"))
	var route=_charterwell_route();var items={"rations":1,"delegate_writ":1}
	if outcome=="escorted":items={"rations":5,"medkit":3,"delegate_writ":1} if route=="council" else {"scrap":6,"crystal":3,"delegate_writ":1} if route=="underroad" else {"rations":3,"medkit":2,"scrap":3,"delegate_writ":1}
	elif outcome=="supplied":items={"timber":3,"scrap":2,"delegate_writ":1}
	var target=_charterwell_center(f,8)+Vector2i(1,0);var reward_name="Charterwell escorted issue" if outcome=="escorted" else "Charterwell passage stores" if outcome=="supplied" else "Charterwell missed-departure writ"
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.charterwell_state=outcome;data.charterwell_timer=0.0;_add_charterwell(f,outcome,data.coilward_state);navigation_cache.erase(str(int(f.z)))
	for pawn in data.pawns:
		if int(pawn.z)==43 and pawn.job.get("kind","")=="charterwell":pawn.job={};pawn.orders=pawn.orders.filter(func(order):return order.get("kind","")!="charterwell")
	if index>=0:_remember_nearby(index,"survival","Resolved Charterwell's delegation warning with {other}.",10.0,9)

func _charterwell_warning(dt:float):
	if data.charterwell_state!="warning":return
	data.charterwell_timer=max(0.0,float(data.charterwell_timer)-dt)
	if data.charterwell_timer>0:return
	var safe_rooms=[0,1,8,9]
	for pawn in data.pawns:
		if int(pawn.z)!=43 or pawn.hp<=0:continue
		var protected=false
		for room_index in safe_rooms:
			if _room_from_data(floor_at(43).rooms[room_index]).has_point(point(pawn)):protected=true;break
		if not protected:_hurt_pawn(pawn,22.0)
	_complete_charterwell(floor_at(43),"missed")
	note("The Charterwell delegation departs. Exposed colonists are hurt, but the station leaves a writ and opens the lower road rather than strand the expedition.")
	events.append({"kind":"charterwell","state":"missed"})

func charterwell_landmark()->Dictionary:
	if not data.floors.has("43"):return {}
	for mark in floor_at(43).landmarks:
		if mark.get("kind","")=="charterwell":return mark
	return {}

func order_charterwell(index:int,action:String,queued:bool=false)->String:
	var mark=charterwell_landmark()
	if mark.is_empty():return "Charterwell Station is not reachable."
	var target=point(mark);var expected="charterwell_platform" if action=="escort" else "charterwell_supply" if action=="supply" else "charterwell"
	for candidate in floor_at(43).landmarks:
		if candidate.get("kind","")==expected:target=point(candidate);break
	return enqueue_order(index,"charterwell",target,{"action":action}) if queued else issue(index,"charterwell",target,{"action":action})

func _writwell_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _writwell_route(history:String="")->String:
	var source=history if history!="" else str(data.charterwell_state)
	return "delegates" if source=="escorted" else "exchange" if source=="supplied" else "commons"

func _writwell_cost(route:String="")->Dictionary:
	var path=route if route!="" else _writwell_route()
	return {"rations":4,"medkit":2} if path=="delegates" else {"scrap":5,"crystal":2} if path=="exchange" else {"timber":3,"rations":3}

func _add_writwell(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Writwell Assembly" and f.rooms.size()>=10
	var route=_writwell_route(history);var resolved=state in ["delegates","exchange","commons"]
	var speaker=_writwell_center(f,2) if bespoke else vec(f.up)
	var route_room=4 if route=="delegates" else 6 if route=="exchange" else 3
	var approach=_writwell_center(f,route_room) if bespoke else speaker+Vector2i(2,0)
	var table=_writwell_center(f,5) if bespoke else vec(f.down)
	var stores=_writwell_center(f,8) if bespoke else vec(f.down)+Vector2i(-2,0)
	var exit_target=_writwell_center(f,9) if bespoke else vec(f.down)
	var lore=_writwell_center(f,1) if bespoke else vec(f.up)+Vector2i(1,0)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="writwell"):
		f.landmarks.append({"x":speaker.x,"y":speaker.y,"name":"Convener Ilex" if route=="delegates" else "Quartermaster Brin" if route=="exchange" else "Open-chair Moss","kind":"writwell","state":state if state!="" else "waiting","route":route,"description":"Charterwell's carried writ determines which settlements answer Writwell's shared-supply vote."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="writwell_route"):
		f.landmarks.append({"x":approach.x,"y":approach.y,"name":"Delegate gallery" if route=="delegates" else "Exchange cloister" if route=="exchange" else "Open assembly aisle","kind":"writwell_route","state":"complete" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"A route-shaped threat blocks the delegates from reaching the common table."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="writwell_table"):
		f.landmarks.append({"x":table.x,"y":table.y,"name":"Writwell common table","kind":"writwell_table","state":state if resolved else "available" if state=="assigned" else "sealed","route":route,"description":"Three colonists vote here. At least two packs must jointly provide the exact shared-supply pledge."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="writwell_stores"):
		f.landmarks.append({"x":stores.x,"y":stores.y,"name":"Ratified common stores","kind":"writwell_stores","state":"open" if resolved else "sealed","description":"The assembly's physical issue waits here after a successful vote."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="writwell_exit"):
		f.landmarks.append({"x":exit_target.x,"y":exit_target.y,"name":"Mandated lower road","kind":"writwell_exit","state":"open" if resolved else "sealed","description":"A ratified multi-settlement mandate opens the connected road below."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="writwell_lore"):
		f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Pledge wall","kind":"writwell_lore","description":"No settlement may promise another's stores. A pledge counts only when distinct carriers place physical supplies on the common table."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"writwell":mark.state=state if state!="" else "waiting";mark.route=route
			"writwell_route":mark.state="complete" if resolved else "open" if state=="assigned" else "sealed";mark.route=route
			"writwell_table":mark.state=state if resolved else "available" if state=="assigned" else "sealed";mark.route=route
			"writwell_stores","writwell_exit":mark.state="open" if resolved else "sealed"

func _open_writwell_vote(f:Dictionary):
	var route=_writwell_route();var route_room=4 if route=="delegates" else 6 if route=="exchange" else 3
	if str(f.get("name",""))=="Writwell Assembly" and f.rooms.size()>=10:
		for link in [[2,route_room],[route_room,5],[5,7]]:corridor(f.grid,_writwell_center(f,link[0]),_writwell_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("writwell_guard")):
		var names=["Burrower","Burrower"] if route=="delegates" else ["Gloam stalker","Gloam stalker"] if route=="exchange" else ["Surface husk","Surface husk","Surface husk"]
		for i in names.size():
			var p=_writwell_center(f,route_room)+Vector2i(i-1,0);var name=str(names[i])
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":name,"hp":48.0 if name=="Burrower" else 34.0 if name=="Gloam stalker" else 42.0,"clock":0.0,"attack":0.0,"writwell_guard":i})
	if route=="delegates" and not f.structures.any(func(s):return bool(s.get("writwell_lamp",false))):
		for room_index in [2,route_room,5]:var lamp=make_structure("lamp",_writwell_center(f,room_index)+Vector2i(-2,0));lamp.writwell_lamp=true;f.structures.append(lamp)
	if route=="commons" and not f.structures.any(func(s):return bool(s.get("writwell_lamp",false))):
		var lamp=make_structure("lamp",_writwell_center(f,2)+Vector2i(-2,0));lamp.writwell_lamp=true;f.structures.append(lamp)
	data.writwell_state="assigned";_add_writwell(f,"assigned",data.charterwell_state);navigation_cache.erase(str(int(f.z)))

func writwell_crew()->Array:
	if not data.floors.has("44"):return []
	var target=Vector2i.ZERO
	for mark in floor_at(44).landmarks:
		if mark.get("kind","")=="writwell_table":target=point(mark);break
	return data.pawns.filter(func(pawn):return int(pawn.z)==44 and pawn.hp>0 and point(pawn).distance_to(target)<=4.0)

func writwell_available(item:String)->int:
	var total=0
	for pawn in writwell_crew():total+=int(pawn.inventory.get(item,0))
	return total

func writwell_contributors()->int:
	var cost=_writwell_cost();var contributors=0
	for pawn in writwell_crew():
		if cost.keys().any(func(item):return int(pawn.inventory.get(item,0))>0):contributors+=1
	return contributors

func _consume_writwell_pledge():
	var remaining=_writwell_cost().duplicate()
	for pawn in writwell_crew():
		for item in remaining:
			var take=min(int(remaining[item]),int(pawn.inventory.get(item,0)))
			pawn.inventory[item]=int(pawn.inventory.get(item,0))-take;remaining[item]=int(remaining[item])-take

func _complete_writwell(f:Dictionary,index:int):
	var route=_writwell_route()
	if str(f.get("name",""))=="Writwell Assembly" and f.rooms.size()>=10:
		for link in [[5,8],[8,9]]:corridor(f.grid,_writwell_center(f,link[0]),_writwell_center(f,link[1]),1)
		f.down=arr(_writwell_center(f,9))
	var items={"rations":5,"medkit":3,"timber":2,"assembly_mandate":1} if route=="delegates" else {"scrap":7,"crystal":3,"medkit":1,"assembly_mandate":1} if route=="exchange" else {"rations":4,"medkit":2,"scrap":3,"timber":2,"assembly_mandate":1}
	var target=_writwell_center(f,8)+Vector2i(1,0);var reward_name="Writwell delegate issue" if route=="delegates" else "Writwell exchange freight" if route=="exchange" else "Writwell commons allotment"
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.writwell_state=route;_add_writwell(f,route,data.charterwell_state);navigation_cache.erase(str(int(f.z)))
	for pawn in data.pawns:
		if int(pawn.z)==44 and pawn.job.get("kind","")=="writwell":pawn.job={};pawn.orders=pawn.orders.filter(func(order):return order.get("kind","")!="writwell")
	_remember_nearby(index,"discovery","Ratified Writwell's shared pledge with {other}.",10.0,10)

func writwell_landmark()->Dictionary:
	if not data.floors.has("44"):return {}
	for mark in floor_at(44).landmarks:
		if mark.get("kind","")=="writwell":return mark
	return {}

func order_writwell(index:int,action:String,queued:bool=false)->String:
	var mark=writwell_landmark()
	if mark.is_empty():return "Writwell Assembly is not reachable."
	var target=point(mark)
	if action=="pledge":
		for candidate in floor_at(44).landmarks:
			if candidate.get("kind","")=="writwell_table":target=point(candidate);break
	return enqueue_order(index,"writwell",target,{"action":action}) if queued else issue(index,"writwell",target,{"action":action})

func _concordance_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _concordance_route(history:String="")->String:
	var source=history if history!="" else str(data.writwell_state)
	return "council" if source=="delegates" else "shadow" if source=="exchange" else "public"

func _concordance_cost(action:String)->Dictionary:
	return {"timber":4,"scrap":3} if action=="bastion" else {"rations":4,"medkit":2}

func _add_concordance(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var bespoke=str(f.get("name",""))=="Concordance Gate" and f.rooms.size()>=10
	var route=_concordance_route(history);var resolved=state in ["bastion","reserve"]
	var speaker=_concordance_center(f,2) if bespoke else vec(f.up)
	var route_room=4 if route=="council" else 6 if route=="shadow" else 3
	var approach=_concordance_center(f,route_room) if bespoke else speaker+Vector2i(2,0)
	var bastion=_concordance_center(f,5) if bespoke else vec(f.down)
	var reserve=_concordance_center(f,7) if bespoke else vec(f.down)+Vector2i(-3,0)
	var stores=_concordance_center(f,8) if bespoke else vec(f.down)+Vector2i(2,0)
	var exit_target=_concordance_center(f,9) if bespoke else vec(f.down)
	var lore=_concordance_center(f,1) if bespoke else vec(f.up)+Vector2i(1,0)
	var marks=[
		{"x":speaker.x,"y":speaker.y,"name":"Gatewarden Sable" if route=="council" else "Runner Ibis" if route=="shadow" else "Public marshal Reed","kind":"concordance","state":state if state!="" else "waiting","route":route,"description":"Writwell's carried assembly mandate determines who receives the crew at Concordance Gate."},
		{"x":approach.x,"y":approach.y,"name":"Council guardline" if route=="council" else "Shadow approach" if route=="shadow" else "Public breach","kind":"concordance_route","state":"complete" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"Route-shaped surface pressure blocks the gate's defensive works."},
		{"x":bastion.x,"y":bastion.y,"name":"Concordance bastion","kind":"concordance_bastion","state":"complete" if state=="bastion" else "available" if state=="assigned" else "sealed","route":route,"description":"Three colonists can build a fixed defense here with exactly 4 timber and 3 scrap."},
		{"x":reserve.x,"y":reserve.y,"name":"Mobile reserve yard","kind":"concordance_reserve","state":"complete" if state=="reserve" else "available" if state=="assigned" else "sealed","route":route,"description":"Two colonists can provision a mobile reserve with exactly 4 rations and 2 medkits, withdrawing past the route guards."},
		{"x":stores.x,"y":stores.y,"name":"Concordance issue","kind":"concordance_stores","state":"open" if resolved else "sealed","description":"The chosen defense's physical stores and response token wait here."},
		{"x":exit_target.x,"y":exit_target.y,"name":"Coordinated lower road","kind":"concordance_exit","state":"open" if resolved else "sealed","description":"A coordinated defense opens the connected road below."},
		{"x":lore.x,"y":lore.y,"name":"Gate compact","kind":"concordance_lore","description":"The settlements can anchor one defended gate or keep a provisioned reserve moving through the deepest roads."}
	]
	for fresh in marks:
		var kind=str(fresh.kind);var existing=f.landmarks.filter(func(mark):return mark.get("kind","")==kind)
		if existing.is_empty():f.landmarks.append(fresh)
		else:
			for key in fresh:existing[0][key]=fresh[key]

func _open_concordance(f:Dictionary):
	var route=_concordance_route();var route_room=4 if route=="council" else 6 if route=="shadow" else 3
	if str(f.get("name",""))=="Concordance Gate" and f.rooms.size()>=10:
		for link in [[2,route_room],[route_room,5],[route_room,7]]:corridor(f.grid,_concordance_center(f,link[0]),_concordance_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("concordance_guard")):
		var names=["Burrower","Burrower"] if route=="council" else ["Gloam stalker","Gloam stalker"] if route=="shadow" else ["Surface husk","Surface husk","Surface husk"]
		for i in names.size():
			var p=_concordance_center(f,route_room)+Vector2i(i-1,0);var name=str(names[i])
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":name,"hp":48.0 if name=="Burrower" else 34.0 if name=="Gloam stalker" else 42.0,"clock":0.0,"attack":0.0,"concordance_guard":i})
	if route=="council" and not f.structures.any(func(s):return bool(s.get("concordance_lamp",false))):
		for room_index in [2,route_room,5]:var lamp=make_structure("lamp",_concordance_center(f,room_index)+Vector2i(-2,0));lamp.concordance_lamp=true;f.structures.append(lamp)
	if route=="public" and not f.structures.any(func(s):return bool(s.get("concordance_lamp",false))):
		var lamp=make_structure("lamp",_concordance_center(f,2)+Vector2i(-2,0));lamp.concordance_lamp=true;f.structures.append(lamp)
	data.concordance_state="assigned";_add_concordance(f,"assigned",data.writwell_state);navigation_cache.erase(str(int(f.z)))

func concordance_gathered(reserve:bool=false)->int:
	if not data.floors.has("45"):return 0
	var target=Vector2i.ZERO
	for mark in floor_at(45).landmarks:
		if mark.get("kind","")==("concordance_reserve" if reserve else "concordance_bastion"):target=point(mark);break
	return data.pawns.filter(func(pawn):return int(pawn.z)==45 and pawn.hp>0 and point(pawn).distance_to(target)<=4.0).size()

func _complete_concordance(f:Dictionary,outcome:String,index:int):
	if str(f.get("name",""))=="Concordance Gate" and f.rooms.size()>=10:
		var choice=5 if outcome=="bastion" else 7
		for link in [[choice,8],[8,9]]:corridor(f.grid,_concordance_center(f,link[0]),_concordance_center(f,link[1]),1)
		f.down=arr(_concordance_center(f,9))
	if outcome=="reserve":f.enemies=f.enemies.filter(func(enemy):return not enemy.has("concordance_guard"))
	if outcome=="bastion" and not f.structures.any(func(s):return bool(s.get("concordance_defense",false))):
		var center=_concordance_center(f,5)
		for offset in [Vector2i(-2,0),Vector2i(2,0),Vector2i(0,2)]:
			var defense=make_structure("barricade",center+offset);defense.concordance_defense=true;f.structures.append(defense)
	var items={"rations":5,"medkit":3,"concordance_token":1} if outcome=="bastion" else {"scrap":6,"crystal":3,"timber":2,"concordance_token":1}
	var target=_concordance_center(f,8)+Vector2i(1,0);var reward_name="Concordance bastion issue" if outcome=="bastion" else "Concordance reserve freight"
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.concordance_state=outcome;_add_concordance(f,outcome,data.writwell_state);navigation_cache.erase(str(int(f.z)))
	for pawn in data.pawns:
		if int(pawn.z)==45 and pawn.job.get("kind","")=="concordance":pawn.job={};pawn.orders=pawn.orders.filter(func(order):return order.get("kind","")!="concordance")
	_remember_nearby(index,"survival","Coordinated Concordance Gate's defense with {other}.",10.0,10)

func concordance_landmark()->Dictionary:
	if not data.floors.has("45"):return {}
	for mark in floor_at(45).landmarks:
		if mark.get("kind","")=="concordance":return mark
	return {}

func order_concordance(index:int,action:String,queued:bool=false)->String:
	var mark=concordance_landmark()
	if mark.is_empty():return "Concordance Gate is not reachable."
	var target=point(mark);var expected="concordance_bastion" if action=="bastion" else "concordance_reserve" if action=="reserve" else "concordance"
	for candidate in floor_at(45).landmarks:
		if candidate.get("kind","")==expected:target=point(candidate);break
	return enqueue_order(index,"concordance",target,{"action":action}) if queued else issue(index,"concordance",target,{"action":action})

func _reservefall_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _reservefall_route(history:String="")->String:
	return "bastion" if (history if history!="" else str(data.concordance_state))=="bastion" else "reserve"

func _reservefall_cost()->Dictionary:
	return {"timber":2,"scrap":2}

func _add_reservefall(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var route=_reservefall_route(history);var resolved=state in ["held","withdrawn","breached"]
	var route_room=4 if route=="bastion" else 6
	var marks=[
		{"x":_reservefall_center(f,2).x,"y":_reservefall_center(f,2).y,"name":"Quarterkeeper Orin","kind":"reservefall","state":state if state!="" else "waiting","route":route,"description":"Concordance's carried response token identifies this crew to the inhabited lower quarter."},
		{"x":_reservefall_center(f,route_room).x,"y":_reservefall_center(f,route_room).y,"name":"Hot tram approach" if route=="bastion" else "Shadow tram approach","kind":"reservefall_route","state":"complete" if resolved else "open" if state=="warning" else "sealed","route":route,"description":"A warned surface incursion is descending through the junction."},
		{"x":_reservefall_center(f,5).x,"y":_reservefall_center(f,5).y,"name":"Reservefall defense line","kind":"reservefall_line","state":"complete" if state=="held" else "available" if state=="warning" else "sealed","description":"Clear the incursion and rally three living colonists here to hold the lower quarter."},
		{"x":_reservefall_center(f,7).x,"y":_reservefall_center(f,7).y,"name":"Lower-quarter fallback","kind":"reservefall_fallback","state":"complete" if state=="withdrawn" else "available" if state=="warning" else "sealed","description":"Two colonists can withdraw here with the token and exactly 2 timber plus 2 scrap."},
		{"x":_reservefall_center(f,8).x,"y":_reservefall_center(f,8).y,"name":"Resident safe rooms","kind":"reservefall_safe","state":"open" if resolved else "sealed","description":"Stone doors shelter residents and crews from a junction breach."},
		{"x":_reservefall_center(f,9).x,"y":_reservefall_center(f,9).y,"name":"Inhabited lower road","kind":"reservefall_exit","state":"open" if resolved else "sealed","description":"Every incursion outcome leaves a connected road and a physical quarter pass."},
		{"x":_reservefall_center(f,1).x,"y":_reservefall_center(f,1).y,"name":"Reservefall signal board","kind":"reservefall_lore","description":"Chalk marks record which upper defenses drew the husks and which moving patrols intercepted them."}
	]
	for fresh in marks:
		var existing=f.landmarks.filter(func(mark):return mark.get("kind","")==fresh.kind)
		if existing.is_empty():f.landmarks.append(fresh)
		else:
			for key in fresh:existing[0][key]=fresh[key]

func _open_reservefall_warning(f:Dictionary):
	var route=_reservefall_route();var route_room=4 if route=="bastion" else 6
	for link in [[2,route_room],[route_room,5],[route_room,7]]:corridor(f.grid,_reservefall_center(f,link[0]),_reservefall_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("reservefall_guard")):
		for i in (4 if route=="bastion" else 2):
			var p=_reservefall_center(f,route_room)+Vector2i(i-1,0)
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":"Surface husk","hp":42.0,"clock":0.0,"attack":0.0,"reservefall_guard":i})
	if not f.structures.any(func(s):return bool(s.get("reservefall_lamp",false))):
		var lit=[2,route_room,5] if route=="bastion" else [2]
		for room_index in lit:
			var lamp=make_structure("lamp",_reservefall_center(f,room_index)+Vector2i(-2,0));lamp.reservefall_lamp=true;f.structures.append(lamp)
	data.reservefall_state="warning";data.reservefall_timer=30.0
	_add_reservefall(f,"warning",data.concordance_state);navigation_cache.erase(str(int(f.z)))

func reservefall_gathered(withdraw:bool=false)->int:
	if not data.floors.has("46"):return 0
	var target=Vector2i.ZERO
	for mark in floor_at(46).landmarks:
		if mark.get("kind","")==("reservefall_fallback" if withdraw else "reservefall_line"):target=point(mark);break
	return data.pawns.filter(func(pawn):return int(pawn.z)==46 and pawn.hp>0 and point(pawn).distance_to(target)<=4.0).size()

func _complete_reservefall(f:Dictionary,outcome:String,index:int=-1):
	var choice=5 if outcome=="held" else 7
	for link in [[choice,8],[8,9]]:corridor(f.grid,_reservefall_center(f,link[0]),_reservefall_center(f,link[1]),1)
	f.down=arr(_reservefall_center(f,9))
	if outcome!="held":f.enemies=f.enemies.filter(func(enemy):return not enemy.has("reservefall_guard"))
	if outcome=="held" and not f.structures.any(func(s):return bool(s.get("reservefall_defense",false))):
		for offset in [Vector2i(-2,0),Vector2i(2,0),Vector2i(0,2)]:
			var defense=make_structure("barricade",_reservefall_center(f,5)+offset);defense.reservefall_defense=true;f.structures.append(defense)
	var route=_reservefall_route();var items={"quarter_pass":1,"rations":1}
	if outcome=="held":items={"scrap":6,"crystal":3,"medkit":1,"quarter_pass":1} if route=="bastion" else {"rations":5,"medkit":3,"timber":1,"quarter_pass":1}
	elif outcome=="withdrawn":items={"timber":3,"scrap":2,"rations":2,"quarter_pass":1}
	var target=_reservefall_center(f,8)+Vector2i(1,0);var reward_name="Reservefall hold issue" if outcome=="held" else "Reservefall fallback stores" if outcome=="withdrawn" else "Reservefall breach cache"
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.reservefall_state=outcome;data.reservefall_timer=0.0;_add_reservefall(f,outcome,data.concordance_state);navigation_cache.erase(str(int(f.z)))
	for pawn in data.pawns:
		if int(pawn.z)==46 and pawn.job.get("kind","")=="reservefall":pawn.job={};pawn.orders=pawn.orders.filter(func(order):return order.get("kind","")!="reservefall")
	if index>=0:_remember_nearby(index,"survival","Faced Reservefall's surface incursion with {other}.",10.0,10)

func _reservefall_warning(dt:float):
	if data.reservefall_state!="warning" or bool(data.paused):return
	data.reservefall_timer=max(0.0,float(data.reservefall_timer)-dt)
	if float(data.reservefall_timer)>0.0:return
	var safe:Array=[]
	if data.floors.has("46"):
		var f=floor_at(46)
		for room_index in [0,1,8,9]:safe.append(Rect2i(int(f.rooms[room_index][0]),int(f.rooms[room_index][1]),int(f.rooms[room_index][2]),int(f.rooms[room_index][3])))
		for pawn in data.pawns:
			if int(pawn.z)!=46 or pawn.hp<=0:continue
			if not safe.any(func(room):return room.has_point(point(pawn))):pawn.hp=max(1.0,float(pawn.hp)-28.0);pawn.injury=min(3,int(pawn.injury)+1)
		_complete_reservefall(f,"breached")
		note("Reservefall's warning expires. The incursion breaches the junction, injuring exposed colonists, but the safe rooms hold and a quarter pass opens the lower road.")
		events.append({"kind":"reservefall"})

func reservefall_landmark()->Dictionary:
	if not data.floors.has("46"):return {}
	for mark in floor_at(46).landmarks:
		if mark.get("kind","")=="reservefall":return mark
	return {}

func order_reservefall(index:int,action:String,queued:bool=false)->String:
	var mark=reservefall_landmark()
	if mark.is_empty():return "Reservefall Junction is not reachable."
	var target=point(mark);var expected="reservefall_line" if action=="hold" else "reservefall_fallback" if action=="withdraw" else "reservefall"
	for candidate in floor_at(46).landmarks:
		if candidate.get("kind","")==expected:target=point(candidate);break
	return enqueue_order(index,"reservefall",target,{"action":action}) if queued else issue(index,"reservefall",target,{"action":action})

func _reserve_commons_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _reserve_commons_route(history:String="")->String:
	var source=history if history!="" else str(data.reservefall_state)
	return "guarded" if source=="held" else "sheltered" if source=="withdrawn" else "public"

func _reserve_commons_cost(route:String="")->Dictionary:
	var resolved=route if route!="" else _reserve_commons_route()
	return {"timber":2,"scrap":2} if resolved=="guarded" else {"timber":2,"scrap":3} if resolved=="sheltered" else {"timber":3,"scrap":3}

func _add_reserve_commons(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var route=_reserve_commons_route(history);var resolved=state in ["guarded","sheltered","public"]
	var route_room=4 if route=="guarded" else 7 if route=="sheltered" else 6
	var route_name="Resident shield court" if route=="guarded" else "Refuge culvert row" if route=="sheltered" else "Wary public arcade"
	var marks=[
		{"x":_reserve_commons_center(f,2).x,"y":_reserve_commons_center(f,2).y,"name":"Steward Nera","kind":"reserve_commons","state":state if state!="" else "waiting","route":route,"description":"Reservefall's held, withdrawn or breached history determines how the lower quarter receives this crew."},
		{"x":_reserve_commons_center(f,route_room).x,"y":_reserve_commons_center(f,route_room).y,"name":route_name,"kind":"reserve_commons_route","state":"complete" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"The junction outcome fixes this district's lighting, occupants and communal repair burden."},
		{"x":_reserve_commons_center(f,route_room).x+1,"y":_reserve_commons_center(f,route_room).y,"name":"Communal shield cache","kind":"reserve_commons_cache","state":"recovered" if resolved else "open" if state=="assigned" else "sealed","description":"Search for the physical 4 kg shield plate needed at the repair court."},
		{"x":_reserve_commons_center(f,5).x,"y":_reserve_commons_center(f,5).y,"name":"Reservefall repair court","kind":"reserve_commons_repair","state":state if resolved else "available" if state=="assigned" else "sealed","description":"Bring the quarter pass, communal shield and exact route-shaped materials here after securing the district."},
		{"x":_reserve_commons_center(f,9).x,"y":_reserve_commons_center(f,9).y,"name":"Shieldline descent","kind":"reserve_commons_exit","state":"open" if resolved else "sealed","description":"The deeper settlement road opens after the communal defense is repaired."},
		{"x":_reserve_commons_center(f,1).x,"y":_reserve_commons_center(f,1).y,"name":"Lower-quarter defense ledger","kind":"reserve_commons_lore","description":"Resident names are written beside movable shields rather than fixed walls: a defense meant to travel with its people."}
	]
	for mark in marks:
		var existing=f.landmarks.filter(func(candidate):return candidate.get("kind","")==mark.kind)
		if existing.is_empty():f.landmarks.append(mark)
		else:
			existing[0].state=mark.get("state",existing[0].get("state",""))
			if mark.has("route"):existing[0].route=route

func _open_reserve_commons(f:Dictionary):
	var route=_reserve_commons_route();var route_room=4 if route=="guarded" else 7 if route=="sheltered" else 6
	var links=[[2,3],[3,4],[4,5]] if route=="guarded" else [[2,6],[6,7],[7,5]] if route=="sheltered" else [[2,6],[6,5]]
	for link in links:corridor(f.grid,_reserve_commons_center(f,link[0]),_reserve_commons_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("reserve_commons_guard")):
		var names=["Burrower"] if route=="guarded" else ["Gloam stalker"] if route=="sheltered" else ["Surface husk","Surface husk"]
		for i in names.size():
			var p=_reserve_commons_center(f,route_room)+Vector2i(i-1,0);var name=str(names[i])
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":name,"hp":42.0 if name=="Surface husk" else 34.0 if name=="Gloam stalker" else 48.0,"clock":0.0,"attack":0.0,"reserve_commons_guard":i})
	if route=="guarded" and not f.structures.any(func(s):return bool(s.get("reserve_commons_lamp",false))):
		for room_index in [3,4,5]:var lamp=make_structure("lamp",_reserve_commons_center(f,room_index)+Vector2i(-2,0));lamp.reserve_commons_lamp=true;f.structures.append(lamp)
	if route=="public" and not f.structures.any(func(s):return bool(s.get("reserve_commons_lamp",false))):
		var lamp=make_structure("lamp",_reserve_commons_center(f,2)+Vector2i(-2,0));lamp.reserve_commons_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Reservefall shield cache"):
		var target=_reserve_commons_center(f,route_room)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Reservefall shield cache","searched":false,"items":{"quarter_shield":1},"kind":"salvage"})
	data.reserve_commons_state="assigned";_add_reserve_commons(f,"assigned",data.reservefall_state);navigation_cache.erase(str(int(f.z)))

func _complete_reserve_commons(f:Dictionary,outcome:String,index:int=-1):
	for link in [[5,8],[8,9]]:corridor(f.grid,_reserve_commons_center(f,link[0]),_reserve_commons_center(f,link[1]),1)
	f.down=arr(_reserve_commons_center(f,9))
	var items={"rations":5,"medkit":3,"crystal":1} if outcome=="guarded" else {"scrap":6,"crystal":3,"timber":2} if outcome=="sheltered" else {"rations":3,"medkit":2,"scrap":3,"timber":1}
	var target=_reserve_commons_center(f,8)+Vector2i(1,0);var reward_name="Reservefall guard stores" if outcome=="guarded" else "Reservefall refuge stores" if outcome=="sheltered" else "Reservefall common stores"
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.reserve_commons_state=outcome;_add_reserve_commons(f,outcome,data.reservefall_state);navigation_cache.erase(str(int(f.z)))
	if index>=0:_remember_nearby(index,"build","Repaired Reservefall Commons' movable defense with {other}.",10.0,10)

func reserve_commons_landmark()->Dictionary:
	if not data.floors.has("47"):return {}
	for mark in floor_at(47).landmarks:
		if mark.get("kind","")=="reserve_commons":return mark
	return {}

func order_reserve_commons(index:int,action:String,queued:bool=false)->String:
	var mark=reserve_commons_landmark()
	if mark.is_empty():return "Reservefall Commons is not reachable."
	var target=point(mark);var expected="reserve_commons_repair" if action=="finish" else "reserve_commons"
	for candidate in floor_at(47).landmarks:
		if candidate.get("kind","")==expected:target=point(candidate);break
	return enqueue_order(index,"reserve_commons",target,{"action":action}) if queued else issue(index,"reserve_commons",target,{"action":action})

func _shieldline_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _shieldline_route(history:String="")->String:
	var source=history if history!="" else str(data.reserve_commons_state)
	return source if source in ["guarded","sheltered","public"] else "public"

func _add_shieldline(f:Dictionary,state:String,history:String="",joined:bool=false):
	if f.rooms.is_empty():return
	var route=_shieldline_route(history);var resolved=state in ["guarded","sheltered","public"]
	var master=_shieldline_center(f,2);var master_name="Guard Shieldwright Kest" if route=="guarded" else "Refuge Shieldwright Kest" if route=="sheltered" else "Commons Shieldwright Kest"
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="shieldline"):
		f.landmarks.append({"x":master.x,"y":master.y,"name":master_name,"kind":"shieldline","state":state if state!="" else "waiting","route":route,"description":"Reservefall's repaired defense determines which Shieldline crew and cargo road remain. Kest can teach the expedition to build folding shieldwalls."})
	var frame_room=4 if route=="guarded" else 7 if route=="sheltered" else 4
	var axle_room=6 if route=="guarded" else 4 if route=="sheltered" else 7
	var frame=_shieldline_center(f,frame_room);var axle=_shieldline_center(f,axle_room);var carriage=_shieldline_center(f,8);var exit=_shieldline_center(f,9)
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="shieldline_lane" and mark.get("cargo","")=="shield_frame"):
		f.landmarks.append({"x":frame.x,"y":frame.y,"name":"Folding-frame lane","kind":"shieldline_lane","cargo":"shield_frame","state":"recovered" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"A six-kilogram folding frame must reach the carriage in its own physical pack."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="shieldline_lane" and mark.get("cargo","")=="shield_axle"):
		f.landmarks.append({"x":axle.x,"y":axle.y,"name":"Carriage-axle lane","kind":"shieldline_lane","cargo":"shield_axle","state":"recovered" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"A six-kilogram carriage axle must travel in a second colonist's pack."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="shieldline_carriage"):
		f.landmarks.append({"x":carriage.x,"y":carriage.y,"name":"Shieldline assembly carriage","kind":"shieldline_carriage","state":"complete" if resolved else "ready" if state=="assigned" else "sealed","description":"Bring both heavy parts in separate packs and gather three colonists including Kest."})
	if not joined and not resolved and not f.landmarks.any(func(mark):return mark.get("kind","")=="shieldline_recruit"):
		var recruit=_shieldline_center(f,5);f.landmarks.append({"x":recruit.x,"y":recruit.y,"name":"Kest","kind":"shieldline_recruit","state":"waiting","route":route,"description":"A mobile-defense specialist who joins with a separate route-shaped pack when the expedition accepts the carriage contract."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="shieldline_exit"):
		f.landmarks.append({"x":exit.x,"y":exit.y,"name":"Shieldline lower road","kind":"shieldline_exit","state":"open" if resolved else "sealed","description":"The lower works open after the mobile shield carriage is assembled."})
	if not f.landmarks.any(func(mark):return mark.get("kind","")=="shieldline_lore"):
		var lore=_shieldline_center(f,1);f.landmarks.append({"x":lore.x,"y":lore.y,"name":"Walking-wall doctrine","kind":"shieldline_lore","description":"Every diagram puts wheels under the wall. Reservefall survived by carrying its defenses instead of dying behind them."})
	for mark in f.landmarks:
		match str(mark.get("kind","")):
			"shieldline":mark.state=state if state!="" else "waiting";mark.route=route;mark.name=master_name
			"shieldline_lane":mark.state="recovered" if resolved else "open" if state=="assigned" else "sealed";mark.route=route
			"shieldline_carriage":mark.state="complete" if resolved else "ready" if state=="assigned" else "sealed"
			"shieldline_exit":mark.state="open" if resolved else "sealed"

func _kest_index()->int:
	for i in data.pawns.size():
		if data.pawns[i].name=="Kest" and data.pawns[i].hp>0:return i
	return -1

func shieldline_carriage()->Dictionary:
	if not data.floors.has("48"):return {}
	for mark in floor_at(48).landmarks:
		if mark.get("kind","")=="shieldline_carriage":return mark
	return {}

func shieldline_gathered()->int:
	var carriage=shieldline_carriage()
	if carriage.is_empty():return 0
	var total=0
	for pawn in data.pawns:
		if pawn.hp>0 and not incapacitated(pawn) and int(pawn.z)==48 and point(pawn).distance_to(point(carriage))<=4.0:total+=1
	return total

func _shieldline_carriers(target:Vector2i)->Array:
	var frames:Array=[];var axles:Array=[]
	for i in data.pawns.size():
		var pawn=data.pawns[i]
		if pawn.hp<=0 or incapacitated(pawn) or int(pawn.z)!=48 or point(pawn).distance_to(target)>4.0:continue
		if int(pawn.inventory.get("shield_frame",0))>0:frames.append(i)
		if int(pawn.inventory.get("shield_axle",0))>0:axles.append(i)
	for frame_index in frames:
		for axle_index in axles:
			if frame_index!=axle_index:return [frame_index,axle_index]
	return []

func _open_shieldline(f:Dictionary):
	var route=_shieldline_route()
	for link in [[2,3],[3,4],[2,6],[6,7],[4,5],[7,5],[5,8]]:corridor(f.grid,_shieldline_center(f,link[0]),_shieldline_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("shieldline_guard")):
		var guard_rooms=[4,6] if route=="guarded" else [7,4] if route=="sheltered" else [4,7]
		for i in guard_rooms.size():
			var p=_shieldline_center(f,guard_rooms[i]);var name="Burrower" if route=="guarded" or route=="public" and i==0 else "Gloam stalker"
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":name,"hp":38.0 if name=="Burrower" else 36.0,"clock":0.0,"attack":0.0,"shieldline_guard":i})
	if route=="guarded" and not f.structures.any(func(s):return bool(s.get("shieldline_lamp",false))):
		for room_index in [3,4,5]:var lamp=make_structure("lamp",_shieldline_center(f,room_index)+Vector2i(-2,0));lamp.shieldline_lamp=true;f.structures.append(lamp)
	if route=="public" and not f.structures.any(func(s):return bool(s.get("shieldline_lamp",false))):
		var lamp=make_structure("lamp",_shieldline_center(f,2)+Vector2i(-2,0));lamp.shieldline_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Shieldline frame rack"):
		var frame_room=4 if route=="guarded" else 7 if route=="sheltered" else 4;var frame=_shieldline_center(f,frame_room)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":frame.x,"y":frame.y,"name":"Shieldline frame rack","searched":false,"items":{"shield_frame":1},"kind":"salvage"})
	if not f.containers.any(func(c):return c.get("name","")=="Shieldline axle cradle"):
		var axle_room=6 if route=="guarded" else 4 if route=="sheltered" else 7;var axle=_shieldline_center(f,axle_room)+Vector2i(-1,0)
		f.containers.append({"id":next_id(),"x":axle.x,"y":axle.y,"name":"Shieldline axle cradle","searched":false,"items":{"shield_axle":1},"kind":"salvage"})
	if not data.shieldline_recruit_joined:
		data.shieldline_recruit_joined=true
		var spawn=_shieldline_center(f,5);var recruit=make_pawn("Kest",spawn.x,spawn.y,"slate");recruit.z=48
		if route=="guarded":recruit.skills={"scavenge":1,"build":2,"combat":4};recruit.inventory={"rations":2,"medkit":2}
		elif route=="sheltered":recruit.skills={"scavenge":2,"build":4,"combat":1};recruit.inventory={"timber":2,"scrap":2}
		else:recruit.skills={"scavenge":2,"build":3,"combat":3};recruit.inventory={"rations":1,"medkit":1,"scrap":1}
		data.pawns.append(recruit)
	f.landmarks=f.landmarks.filter(func(mark):return mark.get("kind","")!="shieldline_recruit")
	data.shieldline_state="assigned";_add_shieldline(f,"assigned",data.reserve_commons_state,true);navigation_cache.erase(str(int(f.z)))

func _complete_shieldline(f:Dictionary,outcome:String,index:int):
	for link in [[8,9]]:corridor(f.grid,_shieldline_center(f,link[0]),_shieldline_center(f,link[1]),1)
	f.down=arr(_shieldline_center(f,9))
	var items={"rations":5,"medkit":3,"scrap":2} if outcome=="guarded" else {"scrap":6,"crystal":3,"timber":2} if outcome=="sheltered" else {"rations":3,"medkit":2,"scrap":4,"timber":2}
	var target=_shieldline_center(f,8)+Vector2i(1,0);var reward_name="Shieldline guard issue" if outcome=="guarded" else "Shieldline refuge freight" if outcome=="sheltered" else "Shieldline commons stores"
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.shieldline_state=outcome;_add_shieldline(f,outcome,data.reserve_commons_state,true);navigation_cache.erase(str(int(f.z)))
	_remember_nearby(index,"building","Built Shieldline's walking wall with {other}.",10.0,10)

func shieldline_landmark()->Dictionary:
	if not data.floors.has("48"):return {}
	for mark in floor_at(48).landmarks:
		if mark.get("kind","")=="shieldline":return mark
	return {}

func order_shieldline(index:int,action:String,queued:bool=false)->String:
	var mark=shieldline_landmark()
	if mark.is_empty():return "Shieldline Works is not reachable."
	var target=point(mark)
	if action=="finish":
		var carriage=shieldline_carriage()
		if not carriage.is_empty():target=point(carriage)
	return enqueue_order(index,"shieldline",target,{"action":action}) if queued else issue(index,"shieldline",target,{"action":action})

func _marchhold_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _marchhold_route(history:String="")->String:
	var source=history if history!="" else str(data.shieldline_state)
	return source if source in ["guarded","sheltered","public"] else "public"

func _marchhold_deploy_cost()->Dictionary:
	return {"timber":2,"scrap":2}

func _marchhold_retreat_cost()->Dictionary:
	return {"rations":2,"medkit":1}

func _add_marchhold(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var route=_marchhold_route(history);var resolved=state in ["deployed","retreated","overrun"]
	var route_room=4 if route=="guarded" else 7 if route=="sheltered" else 6
	var route_name="Lamp-lit bridgeworks" if route=="guarded" else "Dark service span" if route=="sheltered" else "Broken public crossing"
	var marks=[
		{"x":_marchhold_center(f,2).x,"y":_marchhold_center(f,2).y,"name":"Marchwarden Sela","kind":"marchhold","state":state if state!="" else "waiting","route":route,"description":"Shieldline's walking-wall route determines how much light and surface pressure reaches this mobile camp."},
		{"x":_marchhold_center(f,route_room).x,"y":_marchhold_center(f,route_room).y,"name":route_name,"kind":"marchhold_route","state":"complete" if resolved else "open" if state=="warning" else "sealed","route":route,"description":"The warned surface pack must cross this span before the camp can move."},
		{"x":_marchhold_center(f,route_room).x+1,"y":_marchhold_center(f,route_room).y,"name":"Folded-wall cradle","kind":"marchhold_cache","state":"recovered" if resolved else "open" if state=="warning" else "sealed","description":"A physical 4 kg folded wall can anchor the crossing or leave with the retreating crew."},
		{"x":_marchhold_center(f,5).x,"y":_marchhold_center(f,5).y,"name":"Marchhold deployment line","kind":"marchhold_line","state":"complete" if state=="deployed" else "available" if state=="warning" else "sealed","description":"Clear the crossing and gather three colonists including Kest with the folded wall and exact construction materials."},
		{"x":_marchhold_center(f,8).x,"y":_marchhold_center(f,8).y,"name":"Mobile-camp retreat ramp","kind":"marchhold_fallback","state":"complete" if state=="retreated" else "available" if state=="warning" else "sealed","description":"Two colonists can carry the wall away with exact provisions, bypassing living threats."},
		{"x":_marchhold_center(f,1).x,"y":_marchhold_center(f,1).y,"name":"Stone refuge alcoves","kind":"marchhold_safe","state":"open" if resolved else "sealed","description":"Colonists inside the entry alcoves avoid an expired crossing warning."},
		{"x":_marchhold_center(f,9).x,"y":_marchhold_center(f,9).y,"name":"Marchhold lower road","kind":"marchhold_exit","state":"open" if resolved else "sealed","description":"Deployment, retreat or overrun all preserve a connected route below."},
		{"x":_marchhold_center(f,1).x-2,"y":_marchhold_center(f,1).y,"name":"Mobile-camp tally","kind":"marchhold_lore","description":"The tally counts walls recovered after a retreat. Losing ground is expected; losing the wall is not."}
	]
	for fresh in marks:
		var existing=f.landmarks.filter(func(mark):return mark.get("kind","")==fresh.kind)
		if existing.is_empty():f.landmarks.append(fresh)
		else:
			for key in fresh:existing[0][key]=fresh[key]

func _open_marchhold_warning(f:Dictionary):
	var route=_marchhold_route();var route_room=4 if route=="guarded" else 7 if route=="sheltered" else 6
	for link in [[2,route_room],[route_room,5],[route_room,8]]:corridor(f.grid,_marchhold_center(f,link[0]),_marchhold_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("marchhold_guard")):
		var count=4 if route=="guarded" else 2 if route=="sheltered" else 3
		for i in count:
			var p=_marchhold_center(f,route_room)+Vector2i(i-1,0)
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":"Surface husk","hp":42.0,"clock":0.0,"attack":0.0,"marchhold_guard":i})
	if not f.structures.any(func(s):return bool(s.get("marchhold_lamp",false))):
		var lit=[2,route_room,5] if route=="guarded" else [2,5] if route=="public" else [2]
		for room_index in lit:
			var lamp=make_structure("lamp",_marchhold_center(f,room_index)+Vector2i(-2,0));lamp.marchhold_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Marchhold folded wall cradle"):
		var target=_marchhold_center(f,route_room)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Marchhold folded wall cradle","searched":false,"items":{"march_wall":1},"kind":"salvage"})
	data.marchhold_state="warning";data.marchhold_timer=32.0
	_add_marchhold(f,"warning",data.shieldline_state);navigation_cache.erase(str(int(f.z)))

func marchhold_gathered(retreat:bool=false)->int:
	if not data.floors.has("49"):return 0
	var target=Vector2i.ZERO
	for mark in floor_at(49).landmarks:
		if mark.get("kind","")==("marchhold_fallback" if retreat else "marchhold_line"):target=point(mark);break
	return data.pawns.filter(func(pawn):return int(pawn.z)==49 and pawn.hp>0 and not incapacitated(pawn) and point(pawn).distance_to(target)<=4.0).size()

func _marchhold_kest_ready(target:Vector2i)->bool:
	var kest_index=_kest_index()
	return kest_index>=0 and int(data.pawns[kest_index].z)==49 and not incapacitated(data.pawns[kest_index]) and point(data.pawns[kest_index]).distance_to(target)<=4.0

func _complete_marchhold(f:Dictionary,outcome:String,index:int=-1):
	var choice=5 if outcome=="deployed" else 8
	for link in [[choice,9]]:corridor(f.grid,_marchhold_center(f,link[0]),_marchhold_center(f,link[1]),1)
	f.down=arr(_marchhold_center(f,9))
	if outcome!="deployed":f.enemies=f.enemies.filter(func(enemy):return not enemy.has("marchhold_guard"))
	if outcome=="deployed" and not f.structures.any(func(s):return bool(s.get("marchhold_defense",false))):
		for offset in [Vector2i(-2,0),Vector2i(0,0),Vector2i(2,0)]:
			var defense=make_structure("shieldwall",_marchhold_center(f,5)+offset);defense.marchhold_defense=true;f.structures.append(defense)
	var route=_marchhold_route();var items={"crossing_seal":1,"rations":1}
	if outcome=="deployed":items={"crossing_seal":1,"rations":5,"medkit":3,"scrap":2} if route=="guarded" else {"crossing_seal":1,"scrap":5,"crystal":3,"timber":2} if route=="sheltered" else {"crossing_seal":1,"rations":3,"medkit":2,"scrap":3,"timber":1}
	elif outcome=="retreated":items={"crossing_seal":1,"timber":3,"scrap":2,"rations":2}
	var target=_marchhold_center(f,9)+Vector2i(-1,0);var reward_name="Marchhold defense issue" if outcome=="deployed" else "Marchhold retreat stores" if outcome=="retreated" else "Marchhold overrun cache"
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.marchhold_state=outcome;data.marchhold_timer=0.0;_add_marchhold(f,outcome,data.shieldline_state);navigation_cache.erase(str(int(f.z)))
	for pawn in data.pawns:
		if int(pawn.z)==49 and pawn.job.get("kind","")=="marchhold":pawn.job={};pawn.orders=pawn.orders.filter(func(order):return order.get("kind","")!="marchhold")
	if index>=0:_remember_nearby(index,"survival","Moved Marchhold's wall with {other}.",10.0,10)

func _marchhold_warning(dt:float):
	if data.marchhold_state!="warning" or bool(data.paused):return
	data.marchhold_timer=max(0.0,float(data.marchhold_timer)-dt)
	if float(data.marchhold_timer)>0.0:return
	if data.floors.has("49"):
		var f=floor_at(49);var safe:Array=[]
		for room_index in [0,1]:safe.append(Rect2i(int(f.rooms[room_index][0]),int(f.rooms[room_index][1]),int(f.rooms[room_index][2]),int(f.rooms[room_index][3])))
		for pawn in data.pawns:
			if int(pawn.z)!=49 or pawn.hp<=0:continue
			if not safe.any(func(room):return room.has_point(point(pawn))):pawn.hp=max(1.0,float(pawn.hp)-30.0);pawn.injury=min(3,int(pawn.injury)+1)
		_complete_marchhold(f,"overrun")
		note("Marchhold's warning expires. The mobile camp is overrun and exposed colonists are injured, but the refuge alcoves hold and the lower road remains open.")
		events.append({"kind":"marchhold"})

func marchhold_landmark()->Dictionary:
	if not data.floors.has("49"):return {}
	for mark in floor_at(49).landmarks:
		if mark.get("kind","")=="marchhold":return mark
	return {}

func order_marchhold(index:int,action:String,queued:bool=false)->String:
	var mark=marchhold_landmark()
	if mark.is_empty():return "Marchhold Crossing is not reachable."
	var expected="marchhold_line" if action=="deploy" else "marchhold_fallback" if action=="retreat" else "marchhold"
	var target=point(mark)
	for candidate in floor_at(49).landmarks:
		if candidate.get("kind","")==expected:target=point(candidate);break
	return enqueue_order(index,"marchhold",target,{"action":action}) if queued else issue(index,"marchhold",target,{"action":action})

func _march_refuge_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _march_refuge_route(history:String="")->String:
	var source=history if history!="" else str(data.marchhold_state)
	return "guarded" if source=="deployed" else "sheltered" if source=="retreated" else "public"

func _march_refuge_cost(route:String="")->Dictionary:
	var resolved=route if route!="" else _march_refuge_route()
	return {"timber":2,"scrap":2} if resolved=="guarded" else {"timber":3,"scrap":2} if resolved=="sheltered" else {"timber":3,"scrap":3}

func _add_march_refuge(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var route=_march_refuge_route(history);var resolved=state in ["guarded","sheltered","public","walled"]
	var route_room=4 if route=="guarded" else 7 if route=="sheltered" else 6
	var route_name="Shielded welcome court" if route=="guarded" else "Hidden wagon row" if route=="sheltered" else "Broken public gallery"
	var marks=[
		{"x":_march_refuge_center(f,2).x,"y":_march_refuge_center(f,2).y,"name":"Refuge Keeper Orra","kind":"march_refuge","state":state if state!="" else "waiting","route":route,"description":"Marchhold's defense, retreat or overrun determines how this mobile settlement receives the crossing seal."},
		{"x":_march_refuge_center(f,route_room).x,"y":_march_refuge_center(f,route_room).y,"name":route_name,"kind":"march_refuge_route","state":"complete" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"The crossing outcome fixes this refuge road's light, threats and repair burden."},
		{"x":_march_refuge_center(f,route_room).x+1,"y":_march_refuge_center(f,route_room).y,"name":"Refuge brace cabinet","kind":"march_refuge_cache","state":"recovered" if resolved else "open" if state=="assigned" else "sealed","description":"A physical 4 kg brace can repair the refuge without taking the expedition's folded wall."},
		{"x":_march_refuge_center(f,5).x,"y":_march_refuge_center(f,5).y,"name":"Marchhold communal yard","kind":"march_refuge_repair","state":state if resolved else "available" if state=="assigned" else "sealed","description":"Secure the road, then repair with the brace and exact materials. A sheltered crew may instead donate its carried folded wall."},
		{"x":_march_refuge_center(f,9).x,"y":_march_refuge_center(f,9).y,"name":"Deep refuge road","kind":"march_refuge_exit","state":"open" if resolved else "sealed","description":"The deeper resident road opens after the communal defense is settled."},
		{"x":_march_refuge_center(f,1).x,"y":_march_refuge_center(f,1).y,"name":"Wall-keeper tally","kind":"march_refuge_lore","description":"Every mobile wall is marked with two owners: the people carrying it and the settlement that may someday need it."}
	]
	for fresh in marks:
		var existing=f.landmarks.filter(func(mark):return mark.get("kind","")==fresh.kind)
		if existing.is_empty():f.landmarks.append(fresh)
		else:
			for key in fresh:existing[0][key]=fresh[key]

func _open_march_refuge(f:Dictionary):
	var route=_march_refuge_route();var route_room=4 if route=="guarded" else 7 if route=="sheltered" else 6
	var links=[[2,3],[3,4],[4,5]] if route=="guarded" else [[2,6],[6,7],[7,5]] if route=="sheltered" else [[2,6],[6,5]]
	for link in links:corridor(f.grid,_march_refuge_center(f,link[0]),_march_refuge_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("march_refuge_guard")):
		var names=["Burrower"] if route=="guarded" else ["Gloam stalker"] if route=="sheltered" else ["Surface husk","Surface husk"]
		for i in names.size():
			var p=_march_refuge_center(f,route_room)+Vector2i(i-1,0);var name=str(names[i])
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":name,"hp":42.0 if name=="Surface husk" else 36.0 if name=="Gloam stalker" else 48.0,"clock":0.0,"attack":0.0,"march_refuge_guard":i})
	if route=="guarded" and not f.structures.any(func(s):return bool(s.get("march_refuge_lamp",false))):
		for room_index in [3,4,5]:var lamp=make_structure("lamp",_march_refuge_center(f,room_index)+Vector2i(-2,0));lamp.march_refuge_lamp=true;f.structures.append(lamp)
	if route=="public" and not f.structures.any(func(s):return bool(s.get("march_refuge_lamp",false))):
		var lamp=make_structure("lamp",_march_refuge_center(f,2)+Vector2i(-2,0));lamp.march_refuge_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Marchhold refuge brace cabinet"):
		var target=_march_refuge_center(f,route_room)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Marchhold refuge brace cabinet","searched":false,"items":{"refuge_brace":1},"kind":"salvage"})
	data.march_refuge_state="assigned";_add_march_refuge(f,"assigned",data.marchhold_state);navigation_cache.erase(str(int(f.z)))

func _complete_march_refuge(f:Dictionary,outcome:String,index:int=-1):
	for link in [[5,8],[8,9]]:corridor(f.grid,_march_refuge_center(f,link[0]),_march_refuge_center(f,link[1]),1)
	f.down=arr(_march_refuge_center(f,9))
	if outcome=="walled" and not f.structures.any(func(s):return bool(s.get("march_refuge_wall",false))):
		for offset in [Vector2i(-2,0),Vector2i(0,0),Vector2i(2,0)]:var wall=make_structure("shieldwall",_march_refuge_center(f,5)+offset);wall.march_refuge_wall=true;f.structures.append(wall)
	var items={"rations":5,"medkit":3,"scrap":2} if outcome=="guarded" else {"scrap":6,"crystal":3,"timber":2} if outcome=="sheltered" else {"rations":3,"medkit":2,"scrap":3,"timber":1} if outcome=="public" else {"rations":6,"medkit":4,"timber":2}
	var target=_march_refuge_center(f,8)+Vector2i(1,0);var reward_name="Marchhold guard stores" if outcome=="guarded" else "Marchhold shelter stores" if outcome=="sheltered" else "Marchhold public stores" if outcome=="public" else "Marchhold wall-keeper issue"
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.march_refuge_state=outcome;_add_march_refuge(f,outcome,data.marchhold_state);navigation_cache.erase(str(int(f.z)))
	if index>=0:_remember_nearby(index,"build","Settled Marchhold Refuge's defense with {other}.",10.0,10)

func march_refuge_landmark()->Dictionary:
	if not data.floors.has("50"):return {}
	for mark in floor_at(50).landmarks:
		if mark.get("kind","")=="march_refuge":return mark
	return {}

func order_march_refuge(index:int,action:String,queued:bool=false)->String:
	var mark=march_refuge_landmark()
	if mark.is_empty():return "Marchhold Refuge is not reachable."
	var target=point(mark)
	if action in ["repair","donate"]:
		for candidate in floor_at(50).landmarks:
			if candidate.get("kind","")=="march_refuge_repair":target=point(candidate);break
	return enqueue_order(index,"march_refuge",target,{"action":action}) if queued else issue(index,"march_refuge",target,{"action":action})

func _wallward_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _wallward_route(history:String="")->String:
	var source=history if history!="" else str(data.march_refuge_state)
	return source if source in ["guarded","sheltered","public","walled"] else "public"

func _add_wallward(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var route=_wallward_route(history);var resolved=state in ["escorted","screened","missed"]
	var route_room=4 if route in ["guarded","walled"] else 7 if route=="sheltered" else 6
	var route_name="Guard lantern descent" if route=="guarded" else "Wall-keeper descent" if route=="walled" else "Shadow convoy cut" if route=="sheltered" else "Broken public descent"
	var marks=[
		{"x":_wallward_center(f,2).x,"y":_wallward_center(f,2).y,"name":"Wallward signal post","kind":"wallward","state":state if state!="" else "waiting","route":route,"description":"Marchhold Refuge's defense determines the route and danger of this warned convoy rendezvous."},
		{"x":_wallward_center(f,route_room).x,"y":_wallward_center(f,route_room).y,"name":route_name,"kind":"wallward_route","state":"complete" if resolved else "open" if state=="warning" else "sealed","route":route,"description":"The refuge outcome fixes this convoy road's light and threats."},
		{"x":_wallward_center(f,route_room).x+1,"y":_wallward_center(f,route_room).y,"name":"Wallward beacon cabinet","kind":"wallward_cache","state":"recovered" if resolved else "open" if state=="warning" else "sealed","description":"The physical 3 kg beacon must reach the convoy rally or screened bypass."},
		{"x":_wallward_center(f,5).x,"y":_wallward_center(f,5).y,"name":"Convoy rally","kind":"wallward_rally","state":state if resolved else "available" if state=="warning" else "sealed","description":"Clear the route and gather three colonists here with the seal and beacon to escort the convoy."},
		{"x":_wallward_center(f,8).x,"y":_wallward_center(f,8).y,"name":"Screened bypass","kind":"wallward_screen","state":state if resolved else "available" if state=="warning" else "sealed","description":"Two colonists can screen the convoy with its beacon, 2 timber and 2 scrap without clearing the route."},
		{"x":_wallward_center(f,0).x,"y":_wallward_center(f,0).y,"name":"Upper refuge alcove","kind":"wallward_safe","description":"Colonists inside this marked alcove are protected if the convoy warning expires."},
		{"x":_wallward_center(f,1).x,"y":_wallward_center(f,1).y,"name":"Seal refuge alcove","kind":"wallward_safe","description":"Colonists inside this marked alcove are protected if the convoy warning expires."},
		{"x":_wallward_center(f,9).x,"y":_wallward_center(f,9).y,"name":"Wayfarer road","kind":"wallward_exit","state":"open" if resolved else "sealed","description":"The road to the next settlement opens after the convoy is escorted, screened or missed."},
		{"x":_wallward_center(f,1).x+2,"y":_wallward_center(f,1).y,"name":"Convoy chalkboard","kind":"wallward_lore","description":"One chalk line means safe passage. Two means surface movement. Three means the convoy never arrived."}
	]
	for fresh in marks:
		var existing=f.landmarks.filter(func(mark):return mark.get("kind","")==fresh.kind and (fresh.kind!="wallward_safe" or mark.get("name","")==fresh.name))
		if existing.is_empty():f.landmarks.append(fresh)
		else:
			for key in fresh:existing[0][key]=fresh[key]

func _open_wallward_warning(f:Dictionary):
	var route=_wallward_route();var route_room=4 if route in ["guarded","walled"] else 7 if route=="sheltered" else 6
	for link in [[2,route_room],[route_room,5],[route_room,8]]:corridor(f.grid,_wallward_center(f,link[0]),_wallward_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("wallward_guard")):
		var names=["Surface husk","Surface husk","Surface husk"] if route=="guarded" else ["Surface husk","Surface husk"] if route=="walled" else ["Gloam stalker","Gloam stalker"] if route=="sheltered" else ["Surface husk","Surface husk","Surface husk"]
		for i in names.size():
			var p=_wallward_center(f,route_room)+Vector2i(i-1,0);var enemy_name=str(names[i])
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":enemy_name,"hp":36.0 if enemy_name=="Gloam stalker" else 42.0,"clock":0.0,"attack":0.0,"wallward_guard":i})
	if route in ["guarded","walled","public"] and not f.structures.any(func(s):return bool(s.get("wallward_lamp",false))):
		var lit=[2,route_room,5] if route=="guarded" else [2,5] if route in ["walled","public"] else [2]
		for room_index in lit:
			var lamp=make_structure("lamp",_wallward_center(f,room_index)+Vector2i(-2,0));lamp.wallward_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Wallward convoy beacon cabinet"):
		var target=_wallward_center(f,route_room)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Wallward convoy beacon cabinet","searched":false,"items":{"wallward_beacon":1},"kind":"salvage"})
	data.wallward_state="warning";data.wallward_timer=30.0
	_add_wallward(f,"warning",data.march_refuge_state);navigation_cache.erase(str(int(f.z)))

func wallward_gathered(screened:bool=false)->int:
	if not data.floors.has("51"):return 0
	var target=Vector2i.ZERO
	for mark in floor_at(51).landmarks:
		if mark.get("kind","") == ("wallward_screen" if screened else "wallward_rally"):target=point(mark);break
	return data.pawns.filter(func(pawn):return int(pawn.z)==51 and pawn.hp>0 and not incapacitated(pawn) and point(pawn).distance_to(target)<=4.0).size()

func _complete_wallward(f:Dictionary,outcome:String,index:int=-1):
	var choice=8 if outcome=="screened" else 5
	for link in [[choice,9]]:corridor(f.grid,_wallward_center(f,link[0]),_wallward_center(f,link[1]),1)
	f.down=arr(_wallward_center(f,9))
	if outcome!="escorted":f.enemies=f.enemies.filter(func(enemy):return not enemy.has("wallward_guard"))
	var route=_wallward_route();var items={"convoy_tally":1,"rations":1}
	if outcome=="escorted":items={"convoy_tally":1,"rations":5,"medkit":3,"scrap":2} if route in ["guarded","walled"] else {"convoy_tally":1,"scrap":5,"crystal":3,"rations":2} if route=="sheltered" else {"convoy_tally":1,"rations":3,"medkit":2,"scrap":3}
	elif outcome=="screened":items={"convoy_tally":1,"rations":3,"crystal":2,"scrap":2}
	var target=_wallward_center(f,9)+Vector2i(-1,0);var reward_name="Wallward convoy issue" if outcome=="escorted" else "Wallward screen stores" if outcome=="screened" else "Missed convoy cache"
	if not f.containers.any(func(c):return c.get("name","")==reward_name):f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":reward_name,"searched":true,"items":items,"kind":"ground"})
	data.wallward_state=outcome;data.wallward_timer=0.0;_add_wallward(f,outcome,data.march_refuge_state);navigation_cache.erase(str(int(f.z)))
	for pawn in data.pawns:
		if int(pawn.z)==51 and pawn.job.get("kind","")=="wallward":pawn.job={};pawn.orders=pawn.orders.filter(func(order):return order.get("kind","")!="wallward")
	if index>=0:_remember_nearby(index,"survival","Met the Wallward convoy with {other}.",10.0,10)

func _wallward_warning(dt:float):
	if data.wallward_state!="warning" or bool(data.paused):return
	data.wallward_timer=max(0.0,float(data.wallward_timer)-dt)
	if float(data.wallward_timer)>0.0:return
	if data.floors.has("51"):
		var f=floor_at(51);var safe:Array=[]
		for room_index in [0,1]:safe.append(Rect2i(int(f.rooms[room_index][0]),int(f.rooms[room_index][1]),int(f.rooms[room_index][2]),int(f.rooms[room_index][3])))
		for pawn in data.pawns:
			if int(pawn.z)!=51 or pawn.hp<=0:continue
			if not safe.any(func(room):return room.has_point(point(pawn))):pawn.hp=max(1.0,float(pawn.hp)-25.0);pawn.injury=min(3,int(pawn.injury)+1)
		_complete_wallward(f,"missed")
		note("Wallward's convoy window closes. Exposed colonists are injured, but the refuge alcoves hold and a missed-convoy tally opens the lower road.")
		events.append({"kind":"wallward"})

func wallward_landmark()->Dictionary:
	if not data.floors.has("51"):return {}
	for mark in floor_at(51).landmarks:
		if mark.get("kind","")=="wallward":return mark
	return {}

func order_wallward(index:int,action:String,queued:bool=false)->String:
	var mark=wallward_landmark()
	if mark.is_empty():return "Wallward Descent is not reachable."
	var expected="wallward_rally" if action=="escort" else "wallward_screen" if action=="screen" else "wallward"
	var target=point(mark)
	for candidate in floor_at(51).landmarks:
		if candidate.get("kind","")==expected:target=point(candidate);break
	return enqueue_order(index,"wallward",target,{"action":action}) if queued else issue(index,"wallward",target,{"action":action})

func _wayfarer_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[min(index,f.rooms.size()-1)]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _carve_wayfarer_room(f:Dictionary,index:int):
	var room=_room_from_data(f.rooms[min(index,f.rooms.size()-1)])
	for y in range(room.position.y,room.end.y):
		for x in range(room.position.x,room.end.x):carve(f.grid,Vector2i(x,y))

func _wayfarer_route(history:String="current")->String:
	var source=str(data.wallward_state) if history=="current" else history
	return "resident" if source=="escorted" else "hidden" if source=="screened" else "public"

func wayfarer_cost(route:String="")->Dictionary:
	var path=route if route!="" else _wayfarer_route()
	return {"roadstead_jack":1,"timber":4,"scrap":3} if path=="resident" else {"roadstead_jack":1,"timber":3,"scrap":4} if path=="hidden" else {"roadstead_jack":1,"timber":4,"scrap":5}

func _add_wayfarer(f:Dictionary,state:String,history:String=""):
	if f.rooms.is_empty():return
	var route=_wayfarer_route(history);var resolved=state in ["resident","hidden","public"]
	var route_room=4 if route=="resident" else 7 if route=="hidden" else 6
	var marks=[
		{"x":_wayfarer_center(f,2).x,"y":_wayfarer_center(f,2).y,"name":"Roadkeeper Senn","kind":"wayfarer","state":state if state!="" else "waiting","route":route,"description":"Wallward's convoy tally records who arrived here. Senn needs a shared crew to mend the roadstead."},
		{"x":_wayfarer_center(f,route_room).x,"y":_wayfarer_center(f,route_room).y,"name":"Convoy welcome arcade" if route=="resident" else "Screened wagon lane" if route=="hidden" else "Stranded public court","kind":"wayfarer_route","state":"complete" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"Escorted convoys earn a lit welcome, screened convoys keep a dark lane, and a missed convoy leaves a damaged public court."},
		{"x":_wayfarer_center(f,route_room).x+1,"y":_wayfarer_center(f,route_room).y,"name":"Roadstead jack cradle","kind":"wayfarer_cache","state":"installed" if resolved else "open" if state=="assigned" else "sealed","description":"Recover the physical 6 kg jack. The jack and all repair supplies cannot fit in one 12 kg pack."},
		{"x":_wayfarer_center(f,5).x,"y":_wayfarer_center(f,5).y,"name":"Shared roadstead repair","kind":"wayfarer_repair","state":"complete" if resolved else "available" if state=="assigned" else "sealed","description":"Clear the reception road. Gather two fit colonists beside this court with the convoy tally, jack and exact materials in separate packs."},
		{"x":_wayfarer_center(f,9).x,"y":_wayfarer_center(f,9).y,"name":"Underway road","kind":"wayfarer_exit","state":"open" if resolved else "sealed","description":"The repaired roadstead connects the expedition to the deeper Underway."},
		{"x":_wayfarer_center(f,1).x,"y":_wayfarer_center(f,1).y,"name":"The road belongs to its carriers","kind":"wayfarer_lore","description":"Senn's ledger records loads, not promises. Two people must bear the cost of a road that everyone will use."}
	]
	for fresh in marks:
		var existing=f.landmarks.filter(func(mark):return mark.get("kind","")==fresh.kind)
		if existing.is_empty():f.landmarks.append(fresh)
		else:
			for key in fresh:existing[0][key]=fresh[key]

func _open_wayfarer(f:Dictionary):
	var route=_wayfarer_route();var lane=4 if route=="resident" else 7 if route=="hidden" else 6
	var links=[[2,3],[3,4],[4,5]] if route=="resident" else [[2,6],[6,7],[7,5]] if route=="hidden" else [[2,6],[6,5]]
	for link in links:
		_carve_wayfarer_room(f,link[1]);corridor(f.grid,_wayfarer_center(f,link[0]),_wayfarer_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("wayfarer_guard")):
		var names=["Burrower"] if route=="resident" else ["Gloam stalker"] if route=="hidden" else ["Surface husk","Surface husk"]
		for i in names.size():
			var p=_wayfarer_center(f,lane)+Vector2i(i-1,0);var enemy_name=str(names[i])
			f.enemies.append({"id":next_id(),"x":p.x,"y":p.y,"name":enemy_name,"hp":48.0 if enemy_name=="Burrower" else 34.0 if enemy_name=="Gloam stalker" else 42.0,"clock":0.0,"attack":0.0,"wayfarer_guard":i})
	if route!="hidden" and not f.structures.any(func(s):return bool(s.get("wayfarer_lamp",false))):
		var lit=[3,4,5] if route=="resident" else [2]
		for room_index in lit:
			var lamp=make_structure("lamp",_wayfarer_center(f,room_index)+Vector2i(-2,0));lamp.wayfarer_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(c):return c.get("name","")=="Wayfarer jack cradle"):
		var target=_wayfarer_center(f,lane)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Wayfarer jack cradle","searched":false,"items":{"roadstead_jack":1},"kind":"salvage"})
	data.wayfarer_state="assigned";_add_wayfarer(f,"assigned",data.wallward_state);navigation_cache.erase(str(int(f.z)))

func wayfarer_crew()->Array:
	if not data.floors.has("52"):return []
	var target=_wayfarer_center(floor_at(52),5);var crew:Array=[]
	for i in data.pawns.size():
		var pawn=data.pawns[i]
		if int(pawn.z)==52 and pawn.hp>0 and not incapacitated(pawn) and point(pawn).distance_to(target)<=4.0 and line_of_sight(52,point(pawn),target):crew.append(i)
	return crew

func wayfarer_available(item:String)->int:
	var total=0
	for index in wayfarer_crew():total+=int(data.pawns[index].inventory.get(item,0))
	return total

func _wayfarer_delivery()->Array:
	# Plan first; do not take anything until the complete, local delivery exists.
	var remaining=wayfarer_cost();var delivery:Array=[];var donors:Dictionary={}
	for index in wayfarer_crew():
		var pawn=data.pawns[index]
		for item in remaining:
			var amount=min(int(remaining[item]),int(pawn.inventory.get(item,0)))
			if amount>0:
				delivery.append({"pawn":index,"item":item,"amount":amount});donors[index]=true;remaining[item]-=amount
	if donors.size()<2 or remaining.values().any(func(amount):return int(amount)>0):return []
	return delivery

func wayfarer_repair_error(index:int)->String:
	if index<0 or index>=data.pawns.size() or not data.floors.has("52"):return "Select a colonist at Wayfarer Commons."
	if data.wayfarer_state!="assigned":return "Wayfarer's shared roadstead is not waiting for repair."
	if int(data.pawns[index].inventory.get("convoy_tally",0))<1:return "Keep the physical convoy tally in the selected repairer's pack."
	if floor_at(52).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("wayfarer_guard")):return "Clear Wayfarer's reception road before repairing the shared roadstead."
	var crew=wayfarer_crew()
	if not index in crew or crew.size()<2:return "Gather the tally bearer and another fit colonist beside the repair court."
	if _wayfarer_delivery().is_empty():return "Bring the 6 kg roadstead jack and exact timber and scrap in at least two nearby packs."
	return ""

func _complete_wayfarer(f:Dictionary,index:int,delivery:Array):
	for part in delivery:data.pawns[int(part.pawn)].inventory[part.item]-=int(part.amount)
	var route=_wayfarer_route()
	for link in [[5,8],[8,9]]:
		_carve_wayfarer_room(f,link[1]);corridor(f.grid,_wayfarer_center(f,link[0]),_wayfarer_center(f,link[1]),1)
	f.down=arr(_wayfarer_center(f,9))
	var items={"rations":6,"medkit":3,"timber":2} if route=="resident" else {"scrap":6,"crystal":3,"rations":2} if route=="hidden" else {"rations":4,"medkit":2,"scrap":3}
	var target=_wayfarer_center(f,8)+Vector2i(1,0)
	f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Wayfarer resident issue" if route=="resident" else "Wayfarer concealed freight" if route=="hidden" else "Wayfarer public stores","searched":true,"items":items,"kind":"ground"})
	data.wayfarer_state=route;_add_wayfarer(f,route,data.wallward_state);navigation_cache.erase(str(int(f.z)))
	data.pawns[index].skills.build+=1
	_remember_nearby(index,"build","Repaired Wayfarer's shared roadstead with {other}.",10.0,10)

func wayfarer_landmark()->Dictionary:
	if not data.floors.has("52"):return {}
	for mark in floor_at(52).landmarks:
		if mark.get("kind","")=="wayfarer":return mark
	return {}

func _underway_center(f:Dictionary,index:int)->Vector2i:
	var room=f.rooms[index]
	return Vector2i(int(room[0])+int(room[2])/2,int(room[1])+int(room[3])/2)

func _underway_route(history:String="current")->String:
	var source=data.wayfarer_state if history=="current" else history
	return source if source in ["resident","hidden","public"] else "public"

func underway_cost(choice:String)->Dictionary:
	return {"survey_kit":1,"scrap":3,"crystal":2} if choice=="lit" else {"survey_kit":1,"timber":2,"rations":3}

func _add_underway(f:Dictionary,state:String,history:String=""):
	f.landmarks=f.landmarks.filter(func(mark):return not str(mark.get("kind","")).begins_with("underway"))
	var route=_underway_route(history);var resolved=state in ["lit","hidden"]
	var approach_room=4 if route=="resident" else 6 if route=="hidden" else 5
	f.landmarks.append_array([
		{"x":_underway_center(f,1).x,"y":_underway_center(f,1).y,"name":"Underway survey post","kind":"underway","state":state if state!="" else "waiting","route":route,"description":"Wayfarer's carried tally opens a route-shaped survey into the buried road fork."},
		{"x":_underway_center(f,approach_room).x,"y":_underway_center(f,approach_room).y,"name":"Resident guideway" if route=="resident" else "Concealed cartway" if route=="hidden" else "Public rubble road","kind":"underway_route","state":"complete" if resolved else "open" if state=="assigned" else "sealed","route":route,"description":"Wayfarer's roadstead history determines the light and threats on this approach."},
		{"x":_underway_center(f,approach_room).x+1,"y":_underway_center(f,approach_room).y,"name":"Survey kit case","kind":"underway_cache","state":"installed" if resolved else "open" if state=="assigned" else "sealed","description":"Recover the physical 2 kg survey kit before choosing a road."},
		{"x":_underway_center(f,4).x,"y":_underway_center(f,4).y,"name":"Waylight bridge","kind":"underway_light","state":"complete" if state=="lit" else "sealed" if resolved else "available" if state=="assigned" else "sealed","description":"Install the kit with 3 scrap and 2 glowstone. The lit road grants recovery and supplies, but its heat draws two warned surface husks."},
		{"x":_underway_center(f,6).x,"y":_underway_center(f,6).y,"name":"Shrouded bypass","kind":"underway_hide","state":"complete" if state=="hidden" else "sealed" if resolved else "available" if state=="assigned" else "sealed","description":"Install the kit with 2 timber and 3 rations. The dark road grants pressure shelter and avoids a new incursion."},
		{"x":_underway_center(f,9).x,"y":_underway_center(f,9).y,"name":"Deeper Underway","kind":"underway_exit","state":"open" if resolved else "sealed","description":"The surveyed road continues toward the lower works."}
	])

func _open_underway(f:Dictionary):
	var route=_underway_route();var lane=4 if route=="resident" else 6 if route=="hidden" else 5
	# The inherited route determines the approach, but both visible survey choices
	# must be physically reachable once that approach has been cleared.
	for link in [[2,lane],[lane,4],[lane,6]]:
		_carve_wayfarer_room(f,link[1]);corridor(f.grid,_underway_center(f,link[0]),_underway_center(f,link[1]),1)
	if not f.enemies.any(func(enemy):return enemy.has("underway_guard")):
		var names=["Burrower"] if route=="resident" else ["Gloam stalker"] if route=="hidden" else ["Surface husk","Surface husk"]
		for i in names.size():
			var place=_underway_center(f,lane)+Vector2i(i-1,1)
			var enemy_name=str(names[i])
			f.enemies.append({"id":next_id(),"x":place.x,"y":place.y,"name":enemy_name,"hp":48.0 if enemy_name=="Burrower" else 34.0 if enemy_name=="Gloam stalker" else 42.0,"clock":0.0,"attack":0.0,"underway_guard":true})
	if route=="resident" and not f.structures.any(func(structure):return bool(structure.get("underway_approach_lamp",false))):
		var lamp=make_structure("lamp",_underway_center(f,lane)+Vector2i(-2,0));lamp.underway_approach_lamp=true;f.structures.append(lamp)
	if not f.containers.any(func(container):return container.get("name","")=="Underway survey case"):
		var target=_underway_center(f,lane)+Vector2i(1,0)
		f.containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Underway survey case","searched":false,"items":{"survey_kit":1},"kind":"salvage"})
	data.underway_state="assigned";_add_underway(f,"assigned",data.wayfarer_state);navigation_cache.erase(str(int(f.z)))

func underway_error(index:int,choice:String)->String:
	if index<0 or index>=data.pawns.size() or not data.floors.has("53"):return "Select a colonist at Underway Fork."
	if not choice in ["lit","hidden"] or data.underway_state!="assigned":return "The Underway fork is not waiting for a route decision."
	var pawn=data.pawns[index]
	if int(pawn.z)!=53:return "Bring the selected colonist to Underway Fork."
	if int(pawn.inventory.get("convoy_tally",0))<1:return "Keep Wayfarer's physical convoy tally with the surveyor."
	if floor_at(53).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("underway_guard")):return "Clear the Underway approach before setting the survey kit."
	var cost=underway_cost(choice)
	for item in cost:
		if int(pawn.inventory.get(item,0))<int(cost[item]):
			return "Carry the 2 kg survey kit with "+("3 scrap and 2 glowstone." if choice=="lit" else "2 timber and 3 rations.")
	return ""

func _complete_underway(f:Dictionary,index:int,choice:String):
	var pawn=data.pawns[index];var cost=underway_cost(choice)
	for item in cost:pawn.inventory[item]=int(pawn.inventory.get(item,0))-int(cost[item])
	pawn.inventory.route_token=int(pawn.inventory.get("route_token",0))+1
	for link in ([[2,4],[4,5],[5,9]] if choice=="lit" else [[2,6],[6,7],[7,9]]):
		_carve_wayfarer_room(f,link[1]);corridor(f.grid,_underway_center(f,link[0]),_underway_center(f,link[1]),1)
	f.down=arr(_underway_center(f,9))
	var issue=_underway_center(f,8 if choice=="lit" else 7)+Vector2i(1,0)
	var items={"rations":4,"medkit":2,"scrap":2} if choice=="lit" else {"scrap":4,"crystal":2,"rations":2}
	f.containers.append({"id":next_id(),"x":issue.x,"y":issue.y,"name":"Underway waylight issue" if choice=="lit" else "Underway concealed stores","searched":true,"items":items,"kind":"ground"})
	if choice=="lit":
		f.heat=float(f.heat)+8.0
		for room_index in [4,5,9]:
			var lamp=make_structure("lamp",_underway_center(f,room_index)+Vector2i(-2,0));lamp.underway_waylight=true;f.structures.append(lamp)
		for i in 2:
			var place=_underway_center(f,7)+Vector2i(i,0)
			f.enemies.append({"id":next_id(),"x":place.x,"y":place.y,"name":"Surface husk","hp":42.0,"clock":0.0,"attack":0.0,"underway_follow":true})
		pawn.hp=min(100.0,float(pawn.hp)+18.0);pawn.fatigue=max(0.0,float(pawn.fatigue)-18.0)
	data.underway_state=choice;_add_underway(f,choice,data.wayfarer_state);navigation_cache.erase(str(int(f.z)))
	_remember_nearby(index,"discovery","Surveyed the Underway road with {other}.",8.0,7)

func underway_landmark()->Dictionary:
	if not data.floors.has("53"):return {}
	for mark in floor_at(53).landmarks:
		if mark.get("kind","")=="underway":return mark
	return {}

func order_underway(index:int,action:String,queued:bool=false)->String:
	var mark=underway_landmark() if action=="start" else {}
	if action!="start" and data.floors.has("53"):
		var expected="underway_light" if action=="lit" else "underway_hide"
		for candidate in floor_at(53).landmarks:
			if candidate.get("kind","")==expected:mark=candidate;break
	if mark.is_empty():return "Underway Fork is not reachable."
	return enqueue_order(index,"underway",point(mark),{"action":action}) if queued else issue(index,"underway",point(mark),{"action":action})

func order_wayfarer(index:int,action:String,queued:bool=false)->String:
	var mark=wayfarer_landmark()
	if mark.is_empty():return "Wayfarer Commons is not reachable."
	var target=_wayfarer_center(floor_at(52),5) if action=="repair" else point(mark)
	return enqueue_order(index,"wayfarer",target,{"action":action}) if queued else issue(index,"wayfarer",target,{"action":action})

func valid(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < W and p.y < H

func walkable(z: int, p: Vector2i) -> bool:
	if not valid(p) or not data.floors.has(str(z)): return false
	if floor_at(z).grid[p.y][p.x] == 0: return false
	for s in floor_at(z).structures:
		if s.kind in ["barricade", "shieldwall", "bench", "relay"] and point(s) == p and s.hp > 0: return false
	return true

func path_to(z: int, start: Vector2i, target: Vector2i, near: bool = false) -> Array:
	if not valid(target): return []
	var blocking: Array = []
	for s in floor_at(z).structures:
		if s.kind in ["barricade", "shieldwall", "bench", "relay"] and s.hp > 0: blocking.append(arr(point(s)))
	var signature = str(blocking)
	if not navigation_cache.has(str(z)) or navigation_cache[str(z)].signature != signature:
		var grid = AStarGrid2D.new()
		grid.region = Rect2i(0, 0, W, H)
		grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
		grid.update()
		for y in H:
			for x in W: grid.set_point_solid(Vector2i(x,y), floor_at(z).grid[y][x] == 0)
		for b in blocking: grid.set_point_solid(vec(b),true)
		navigation_cache[str(z)] = {"astar":grid,"signature":signature}
	var astar = navigation_cache[str(z)].astar
	var goals = [target]
	if near:
		goals = [target]
		for d in DIRS: goals.append(target + d)
	var best: Array = []
	var found = false
	for goal in goals:
		if not walkable(z, goal): continue
		if start == goal: return [arr(start)]
		var route = astar.get_id_path(start, goal)
		if route.size() > 0 and (not found or route.size() < best.size()):
			best = []
			for p in route: best.append(arr(p))
			found = true
	return best

func line_of_sight(z: int, a: Vector2i, b: Vector2i) -> bool:
	var delta = b - a
	var length = max(abs(delta.x), abs(delta.y))
	if length == 0: return true
	for i in range(1, length):
		var p = Vector2i((Vector2(a) + Vector2(delta) * float(i) / float(length)).round())
		if not walkable(z, p): return false
	return true

func reveal_all():
	visible_cells.clear()
	for pawn in data.pawns:
		if pawn.hp <= 0: continue
		var z = int(pawn.z)
		if not visible_cells.has(str(z)): visible_cells[str(z)] = {}
		var radius = 8
		for y in range(max(0,pawn.y-radius),min(H,pawn.y+radius+1)):
			for x in range(max(0,pawn.x-radius),min(W,pawn.x+radius+1)):
				var p = Vector2i(x,y)
				if point(pawn).distance_squared_to(p) <= radius*radius and line_of_sight(z, point(pawn), p):
					visible_cells[str(z)][cell_key(p)] = true
					floor_at(z).seen[cell_key(p)] = true
		for s in floor_at(z).structures:
			if s.kind != "lamp": continue
			for y in range(max(0,s.y-5),min(H,s.y+6)):
				for x in range(max(0,s.x-5),min(W,s.x+6)):
					var p = Vector2i(x,y)
					if point(s).distance_to(p) < 5 and line_of_sight(z, point(s), p):
						visible_cells[str(z)][cell_key(p)] = true
						floor_at(z).seen[cell_key(p)] = true

func is_visible(z: int, p: Vector2i) -> bool:
	return visible_cells.get(str(z), {}).has(cell_key(p))

func weight(inventory: Dictionary) -> float:
	var total = 0.0
	for item in inventory: total += float(inventory[item]) * float(ITEMS.get(item, {"weight": 0}).weight)
	return total

func free_units(pawn: Dictionary, item: String) -> int:
	return max(0, int(floor((CAPACITY - weight(pawn.inventory) + 0.0001) / ITEMS[item].weight)))

func note(text: String):
	data.log.push_front(text)
	if data.log.size() > 30: data.log.resize(30)
	events.append({"kind": "note", "text": text})

func container_by_id(z: int, id: int) -> Dictionary:
	for c in floor_at(z).containers:
		if int(c.id) == id: return c
	return {}

func container_at(z: int, p: Vector2i) -> Dictionary:
	for c in floor_at(z).containers:
		if point(c) == p: return c
	return {}

func structure_at(z: int, p: Vector2i) -> Dictionary:
	for s in floor_at(z).structures:
		if point(s) == p: return s
	return {}

func structure_by_id(z:int,id:int)->Dictionary:
	for s in floor_at(z).structures:
		if int(s.id)==id:return s
	return {}

func make_structure(recipe:String,target:Vector2i)->Dictionary:
	var structure={"id":next_id(),"kind":recipe,"x":target.x,"y":target.y,"hp":35.0 if recipe=="tripwire" else 150.0 if recipe=="shieldwall" else 80.0}
	if recipe=="tripwire":
		structure.state="armed";structure.ring=0.0;structure.triggered_by=""
	return structure

func container_has_items(c:Dictionary)->bool:
	for item in c.get("items",{}):
		if int(c.items[item])>0:return true
	return false

func interaction_target(z:int,target:Vector2i,extra:Dictionary)->Dictionary:
	var object:Dictionary={}
	match str(extra.get("type","")):
		"container","blueprint":
			object=container_by_id(z,int(extra.get("id",-1)))
			if not object.is_empty() and (object.get("kind","")=="blueprint")!=(extra.type=="blueprint"):return {}
		"structure":object=structure_by_id(z,int(extra.get("id",-1)))
		"landmark":
			for mark in floor_at(z).landmarks:
				if point(mark)==target and mark.kind==extra.get("mark",""):object=mark;break
	if object.is_empty() or point(object)!=target:return {}
	return object

func order_interact(index:int,target:Vector2i,extra:Dictionary,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if interaction_target(int(data.pawns[index].z),target,extra).is_empty():return "That object is no longer here."
	return enqueue_order(index,"interact",target,extra) if queued else issue(index,"interact",target,extra)

func _search_container(index:int,c:Dictionary):
	if c.is_empty() or c.searched:return
	var p=data.pawns[index]
	c.searched=true
	p.skills.scavenge+=1
	floor_at(int(p.z)).heat+=2.5
	note(p.name+" searched "+c.name.to_lower()+". Supplies found.")
	_remember_nearby(index,"scavenge","Searched depth "+str(int(p.z)+1)+" supplies with {other}.",3.0,3)
	events.append({"kind":"search"})

func issue(index: int, kind: String, target: Vector2i, extra: Dictionary = {}) -> String:
	if index < 0 or index >= data.pawns.size(): return "Select a colonist."
	var p = data.pawns[index]
	if p.hp <= 0: return "This colonist is lost."
	if incapacitated(p):return "This colonist is incapacitated. Another colonist must rescue them."
	if not p.job.is_empty():
		if not bool(extra.get("automatic",false)) and bool(p.job.get("extra",{}).get("automatic",false)):
			p.job={};p.orders.clear()
		else:return "Finish, queue, or cancel the current order first."
	var z = int(p.z)
	if not valid(target): return "Outside the explored region."
	if not floor_at(z).seen.has(cell_key(target)) and not kind in ["travel","retreat"]: return "Explore closer to reveal that area."
	var near = kind in ["search", "transfer", "talk", "recruit", "outpost", "bellwether", "spindle", "ashline", "service", "foundry", "archive", "wake", "quiet", "stillworks", "cistern", "drowned", "tidecourt", "sump", "market", "depot", "refuge", "ashrail", "customs", "railcourt", "registry", "morrow", "terminus", "farline", "thimble", "latchwater", "driftglass", "bellhome", "commons", "yard", "kiln", "junction", "ember_commons", "deepcoil", "coilward", "charterwell", "writwell", "concordance", "reservefall", "reserve_commons", "shieldline", "marchhold", "march_refuge", "wallward","wayfarer","underway", "build", "construct", "dismantle", "reset_alarm", "rest", "spring", "pump", "rescue", "tend"]
	if kind=="rescue" and bool(extra.get("carrying",false)):near=false
	if kind=="interact":near=true
	var route = path_to(z, point(p), target, near)
	if route.is_empty(): return "No open route."
	if kind=="interact" and interaction_target(z,target,extra).is_empty():return "That object is no longer here."
	if kind == "search":
		var c = container_by_id(z, int(extra.get("container", -1)))
		if c.is_empty() or c.searched: return "Choose an unsearched container."
	if kind == "build":
		var recipe = str(extra.recipe)
		if not can_build(p, recipe): return "Carry the required materials in this colonist's pack."
		if not can_place(z, target): return "Choose an empty explored floor tile away from the stairs."
		if recipe == "relay" and z < 2: return "The signal cannot reach the deep city from this close to the surface."
		if recipe in ["barricade","shieldwall","bench","relay"] and not connection_after_block(z,target): return "Leave open routes through this level."
	if kind == "construct":
		var blueprint=container_by_id(z,int(extra.get("blueprint",-1)))
		if blueprint.is_empty() or blueprint.get("kind","")!="blueprint" or point(blueprint)!=target:return "That blueprint no longer exists."
		if not blueprint_ready(blueprint):return "The blueprint still needs materials."
		if blueprint.recipe in ["barricade","shieldwall","bench","relay"] and not connection_after_block(z,target):return "Leave open routes through this level."
	if kind=="dismantle":
		var structure=structure_by_id(z,int(extra.get("structure",-1)))
		if structure.is_empty() or point(structure)!=target:return "That camp structure is no longer here."
		if not DISMANTLE_RETURNS.has(structure.kind):return "That cannot be packed up."
		if str(extra.get("recipe",""))!=str(structure.kind):return "That structure changed before it could be packed."
		if structure.kind=="stockpile":
			var storage=container_by_id(z,int(structure.id))
			if storage.is_empty() or container_has_items(storage):return "Empty the supply chest before packing it up."
		if structure.kind=="bed":
			for patient in data.pawns:
				if int(patient.z)==z and int(patient.get("bed_id",-1))==int(structure.id):return "This bedroll is assigned to an injured colonist."
	if kind=="reset_alarm":
		var alarm_structure=structure_by_id(z,int(extra.get("structure",-1)))
		if alarm_structure.is_empty() or point(alarm_structure)!=target or alarm_structure.kind!="tripwire":return "That tripwire alarm is no longer here."
		if alarm_structure.get("state","armed")!="spent":return "The tripwire can only be reset after its ringing stops."
	if kind=="rest":
		var bed=structure_at(z,target)
		if bed.is_empty() or bed.get("kind","")!="bed":return "Choose a bedroll."
		if _bed_reserved(z,target,index):return "That bedroll is already reserved."
	if kind in ["rescue","tend"]:
		var patient_index=int(extra.get("patient",-1));var bed_id=int(extra.get("bed",-1))
		if patient_index<0 or patient_index>=data.pawns.size() or patient_index==index:return "Choose another incapacitated colonist."
		var patient=data.pawns[patient_index];var treatment_bed=structure_by_id(z,bed_id)
		if patient.hp<=0:return "That colonist was lost before help arrived."
		if not incapacitated(patient):return "That colonist can act without rescue."
		if int(patient.z)!=z:return "That colonist is on another level."
		if treatment_bed.is_empty() or treatment_bed.get("kind","")!="bed":return "The assigned bedroll is gone."
		if kind=="rescue":
			if not bool(extra.get("carrying",false)) and point(patient)!=target:return "The injured colonist moved before rescue began."
			if bool(extra.get("carrying",false)) and point(treatment_bed)!=target:return "The rescue route changed."
		elif kind=="tend":
			if pawn_at_bed(patient).is_empty() or point(patient)!=target:return "Rescue this colonist to a bedroll first."
			if not _safe_for_colony_work(z):return "Tending is unsafe while a visible threat or warning remains."
			if int(p.inventory.get("medkit",0))<1:return "The tending colonist must carry a medkit."
	if kind=="spring":
		var spring={}
		for mark in floor_at(z).landmarks:
			if mark.get("kind","")=="spring" and point(mark)==target:spring=mark;break
		if spring.is_empty() or spring.get("state","")!="untouched":return "The spring has already been changed."
		if not extra.get("choice","") in ["drink","harvest"]:return "Choose whether to drink or harvest the spring."
	if kind=="pump":
		var console={}
		for mark in floor_at(z).landmarks:
			if mark.get("kind","")=="pump_console" and point(mark)==target:console=mark;break
		if console.is_empty() or console.get("state","")!="idle":return "The emergency pump has already burned out."
		if not extra.get("choice","") in ["residences","substation"]:return "Choose which flooded branch to reclaim."
	if kind=="outpost":
		var council={}
		for mark in floor_at(z).landmarks:
			if mark.get("kind","")=="outpost" and point(mark)==target:council=mark;break
		if council.is_empty() or council.get("state","")!="waiting" or data.outpost_choice!="":return "Low Lantern has already recorded the expedition's choice."
		var choice=str(extra.get("choice",""));var cost={"rations":3,"medkit":1} if choice=="aid" else {"scrap":4,"crystal":2} if choice=="trade" else {}
		if cost.is_empty():return "Choose whether to aid Low Lantern or trade for supplies."
		for item in cost:
			if int(p.inventory.get(item,0))<int(cost[item]):return "Carry "+("3 rations and 1 medkit to aid the ward." if choice=="aid" else "4 scrap and 2 glowstone to make the trade.")
	if kind=="bellwether":
		var control={}
		for mark in floor_at(z).landmarks:
			if mark.get("kind","")=="bellwether" and point(mark)==target:control=mark;break
		if control.is_empty() or control.get("state","")!="waiting" or data.bellwether_choice!="":return "Bellwether's route is already fixed."
		if data.outpost_choice=="":return "Low Lantern's chart is needed before choosing a Bellwether route."
		var route_choice=str(extra.get("choice",""))
		if not route_choice in ["courier","maintenance"]:return "Choose the marked courier cage or maintenance bypass."
		if route_choice=="courier" and data.outpost_choice=="trade":
			if int(p.inventory.get("scrap",0))<2 or int(p.inventory.get("crystal",0))<1:return "Carry 2 scrap and 1 glowstone to repair the marked cage brake."
	if kind=="spindle":
		var watch={}
		for mark in floor_at(z).landmarks:
			if mark.get("kind","")=="spindle" and point(mark)==target:watch=mark;break
		if watch.is_empty() or watch.get("state","")!="waiting" or data.spindle_contact!="":return "Spindle Gate has already recorded this expedition."
		if data.bellwether_choice=="":return "Choose a Bellwether route before approaching Spindle Gate."
		if data.bellwether_choice=="maintenance" and floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "The Gate Watch will not open while burrowers remain in the breached intake."
	if kind=="ashline":
		var officer={}
		for mark in floor_at(z).landmarks:
			if mark.get("kind","")=="ashline" and point(mark)==target:officer=mark;break
		var action=str(extra.get("action",""))
		if officer.is_empty() or not action in ["accept","deliver"]:return "Ashline's screening officer is not here."
		if action=="accept":
			if officer.get("state","")!="waiting" or data.ashline_state!="":return "Ashline has already issued its field request."
			if data.spindle_contact=="":return "Make contact at Spindle Gate before submitting to Ashline."
		else:
			if officer.get("state","")!="assigned" or data.ashline_state!="assigned":return "Ashline is not waiting for a cartridge delivery."
			if int(p.inventory.get("filter",0))<1:return "The selected colonist must carry the purifier cartridge."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Ashline will not cycle quarantine while a breach threat remains."
	if kind=="service":
		var registrar={}
		for mark in floor_at(z).landmarks:
			if mark.get("kind","")=="service_ring" and point(mark)==target:registrar=mark;break
		var choice=str(extra.get("choice",""))
		if registrar.is_empty() or registrar.get("state","")!="waiting" or data.service_choice!="":return "The service ring has already recorded the expedition's terms."
		if data.ashline_state!="cleared":return "Ashline clearance is required before Meridian assigns standing terms."
		if not choice in ["city","field"]:return "Choose city quarters or an independent field charter."
		if choice=="field" and (int(p.inventory.get("scrap",0))<3 or int(p.inventory.get("crystal",0))<2):return "Carry 3 scrap and 2 glowstone to purchase the field charter."
	if kind=="foundry":
		var forewoman={}
		for mark in floor_at(z).landmarks:
			if mark.get("kind","")=="foundry" and point(mark)==target:forewoman=mark;break
		var action=str(extra.get("action",""))
		if forewoman.is_empty() or not action in ["accept","deliver","contract"]:return "Foundry Ward's forewoman is not here."
		if data.service_choice=="city":
			if action=="accept":
				if data.foundry_state!="" or forewoman.get("state","")!="waiting":return "Foundry Ward has already issued the municipal repair."
			elif action=="deliver":
				if data.foundry_state!="assigned" or forewoman.get("state","")!="assigned":return "Kes is not waiting for the foundry regulator."
				if int(p.inventory.get("coil",0))<1:return "The selected colonist must carry the foundry regulator."
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Kes will not restart the furnace while the repair line is occupied."
			else:return "Municipal standing requires the assigned furnace repair."
		elif data.service_choice=="field":
			if action!="contract" or data.foundry_state!="" or forewoman.get("state","")!="waiting":return "Independent standing has no municipal assignment here."
			if int(p.inventory.get("scrap",0))<5 or int(p.inventory.get("crystal",0))<2:return "Carry 5 scrap and 2 glowstone to post the independent material bond."
		else:return "Accept standing terms in Meridian's service ring first."
	if kind=="archive":
		var archivist={}
		for mark in floor_at(z).landmarks:
			if mark.get("kind","")=="archive" and point(mark)==target:archivist=mark;break
		var action=str(extra.get("action",""))
		if archivist.is_empty() or not action in ["open","share","preserve"]:return "Archive Junction's archivist is not here."
		if action=="open":
			if data.archive_choice!="" or archivist.get("state","")!="waiting":return "Archive Junction has already opened the survey record."
			if not data.foundry_state in ["municipal","independent"]:return "Complete Foundry Ward before requesting the route survey file."
		else:
			if data.archive_choice!="assigned" or archivist.get("state","")!="assigned":return "The traveler dossier is not awaiting a custody decision."
			if int(p.inventory.get("dossier",0))<1:return "The selected colonist must carry the traveler dossier."
	if kind=="wake":
		var contact={}
		for mark in floor_at(z).landmarks:
			if mark.get("kind","")=="wake" and point(mark)==target:contact=mark;break
		var action=str(extra.get("action",""))
		if contact.is_empty() or not action in ["start","finish"]:return "Surveyor's Wake has no route contact here."
		if action=="start":
			if data.wake_state!="" or contact.get("state","")!="waiting":return "The final survey recovery is already underway."
			if not data.archive_choice in ["shared","preserved"]:return "Resolve the traveler dossier at Archive Junction first."
			if data.archive_choice=="preserved" and int(p.inventory.get("dossier",0))<1:return "The selected colonist must carry the preserved traveler dossier."
		else:
			if data.wake_state!="assigned" or contact.get("state","")!="assigned":return "The missing survey team has not been located yet."
			if int(p.inventory.get("compass",0))<1:return "Carry the recovered survey compass back to the Wake."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Clear the recovery route before aligning the final descent."
	if kind=="quiet":
		var action=str(extra.get("action",""))
		if z!=16 or not action in ["tune","play"]:return "Quiet Mile's receiver cannot read that order."
		var current_floor=floor_at(z)
		if action=="tune":
			var stage=int(extra.get("stage",0));var post={}
			for mark in current_floor.landmarks:
				if mark.get("kind","")=="quiet_post" and int(mark.get("stage",0))==stage and point(mark)==target:post=mark;break
			if post.is_empty() or post.get("state","")!="available" or stage!=_quiet_rank(str(data.quiet_state))+1:return "That listening post is not the next signal in sequence."
		else:
			var receiver={}
			for mark in current_floor.landmarks:
				if mark.get("kind","")=="quiet_receiver" and point(mark)==target:receiver=mark;break
			if receiver.is_empty() or data.quiet_state!="open":return "Recover the final signal before returning to the receiver."
			if int(p.inventory.get("tape",0))<1:return "The selected colonist must carry the traveler's signal tape."
		var silence=quiet_error(index,target)
		if silence!="":return silence
	if kind=="stillworks":
		var manifold={}
		for mark in floor_at(z).landmarks:
			if mark.get("kind","")=="stillworks" and point(mark)==target:manifold=mark;break
		var choice=str(extra.get("choice",""))
		if z!=17 or manifold.is_empty() or manifold.get("state","")!="waiting" or data.stillworks_choice!="":return "The Stillworks manifold has already fixed its route."
		if not choice in ["restore","dark"]:return "Choose restoration or the dark overflow bypass."
		if data.quiet_state!="heard" or int(p.inventory.get("tape",0))<1:return "The selected colonist must carry the traveler's signal tape to read the maintenance bells."
		if choice=="restore" and (int(p.inventory.get("scrap",0))<4 or int(p.inventory.get("crystal",0))<2):return "Carry 4 scrap and 2 glowstone to restore the scrubbers."
		if choice=="dark" and (int(p.inventory.get("timber",0))<2 or int(p.inventory.get("scrap",0))<2):return "Carry 2 timber and 2 scrap to baffle the overflow route."
	if kind=="cistern":
		var keeper={}
		for mark in floor_at(z).landmarks:
			if mark.get("kind","")=="cistern" and point(mark)==target:keeper=mark;break
		var action=str(extra.get("action",""))
		if z!=18 or keeper.is_empty() or not action in ["start","finish"]:return "Cistern Spine's water keeper is not here."
		if action=="start":
			if data.stillworks_choice=="" or data.cistern_state!="" or keeper.get("state","")!="waiting":return "The reservoir request is not available."
		else:
			if data.cistern_state!="assigned" or keeper.get("state","")!="assigned":return "The water keepers are not waiting for the gate seal."
			if int(p.inventory.get("seal",0))<1:return "The selected colonist must carry the recovered cistern gate seal."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Secure the reservoir route before returning the gate seal."
	if kind=="drowned":
		var action=str(extra.get("action",""));var mark={};var expected_kind="drowned_control" if action=="start" else "drowned_rescue" if action=="rescue" else "drowned_salvage"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=19 or mark.is_empty() or not action in ["start","rescue","salvage"]:return "That Drowned Gallery order is unavailable."
		if action=="start" and (not data.cistern_state in ["pressure","spillway"] or data.drowned_state!="" or mark.get("state","")!="waiting"):return "The Gallery sluice cannot be cycled now."
		if action in ["rescue","salvage"] and (data.drowned_state!="warning" or mark.get("state","")!="available" or float(data.drowned_timer)<=0):return "The surge has already decided both gallery wings."
	if kind=="tidecourt":
		var clerk={}
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")=="tidecourt" and point(candidate)==target:clerk=candidate;break
		var action=str(extra.get("action",""));var court_route=_tidecourt_route()
		if z!=20 or clerk.is_empty() or not action in ["sponsor","contract","start","finish"]:return "That Tidecourt order is unavailable."
		if action in ["sponsor","contract","start"]:
			if data.tidecourt_state!="" or clerk.get("state","")!="waiting":return "Tidecourt has already recorded this expedition."
			if action=="sponsor" and court_route!="sponsor":return "Keeper sponsorship requires Olan's rescue."
			if action=="contract":
				if court_route!="contract":return "The regulator exchange requires recovered Gallery salvage."
				if int(p.inventory.get("scrap",0))<3 or int(p.inventory.get("crystal",0))<2:return "Carry 3 scrap and 2 glowstone to post Tidecourt's material bond."
			if action=="start" and court_route!="recovery":return "Public recovery is reserved for expeditions that lost both Gallery objectives."
		else:
			if data.tidecourt_state!="assigned" or clerk.get("state","")!="assigned":return "Tidecourt is not waiting for its water docket."
			if int(p.inventory.get("docket",0))<1:return "The selected colonist must carry the recovered water docket."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Clear the silted record route before returning the water docket."
	if kind=="sump":
		var pumpwright={}
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")=="sump" and point(candidate)==target:pumpwright=candidate;break
		var action=str(extra.get("action",""))
		if z!=21 or pumpwright.is_empty() or not action in ["start","finish"]:return "That Sump Commons order is unavailable."
		if action=="start":
			if data.sump_state!="" or pumpwright.get("state","")!="waiting" or not data.tidecourt_state in ["sponsored","contracted","recovered"]:return "The Commons pump repair is not available."
		else:
			if data.sump_state!="assigned" or pumpwright.get("state","")!="assigned":return "Pumpwright Edda is not waiting for the impeller."
			if int(p.inventory.get("impeller",0))<1:return "The selected colonist must carry the recovered pump impeller."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Secure the opened service route before returning the impeller."
	if kind=="market":
		var broker={}
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")=="market" and point(candidate)==target:broker=candidate;break
		var market_route=_market_route();var cost=_market_cost(market_route)
		if z!=22 or broker.is_empty() or data.market_state!="" or data.market_recruit_joined or broker.get("state","")!="waiting":return "That Mainspring exchange is unavailable."
		if not data.sump_state in ["resident","service","public"]:return "Establish Sump Commons before bargaining at Mainspring."
		for item in cost:
			if int(p.inventory.get(item,0))<int(cost[item]):return "Carry Mainspring's exact physical exchange in the selected colonist's pack."
	if kind=="depot":
		var dispatcher={}
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")=="depot" and point(candidate)==target:dispatcher=candidate;break
		var depot_action=str(extra.get("action",""))
		if z!=23 or dispatcher.is_empty() or not depot_action in ["start","finish"]:return "That Clockline Depot order is unavailable."
		if depot_action=="start":
			if data.depot_state!="" or dispatcher.get("state","")!="waiting" or not data.market_state in ["resident","service","public"]:return "Clockline's recovery route is not available."
			var tavi_index=_tavi_index()
			if tavi_index<0 or int(data.pawns[tavi_index].z)!=23 or point(data.pawns[tavi_index]).distance_to(target)>3.0:return "Bring Tavi beside Dispatcher Jun to identify the specialty route."
		else:
			if data.depot_state!="assigned" or dispatcher.get("state","")!="assigned":return "Clockline is not waiting for both freight mechanisms."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Secure both freight lanes before installation."
			if _depot_carriers(target).size()!=2:return "Bring the 6.5 kg traction drive and brake drum in two different colonist packs beside Jun."
	if kind=="refuge":
		var keeper={}
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")=="refuge" and point(candidate)==target:keeper=candidate;break
		var choice=str(extra.get("choice",""));var cost=_refuge_cost(choice)
		if z!=24 or keeper.is_empty() or data.refuge_state!="" or keeper.get("state","")!="waiting" or not data.depot_state in ["resident","service","public"]:return "That Switchyard evacuation plan is unavailable."
		if cost.is_empty():return "Choose whether to anchor the sanctuary or launch the mobile corridor."
		if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Secure the switch hall before moving the residents."
		for item in cost:
			if int(p.inventory.get(item,0))<int(cost[item]):return "Carry the evacuation plan's exact physical supplies in the selected colonist's pack."
	if kind=="ashrail":
		var steward={}
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")=="ashrail" and point(candidate)==target:steward=candidate;break
		var ash_route=_ashrail_route();var ash_cost=_ashrail_cost(ash_route)
		if z!=25 or steward.is_empty() or data.ashrail_state!="" or steward.get("state","")!="waiting" or not data.refuge_state in ["foothold","corridor"]:return "That Ashrail provisioning run is unavailable."
		if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Clear the opened Ashrail lane before stocking the far platform."
		for item in ash_cost:
			if int(p.inventory.get(item,0))<int(ash_cost[item]):return "Carry Ashrail's exact route-shaped provisions in the selected colonist's pack."
	if kind=="customs":
		var captain={}
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")=="customs" and point(candidate)==target:captain=candidate;break
		var customs_choice=str(extra.get("choice",""));var customs_cost=_customs_cost(customs_choice)
		if z!=26 or captain.is_empty() or data.customs_state!="" or captain.get("state","")!="waiting" or data.ashrail_state!="stocked" or customs_cost.is_empty():return "That Emberline customs route is unavailable."
		for item in customs_cost:
			if int(p.inventory.get(item,0))<int(customs_cost[item]):return "Carry Emberline's exact route-shaped tariff in the selected colonist's pack."
	if kind=="railcourt":
		var steward={}
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")=="railcourt" and point(candidate)==target:steward=candidate;break
		var rail_action=str(extra.get("action",""));var rail_route=_railcourt_route()
		if z!=27 or steward.is_empty() or not rail_action in ["start","finish","trade"]:return "That Railcourt order is unavailable."
		if rail_route=="authority":
			if rail_action=="start" and (data.railcourt_state!="" or steward.get("state","")!="waiting"):return "Railcourt's authority contract is not available."
			if rail_action=="finish":
				if data.railcourt_state!="assigned" or steward.get("state","")!="assigned":return "Magistrate Sera is not waiting for the switch warrant."
				if int(p.inventory.get("warrant",0))<1:return "The selected colonist must carry the recovered Railcourt switch warrant."
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Clear the seized switchhouse before returning its warrant."
			if rail_action=="trade":return "Declared expeditions receive public work instead of the resident exchange."
		else:
			if rail_action!="trade" or data.railcourt_state!="" or steward.get("state","")!="waiting":return "The resident compact is not available."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Clear the Gloam stalker from the resident undercroft first."
			if int(p.inventory.get("scrap",0))<3 or int(p.inventory.get("crystal",0))<2:return "Carry exactly 3 scrap and 2 glowstone for Railcourt's resident compact."
	if kind=="registry":
		var clerk={}
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")=="registry" and point(candidate)==target:clerk=candidate;break
		var registry_action=str(extra.get("action",""));var registry_route=_registry_route()
		if z!=28 or clerk.is_empty() or not registry_action in ["start","finish","copy"]:return "That Cinder Registry order is unavailable."
		if registry_route=="official":
			if registry_action=="start" and (data.registry_state!="" or clerk.get("state","")!="waiting"):return "Cinder Registry's public audit is not available."
			if registry_action=="finish":
				if data.registry_state!="assigned" or clerk.get("state","")!="assigned":return "Registrar Kade is not waiting for the registry plate."
				if int(p.inventory.get("plate",0))<1:return "The selected colonist must carry the recovered Cinder registry plate."
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Clear the charred audit vault before returning its plate."
			if registry_action=="copy":return "Licensed expeditions receive a public audit instead of the resident copy."
		else:
			if registry_action!="copy" or data.registry_state!="" or clerk.get("state","")!="waiting":return "The resident registry copy is not available."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Clear the Gloam stalker from the resident copy room first."
			if int(p.inventory.get("scrap",0))<4 or int(p.inventory.get("crystal",0))<1:return "Carry exactly 4 scrap and 1 glowstone for the off-ledger freight copy."
	if kind=="morrow":
		var dispatcher={}
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")=="morrow" and point(candidate)==target:dispatcher=candidate;break
		var morrow_action=str(extra.get("action",""))
		if z!=29 or dispatcher.is_empty() or not morrow_action in ["start","depart"]:return "That Morrow Exchange order is unavailable."
		if int(p.inventory.get("waybill",0))<1:return "The selected colonist must carry the physical Morrow freight waybill."
		if morrow_action=="start":
			if data.morrow_state!="" or dispatcher.get("state","")!="waiting" or not data.registry_state in ["official","resident"]:return "Morrow's next freight call is not available."
		else:
			if data.morrow_state!="boarding" or dispatcher.get("state","")!="boarding" or float(data.morrow_timer)<=0:return "That Morrow train has already departed."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Clear the loading lane before boarding Morrow's train."
			if morrow_gathered()<2:return "Rally at least two living colonists beside the Morrow dispatcher."
	if kind=="terminus":
		var speaker={}
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")=="terminus" and point(candidate)==target:speaker=candidate;break
		var terminus_action=str(extra.get("action",""));var terminus_route=_terminus_route()
		if z!=30 or speaker.is_empty() or not terminus_action in ["start","finish","pledge"]:return "That Morrow Terminus order is unavailable."
		if int(p.inventory.get("waybill",0))<1:return "The selected colonist must still carry the physical Morrow freight waybill."
		if terminus_route=="official":
			if terminus_action=="start" and (data.terminus_state!="" or speaker.get("state","")!="waiting"):return "Cairn Reach's witness request is not available."
			if terminus_action=="finish":
				if data.terminus_state!="assigned" or speaker.get("state","")!="assigned":return "Speaker Nera is not waiting for the witness ledger."
				if int(p.inventory.get("ledger",0))<1:return "The selected colonist must carry Cairn Reach's physical witness ledger."
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Clear the breached witness hall before returning its ledger."
			if terminus_action=="pledge":return "The stamped train must answer Cairn Reach's witness request."
		else:
			if terminus_action!="pledge" or data.terminus_state!="" or speaker.get("state","")!="waiting":return "The free-siding lift repair is not available."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Clear the Gloam stalker from Cairn Reach's free siding first."
			if int(p.inventory.get("scrap",0))<4 or int(p.inventory.get("crystal",0))<2:return "Carry exactly 4 scrap and 2 glowstone for Cairn Reach's communal far lift."
	if kind=="farline":
		var steward={}
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")=="farline" and point(candidate)==target:steward=candidate;break
		var farline_action=str(extra.get("action",""))
		if z!=31 or steward.is_empty() or not farline_action in ["start","finish"]:return "That Farline Commons order is unavailable."
		if farline_action=="start":
			if data.farline_state!="" or steward.get("state","")!="waiting" or not data.terminus_state in ["chartered","free"]:return "Farline's settlement road is not available."
		else:
			if data.farline_state!="assigned" or steward.get("state","")!="assigned":return "Farline is not waiting for the route braid."
			if int(p.inventory.get("braid",0))<1:return "The selected colonist must carry Farline's physical route braid."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):return "Clear Farline's chosen road before binding the route braid."
			if farline_gathered()<2:return "Rally at least two living colonists beside the Farline steward."
	if kind=="thimble":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="thimble_evacuation" if action=="depart" else "thimble"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=32 or mark.is_empty() or not action in ["defend","evacuate","hold","depart"]:return "That Thimble Crossing order is unavailable."
		if action in ["defend","evacuate"]:
			if data.thimble_state!="" or mark.get("state","")!="waiting" or not data.farline_state in ["accord","cacheway"]:return "Thimble's warning choice has already been made."
		elif action=="hold":
			if data.thimble_state!="defending" or float(data.thimble_timer)<=0:return "Thimble's defense window has closed."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("thimble_guard")):return "Clear the surface husks before sealing Thimble's breach."
			if thimble_gathered()<2:return "Rally at least two living colonists beside Thimble's warning bell."
		else:
			if data.thimble_state!="evacuating" or float(data.thimble_timer)<=0:return "Thimble's evacuation window has closed."
			if int(p.inventory.get("roster",0))<1:return "Carry Thimble's physical resident cord to the evacuation lift."
			if thimble_gathered(true)<2:return "Rally at least two living colonists beside Thimble's evacuation lift."
	if kind=="latchwater":
		var action=str(extra.get("action",""));var keeper={}
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")=="latchwater" and point(candidate)==target:keeper=candidate;break
		if z!=33 or keeper.is_empty() or not action in ["start","warm","cold"]:return "That Latchwater Ward order is unavailable."
		if action=="start":
			if data.latchwater_state!="" or keeper.get("state","")!="waiting" or not data.thimble_state in ["defended","evacuated","overrun"]:return "Latchwater's heater request is not available."
		else:
			if data.latchwater_state!="assigned" or keeper.get("state","")!="assigned":return "Latchwater is not waiting for its heat exchanger."
			if int(p.inventory.get("exchanger",0))<1:return "The selected colonist must carry Latchwater's physical heat exchanger."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("latchwater_guard")):return "Clear the heater route before installing its exchanger."
	if kind=="driftglass":
		var action=str(extra.get("action",""));var keeper={}
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")=="driftglass" and point(candidate)==target:keeper=candidate;break
		if z!=34 or keeper.is_empty() or not action in ["start","powered","shaded"]:return "That Driftglass Hall order is unavailable."
		if action=="start":
			if data.driftglass_state!="" or keeper.get("state","")!="waiting" or not data.latchwater_state in ["warm","cold"]:return "Driftglass's excavation request is not available."
		else:
			if data.driftglass_state!="assigned" or keeper.get("state","")!="assigned":return "Driftglass is not waiting for its focusing prism."
			if int(p.inventory.get("prism",0))<1:return "The selected colonist must carry Driftglass's physical focusing prism."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("driftglass_guard")):return "Clear the excavation route before setting its lens."
	if kind=="bellhome":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="bellhome_diversion" if action=="divert" else "bellhome_convoy" if action=="escort" else "bellhome"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=35 or mark.is_empty() or not action in ["start","escort","divert"]:return "That Bellhome Gate order is unavailable."
		if action=="start":
			if data.bellhome_state!="" or mark.get("state","")!="waiting" or not data.driftglass_state in ["powered","shaded"]:return "Bellhome's convoy warning is not available."
		else:
			if data.bellhome_state!="warning" or float(data.bellhome_timer)<=0:return "Bellhome's convoy window has closed."
			if int(p.inventory.get("charter",0))<1:return "Carry Bellhome's physical convoy charter."
			if action=="escort":
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("bellhome_guard")):return "Clear Bellhome's approach before escorting the convoy."
				if bellhome_gathered()<2:return "Rally at least two living colonists beside Bellhome's convoy."
			else:
				if int(p.inventory.get("timber",0))<2 or int(p.inventory.get("scrap",0))<2:return "The diversion requires exactly 2 timber and 2 scrap in the selected pack."
				if bellhome_gathered(true)<2:return "Rally at least two living colonists beside Bellhome's diversion culvert."
	if kind=="commons":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="commons_repair" if action=="finish" else "commons"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=36 or mark.is_empty() or not action in ["start","finish"]:return "That Bellhome Commons order is unavailable."
		if action=="start":
			if data.commons_state!="" or mark.get("state","")!="waiting" or not data.bellhome_state in ["escorted","diverted","retreated"]:return "Bellhome's housing repair is not available."
		else:
			if data.commons_state!="assigned" or mark.get("state","")!="available":return "Bellhome Commons is not waiting for the wall brace."
			if int(p.inventory.get("brace",0))<1:return "Carry Bellhome's physical wall brace to the housing frame."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("commons_guard")):return "Clear Bellhome's housing route before starting the repair."
			var cost=_commons_cost()
			for item in cost:
				if int(p.inventory.get(item,0))<int(cost[item]):return "Carry Bellhome's exact route-shaped timber and scrap contribution with the brace."
	if kind=="yard":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="yard_gantry" if action=="finish" else "yard"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=37 or mark.is_empty() or not action in ["start","finish"]:return "That Hearthline Yard order is unavailable."
		if action=="start":
			if data.yard_state!="" or mark.get("state","")!="waiting" or not data.commons_state in ["resident","culvert","public"] or data.yard_recruit_joined:return "Hearthline's expansion is not available."
		else:
			if data.yard_state!="assigned" or mark.get("state","")!="ready":return "Hearthline's gantry is not waiting for both mechanisms."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("yard_guard")):return "Clear Hearthline's cargo lanes before installation."
			if _yard_carriers(target).size()!=2:return "Bring the seven-kilogram thermal core and lift winch in two different colonist packs beside the gantry."
			var pell_index=_pell_index()
			if pell_index<0 or int(data.pawns[pell_index].z)!=37 or point(data.pawns[pell_index]).distance_to(target)>4.0:return "Bring Pell beside the Hearthline gantry."
			if yard_gathered()<3:return "Rally at least three living colonists beside the Hearthline gantry."
	if kind=="kiln":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="kiln_option" if action in ["build","conceal"] else "kiln"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=38 or mark.is_empty() or not action in ["start","build","conceal"]:return "That Kilnreach Works order is unavailable."
		if action=="start":
			if data.kiln_state!="" or mark.get("state","")!="waiting" or not data.yard_state in ["resident","culvert","public"]:return "Kilnreach's survey is not available."
			if index!=_pell_index():return "Pell must personally survey Kilnreach's abandoned controls."
		else:
			if data.kiln_state!="assigned" or mark.get("state","")!="available":return "Kilnreach is not waiting for its furnace commitment."
			if int(p.inventory.get("kiln_igniter",0))<1:return "Carry Kilnreach's physical ignition spindle to the furnace crown."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("kiln_guard")):return "Clear Kilnreach's route threats before committing the furnace."
			var cost=_kiln_cost(action)
			for item in cost:
				if int(p.inventory.get(item,0))<int(cost[item]):return "Carry the spindle with Kilnreach's exact route-shaped timber and scrap commitment."
	if kind=="junction":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="junction_platform" if action=="receive" else "junction_shunt" if action=="shunt" else "junction"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=39 or mark.is_empty() or not action in ["start","receive","shunt"]:return "That Embervault Junction order is unavailable."
		if action=="start":
			if data.junction_state!="" or mark.get("state","")!="waiting" or not data.kiln_state in ["built","concealed"]:return "Embervault's freight warning is not available."
		else:
			if data.junction_state!="warning" or float(data.junction_timer)<=0:return "Embervault's freight window has closed."
			if int(p.inventory.get("junction_seal",0))<1:return "Carry Embervault's physical signal seal."
			if action=="receive":
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("junction_guard")):return "Clear Embervault's approach before receiving the freight."
				if junction_gathered()<2:return "Rally at least two living colonists beside Embervault's freight platform."
			else:
				if int(p.inventory.get("timber",0))<2 or int(p.inventory.get("scrap",0))<2:return "The refuge shunt requires exactly 2 timber and 2 scrap in the selected pack."
				if junction_gathered(true)<2:return "Rally at least two living colonists beside Embervault's refuge shunt."
	if kind=="ember_commons":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="ember_commons_repair" if action=="finish" else "ember_commons"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=40 or mark.is_empty() or not action in ["start","finish"]:return "That Embervault Commons order is unavailable."
		if action=="start":
			if data.ember_commons_state!="" or mark.get("state","")!="waiting" or not data.junction_state in ["received","shunted","missed"]:return "Embervault's signal-house repair is not available."
		else:
			if data.ember_commons_state!="assigned" or mark.get("state","")!="available":return "Embervault Commons is not waiting for its signal breaker."
			if int(p.inventory.get("signal_breaker",0))<1:return "Carry Embervault's physical signal breaker to the signal house."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("ember_commons_guard")):return "Clear Embervault's settlement route before repairing the signal house."
			var cost=_ember_commons_cost()
			for item in cost:
				if int(p.inventory.get(item,0))<int(cost[item]):return "Carry the breaker with Embervault's exact route-shaped timber and scrap contribution."
	if kind=="deepcoil":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="deepcoil_sync" if action=="finish" else "deepcoil"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=41 or mark.is_empty() or not action in ["start","finish"]:return "That Deepcoil Relay order is unavailable."
		if action=="start":
			if data.deepcoil_state!="" or mark.get("state","")!="waiting" or not data.ember_commons_state in ["freight","refuge","public"]:return "Deepcoil's paired relay expedition is not available."
		else:
			if data.deepcoil_state!="assigned" or mark.get("state","")!="available":return "Deepcoil is not waiting for its paired coils."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("deepcoil_guard")):return "Clear both Deepcoil galleries before synchronizing the relay."
			if _deepcoil_carriers(target).size()!=2:return "Rally two distinct carriers beside the synchronizer, one with each physical Deepcoil coil."
	if kind=="coilward":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="coilward_seal" if action=="finish" else "coilward"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=42 or mark.is_empty() or not action in ["start","finish"]:return "That Coilward Commons order is unavailable."
		if action=="start":
			if data.coilward_state!="" or mark.get("state","")!="waiting" or not data.deepcoil_state in ["keepers","freeband","echo"]:return "Coilward's community charter is not available."
		else:
			if data.coilward_state!="assigned" or mark.get("state","")!="available":return "Coilward is not waiting for its charter."
			if int(p.inventory.get("ward_charter",0))<1:return "Carry Coilward's physical community charter to the council seal."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("coilward_guard")):return "Clear Coilward's settlement route before ratifying the charter."
			var cost=_coilward_cost()
			for item in cost:
				if int(p.inventory.get(item,0))<int(cost[item]):return "Carry the charter with Coilward's exact route-shaped contribution."
	if kind=="charterwell":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="charterwell_platform" if action=="escort" else "charterwell_supply" if action=="supply" else "charterwell"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=43 or mark.is_empty() or not action in ["start","escort","supply"]:return "That Charterwell Station order is unavailable."
		if action=="start":
			if data.charterwell_state!="" or mark.get("state","")!="waiting" or not data.coilward_state in ["keepers","freeband","echo"]:return "Charterwell's delegation warning is not available."
			if int(p.inventory.get("ward_charter",0))<1:return "Carry Coilward's signed physical charter to open Charterwell Station."
		else:
			if data.charterwell_state!="warning" or float(data.charterwell_timer)<=0:return "Charterwell's delegation has already departed."
			if int(p.inventory.get("ward_charter",0))<1:return "The selected colonist must carry Coilward's signed charter."
			if action=="escort":
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("charterwell_guard")):return "Clear Charterwell's approach before escorting the delegation."
				if charterwell_gathered()<3:return "Rally at least three living colonists beside Charterwell's delegation platform."
			else:
				var cost=_charterwell_cost()
				for item in cost:
					if int(p.inventory.get(item,0))<int(cost[item]):return "Carry the charter with Charterwell's exact route-shaped passage supplies."
				if charterwell_gathered(true)<2:return "Rally at least two living colonists beside Charterwell's supply gate."
	if kind=="writwell":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="writwell_table" if action=="pledge" else "writwell"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=44 or mark.is_empty() or not action in ["start","pledge"]:return "That Writwell Assembly order is unavailable."
		if action=="start":
			if data.writwell_state!="" or mark.get("state","")!="waiting" or not data.charterwell_state in ["escorted","supplied","missed"]:return "Writwell's multi-settlement vote is not available."
			if int(p.inventory.get("delegate_writ",0))<1:return "Carry Charterwell's physical delegation writ to convene Writwell Assembly."
		else:
			if data.writwell_state!="assigned" or mark.get("state","")!="available":return "Writwell is not waiting for its shared pledge."
			if int(p.inventory.get("delegate_writ",0))<1:return "The selected colonist must carry Charterwell's physical writ."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("writwell_guard")):return "Clear Writwell's delegate gallery before calling the vote."
			if writwell_crew().size()<3:return "Rally at least three living colonists beside Writwell's common table."
			if writwell_contributors()<2:return "Split Writwell's shared-supply pledge across at least two gathered packs."
			for item in _writwell_cost():
				if writwell_available(item)<int(_writwell_cost()[item]):return "The gathered packs do not hold Writwell's exact shared-supply pledge."
	if kind=="concordance":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="concordance_bastion" if action=="bastion" else "concordance_reserve" if action=="reserve" else "concordance"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=45 or mark.is_empty() or not action in ["start","bastion","reserve"]:return "That Concordance Gate order is unavailable."
		if action=="start":
			if data.concordance_state!="" or mark.get("state","")!="waiting" or not data.writwell_state in ["delegates","exchange","commons"]:return "Concordance Gate's coordinated defense is not available."
			if int(p.inventory.get("assembly_mandate",0))<1:return "Carry Writwell's physical assembly mandate to open Concordance Gate."
		else:
			if data.concordance_state!="assigned" or mark.get("state","")!="available":return "Concordance Gate is not waiting for that defense plan."
			if int(p.inventory.get("assembly_mandate",0))<1:return "The selected colonist must carry Writwell's physical assembly mandate."
			if action=="bastion":
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("concordance_guard")):return "Clear Concordance's approach before building the bastion."
				if concordance_gathered()<3:return "Rally at least three living colonists beside the Concordance bastion."
			else:
				if concordance_gathered(true)<2:return "Rally at least two living colonists beside the mobile reserve yard."
			for item in _concordance_cost(action):
				if int(p.inventory.get(item,0))<int(_concordance_cost(action)[item]):return "Carry the mandate with Concordance's exact chosen supplies."
	if kind=="reservefall":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="reservefall_line" if action=="hold" else "reservefall_fallback" if action=="withdraw" else "reservefall"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=46 or mark.is_empty() or not action in ["start","hold","withdraw"]:return "That Reservefall Junction order is unavailable."
		if action=="start":
			if data.reservefall_state!="" or mark.get("state","")!="waiting" or not data.concordance_state in ["bastion","reserve"]:return "Reservefall's lower-quarter warning is not available."
			if int(p.inventory.get("concordance_token",0))<1:return "Carry Concordance's physical response token to contact Reservefall."
		else:
			if data.reservefall_state!="warning" or float(data.reservefall_timer)<=0:return "Reservefall's incursion warning has already ended."
			if int(p.inventory.get("concordance_token",0))<1:return "The selected colonist must carry Concordance's physical response token."
			if action=="hold":
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("reservefall_guard")):return "Clear Reservefall's incursion before holding the defense line."
				if reservefall_gathered()<3:return "Rally at least three living colonists beside Reservefall's defense line."
			else:
				if reservefall_gathered(true)<2:return "Rally at least two living colonists beside Reservefall's fallback gate."
				for item in _reservefall_cost():
					if int(p.inventory.get(item,0))<int(_reservefall_cost()[item]):return "Carry the token with exactly 2 timber and 2 scrap for Reservefall's withdrawal."
	if kind=="reserve_commons":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="reserve_commons_repair" if action=="finish" else "reserve_commons"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=47 or mark.is_empty() or not action in ["start","finish"]:return "That Reservefall Commons order is unavailable."
		if action=="start":
			if data.reserve_commons_state!="" or mark.get("state","")!="waiting" or not data.reservefall_state in ["held","withdrawn","breached"]:return "Reservefall's communal defense repair is not available."
			if int(p.inventory.get("quarter_pass",0))<1:return "Carry Reservefall's physical quarter pass to enter the commons."
		else:
			if data.reserve_commons_state!="assigned" or mark.get("state","")!="available":return "Reservefall Commons is not waiting for its shield repair."
			if int(p.inventory.get("quarter_pass",0))<1 or int(p.inventory.get("quarter_shield",0))<1:return "Carry the quarter pass and physical communal shield to the repair court."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("reserve_commons_guard")):return "Clear Reservefall Commons' reception road before repairing the communal defense."
			var cost=_reserve_commons_cost()
			for item in cost:
				if int(p.inventory.get(item,0))<int(cost[item]):return "Carry the shield with Reservefall Commons' exact route-shaped timber and scrap contribution."
	if kind=="shieldline":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="shieldline_carriage" if action=="finish" else "shieldline"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=48 or mark.is_empty() or not action in ["start","finish"]:return "That Shieldline Works order is unavailable."
		if action=="start":
			if data.shieldline_state!="" or mark.get("state","")!="waiting" or not data.reserve_commons_state in ["guarded","sheltered","public"] or data.shieldline_recruit_joined:return "Shieldline's mobile-defense contract is not available."
			if int(p.inventory.get("quarter_pass",0))<1:return "Carry Reservefall's physical quarter pass to Shieldline Works."
		else:
			if data.shieldline_state!="assigned" or mark.get("state","")!="ready":return "Shieldline's carriage is not waiting for both heavy parts."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("shieldline_guard")):return "Clear Shieldline's component lanes before assembly."
			if _shieldline_carriers(target).size()!=2:return "Bring the six-kilogram folding frame and carriage axle in two different packs beside the carriage."
			var kest_index=_kest_index()
			if kest_index<0 or int(data.pawns[kest_index].z)!=48 or point(data.pawns[kest_index]).distance_to(target)>4.0:return "Bring Kest beside the Shieldline carriage."
			if shieldline_gathered()<3:return "Rally at least three living colonists beside the Shieldline carriage."
	if kind=="marchhold":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="marchhold_line" if action=="deploy" else "marchhold_fallback" if action=="retreat" else "marchhold"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=49 or mark.is_empty() or not action in ["start","deploy","retreat"]:return "That Marchhold Crossing order is unavailable."
		if action=="start":
			if data.marchhold_state!="" or mark.get("state","")!="waiting" or not data.shieldline_state in ["guarded","sheltered","public"] or _kest_index()<0:return "Marchhold's mobile-camp warning is not available."
		else:
			if data.marchhold_state!="warning" or float(data.marchhold_timer)<=0:return "Marchhold's crossing warning has already ended."
			if int(p.inventory.get("march_wall",0))<1:return "Carry Marchhold's physical folded wall to the chosen line."
			if action=="deploy":
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("marchhold_guard")):return "Clear Marchhold's surface pack before deploying the wall."
				if marchhold_gathered()<3:return "Rally at least three living colonists beside Marchhold's deployment line."
				if not _marchhold_kest_ready(target):return "Bring Kest beside Marchhold's deployment line."
				for item in _marchhold_deploy_cost():
					if int(p.inventory.get(item,0))<int(_marchhold_deploy_cost()[item]):return "Carry the folded wall with exactly 2 timber and 2 scrap for deployment."
			else:
				if marchhold_gathered(true)<2:return "Rally at least two living colonists beside Marchhold's retreat ramp."
				for item in _marchhold_retreat_cost():
					if int(p.inventory.get(item,0))<int(_marchhold_retreat_cost()[item]):return "Carry the folded wall with exactly 2 rations and 1 medkit for the retreat."
	if kind=="march_refuge":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="march_refuge_repair" if action in ["repair","donate"] else "march_refuge"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=50 or mark.is_empty() or not action in ["start","repair","donate"]:return "That Marchhold Refuge order is unavailable."
		if action=="start":
			if data.march_refuge_state!="" or mark.get("state","")!="waiting" or not data.marchhold_state in ["deployed","retreated","overrun"]:return "Marchhold Refuge is not ready to receive the crossing seal."
			if int(p.inventory.get("crossing_seal",0))<1:return "Carry Marchhold's physical crossing seal to Refuge Keeper Orra."
		else:
			if data.march_refuge_state!="assigned" or mark.get("state","")!="available":return "Marchhold Refuge is not waiting for its communal defense repair."
			if int(p.inventory.get("crossing_seal",0))<1:return "Keep Marchhold's physical crossing seal with the repair crew."
			if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("march_refuge_guard")):return "Clear Marchhold Refuge's reception road before repairing its defense."
			if action=="donate":
				if _march_refuge_route()!="sheltered":return "Only Marchhold's sheltered retreat can donate the still-mobile folded wall."
				if int(p.inventory.get("march_wall",0))<1 or int(p.inventory.get("timber",0))<1 or int(p.inventory.get("scrap",0))<1:return "Carry the folded wall with exactly 1 timber and 1 scrap to donate a mobile defense."
			else:
				if int(p.inventory.get("refuge_brace",0))<1:return "Carry Marchhold Refuge's physical brace to the communal yard."
				for item in _march_refuge_cost():
					if int(p.inventory.get(item,0))<int(_march_refuge_cost()[item]):return "Carry the brace with Marchhold Refuge's exact route-shaped timber and scrap contribution."
	if kind=="wayfarer":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="wayfarer_repair" if action=="repair" else "wayfarer"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=52 or mark.is_empty() or not action in ["start","repair"]:return "That Wayfarer Commons order is unavailable."
		if action=="start":
			if data.wayfarer_state!="" or mark.get("state","")!="waiting" or not data.wallward_state in ["escorted","screened","missed"]:return "Wayfarer Commons is not ready to receive the convoy tally."
			if int(p.inventory.get("convoy_tally",0))<1:return "Carry Wallward's physical convoy tally to Roadkeeper Senn."
		else:
			var repair_error=wayfarer_repair_error(index)
			if repair_error!="":return repair_error
	if kind=="underway":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="underway" if action=="start" else "underway_light" if action=="lit" else "underway_hide"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=53 or mark.is_empty() or not action in ["start","lit","hidden"]:return "That Underway survey order is unavailable."
		if action=="start":
			if data.underway_state!="" or mark.get("state","")!="waiting" or not data.wayfarer_state in ["resident","hidden","public"]:return "Underway Fork is not ready for Wayfarer's survey."
			if int(p.inventory.get("convoy_tally",0))<1:return "Carry Wayfarer's physical convoy tally to the survey post."
		else:
			var survey_error=underway_error(index,action)
			if survey_error!="":return survey_error
	if kind=="wallward":
		var action=str(extra.get("action",""));var mark:Dictionary={};var expected_kind="wallward_rally" if action=="escort" else "wallward_screen" if action=="screen" else "wallward"
		for candidate in floor_at(z).landmarks:
			if candidate.get("kind","")==expected_kind and point(candidate)==target:mark=candidate;break
		if z!=51 or mark.is_empty() or not action in ["start","escort","screen"]:return "That Wallward Descent order is unavailable."
		if action=="start":
			if data.wallward_state!="" or mark.get("state","")!="waiting" or not data.march_refuge_state in ["guarded","sheltered","public","walled"]:return "Wallward's convoy warning is not available."
			if int(p.inventory.get("crossing_seal",0))<1:return "Carry Marchhold's physical crossing seal to the Wallward signal post."
		else:
			if data.wallward_state!="warning" or float(data.wallward_timer)<=0:return "Wallward's convoy window has already closed."
			if int(p.inventory.get("crossing_seal",0))<1 or int(p.inventory.get("wallward_beacon",0))<1:return "Carry the crossing seal and physical Wallward beacon to the chosen rendezvous."
			if action=="escort":
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("wallward_guard")):return "Clear Wallward's convoy road before escorting the convoy."
				if wallward_gathered()<3:return "Rally at least three living colonists beside the convoy rally."
			else:
				if wallward_gathered(true)<2:return "Rally at least two living colonists beside the screened bypass."
				if int(p.inventory.get("timber",0))<2 or int(p.inventory.get("scrap",0))<2:return "Carry the beacon with exactly 2 timber and 2 scrap to screen the convoy."
	var seconds = {"search": 2.8, "transfer": 0.65, "talk": 1.0, "recruit":1.0, "outpost":4.0, "bellwether":4.5, "spindle":4.0, "ashline":4.0, "service":8.0, "foundry":4.0, "archive":4.0, "quiet":5.5, "stillworks":6.0, "cistern":4.5, "drowned":4.0, "tidecourt":4.0, "sump":4.5, "market":6.0, "depot":5.0, "refuge":6.0, "ashrail":5.5, "customs":5.5, "railcourt":5.0, "registry":5.0, "morrow":4.5, "terminus":5.0, "farline":5.0, "thimble":4.5, "latchwater":5.0, "driftglass":5.5, "bellhome":5.0, "commons":6.0, "yard":6.5, "kiln":6.0, "junction":5.5, "ember_commons":6.0, "deepcoil":6.5, "coilward":6.0, "charterwell":5.5, "writwell":6.5, "concordance":6.5, "reservefall":5.5, "reserve_commons":6.0, "shieldline":6.5, "marchhold":5.5, "march_refuge":6.0, "wallward":5.5, "wayfarer":6.0, "underway":5.5, "spring":2.5, "pump":3.5, "travel": 0.7, "retreat":0.7, "walk": 0.0, "rest": 12.0, "rescue":1.0, "tend":5.0, "build": 4.0, "construct":4.0, "dismantle":3.5, "reset_alarm":2.0}.get(kind, 0.0)
	if kind=="drowned" and str(extra.get("action",""))=="start":seconds=3.0
	if kind=="service" and str(extra.get("choice",""))=="field":seconds=5.0
	if kind=="foundry" and str(extra.get("action",""))=="contract":seconds=6.0
	if kind=="archive" and str(extra.get("action","")) in ["share","preserve"]:seconds=5.0
	if kind=="wake":seconds=5.0 if str(extra.get("action",""))=="finish" else 4.0
	if kind=="quiet" and str(extra.get("action",""))=="play":seconds=4.0
	if kind=="stillworks" and str(extra.get("choice",""))=="restore":seconds=7.0
	if kind=="tidecourt" and str(extra.get("action",""))=="contract":seconds=6.0
	if kind == "build": seconds = float(RECIPES[extra.recipe].time) / (1.0 + int(p.skills.build) * 0.02)
	if kind == "construct":seconds=float(RECIPES[extra.recipe].time)/(1.0+int(p.skills.build)*0.02)
	if kind=="dismantle":
		var dismantle_structure=structure_by_id(z,int(extra.structure))
		seconds=max(2.5,float(RECIPES[dismantle_structure.kind].time)*.75)/(1.0+int(p.skills.build)*0.02)
	if kind=="interact":
		var object=interaction_target(z,target,extra)
		seconds=2.8 if extra.type=="container" and not object.searched else 0.0
	if kind in ["search","interact"]: seconds /= 1.0 + int(p.skills.scavenge) * 0.025
	if kind != "walk":seconds*=1.0+int(p.injury)*0.15
	if not kind in ["walk","rest","travel","retreat"]:seconds*=(1.0+float(p.fatigue)*0.004)*morale_action_multiplier(p)
	if kind in ["build","construct"]:
		for bench in floor_at(z).structures:
			if bench.kind == "bench" and point(bench).distance_to(target) <= 6: seconds *= 0.75; break
	p.job = {"kind": kind, "target": arr(target), "path": route.slice(1), "elapsed": 0.0, "duration": seconds, "extra": extra.duplicate(true)}
	p.move_clock = 0.0
	return ""

func enqueue_order(index: int, kind: String, target: Vector2i, extra: Dictionary = {}) -> String:
	if index < 0 or index >= data.pawns.size(): return "Select a colonist."
	var p = data.pawns[index]
	if p.hp <= 0: return "This colonist is lost."
	if incapacitated(p):return "This colonist is incapacitated. Another colonist must rescue them."
	if not bool(extra.get("automatic",false)) and bool(p.job.get("extra",{}).get("automatic",false)):
		p.job={};p.orders.clear()
	if p.orders.size() >= 4: return "This colonist already has four waiting orders."
	if not valid(target): return "Outside the explored region."
	if kind != "travel" and not floor_at(p.z).seen.has(cell_key(target)): return "Explore closer to reveal that area."
	p.orders.append({"kind":kind,"target":arr(target),"extra":extra.duplicate(true),"z":int(p.z)})
	if p.job.is_empty(): start_next(index)
	return ""

func start_next(index: int):
	var p = data.pawns[index]
	while p.job.is_empty() and not p.orders.is_empty():
		var order = p.orders.pop_front()
		if int(order.get("z",p.z)) != int(p.z):
			note(p.name+" skipped an order left on another level.")
			continue
		var problem = issue(index,str(order.kind),vec(order.target),order.get("extra",{}))
		if problem != "": note(p.name+" skipped an order: "+problem)

func order_walk(index: int, target: Vector2i, queued: bool = false) -> String:
	return enqueue_order(index,"walk",target) if queued else issue(index,"walk",target)

func order_search(index: int, id: int, queued: bool = false) -> String:
	var pawn = data.pawns[index]
	var c = container_by_id(pawn.z, id)
	if c.is_empty(): return "No container."
	if c.searched: return "Choose an unsearched container."
	return enqueue_order(index,"search",point(c),{"container":id}) if queued else issue(index,"search",point(c),{"container":id})

func transfer_error(pawn: Dictionary, c: Dictionary, direction: String, item: String, quantity: int) -> String:
	if not ITEMS.has(item) or quantity <= 0: return "Choose an item and positive quantity."
	if not direction in ["take", "store"]: return "Choose Take or Store."
	if c.is_empty() or not c.searched: return "Search the container first."
	var source = c.items if direction == "take" else pawn.inventory
	if int(source.get(item,0)) < quantity: return "There are not enough of those items."
	if direction == "take" and quantity > free_units(pawn, item): return "That is too heavy for this colonist."
	return ""

func _new_stockpile(id:int,target:Vector2i)->Dictionary:
	var filters={}
	for item in ITEMS:filters[item]=true
	return {"id":id,"x":target.x,"y":target.y,"name":"Supply chest","searched":true,"items":{},"kind":"stockpile","auto_haul":true,"filters":filters}

func stockpile_accepts(c:Dictionary,item:String)->bool:
	return not c.is_empty() and c.get("kind","")=="stockpile" and bool(c.get("auto_haul",true)) and bool(c.get("filters",{}).get(item,true))

func _reserved_take(z:int,container_id:int,item:String)->int:
	var total=0
	for pawn in data.pawns:
		if int(pawn.z)!=z:continue
		var work:Array=[]
		if not pawn.job.is_empty():work.append(pawn.job)
		work.append_array(pawn.orders)
		for order in work:
			var extra=order.get("extra",{})
			if order.get("kind","")=="transfer" and extra.get("direction","")=="take" and int(extra.get("container",-1))==container_id and extra.get("item","")==item:
				total+=int(extra.get("quantity",0))
	return total

func _reserved_store(z:int,container_id:int,item:String)->int:
	var total=0
	for pawn in data.pawns:
		if int(pawn.z)!=z:continue
		var work:Array=[]
		if not pawn.job.is_empty():work.append(pawn.job)
		work.append_array(pawn.orders)
		for order in work:
			var extra=order.get("extra",{})
			if order.get("kind","")=="transfer" and extra.get("direction","")=="store" and int(extra.get("container",-1))==container_id and extra.get("item","")==item:
				total+=int(extra.get("quantity",0))
	return total

func _reserved_construct(z:int,blueprint_id:int)->bool:
	for pawn in data.pawns:
		if int(pawn.z)!=z:continue
		var work:Array=[]
		if not pawn.job.is_empty():work.append(pawn.job)
		work.append_array(pawn.orders)
		for order in work:
			if order.get("kind","")=="construct" and int(order.get("extra",{}).get("blueprint",-1))==blueprint_id:return true
	return false

func blueprint_ready(blueprint:Dictionary)->bool:
	if blueprint.is_empty() or blueprint.get("kind","")!="blueprint" or not RECIPES.has(blueprint.get("recipe","")):return false
	if not recipe_available(str(blueprint.recipe)):return false
	for item in RECIPES[blueprint.recipe].cost:
		if int(blueprint.items.get(item,0))<int(RECIPES[blueprint.recipe].cost[item]):return false
	return true

func place_designation(z:int,recipe:String,target:Vector2i)->String:
	if not RECIPES.has(recipe):return "Choose a structure."
	if not recipe_available(recipe):return "Complete Shieldline's walking wall before using that blueprint."
	if not data.floors.has(str(z)) or not can_place(z,target):return "Choose an empty explored floor tile away from the stairs."
	if recipe=="relay" and z<2:return "The signal cannot reach the deep city from this close to the surface."
	if recipe in ["barricade","shieldwall","bench","relay"] and not connection_after_block(z,target):return "Leave open routes through this level."
	var id=next_id()
	floor_at(z).containers.append({"id":id,"x":target.x,"y":target.y,"name":RECIPES[recipe].name+" blueprint","searched":true,"items":{},"kind":"blueprint","recipe":recipe})
	note(RECIPES[recipe].name+" blueprint marked for the colony.")
	return ""

func cancel_designation(z:int,id:int)->String:
	var blueprint=container_by_id(z,id)
	if blueprint.is_empty() or blueprint.get("kind","")!="blueprint":return "That blueprint no longer exists."
	for pawn in data.pawns:
		if int(pawn.z)!=z:continue
		var referenced=int(pawn.job.get("extra",{}).get("blueprint",-1))==id or (pawn.job.get("kind","")=="transfer" and int(pawn.job.get("extra",{}).get("container",-1))==id)
		for order in pawn.orders:
			if int(order.get("extra",{}).get("blueprint",-1))==id or (order.get("kind","")=="transfer" and int(order.get("extra",{}).get("container",-1))==id):referenced=true
		if referenced and bool(pawn.job.get("extra",{}).get("automatic",false)):
			pawn.job={};pawn.orders.clear()
	floor_at(z).containers.erase(blueprint)
	if not blueprint.items.is_empty():
		var pile={"id":next_id(),"x":blueprint.x,"y":blueprint.y,"name":"Recovered blueprint supplies","searched":true,"items":blueprint.items.duplicate(true),"kind":"ground"}
		floor_at(z).containers.append(pile)
	note(blueprint.name+" cancelled. Delivered materials remain on the ground.")
	return ""

func _safe_for_colony_work(z:int)->bool:
	if floor_at(z).alarm>=0:return false
	for enemy in floor_at(z).enemies:
		if enemy.hp>0 and is_visible(z,point(enemy)):return false
	return true

func incapacitated(pawn:Dictionary)->bool:
	return float(pawn.get("hp",0.0))>0.0 and (float(pawn.get("hp",0.0))<=20.0 or int(pawn.get("injury",0))>=3)

func pawn_at_bed(pawn:Dictionary)->Dictionary:
	var bed_id=int(pawn.get("bed_id",-1))
	if bed_id<1:return {}
	var bed=structure_by_id(int(pawn.z),bed_id)
	if bed.is_empty() or bed.get("kind","")!="bed" or point(bed)!=point(pawn):return {}
	return bed

func work_priority(index:int,role:String)->int:
	if index<0 or index>=data.pawns.size() or not role in ["haul","build"]:return 0
	return int(data.pawns[index].get("work",{}).get(role,1))

func automatic_role(job:Dictionary)->String:
	if job.is_empty() or not bool(job.get("extra",{}).get("automatic",false)):return ""
	return "build" if job.get("kind","")=="construct" else "haul" if job.get("kind","")=="transfer" else ""

func set_work_priority(index:int,role:String,level:int)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if not role in ["haul","build"] or level<0 or level>=WORK_LEVELS.size():return "Choose a valid work priority."
	var pawn=data.pawns[index]
	pawn.work[role]=level
	if level==0 and automatic_role(pawn.job)==role:
		pawn.job={};pawn.orders.clear()
		note(pawn.name+" stopped automatic "+role+" work. Carried items remain in their pack.")
	return ""

func _role_can_claim(index:int,role:String)->bool:
	var level=work_priority(index,role)
	if level<=0:return false
	var pawn=data.pawns[index]
	for other_index in data.pawns.size():
		if other_index==index:continue
		var other=data.pawns[other_index]
		if other.hp>0 and not incapacitated(other) and not other.drafted and int(other.z)==int(pawn.z) and other.job.is_empty() and other.orders.is_empty() and work_priority(other_index,role)>level:return false
	return true

func work_status(index:int)->String:
	if index<0 or index>=data.pawns.size():return "No colonist selected"
	var pawn=data.pawns[index]
	if pawn.hp<=0:return "Lost"
	if incapacitated(pawn):return "Incapacitated · awaiting safe tending" if not pawn_at_bed(pawn).is_empty() else "Incapacitated · rescue to a bedroll"
	if pawn.drafted:return "Drafted · colony work paused"
	if not _safe_for_colony_work(int(pawn.z)):return "Alert · colony work paused"
	if float(pawn.fatigue)>=80.0:
		return "Exhausted · resting when a bedroll is free" if not _nearest_free_bed(index).is_empty() else "Exhausted · no free bedroll on this level"
	var haul=work_priority(index,"haul");var build=work_priority(index,"build")
	if haul==0 and build==0:return "Idle · colony work disabled"
	var has_plan=false;var ready_plan=false
	for c in floor_at(pawn.z).containers:
		if c.get("kind","")=="blueprint":has_plan=true;ready_plan=ready_plan or blueprint_ready(c)
	if ready_plan and build==0:return "Idle · building disabled; plan is ready"
	if has_plan and not ready_plan and haul==0:return "Idle · hauling disabled; plan needs supplies"
	if has_plan:return "Idle · plan is waiting for supplies"
	if haul==0:return "Idle · hauling disabled"
	return "Ready · no enabled colony work"

func fatigue_state(pawn:Dictionary)->String:
	var level=float(pawn.get("fatigue",0.0))
	if level<30.0:return FATIGUE_LEVELS[0]
	if level<60.0:return FATIGUE_LEVELS[1]
	if level<85.0:return FATIGUE_LEVELS[2]
	return FATIGUE_LEVELS[3]

func morale_state(pawn:Dictionary)->String:
	var level=float(pawn.get("morale",60.0))
	if level<45.0:return MORALE_LEVELS[0]
	if level<75.0:return MORALE_LEVELS[1]
	return MORALE_LEVELS[2]

func morale_action_multiplier(pawn:Dictionary)->float:
	var level=float(pawn.get("morale",60.0))
	if level<45.0:return 1.15
	if level>=75.0:return 0.90
	return 1.0

func bond_with(pawn:Dictionary,other_name:String)->int:
	return int(pawn.get("bonds",{}).get(other_name,0))

func social_summary(index:int)->String:
	if index<0 or index>=data.pawns.size():return "Alone"
	var pawn=data.pawns[index];var companion=companion_for(index)
	if not companion.is_empty():return str(companion.name)+" nearby · bond "+str(bond_with(pawn,str(companion.name)))
	var strongest_name="";var strongest_value=-1
	for other_name in pawn.get("bonds",{}):
		var value=bond_with(pawn,str(other_name))
		if value>strongest_value:strongest_name=str(other_name);strongest_value=value
	if strongest_name!="":return strongest_name+" away · bond "+str(strongest_value)
	return "Alone"

func latest_memory(pawn:Dictionary)->String:
	var memories=pawn.get("memories",[])
	return "No shared memories yet." if memories.is_empty() else str(memories[0].text)

func _record_memory_one(index:int,other_index:int,kind:String,text_template:String,morale_delta:float,bond_delta:int)->bool:
	if index<0 or other_index<0 or index>=data.pawns.size() or other_index>=data.pawns.size() or index==other_index:return false
	var pawn=data.pawns[index];var other=data.pawns[other_index];var depth=int(pawn.z)
	for memory in pawn.memories:
		if memory.kind==kind and memory.with==other.name and int(memory.depth)==depth:return false
	var text=str(text_template).replace("{other}",str(other.name))
	pawn.memories.push_front({"kind":kind,"with":str(other.name),"depth":depth,"time":float(data.seconds),"text":text,"value":int(morale_delta)})
	if pawn.memories.size()>6:pawn.memories.resize(6)
	pawn.bonds[other.name]=clampi(bond_with(pawn,str(other.name))+bond_delta,0,100)
	pawn.morale=clampf(float(pawn.morale)+morale_delta,0.0,100.0)
	return true

func record_shared_memory(first_index:int,second_index:int,kind:String,text_template:String,morale_delta:float,bond_delta:int)->bool:
	if not kind in MEMORY_KINDS:return false
	var changed=_record_memory_one(first_index,second_index,kind,text_template,morale_delta,bond_delta)
	changed=_record_memory_one(second_index,first_index,kind,text_template,morale_delta,bond_delta) or changed
	return changed

func _remember_nearby(index:int,kind:String,text_template:String,morale_delta:float,bond_delta:int)->bool:
	var companion=companion_for(index)
	if companion.is_empty():return false
	return record_shared_memory(index,data.pawns.find(companion),kind,text_template,morale_delta,bond_delta)

func companion_for(index:int)->Dictionary:
	if index<0 or index>=data.pawns.size():return {}
	var pawn=data.pawns[index];var closest:Dictionary={};var distance=INF
	if pawn.hp<=0 or incapacitated(pawn):return {}
	for other_index in data.pawns.size():
		if other_index==index:continue
		var other=data.pawns[other_index]
		if other.hp<=0 or incapacitated(other) or int(other.z)!=int(pawn.z):continue
		var candidate=point(pawn).distance_to(point(other))
		if candidate<=5.0 and candidate<distance:distance=candidate;closest=other
	return closest

func fatigue_rate(index:int)->float:
	if index<0 or index>=data.pawns.size():return 0.0
	var pawn=data.pawns[index]
	if pawn.hp<=0 or pawn.job.get("kind","")=="rest":return 0.0
	if int(pawn.z)==5 and data.outpost_choice=="aid" and pawn.job.is_empty():return -0.055
	if int(pawn.z)==12 and data.service_choice=="city" and pawn.job.is_empty():return -0.07
	if int(pawn.z)==17 and data.stillworks_choice=="restore" and pawn.job.is_empty() and _safe_for_colony_work(17):return -0.08
	if int(pawn.z)==20 and data.tidecourt_state=="sponsored" and pawn.job.is_empty() and _safe_for_colony_work(20):return -0.07
	if int(pawn.z)==21 and data.sump_state in ["resident","service","public"] and pawn.job.is_empty() and _safe_for_colony_work(21):return -0.08 if data.sump_state=="resident" else -0.05
	if int(pawn.z)==24 and data.refuge_state=="foothold" and pawn.job.is_empty() and _safe_for_colony_work(24):return -0.075
	if int(pawn.z)==27 and data.railcourt_state=="licensed" and pawn.job.is_empty() and _safe_for_colony_work(27):return -0.07
	if int(pawn.z)==29 and data.morrow_state=="official" and pawn.job.is_empty() and _safe_for_colony_work(29):return -0.07
	if int(pawn.z)==30 and data.terminus_state=="chartered" and pawn.job.is_empty() and _safe_for_colony_work(30):return -0.075
	if int(pawn.z)==31 and data.farline_state=="accord" and pawn.job.is_empty() and _safe_for_colony_work(31):return -0.08
	if int(pawn.z)==32 and data.thimble_state=="defended" and pawn.job.is_empty() and _safe_for_colony_work(32):return -0.08
	if int(pawn.z)==33 and data.latchwater_state=="warm" and pawn.job.is_empty() and _safe_for_colony_work(33):return -0.075
	if int(pawn.z)==35 and data.bellhome_state=="escorted" and pawn.job.is_empty() and _safe_for_colony_work(35):return -0.075
	if int(pawn.z)==36 and data.commons_state in ["resident","public"] and pawn.job.is_empty() and _safe_for_colony_work(36):return -0.08 if data.commons_state=="resident" else -0.05
	if int(pawn.z)==37 and data.yard_state in ["resident","public"] and pawn.job.is_empty() and _safe_for_colony_work(37):return -0.085 if data.yard_state=="resident" else -0.05
	if int(pawn.z)==38 and data.kiln_state=="built" and pawn.job.is_empty() and _safe_for_colony_work(38):return -0.065
	if int(pawn.z)==39 and data.junction_state=="received" and pawn.job.is_empty() and _safe_for_colony_work(39):return -0.07
	if int(pawn.z)==40 and data.ember_commons_state in ["freight","public"] and pawn.job.is_empty() and _safe_for_colony_work(40):return -0.08 if data.ember_commons_state=="freight" else -0.05
	if int(pawn.z)==41 and data.deepcoil_state in ["keepers","echo"] and pawn.job.is_empty() and _safe_for_colony_work(41):return -0.085 if data.deepcoil_state=="keepers" else -0.05
	if int(pawn.z)==42 and data.coilward_state in ["keepers","echo"] and pawn.job.is_empty() and _safe_for_colony_work(42):return -0.085 if data.coilward_state=="keepers" else -0.05
	if int(pawn.z)==43 and data.charterwell_state=="escorted" and pawn.job.is_empty() and _safe_for_colony_work(43):return -0.08
	if int(pawn.z)==44 and data.writwell_state=="delegates" and pawn.job.is_empty() and _safe_for_colony_work(44):return -0.09
	if int(pawn.z)==45 and data.concordance_state=="bastion" and pawn.job.is_empty() and _safe_for_colony_work(45):return -0.09
	if int(pawn.z)==46 and data.reservefall_state=="held" and pawn.job.is_empty() and _safe_for_colony_work(46):return -0.09
	if int(pawn.z)==47 and data.reserve_commons_state=="guarded" and pawn.job.is_empty() and _safe_for_colony_work(47):return -0.09
	if int(pawn.z)==48 and data.shieldline_state in ["guarded","public"] and pawn.job.is_empty() and _safe_for_colony_work(48):return -0.095 if data.shieldline_state=="guarded" else -0.05
	if int(pawn.z)==49 and data.marchhold_state=="deployed" and pawn.job.is_empty() and _safe_for_colony_work(49):return -0.095
	if int(pawn.z)==50 and data.march_refuge_state in ["guarded","walled"] and pawn.job.is_empty() and _safe_for_colony_work(50):return -0.095
	if int(pawn.z)==51 and data.wallward_state=="escorted" and pawn.job.is_empty() and _safe_for_colony_work(51):return -0.09
	if int(pawn.z)==52 and data.wayfarer_state in ["resident","public"] and pawn.job.is_empty() and _safe_for_colony_work(52):return -0.1 if data.wayfarer_state=="resident" else -0.045
	if int(pawn.z)==53 and data.underway_state=="lit" and pawn.job.is_empty() and _safe_for_colony_work(53):return -0.08
	var rate=0.018
	if not pawn.job.is_empty():rate+=0.026
	var companion=companion_for(index)
	if not companion.is_empty():rate*=max(0.55,0.68-float(bond_with(pawn,str(companion.name)))*0.0025)
	if float(pawn.morale)<45.0:rate*=1.20
	elif float(pawn.morale)>=75.0:rate*=0.85
	return rate

func _bed_reserved(z:int,target:Vector2i,except_index:int)->bool:
	for other_index in data.pawns.size():
		if other_index==except_index:continue
		var other=data.pawns[other_index]
		if int(other.z)!=z:continue
		if int(other.get("bed_id",-1))>0:
			var assigned=structure_by_id(z,int(other.bed_id))
			if not assigned.is_empty() and point(assigned)==target:return true
		if other.job.get("kind","")=="rest" and vec(other.job.target)==target:return true
		if other.job.get("kind","") in ["rescue","tend"] and int(other.job.get("extra",{}).get("bed",-1))>0:
			var active_bed=structure_by_id(z,int(other.job.extra.bed))
			if not active_bed.is_empty() and point(active_bed)==target:return true
		for order in other.orders:
			if order.kind=="rest" and vec(order.target)==target:return true
			if order.kind in ["rescue","tend"] and int(order.get("extra",{}).get("bed",-1))>0:
				var waiting_bed=structure_by_id(z,int(order.extra.bed))
				if not waiting_bed.is_empty() and point(waiting_bed)==target:return true
	return false

func _patient_reserved(patient_index:int,except_index:int)->bool:
	for other_index in data.pawns.size():
		if other_index==except_index:continue
		var other=data.pawns[other_index];var work:Array=[]
		if not other.job.is_empty():work.append(other.job)
		work.append_array(other.orders)
		for order in work:
			if order.get("kind","") in ["rescue","tend"] and int(order.get("extra",{}).get("patient",-1))==patient_index:return true
	return false

func _nearest_free_bed(index:int)->Dictionary:
	if index<0 or index>=data.pawns.size():return {}
	var pawn=data.pawns[index];var best:Dictionary={};var best_distance=999999
	for structure in floor_at(pawn.z).structures:
		if structure.kind!="bed" or structure.hp<=0 or _bed_reserved(int(pawn.z),point(structure),index):continue
		var route=path_to(int(pawn.z),point(pawn),point(structure),true)
		if not route.is_empty() and route.size()<best_distance:best_distance=route.size();best=structure
	return best

func claim_recovery(index:int)->bool:
	var pawn=data.pawns[index]
	if pawn.hp<=0 or pawn.drafted or float(pawn.fatigue)<80.0 or not pawn.job.is_empty() or not pawn.orders.is_empty():return false
	if not _safe_for_colony_work(int(pawn.z)):return false
	var bed=_nearest_free_bed(index)
	if bed.is_empty():return false
	if enqueue_order(index,"rest",point(bed),{"automatic":true})!="":return false
	note(pawn.name+" is exhausted and is heading for a bedroll.")
	return true

func claim_construction_work(index:int)->bool:
	var pawn=data.pawns[index]
	var z=int(pawn.z)
	var build_allowed=_role_can_claim(index,"build")
	var haul_allowed=_role_can_claim(index,"haul")
	var blueprints:Array=[]
	for c in floor_at(z).containers:
		if c.get("kind","")=="blueprint":blueprints.append(c)
	# Ready plans become construction work, reserved to one builder.
	for blueprint in blueprints:
		if not build_allowed:break
		if blueprint_ready(blueprint) and not _reserved_construct(z,int(blueprint.id)):
			var extra={"blueprint":blueprint.id,"recipe":blueprint.recipe,"automatic":true}
			if enqueue_order(index,"construct",point(blueprint),extra)=="":
				note(pawn.name+" is building "+RECIPES[blueprint.recipe].name.to_lower()+".")
				return true
	# Carry useful materials already in the pack before fetching another load.
	for blueprint in blueprints:
		if not haul_allowed:break
		for item in RECIPES[blueprint.recipe].cost:
			var missing=int(RECIPES[blueprint.recipe].cost[item])-int(blueprint.items.get(item,0))-_reserved_store(z,int(blueprint.id),item)
			var reserve=int({"rations":2,"medkit":1}.get(item,0))
			var quantity=min(missing,max(0,int(pawn.inventory.get(item,0))-reserve),4)
			if quantity<=0:continue
			var extra={"container":blueprint.id,"direction":"store","item":item,"quantity":quantity,"automatic":true}
			if enqueue_order(index,"transfer",point(blueprint),extra)=="":
				note(pawn.name+" is supplying "+blueprint.name.to_lower()+".")
				return true
	# Otherwise reserve an exact source-to-blueprint delivery.
	if not haul_allowed:return false
	var best:Dictionary={};var best_distance=999999
	for blueprint in blueprints:
		for item in RECIPES[blueprint.recipe].cost:
			var missing=int(RECIPES[blueprint.recipe].cost[item])-int(blueprint.items.get(item,0))-_reserved_store(z,int(blueprint.id),item)
			if missing<=0:continue
			for source in floor_at(z).containers:
				if source.get("kind","")=="blueprint" or not source.get("searched",false):continue
				var available=int(source.items.get(item,0))-_reserved_take(z,int(source.id),item)
				var quantity=min(missing,available,free_units(pawn,item),4)
				if quantity<=0:continue
				var to_source=path_to(z,point(pawn),point(source),true)
				var to_plan=path_to(z,point(source),point(blueprint),true)
				if to_source.is_empty() or to_plan.is_empty():continue
				var distance=to_source.size()+to_plan.size()-(3 if source.get("kind","")=="stockpile" else 0)
				if distance<best_distance:
					best_distance=distance;best={"source":source,"blueprint":blueprint,"item":item,"quantity":quantity}
	if best.is_empty():return false
	var take={"container":best.source.id,"direction":"take","item":best.item,"quantity":best.quantity,"automatic":true}
	var deliver={"container":best.blueprint.id,"direction":"store","item":best.item,"quantity":best.quantity,"automatic":true}
	if enqueue_order(index,"transfer",point(best.source),take)!="":return false
	enqueue_order(index,"transfer",point(best.blueprint),deliver)
	note(pawn.name+" is bringing "+str(best.quantity)+" "+str(best.item)+" to "+best.blueprint.name.to_lower()+".")
	return true

func claim_colony_work(index:int)->bool:
	var pawn=data.pawns[index]
	if pawn.hp<=0 or pawn.drafted or not pawn.job.is_empty() or not pawn.orders.is_empty():return false
	var z=int(pawn.z)
	if not _safe_for_colony_work(z):return false
	if claim_construction_work(index):return true
	if not _role_can_claim(index,"haul"):return false
	var destinations:Array=[]
	for c in floor_at(z).containers:
		if c.get("kind","")=="stockpile" and bool(c.get("auto_haul",true)):destinations.append(c)
	if destinations.is_empty():return false
	# Put away excess carried materials first, but retain a small survival kit.
	var best:Dictionary={}
	var best_distance=999999
	for destination in destinations:
		for item in ITEMS:
			if not stockpile_accepts(destination,item):continue
			var reserve=int({"rations":2,"medkit":1}.get(item,0))
			var quantity=int(pawn.inventory.get(item,0))-reserve
			if quantity<=0:continue
			var route=path_to(z,point(pawn),point(destination),true)
			if not route.is_empty() and route.size()<best_distance:
				best_distance=route.size();best={"destination":destination,"item":item,"quantity":min(quantity,4)}
	if not best.is_empty():
		var extra={"container":best.destination.id,"direction":"store","item":best.item,"quantity":best.quantity,"automatic":true}
		enqueue_order(index,"transfer",point(best.destination),extra)
		note(pawn.name+" is stocking "+str(best.quantity)+" "+str(best.item)+".")
		return true
	# Otherwise reserve a physical source-to-stockpile trip.
	best={};best_distance=999999
	for destination in destinations:
		for source in floor_at(z).containers:
			if source.get("kind","")=="stockpile" or not source.get("searched",false):continue
			for item in ITEMS:
				if not stockpile_accepts(destination,item):continue
				var available=int(source.items.get(item,0))-_reserved_take(z,int(source.id),item)
				var quantity=min(available,free_units(pawn,item),4)
				if quantity<=0:continue
				var to_source=path_to(z,point(pawn),point(source),true)
				var to_store=path_to(z,point(source),point(destination),true)
				if to_source.is_empty() or to_store.is_empty():continue
				var distance=to_source.size()+to_store.size()
				if distance<best_distance:
					best_distance=distance;best={"source":source,"destination":destination,"item":item,"quantity":quantity}
	if best.is_empty():return false
	var take={"container":best.source.id,"direction":"take","item":best.item,"quantity":best.quantity,"automatic":true}
	var store={"container":best.destination.id,"direction":"store","item":best.item,"quantity":best.quantity,"automatic":true}
	enqueue_order(index,"transfer",point(best.source),take)
	enqueue_order(index,"transfer",point(best.destination),store)
	note(pawn.name+" is hauling "+str(best.quantity)+" "+str(best.item)+" to "+best.destination.name.to_lower()+".")
	return true

func order_transfer(index: int, id: int, direction: String, item: String, quantity: int, queued: bool = false) -> String:
	var p = data.pawns[index]
	var c = container_by_id(p.z, id)
	if queued:
		if not ITEMS.has(item) or quantity<=0 or not direction in ["take","store"]:return "Choose an item and positive quantity."
		if c.is_empty() or not c.searched:return "Search the container first."
		return enqueue_order(index,"transfer",point(c),{"container":id,"direction":direction,"item":item,"quantity":quantity})
	var problem = transfer_error(p,c,direction,item,quantity)
	if problem != "": return problem
	var extra = {"container":id,"direction":direction,"item":item,"quantity":quantity}
	return enqueue_order(index,"transfer",point(c),extra) if queued else issue(index,"transfer",point(c),extra)

func drop(index: int, item: String, quantity: int) -> String:
	var p = data.pawns[index]
	if p.hp <= 0 or not p.job.is_empty(): return "Finish or cancel the current order first."
	if not ITEMS.has(item) or quantity <= 0 or int(p.inventory.get(item,0)) < quantity: return "Choose a carried item and quantity."
	var c = container_at(p.z,point(p))
	if not c.is_empty() and not c.searched: return "Search this spot before storing anything here."
	if c.is_empty():
		c = {"id":next_id(),"x":p.x,"y":p.y,"name":"Dropped supplies","searched":true,"items":{},"kind":"ground"}
		floor_at(p.z).containers.append(c)
	p.inventory[item] -= quantity
	c.items[item] = int(c.items.get(item,0)) + quantity
	note(p.name + " put down " + str(quantity) + " " + item + ".")
	return ""

func recipe_available(recipe:String)->bool:
	return RECIPES.has(recipe) and (recipe!="shieldwall" or data.shieldline_state in ["guarded","sheltered","public"])

func can_build(pawn: Dictionary, recipe: String) -> bool:
	if not recipe_available(recipe): return false
	for item in RECIPES[recipe].cost:
		if pawn.inventory.get(item,0) < RECIPES[recipe].cost[item]: return false
	return true

func can_place(z: int, p: Vector2i, ignored_container: int = -1) -> bool:
	var f = floor_at(z)
	var occupying=container_at(z,p)
	if not walkable(z,p) or not f.seen.has(cell_key(p)) or (not occupying.is_empty() and int(occupying.id)!=ignored_container) or not structure_at(z,p).is_empty(): return false
	if p.distance_to(vec(f.up)) <= 1 or p.distance_to(vec(f.down)) <= 1: return false
	for pawn in data.pawns:
		if pawn.z == z and point(pawn) == p: return false
	for mark in f.landmarks:
		if point(mark) == p: return false
	return true

func connection_after_block(z: int, p: Vector2i) -> bool:
	var f = floor_at(z)
	var entry = vec(f.up)
	var queue = [entry]
	var visited = {cell_key(entry):true}
	var cursor = 0
	while cursor < queue.size():
		var at = queue[cursor]
		cursor += 1
		for d in DIRS:
			var n = at+d
			if n != p and walkable(z,n) and not visited.has(cell_key(n)):
				visited[cell_key(n)] = true
				queue.append(n)
	for y in H:
		for x in W:
			var at=Vector2i(x,y)
			if at != p and walkable(z,at) and not visited.has(cell_key(at)): return false
	return true

func order_build(index: int, recipe: String, p: Vector2i, queued: bool = false) -> String:
	if queued:
		var pawn = data.pawns[index]
		if not RECIPES.has(recipe):return "Choose a structure."
		if not recipe_available(recipe):return "Complete Shieldline's walking wall before building folding shieldwalls."
		if not can_place(pawn.z,p): return "Choose an empty explored floor tile away from the stairs."
		if recipe == "relay" and pawn.z < 2: return "The signal cannot reach the deep city from this close to the surface."
		if recipe in ["barricade","shieldwall","bench","relay"] and not connection_after_block(pawn.z,p): return "Leave open routes through this level."
		return enqueue_order(index,"build",p,{"recipe":recipe})
	return issue(index,"build",p,{"recipe":recipe})

func order_dismantle(index:int,structure_id:int,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var pawn=data.pawns[index];var structure=structure_by_id(int(pawn.z),structure_id)
	if structure.is_empty():return "That camp structure is no longer here."
	if not DISMANTLE_RETURNS.has(structure.kind):return "That cannot be packed up."
	var storage={}
	if structure.kind=="stockpile":
		storage=container_by_id(int(pawn.z),structure_id)
		if storage.is_empty() or container_has_items(storage):return "Empty the supply chest before packing it up."
	var extra={"structure":structure_id,"recipe":str(structure.kind)}
	var result=enqueue_order(index,"dismantle",point(structure),extra) if queued else issue(index,"dismantle",point(structure),extra)
	if result=="" and not storage.is_empty():storage.auto_haul=false
	return result

func order_reset_alarm(index:int,structure_id:int,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var pawn=data.pawns[index];var structure=structure_by_id(int(pawn.z),structure_id)
	if structure.is_empty() or structure.get("kind","")!="tripwire":return "That tripwire alarm is no longer here."
	if structure.get("state","armed")!="spent":return "The tripwire can only be reset after its ringing stops."
	var extra={"structure":structure_id}
	return enqueue_order(index,"reset_alarm",point(structure),extra) if queued else issue(index,"reset_alarm",point(structure),extra)

func travel_error(index: int, destination: int) -> String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var p = data.pawns[index]
	if p.hp<=0:return "This colonist is lost."
	if incapacitated(p):return "This colonist needs rescue before traveling."
	if destination < 0: return "The surface is lethal. Stay below."
	if destination == p.z: return "Already on that level."
	if int(p.z)==7 and destination>int(p.z) and data.bellwether_choice=="":return "Choose a Bellwether route at the lift control first."
	if int(p.z)==9 and destination>int(p.z) and data.spindle_contact=="":return "Make contact with the Gate Watch before crossing Spindle's threshold."
	if int(p.z)==11 and destination>int(p.z) and data.ashline_state!="cleared":return "Complete Ashline's scrubber request before entering Meridian's service ring."
	if int(p.z)==12 and destination>int(p.z) and data.service_choice=="":return "Accept service-ring terms before Meridian opens the lower lock."
	if int(p.z)==13 and destination>int(p.z) and not data.foundry_state in ["municipal","independent"]:return "Complete Foundry Ward's standing contract before Kes opens the freight gate."
	if int(p.z)==14 and destination>int(p.z) and not data.archive_choice in ["shared","preserved"]:return "Decide who keeps the traveler's dossier before Archive Junction opens the lower catalog gate."
	if int(p.z)==15 and destination>int(p.z) and not data.wake_state in ["marshal","waymark"]:return "Recover the survey compass before following the traveler toward Quiet Mile."
	if int(p.z)==16 and destination>int(p.z) and data.quiet_state!="heard":return "Tune Quiet Mile's three listening posts and replay the traveler's signal before descending."
	if int(p.z)==17 and destination>int(p.z) and data.stillworks_choice=="":return "Choose whether to restore the Stillworks or preserve its dark bypass before descending."
	if int(p.z)==18 and destination>int(p.z) and not data.cistern_state in ["pressure","spillway"]:return "Recover and return Cistern Spine's physical gate seal before descending."
	if int(p.z)==19 and destination>int(p.z) and not data.drowned_state in ["rescued","salvaged","flooded"]:return "Resolve the Drowned Gallery surge before using the drained stair."
	if int(p.z)==20 and destination>int(p.z) and not data.tidecourt_state in ["sponsored","contracted","recovered"]:return "Earn Tidecourt access before entering Meridian's lower water district."
	if int(p.z)==21 and destination>int(p.z) and not data.sump_state in ["resident","service","public"]:return "Repair Sump Commons' communal pump before using the lower mains stair."
	if int(p.z)==22 and destination>int(p.z) and not data.market_state in ["resident","service","public"]:return "Complete Mainspring's physical exchange before using the Clockline stair."
	if int(p.z)==23 and destination>int(p.z) and not data.depot_state in ["resident","service","public"]:return "Reopen Clockline Depot with both freight mechanisms before using the lower platform."
	if int(p.z)==24 and destination>int(p.z) and not data.refuge_state in ["foothold","corridor"]:return "Complete the Switchyard evacuation before using the outbound stair."
	if int(p.z)==25 and destination>int(p.z) and data.ashrail_state!="stocked":return "Provision Ashrail's far platform before using the lower exchange stair."
	if int(p.z)==26 and destination>int(p.z):
		if not data.customs_state in ["security","smuggle"]:return "Choose Emberline's security platform or ghost siding before using the lower authority gate."
		if floor_at(26).enemies.any(func(enemy):return enemy.hp>0):return "Clear Emberline's chosen route before using the lower authority gate."
	if int(p.z)==27 and destination>int(p.z) and not data.railcourt_state in ["licensed","resident"]:return "Complete Railcourt's public contract or resident compact before using the lower freight stair."
	if int(p.z)==28 and destination>int(p.z) and not data.registry_state in ["official","resident"]:return "Secure Cinder Registry's Morrow freight waybill before using the dispatch stair."
	if int(p.z)==29 and destination>int(p.z) and not data.morrow_state in ["official","resident"]:return "Catch Morrow's freight train before using the deep line."
	if int(p.z)==30 and destination>int(p.z) and not data.terminus_state in ["chartered","free"]:return "Earn Cairn Reach's trust before using the far lift."
	if int(p.z)==31 and destination>int(p.z) and not data.farline_state in ["accord","cacheway"]:return "Bind Farline's route braid before using the settlement descent."
	if int(p.z)==32 and destination>int(p.z) and not data.thimble_state in ["defended","evacuated","overrun"]:return "Resolve Thimble's warned surface incursion before using the lower road."
	if int(p.z)==33 and destination>int(p.z) and not data.latchwater_state in ["warm","cold"]:return "Set Latchwater's shared heater before using the lower settlement road."
	if int(p.z)==34 and destination>int(p.z):
		if not data.driftglass_state in ["powered","shaded"]:return "Set Driftglass Hall's recovered prism before using the lower seam."
		if floor_at(34).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("driftglass_awakened")):return "Clear the Gloam awakened by Driftglass's powered cutters before using the lower seam."
	if int(p.z)==35 and destination>int(p.z) and not data.bellhome_state in ["escorted","diverted","retreated"]:return "Resolve Bellhome's convoy warning before using the settlement road."
	if int(p.z)==36 and destination>int(p.z) and not data.commons_state in ["resident","culvert","public"]:return "Repair Bellhome Commons' occupied homes before using the lower dwellings road."
	if int(p.z)==37 and destination>int(p.z) and not data.yard_state in ["resident","culvert","public"]:return "Reopen Hearthline Yard's communal lift before using the independent lower line."
	if int(p.z)==38 and destination>int(p.z):
		if not data.kiln_state in ["built","concealed"]:return "Commit Kilnreach's furnace crown before using the lower tram."
		if floor_at(38).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("kiln_awakened")):return "Clear the surface husks drawn by Kilnreach's rebuilt furnace before using the lower tram."
	if int(p.z)==39 and destination>int(p.z) and not data.junction_state in ["received","shunted","missed"]:return "Resolve Embervault's warned freight arrival before using the settlement road."
	if int(p.z)==40 and destination>int(p.z) and not data.ember_commons_state in ["freight","refuge","public"]:return "Repair Embervault Commons' signal house before using the lower stair."
	if int(p.z)==41 and destination>int(p.z) and not data.deepcoil_state in ["keepers","freeband","echo"]:return "Synchronize Deepcoil's paired relays before using the answered descent."
	if int(p.z)==42 and destination>int(p.z) and not data.coilward_state in ["keepers","freeband","echo"]:return "Ratify Coilward's community charter before using the lower road."
	if int(p.z)==43 and destination>int(p.z) and not data.charterwell_state in ["escorted","supplied","missed"]:return "Resolve Charterwell's delegation warning before using the lower road."
	if int(p.z)==44 and destination>int(p.z) and not data.writwell_state in ["delegates","exchange","commons"]:return "Ratify Writwell's shared-supply pledge before using the mandated lower road."
	if int(p.z)==45 and destination>int(p.z) and not data.concordance_state in ["bastion","reserve"]:return "Coordinate Concordance Gate's bastion or mobile reserve before using the lower road."
	if int(p.z)==46 and destination>int(p.z) and not data.reservefall_state in ["held","withdrawn","breached"]:return "Resolve Reservefall's warned incursion before using the inhabited lower road."
	if int(p.z)==47 and destination>int(p.z) and not data.reserve_commons_state in ["guarded","sheltered","public"]:return "Repair Reservefall Commons' communal defense before using Shieldline descent."
	if int(p.z)==48 and destination>int(p.z) and not data.shieldline_state in ["guarded","sheltered","public"]:return "Assemble Shieldline's walking wall before using the lower works road."
	if int(p.z)==49 and destination>int(p.z) and not data.marchhold_state in ["deployed","retreated","overrun"]:return "Resolve Marchhold's warned crossing before using the lower road."
	if int(p.z)==50 and destination>int(p.z) and not data.march_refuge_state in ["guarded","sheltered","public","walled"]:return "Settle Marchhold Refuge's communal defense before using the deep resident road."
	if int(p.z)==51 and destination>int(p.z) and not data.wallward_state in ["escorted","screened","missed"]:return "Resolve Wallward's warned convoy rendezvous before using the Wayfarer road."
	if int(p.z)==52 and destination>int(p.z) and not data.wayfarer_state in ["resident","hidden","public"]:return "Repair Wayfarer's shared roadstead before using the Underway road."
	if int(p.z)==53 and destination>int(p.z) and not data.underway_state in ["lit","hidden"]:return "Survey the lit bridge or concealed bypass before using the deeper Underway."
	return ""

func order_travel(index: int, destination: int, queued: bool = false) -> String:
	var error=travel_error(index,destination)
	if error!="":return error
	var p=data.pawns[index]
	var f = floor_at(p.z)
	var target = vec(f.down if destination > p.z else f.up)
	return enqueue_order(index,"travel",target,{"destination":destination}) if queued else issue(index,"travel",target,{"destination":destination})

func expedition_cargo(essentials:bool=true,query:String="") -> Array:
	# A read-only manifest of physical, known goods. Never reveal unopened caches.
	var rows:Array=[]
	var supplies=["armor","timber","scrap","rations","medkit","crystal"]
	var search_text=query.strip_edges().to_lower()
	for index in data.pawns.size():
		var pawn=data.pawns[index]
		for item in ITEMS:
			if essentials and item in supplies:continue
			var quantity=int(pawn.inventory.get(item,0))
			if quantity<=0:continue
			if search_text!="" and not (str(ITEMS[item].name)+" "+str(pawn.name)).to_lower().contains(search_text):continue
			rows.append({"item":item,"quantity":quantity,"owner":str(pawn.name)+"'s pack","pawn":index,"container":-1,"z":int(pawn.z),"x":int(pawn.x),"y":int(pawn.y)})
		if not essentials and pawn.equipment.get("body","")=="armor" and (search_text=="" or (str(ITEMS.armor.name)+" "+str(pawn.name)).to_lower().contains(search_text)):
			rows.append({"item":"armor","quantity":1,"owner":str(pawn.name)+" · worn","pawn":index,"container":-1,"z":int(pawn.z),"x":int(pawn.x),"y":int(pawn.y)})
	var depths:Array=[]
	for key in data.floors:depths.append(int(key))
	depths.sort()
	for z in depths:
		var floor_data=floor_at(z)
		for container in floor_data.containers:
			if not container.get("searched",false) or not floor_data.seen.has(cell_key(point(container))):continue
			for item in ITEMS:
				if essentials and item in supplies:continue
				var quantity=int(container.items.get(item,0))
				if quantity<=0:continue
				if search_text!="" and not (str(ITEMS[item].name)+" "+str(container.name)).to_lower().contains(search_text):continue
				rows.append({"item":item,"quantity":quantity,"owner":str(container.name),"pawn":-1,"container":int(container.id),"z":z,"x":int(container.x),"y":int(container.y)})
	return rows

func regroup_error(index:int,anchor_index:int) -> String:
	if index<0 or index>=data.pawns.size() or anchor_index<0 or anchor_index>=data.pawns.size():return "Select a colonist."
	var pawn=data.pawns[index];var anchor=data.pawns[anchor_index]
	if index==anchor_index:return "Rally destination."
	if anchor.hp<=0:return "Choose a living colonist as the destination."
	if pawn.hp<=0:return "Lost."
	if incapacitated(pawn):return "Needs rescue."
	if pawn.drafted:return "Stand down before regrouping."
	if not pawn.job.is_empty() or not pawn.orders.is_empty():return "Finish or clear this colonist's orders first."
	if int(pawn.z)==int(anchor.z):
		if point(pawn).distance_to(point(anchor))<=1.5:return "Already gathered."
		if not floor_at(int(pawn.z)).seen.has(cell_key(point(anchor))):return "Explore the rally point first."
		if path_to(int(pawn.z),point(pawn),point(anchor)).is_empty():return "No open route to the rally point."
	else:
		for z in range(min(int(pawn.z),int(anchor.z)),max(int(pawn.z),int(anchor.z))+1):
			if not data.floors.has(str(z)):return "Explore the connecting floors first."
		var error=travel_error(index,int(anchor.z))
		if error!="":return error
		var stair=vec(floor_at(int(pawn.z)).down if int(anchor.z)>int(pawn.z) else floor_at(int(pawn.z)).up)
		if path_to(int(pawn.z),point(pawn),stair).is_empty():return "No open route to the stairs."
	return ""

func order_regroup(index:int,anchor_index:int) -> String:
	var error=regroup_error(index,anchor_index)
	if error!="":return error
	var pawn=data.pawns[index];var anchor=data.pawns[anchor_index]
	if int(pawn.z)!=int(anchor.z):return order_travel(index,int(anchor.z))
	return order_walk(index,point(anchor))

func order_retreat(source:int,destination:int)->Dictionary:
	var result={"joined":[],"skipped":[],"error":""}
	if not data.floors.has(str(source)):result.error="That level is not part of this expedition.";return result
	if destination<0:result.error="The surface is lethal. Stay below.";return result
	if abs(destination-source)!=1:result.error="A colony retreat uses one connected stair at a time.";return result
	var stair=vec(floor_at(source).down if destination>source else floor_at(source).up)
	var candidates:Array=[];var routes:Dictionary={}
	for index in data.pawns.size():
		var pawn=data.pawns[index];var name=str(pawn.name)
		if int(pawn.z)!=source:
			result.skipped.append(name+" is on depth "+str(int(pawn.z)+1)+".");continue
		if float(pawn.hp)<=0:
			result.skipped.append(name+" is lost.");continue
		if incapacitated(pawn):
			result.skipped.append(name+" is incapacitated and must be rescued first.");continue
		if bool(pawn.drafted):
			result.skipped.append(name+" is drafted.");continue
		var automatic=bool(pawn.get("job",{}).get("extra",{}).get("automatic",false))
		var manual_waiting=pawn.orders.any(func(order):return not bool(order.get("extra",{}).get("automatic",false)))
		if (not pawn.job.is_empty() and not automatic) or manual_waiting:
			result.skipped.append(name+" is busy with a direct order.");continue
		var route=path_to(source,point(pawn),stair)
		if route.is_empty():
			result.skipped.append(name+" has no route to the stairs.");continue
		candidates.append(index);routes[index]=route
	if candidates.is_empty():result.error="No available colonist can join this retreat.";return result
	var group=next_id();var members=candidates.duplicate()
	for index in candidates:
		var pawn=data.pawns[index]
		pawn.job={"kind":"retreat","target":arr(stair),"path":routes[index].slice(1),"elapsed":0.0,"duration":0.7*(1.0+int(pawn.injury)*0.15),"extra":{"destination":destination,"source":source,"group":group,"members":members.duplicate()}}
		pawn.orders.clear();pawn.move_clock=0.0
		result.joined.append(str(pawn.name))
	note("Retreat ordered. "+", ".join(result.joined)+" will rally at the stairs.")
	return result

func order_talk(index: int, queued: bool = false) -> String:
	if data.traveler: return "The traveler is gone. Their story remains in the journal."
	if data.pawns[index].z != 0: return "The traveler was near the shelter entrance."
	return enqueue_order(index,"talk",Vector2i(9,9)) if queued else issue(index,"talk",Vector2i(9,9))

func recruit_landmark()->Dictionary:
	if not data.floors.has("1"):return {}
	for mark in floor_at(1).landmarks:
		if mark.get("kind","")=="recruit":return mark
	return {}

func order_recruit(index:int,queued:bool=false)->String:
	if data.recruit_joined:return "Vale already joined the expedition."
	var mark=recruit_landmark()
	if mark.is_empty():return "No survivor is waiting here."
	if int(data.pawns[index].z)!=1:return "Vale is waiting at Cinder Waystation."
	if data.station_met and not queued:
		var inventory=data.pawns[index].inventory
		if int(inventory.get("rations",0))<2 or int(inventory.get("medkit",0))<1:return "Carry 2 rations and 1 medkit to help Vale."
	return enqueue_order(index,"recruit",point(mark)) if queued else issue(index,"recruit",point(mark))

func outpost_landmark()->Dictionary:
	if not data.floors.has("5"):return {}
	for mark in floor_at(5).landmarks:
		if mark.get("kind","")=="outpost":return mark
	return {}

func order_outpost(index:int,choice:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var mark=outpost_landmark()
	if mark.is_empty():return "Low Lantern has not been reached."
	if int(data.pawns[index].z)!=5:return "The Lantern Compact is waiting at Low Lantern."
	if data.outpost_choice!="":return "The expedition already made its choice at Low Lantern."
	var extra={"choice":choice}
	return enqueue_order(index,"outpost",point(mark),extra) if queued else issue(index,"outpost",point(mark),extra)

func bellwether_landmark()->Dictionary:
	if not data.floors.has("7"):return {}
	for mark in floor_at(7).landmarks:
		if mark.get("kind","")=="bellwether":return mark
	return {}

func order_bellwether(index:int,choice:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var mark=bellwether_landmark()
	if mark.is_empty():return "Bellwether Lift has not been reached."
	if int(data.pawns[index].z)!=7:return "Bellwether's control waits at depth 8."
	if data.bellwether_choice!="":return "The expedition already fixed Bellwether's route."
	var extra={"choice":choice}
	return enqueue_order(index,"bellwether",point(mark),extra) if queued else issue(index,"bellwether",point(mark),extra)

func spindle_landmark()->Dictionary:
	if not data.floors.has("9"):return {}
	for mark in floor_at(9).landmarks:
		if mark.get("kind","")=="spindle":return mark
	return {}

func order_spindle(index:int,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var mark=spindle_landmark()
	if mark.is_empty():return "Spindle Gate has not been reached."
	if int(data.pawns[index].z)!=9:return "The Gate Watch waits at depth 10."
	if data.spindle_contact!="":return "Spindle Gate has already recorded this expedition."
	return enqueue_order(index,"spindle",point(mark)) if queued else issue(index,"spindle",point(mark))

func ashline_landmark()->Dictionary:
	if not data.floors.has("11"):return {}
	for mark in floor_at(11).landmarks:
		if mark.get("kind","")=="ashline":return mark
	return {}

func order_ashline(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var mark=ashline_landmark()
	if mark.is_empty():return "Ashline checkpoint has not been reached."
	if int(data.pawns[index].z)!=11:return "Ashline screening waits at depth 12."
	if not action in ["accept","deliver"]:return "Choose an Ashline checkpoint action."
	return enqueue_order(index,"ashline",point(mark),{"action":action}) if queued else issue(index,"ashline",point(mark),{"action":action})

func service_landmark()->Dictionary:
	if not data.floors.has("12"):return {}
	for mark in floor_at(12).landmarks:
		if mark.get("kind","")=="service_ring":return mark
	return {}

func order_service(index:int,choice:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var mark=service_landmark()
	if mark.is_empty():return "Meridian's service ring has not been reached."
	if int(data.pawns[index].z)!=12:return "Service Registrar Rook waits at depth 13."
	if data.service_choice!="":return "The expedition already accepted service-ring terms."
	if not choice in ["city","field"]:return "Choose city quarters or an independent field charter."
	return enqueue_order(index,"service",point(mark),{"choice":choice}) if queued else issue(index,"service",point(mark),{"choice":choice})

func foundry_landmark()->Dictionary:
	if not data.floors.has("13"):return {}
	for mark in floor_at(13).landmarks:
		if mark.get("kind","")=="foundry":return mark
	return {}

func order_foundry(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var mark=foundry_landmark()
	if mark.is_empty():return "Foundry Ward has not been reached."
	if int(data.pawns[index].z)!=13:return "Forewoman Kes waits at depth 14."
	if not action in ["accept","deliver","contract"]:return "Choose the standing-specific foundry contract."
	return enqueue_order(index,"foundry",point(mark),{"action":action}) if queued else issue(index,"foundry",point(mark),{"action":action})

func archive_landmark()->Dictionary:
	if not data.floors.has("14"):return {}
	for mark in floor_at(14).landmarks:
		if mark.get("kind","")=="archive":return mark
	return {}

func order_archive(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var mark=archive_landmark()
	if mark.is_empty():return "Archive Junction has not been reached."
	if int(data.pawns[index].z)!=14:return "Archivist Sen waits at depth 15."
	if not action in ["open","share","preserve"]:return "Choose how to handle the traveler's record."
	return enqueue_order(index,"archive",point(mark),{"action":action}) if queued else issue(index,"archive",point(mark),{"action":action})

func wake_landmark()->Dictionary:
	if not data.floors.has("15"):return {}
	for mark in floor_at(15).landmarks:
		if mark.get("kind","")=="wake":return mark
	return {}

func order_wake(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var mark=wake_landmark()
	if mark.is_empty():return "Surveyor's Wake has not been reached."
	if int(data.pawns[index].z)!=15:return "The final survey staging post waits at depth 16."
	if not action in ["start","finish"]:return "Choose whether to begin or complete the survey recovery."
	return enqueue_order(index,"wake",point(mark),{"action":action}) if queued else issue(index,"wake",point(mark),{"action":action})

func quiet_receiver_landmark()->Dictionary:
	if not data.floors.has("16"):return {}
	for mark in floor_at(16).landmarks:
		if mark.get("kind","")=="quiet_receiver":return mark
	return {}

func quiet_post(stage:int)->Dictionary:
	if not data.floors.has("16"):return {}
	for mark in floor_at(16).landmarks:
		if mark.get("kind","")=="quiet_post" and int(mark.get("stage",0))==stage:return mark
	return {}

func order_quiet(index:int,action:String,stage:int=0,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=16:return "Quiet Mile waits at depth 17."
	if not action in ["tune","play"]:return "Choose a listening post or the final receiver."
	var mark=quiet_post(stage) if action=="tune" else quiet_receiver_landmark()
	if mark.is_empty():return "That Quiet Mile signal is not present."
	var extra={"action":action}
	if action=="tune":extra.stage=stage
	return enqueue_order(index,"quiet",point(mark),extra) if queued else issue(index,"quiet",point(mark),extra)

func stillworks_landmark()->Dictionary:
	if not data.floors.has("17"):return {}
	for mark in floor_at(17).landmarks:
		if mark.get("kind","")=="stillworks":return mark
	return {}

func order_stillworks(index:int,choice:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=17:return "The Stillworks waits at depth 18."
	if not choice in ["restore","dark"]:return "Choose restoration or the dark overflow bypass."
	var mark=stillworks_landmark()
	if mark.is_empty():return "The Stillworks bell manifold is not present."
	return enqueue_order(index,"stillworks",point(mark),{"choice":choice}) if queued else issue(index,"stillworks",point(mark),{"choice":choice})

func cistern_landmark()->Dictionary:
	if not data.floors.has("18"):return {}
	for mark in floor_at(18).landmarks:
		if mark.get("kind","")=="cistern":return mark
	return {}

func order_cistern(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=18:return "Cistern Spine waits at depth 19."
	if not action in ["start","finish"]:return "Choose whether to accept the reservoir request or return its gate seal."
	var mark=cistern_landmark()
	if mark.is_empty():return "Cistern Spine's water keeper is not present."
	return enqueue_order(index,"cistern",point(mark),{"action":action}) if queued else issue(index,"cistern",point(mark),{"action":action})

func drowned_landmark(kind:String="drowned_control")->Dictionary:
	if not data.floors.has("19"):return {}
	for mark in floor_at(19).landmarks:
		if mark.get("kind","")==kind:return mark
	return {}

func order_drowned(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=19:return "The Drowned Gallery waits at depth 20."
	if not action in ["start","rescue","salvage"]:return "Choose whether to cycle the sluice, rescue Olan, or recover the regulator."
	var kind="drowned_control" if action=="start" else "drowned_rescue" if action=="rescue" else "drowned_salvage"
	var mark=drowned_landmark(kind)
	if mark.is_empty():return "That Drowned Gallery objective is not present."
	return enqueue_order(index,"drowned",point(mark),{"action":action}) if queued else issue(index,"drowned",point(mark),{"action":action})

func tidecourt_landmark()->Dictionary:
	if not data.floors.has("20"):return {}
	for mark in floor_at(20).landmarks:
		if mark.get("kind","")=="tidecourt":return mark
	return {}

func order_tidecourt(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=20:return "Tidecourt waits at depth 21."
	if not action in ["sponsor","contract","start","finish"]:return "Choose Tidecourt sponsorship, a material bond, or public recovery."
	var mark=tidecourt_landmark()
	if mark.is_empty():return "Tidecourt's lower court clerk is not present."
	return enqueue_order(index,"tidecourt",point(mark),{"action":action}) if queued else issue(index,"tidecourt",point(mark),{"action":action})

func sump_landmark()->Dictionary:
	if not data.floors.has("21"):return {}
	for mark in floor_at(21).landmarks:
		if mark.get("kind","")=="sump":return mark
	return {}

func order_sump(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=21:return "Sump Commons waits at depth 22."
	if not action in ["start","finish"]:return "Choose whether to accept the pump repair or return its impeller."
	var mark=sump_landmark()
	if mark.is_empty():return "Sump Commons' pumpwright is not present."
	return enqueue_order(index,"sump",point(mark),{"action":action}) if queued else issue(index,"sump",point(mark),{"action":action})

func market_landmark()->Dictionary:
	if not data.floors.has("22"):return {}
	for mark in floor_at(22).landmarks:
		if mark.get("kind","")=="market":return mark
	return {}

func order_market(index:int,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=22:return "Mainspring Market waits at depth 23."
	var mark=market_landmark()
	if mark.is_empty():return "Mainspring's broker is not present."
	return enqueue_order(index,"market",point(mark)) if queued else issue(index,"market",point(mark))

func depot_landmark()->Dictionary:
	if not data.floors.has("23"):return {}
	for mark in floor_at(23).landmarks:
		if mark.get("kind","")=="depot":return mark
	return {}

func order_depot(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=23:return "Clockline Depot waits at depth 24."
	if not action in ["start","finish"]:return "Choose whether to begin or complete Clockline's split-freight recovery."
	var mark=depot_landmark()
	if mark.is_empty():return "Dispatcher Jun is not present."
	return enqueue_order(index,"depot",point(mark),{"action":action}) if queued else issue(index,"depot",point(mark),{"action":action})

func refuge_landmark()->Dictionary:
	if not data.floors.has("24"):return {}
	for mark in floor_at(24).landmarks:
		if mark.get("kind","")=="refuge":return mark
	return {}

func order_refuge(index:int,choice:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=24:return "Switchyard Refuge waits at depth 25."
	if not choice in ["foothold","corridor"]:return "Choose a fixed sanctuary or mobile supply corridor."
	var mark=refuge_landmark()
	if mark.is_empty():return "Signal Keeper Esi is not present."
	return enqueue_order(index,"refuge",point(mark),{"choice":choice}) if queued else issue(index,"refuge",point(mark),{"choice":choice})

func ashrail_landmark()->Dictionary:
	if not data.floors.has("25"):return {}
	for mark in floor_at(25).landmarks:
		if mark.get("kind","")=="ashrail":return mark
	return {}

func order_ashrail(index:int,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=25:return "Ashrail Interchange waits at depth 26."
	var mark=ashrail_landmark()
	if mark.is_empty():return "Rail Steward Niko is not present."
	return enqueue_order(index,"ashrail",point(mark)) if queued else issue(index,"ashrail",point(mark))

func customs_landmark()->Dictionary:
	if not data.floors.has("26"):return {}
	for mark in floor_at(26).landmarks:
		if mark.get("kind","")=="customs":return mark
	return {}

func order_customs(index:int,choice:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=26:return "Emberline Customs waits at depth 27."
	if not choice in ["security","smuggle"]:return "Choose security inspection or the ghost siding."
	var mark=customs_landmark()
	if mark.is_empty():return "Customs Captain Vara is not present."
	return enqueue_order(index,"customs",point(mark),{"choice":choice}) if queued else issue(index,"customs",point(mark),{"choice":choice})

func railcourt_landmark()->Dictionary:
	if not data.floors.has("27"):return {}
	for mark in floor_at(27).landmarks:
		if mark.get("kind","")=="railcourt":return mark
	return {}

func order_railcourt(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=27:return "Railcourt Concourse waits at depth 28."
	if not action in ["start","finish","trade"]:return "Choose the authority contract or resident compact."
	var mark=railcourt_landmark()
	if mark.is_empty():return "Railcourt's steward is not present."
	return enqueue_order(index,"railcourt",point(mark),{"action":action}) if queued else issue(index,"railcourt",point(mark),{"action":action})

func registry_landmark()->Dictionary:
	if not data.floors.has("28"):return {}
	for mark in floor_at(28).landmarks:
		if mark.get("kind","")=="registry":return mark
	return {}

func order_registry(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=28:return "Cinder Registry waits at depth 29."
	if not action in ["start","finish","copy"]:return "Choose the public audit or resident freight copy."
	var mark=registry_landmark()
	if mark.is_empty():return "Cinder Registry's clerk is not present."
	return enqueue_order(index,"registry",point(mark),{"action":action}) if queued else issue(index,"registry",point(mark),{"action":action})

func morrow_landmark()->Dictionary:
	if not data.floors.has("29"):return {}
	for mark in floor_at(29).landmarks:
		if mark.get("kind","")=="morrow":return mark
	return {}

func order_morrow(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=29:return "Morrow Exchange waits at depth 30."
	if not action in ["start","depart"]:return "Call the train or board the waiting consist."
	var mark=morrow_landmark()
	if mark.is_empty():return "Morrow's dispatcher is not present."
	return enqueue_order(index,"morrow",point(mark),{"action":action}) if queued else issue(index,"morrow",point(mark),{"action":action})

func terminus_landmark()->Dictionary:
	if not data.floors.has("30"):return {}
	for mark in floor_at(30).landmarks:
		if mark.get("kind","")=="terminus":return mark
	return {}

func order_terminus(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=30:return "Morrow Terminus waits at depth 31."
	if not action in ["start","finish","pledge"]:return "Accept the witness request, return its ledger, or repair the free lift."
	var mark=terminus_landmark()
	if mark.is_empty():return "Cairn Reach's speaker is not present."
	return enqueue_order(index,"terminus",point(mark),{"action":action}) if queued else issue(index,"terminus",point(mark),{"action":action})

func farline_landmark()->Dictionary:
	if not data.floors.has("31"):return {}
	for mark in floor_at(31).landmarks:
		if mark.get("kind","")=="farline":return mark
	return {}

func order_farline(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=31:return "Farline Commons waits at depth 32."
	if not action in ["start","finish"]:return "Open the chosen road or bind its recovered route braid."
	var mark=farline_landmark()
	if mark.is_empty():return "Farline's steward is not present."
	return enqueue_order(index,"farline",point(mark),{"action":action}) if queued else issue(index,"farline",point(mark),{"action":action})

func thimble_landmark()->Dictionary:
	if not data.floors.has("32"):return {}
	for mark in floor_at(32).landmarks:
		if mark.get("kind","")=="thimble":return mark
	return {}

func thimble_evacuation_landmark()->Dictionary:
	if not data.floors.has("32"):return {}
	for mark in floor_at(32).landmarks:
		if mark.get("kind","")=="thimble_evacuation":return mark
	return {}

func order_thimble(index:int,action:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	if int(data.pawns[index].z)!=32:return "Thimble Crossing waits at depth 33."
	if not action in ["defend","evacuate","hold","depart"]:return "Defend Thimble or evacuate its residents."
	var mark=thimble_evacuation_landmark() if action=="depart" else thimble_landmark()
	if mark.is_empty():return "Thimble's warning bell is not present."
	return enqueue_order(index,"thimble",point(mark),{"action":action}) if queued else issue(index,"thimble",point(mark),{"action":action})

func order_rest(index: int, target: Vector2i, queued: bool = false) -> String:
	return enqueue_order(index,"rest",target) if queued else issue(index,"rest",target)

func _nearest_rescue_bed(rescuer_index:int,patient_index:int)->Dictionary:
	if rescuer_index<0 or patient_index<0 or rescuer_index>=data.pawns.size() or patient_index>=data.pawns.size():return {}
	var rescuer=data.pawns[rescuer_index];var patient=data.pawns[patient_index]
	if int(rescuer.z)!=int(patient.z):return {}
	var best:Dictionary={};var best_distance=999999
	for structure in floor_at(patient.z).structures:
		if structure.kind!="bed" or structure.hp<=0 or _bed_reserved(int(patient.z),point(structure),patient_index):continue
		var route=path_to(int(patient.z),point(patient),point(structure),false)
		if not route.is_empty() and route.size()<best_distance:best_distance=route.size();best=structure
	return best

func order_rescue(rescuer_index:int,patient_index:int,queued:bool=false)->String:
	if rescuer_index<0 or rescuer_index>=data.pawns.size():return "Select a rescuer."
	if patient_index<0 or patient_index>=data.pawns.size() or patient_index==rescuer_index:return "Choose another incapacitated colonist."
	var rescuer=data.pawns[rescuer_index];var patient=data.pawns[patient_index]
	if rescuer.hp<=0 or incapacitated(rescuer):return "This colonist cannot perform a rescue."
	if patient.hp<=0:return "That colonist has been lost."
	if not incapacitated(patient):return "That colonist does not need rescue."
	if int(rescuer.z)!=int(patient.z):return "Rescuer and patient must be on the same level."
	if not pawn_at_bed(patient).is_empty():return "That colonist is already awaiting treatment at a bedroll."
	if _patient_reserved(patient_index,-1):return "Another colonist is already helping this patient."
	var bed=_nearest_rescue_bed(rescuer_index,patient_index)
	if bed.is_empty():return "Build or free a reachable bedroll on this level first."
	var extra={"patient":patient_index,"bed":int(bed.id),"carrying":false}
	return enqueue_order(rescuer_index,"rescue",point(patient),extra) if queued else issue(rescuer_index,"rescue",point(patient),extra)

func order_tend(rescuer_index:int,patient_index:int,queued:bool=false)->String:
	if rescuer_index<0 or rescuer_index>=data.pawns.size():return "Select a tending colonist."
	if patient_index<0 or patient_index>=data.pawns.size() or patient_index==rescuer_index:return "Choose another incapacitated colonist."
	var rescuer=data.pawns[rescuer_index];var patient=data.pawns[patient_index]
	if rescuer.hp<=0 or incapacitated(rescuer):return "This colonist cannot tend anyone."
	if patient.hp<=0:return "That colonist has been lost."
	var bed=pawn_at_bed(patient)
	if bed.is_empty():return "Rescue this colonist to a bedroll first."
	if int(rescuer.z)!=int(patient.z):return "Rescuer and patient must be on the same level."
	if _patient_reserved(patient_index,-1):return "Another colonist is already helping this patient."
	if not _safe_for_colony_work(int(patient.z)):return "Tending is unsafe while a visible threat or warning remains."
	if int(rescuer.inventory.get("medkit",0))<1:return "The tending colonist must carry a medkit."
	var extra={"patient":patient_index,"bed":int(bed.id)}
	return enqueue_order(rescuer_index,"tend",point(patient),extra) if queued else issue(rescuer_index,"tend",point(patient),extra)

func order_spring(index:int,choice:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var pawn=data.pawns[index];var spring={}
	for mark in floor_at(pawn.z).landmarks:
		if mark.get("kind","")=="spring":spring=mark;break
	if spring.is_empty():return "There is no luminous spring on this level."
	var extra={"choice":choice}
	return enqueue_order(index,"spring",point(spring),extra) if queued else issue(index,"spring",point(spring),extra)

func order_pump(index:int,choice:String,queued:bool=false)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var pawn=data.pawns[index];var console={}
	for mark in floor_at(pawn.z).landmarks:
		if mark.get("kind","")=="pump_console":console=mark;break
	if console.is_empty():return "There is no emergency pump on this level."
	var extra={"choice":choice}
	return enqueue_order(index,"pump",point(console),extra) if queued else issue(index,"pump",point(console),extra)

func cancel(index: int, clear_waiting: bool = true):
	data.pawns[index].job = {}
	if clear_waiting: data.pawns[index].orders.clear()

func use_item(index: int, item: String) -> String:
	var p = data.pawns[index]
	if p.hp <= 0 or p.inventory.get(item,0) < 1: return "None carried."
	if incapacitated(p):return "This colonist cannot treat themself while incapacitated."
	if item == "rations":
		if p.hunger < 5: return "Not hungry yet."
		p.hunger = max(0.0,p.hunger-50.0)
	elif item == "medkit":
		if p.hp >= 100 and int(p.injury)==0: return "Already healthy."
		p.hp = min(100.0,p.hp+40.0)
		p.injury=max(0,int(p.injury)-1)
	else: return "Use this for construction."
	p.inventory[item] -= 1
	note(p.name+" used "+ITEMS[item].name.to_lower()+".")
	return ""

func toggle_armor(index:int)->String:
	if index<0 or index>=data.pawns.size():return "Select a colonist."
	var p=data.pawns[index]
	if p.hp<=0:return "This colonist is lost."
	if incapacitated(p):return "This colonist is incapacitated."
	if not p.job.is_empty():return "Finish or clear the current order first."
	if p.equipment.body=="armor":
		if free_units(p,"armor")<1:return "The pack needs 2.5 kg free to remove the coat."
		p.equipment.body=""
		p.inventory.armor=int(p.inventory.get("armor",0))+1
		note(p.name+" packed the reinforced coat.")
	elif int(p.inventory.get("armor",0))>0:
		p.inventory.armor-=1
		p.equipment.body="armor"
		note(p.name+" put on the reinforced coat.")
	else:return "No reinforced coat in this pack."
	return ""

func target_enemy(index: int, id: int) -> String:
	var p = data.pawns[index]
	if p.hp<=0 or incapacitated(p):return "This colonist cannot fight."
	for enemy in floor_at(p.z).enemies:
		if enemy.id == id and enemy.hp > 0 and is_visible(p.z,point(enemy)):
			p.orders.clear()
			p.drafted = true
			p.job = {"kind":"attack","target":arr(point(enemy)),"extra":{"enemy":id},"path":[],"elapsed":0.0,"duration":0.0}
			return ""
	return "No visible target."

func _finish(index: int):
	var p = data.pawns[index]
	var job = p.job
	if job.get("kind","")=="retreat":
		_finish_retreat(index)
		return
	if job.get("kind","")=="rescue":
		_finish_rescue(index)
		return
	var z = int(p.z)
	var target = vec(job.target)
	if point(p).distance_to(target) > 1.01 and job.kind != "walk":
		p.job = {}
		return
	var extra = job.extra
	p.job = {}
	match job.kind:
		"interact":
			var object=interaction_target(z,target,extra)
			if object.is_empty():note("Interaction stopped; that object is gone.")
			else:
				if extra.type=="container":_search_container(index,object)
				events.append({"kind":"interaction_ready","pawn":index,"z":z,"target":arr(target),"extra":extra.duplicate(true)})
		"search":
			var c = container_by_id(z,int(extra.container))
			_search_container(index,c)
		"transfer":
			var c = container_by_id(z,int(extra.container))
			var problem = transfer_error(p,c,extra.direction,extra.item,int(extra.quantity))
			if problem != "": note(problem)
			else:
				var source = c.items if extra.direction == "take" else p.inventory
				var dest = p.inventory if extra.direction == "take" else c.items
				source[extra.item] -= int(extra.quantity)
				dest[extra.item] = int(dest.get(extra.item,0)) + int(extra.quantity)
				note(p.name+(" took " if extra.direction == "take" else " stored ")+str(extra.quantity)+" "+str(extra.item)+".")
				events.append({"kind":"transfer"})
		"build":
			var recipe = str(extra.recipe)
			# The worker may stand on a walkable construction tile; allow that one occupancy.
			var original = point(p)
			p.x = -10
			var allowed = can_place(z,target)
			p.x = original.x
			if not allowed or not can_build(p,recipe): note("Construction stopped; materials were kept.")
			elif recipe in ["barricade","shieldwall","bench","relay"] and not connection_after_block(z,target): note("Construction stopped: keep routes through the level open.")
			else:
				for item in RECIPES[recipe].cost: p.inventory[item] -= RECIPES[recipe].cost[item]
				var structure = make_structure(recipe,target)
				floor_at(z).structures.append(structure)
				if recipe == "stockpile": floor_at(z).containers.append(_new_stockpile(structure.id,target))
				if recipe in ["bench","barricade","shieldwall","relay"] and point(p) == target:
					for d in DIRS:
						if walkable(z,target+d): p.x = target.x+d.x; p.y = target.y+d.y; break
				p.skills.build += 1
				data.built_total += 1
				floor_at(z).heat += 5.0
				note(p.name+" built a "+RECIPES[recipe].name.to_lower()+".")
				_remember_nearby(index,"build","Raised camp on depth "+str(z+1)+" with {other}.",4.0,4)
				events.append({"kind":"build"})
				if recipe == "relay" and z >= 2:
					data.signal = true
					note("The relay catches a human voice: 'Still alive down here. Keep going.' The city is real—or someone wants you to think so.")
		"construct":
			var blueprint=container_by_id(z,int(extra.blueprint))
			var recipe=str(extra.recipe)
			if blueprint.is_empty() or blueprint.get("kind","")!="blueprint" or blueprint.recipe!=recipe or not blueprint_ready(blueprint):
				note("Construction stopped; the blueprint or its supplies changed.")
			else:
				var original=point(p)
				p.x=-10
				var site_clear=can_place(z,target,int(blueprint.id))
				p.x=original.x
				if not site_clear:
					note("Construction stopped; the site is no longer clear.")
				elif recipe in ["barricade","shieldwall","bench","relay"] and not connection_after_block(z,target):
					note("Construction stopped: keep routes through the level open.")
				else:
					for item in RECIPES[recipe].cost:blueprint.items[item]-=int(RECIPES[recipe].cost[item])
					floor_at(z).containers.erase(blueprint)
					var structure=make_structure(recipe,target)
					floor_at(z).structures.append(structure)
					if recipe=="stockpile":floor_at(z).containers.append(_new_stockpile(structure.id,target))
					if recipe in ["bench","barricade","shieldwall","relay"] and point(p)==target:
						for d in DIRS:
							if walkable(z,target+d):p.x=target.x+d.x;p.y=target.y+d.y;break
					p.skills.build+=1;data.built_total+=1;floor_at(z).heat+=5.0
					note(p.name+" completed the "+RECIPES[recipe].name.to_lower()+" blueprint.")
					_remember_nearby(index,"build","Raised camp on depth "+str(z+1)+" with {other}.",4.0,4)
					events.append({"kind":"build"})
					if recipe=="relay" and z>=2:
						data.signal=true
						note("The relay catches a human voice: 'Still alive down here. Keep going.' The city is real—or someone wants you to think so.")
		"dismantle":
			var structure=structure_by_id(z,int(extra.get("structure",-1)))
			var storage=container_by_id(z,int(extra.get("structure",-1)))
			if structure.is_empty() or point(structure)!=target:note("Dismantling stopped; the structure is gone.")
			elif structure.kind=="stockpile" and (storage.is_empty() or container_has_items(storage)):note("Dismantling stopped; empty the supply chest first.")
			else:
				var recipe=str(structure.kind)
				if recipe=="stockpile" and not storage.is_empty():floor_at(z).containers.erase(storage)
				floor_at(z).structures.erase(structure);navigation_cache.erase(str(z))
				var recovered=DISMANTLE_RETURNS[recipe].duplicate(true);var cache=container_at(z,target)
				if cache.is_empty():
					cache={"id":next_id(),"x":target.x,"y":target.y,"name":"Packed camp materials","searched":true,"items":{},"kind":"ground"}
					floor_at(z).containers.append(cache)
				for item in recovered:cache.items[item]=int(cache.items.get(item,0))+int(recovered[item])
				p.skills.build+=1
				note(p.name+" packed up the "+RECIPES[recipe].name.to_lower()+". Recovered materials are on the floor.")
				events.append({"kind":"build"})
		"reset_alarm":
			var alarm_structure=structure_by_id(z,int(extra.get("structure",-1)))
			if alarm_structure.is_empty() or point(alarm_structure)!=target or alarm_structure.kind!="tripwire" or alarm_structure.get("state","armed")!="spent":
				note("Reset stopped; the tripwire alarm changed.")
			else:
				alarm_structure.state="armed";alarm_structure.ring=0.0;alarm_structure.triggered_by=""
				note(p.name+" reset the tripwire alarm. The passage is watched again.")
				events.append({"kind":"build"})
		"talk":
			if not data.traveler:
				data.traveler = true
				data.rumor = true
				floor_at(0).landmarks = floor_at(0).landmarks.filter(func(m): return m.kind != "traveler")
				note("'A city below the old mines. Warm lights. Clean water. They call it the Hollow.' The traveler steps into the dark. When you look again, they are gone.")
				events.append({"kind":"story"})
		"recruit":
			if not data.station_met:
				data.station_met=true
				note("Vale guards the last lamp at Cinder Waystation. They will join for 2 rations and a medkit.")
				events.append({"kind":"station"})
			elif not data.recruit_joined:
				if int(p.inventory.get("rations",0))<2 or int(p.inventory.get("medkit",0))<1:
					note("Vale still needs 2 rations and a medkit.")
				else:
					p.inventory.rations-=2;p.inventory.medkit-=1
					data.recruit_joined=true
					var mark=recruit_landmark();var recruit=make_pawn("Vale",int(mark.x),int(mark.y),"rust")
					recruit.z=1;recruit.inventory={};recruit.skills={"scavenge":1,"build":0,"combat":2}
					data.pawns.append(recruit)
					record_shared_memory(index,data.pawns.size()-1,"recruit","Chose to travel with {other} at Cinder Waystation.",6.0,5)
					floor_at(1).landmarks=floor_at(1).landmarks.filter(func(m):return m.get("kind","")!="recruit")
					note("Vale accepted the supplies and joined the expedition.")
					events.append({"kind":"recruit"})
		"outpost":
			var council=outpost_landmark();var choice=str(extra.get("choice",""))
			var cost={"rations":3,"medkit":1} if choice=="aid" else {"scrap":4,"crystal":2} if choice=="trade" else {}
			var affordable=not council.is_empty() and council.get("state","")=="waiting" and data.outpost_choice==""
			for item in cost:affordable=affordable and int(p.inventory.get(item,0))>=int(cost[item])
			if cost.is_empty() or not affordable:note("Low Lantern could not complete the choice; carried supplies were kept.")
			else:
				for item in cost:p.inventory[item]-=int(cost[item])
				data.outpost_choice=choice;council.state=choice
				if choice=="aid":
					for colonist in data.pawns:
						if colonist.hp>0:colonist.morale=min(100.0,float(colonist.morale)+8.0)
					note(p.name+" gave the ward food and medicine. Low Lantern is now a sanctuary where idle colonists recover fatigue.")
				else:
					var cache_target=target+Vector2i(0,1);var cache=container_at(z,cache_target)
					if cache.is_empty():
						cache={"id":next_id(),"x":cache_target.x,"y":cache_target.y,"name":"Compact trade crate","searched":true,"items":{},"kind":"ground"};floor_at(z).containers.append(cache)
					var trade_goods={"rations":5,"medkit":2,"armor":1}
					for item in trade_goods:cache.items[item]=int(cache.items.get(item,0))+int(trade_goods[item])
					note(p.name+" traded with the Compact. Their survival crate remains on the floor for physical hauling.")
				_remember_nearby(index,"discovery","Won the Lantern Compact's route to Bellwether Lift with {other}.",6.0,5)
				note("Compact couriers confirm the clue: at depth 8, follow three white bars to Bellwether Lift. Safe-city traffic passed there recently.")
				events.append({"kind":"outpost"})
		"bellwether":
			var control=bellwether_landmark();var choice=str(extra.get("choice",""))
			var cost={"scrap":2,"crystal":1} if choice=="courier" and data.outpost_choice=="trade" else {}
			var affordable=not control.is_empty() and control.get("state","")=="waiting" and data.bellwether_choice=="" and data.outpost_choice!="" and choice in ["courier","maintenance"]
			for item in cost:affordable=affordable and int(p.inventory.get(item,0))>=int(cost[item])
			if not affordable:note("Bellwether could not fix the route; carried supplies were kept.")
			else:
				for item in cost:p.inventory[item]-=int(cost[item])
				data.bellwether_choice=choice;control.state=choice;_open_bellwether_route(floor_at(z),choice)
				if choice=="courier":
					var access="The ward's lantern phrase releases the Compact brake." if data.outpost_choice=="aid" else "Two scrap and one glowstone restore the charted brake."
					note(access+" The courier cage opens beside a fresh satchel with 2 rations and 1 medkit.")
				else:note("The counterweight crawl opens beside 4 scrap and 2 glowstone. A burrower stirs in the newly exposed trench.")
				_remember_nearby(index,"discovery","Confirmed recent safe-city traffic at Bellwether Lift with {other}.",7.0,6)
				note("Bellwether confirms the Compact account: the newest manifest and water seal point toward Spindle Gate below.")
				events.append({"kind":"bellwether"})
		"spindle":
			var watch=spindle_landmark()
			var contact="recognized" if data.bellwether_choice=="courier" else "breach"
			var safe=not watch.is_empty() and watch.get("state","")=="waiting" and data.spindle_contact=="" and data.bellwether_choice!=""
			if data.bellwether_choice=="maintenance" and floor_at(z).enemies.any(func(enemy):return enemy.hp>0):safe=false
			if not safe:note("Spindle's watch did not answer. The perimeter remains sealed.")
			else:
				data.spindle_contact=contact;watch.state=contact;_open_spindle_gate(floor_at(z),contact)
				if contact=="recognized":
					note("Mara recognizes the three-bar seals. Meridian opens its quarantine threshold and leaves 3 rations and 2 medkits in a physical relief locker.")
				else:
					note("With the intake quiet, Mara opens Meridian's service threshold. A repair cache holds 3 scrap, 2 glowstone and 1 medkit.")
				_remember_nearby(index,"discovery","Made first contact with Meridian's Gate Watch beside {other}.",8.0,7)
				note("The rumored city has a name: Meridian. Spindle is only its outer quarantine; the Gate Watch directs you toward Ashline checkpoint below.")
				events.append({"kind":"spindle"})
		"ashline":
			var officer=ashline_landmark();var action=str(extra.get("action",""))
			if action=="accept":
				var can_assign=not officer.is_empty() and officer.get("state","")=="waiting" and data.ashline_state=="" and data.spindle_contact!=""
				if not can_assign:note("Ashline could not issue the request; the checkpoint record has changed.")
				else:
					data.ashline_state="assigned";officer.state="assigned";_open_ashline_wing(floor_at(z))
					note("Officer Tamsin opens the failed scrubber wing. Recover its purifier cartridge and carry it back through Ashline screening.")
					_remember_nearby(index,"discovery","Submitted to Ashline quarantine beside {other}.",5.0,4)
					events.append({"kind":"ashline"})
			elif action=="deliver":
				var safe=not officer.is_empty() and officer.get("state","")=="assigned" and data.ashline_state=="assigned" and int(p.inventory.get("filter",0))>=1
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):safe=false
				if not safe:note("Ashline could not complete screening. The purifier cartridge was kept.")
				else:
					p.inventory.filter-=1;data.ashline_state="cleared";officer.state="cleared";_clear_ashline(floor_at(z))
					note(p.name+" installed the purifier cartridge under watch. Ashline grants provisional passage into Meridian's service ring.")
					note("Meridian pays in physical supplies: 2 rations and 1 medkit wait beside the open threshold.")
					_remember_nearby(index,"discovery","Earned Ashline clearance into Meridian beside {other}.",8.0,7)
					events.append({"kind":"ashline"})
		"service":
			var registrar=service_landmark();var choice=str(extra.get("choice",""));var cost={"scrap":3,"crystal":2} if choice=="field" else {}
			var accepted=not registrar.is_empty() and registrar.get("state","")=="waiting" and data.service_choice=="" and data.ashline_state=="cleared" and choice in ["city","field"]
			for item in cost:accepted=accepted and int(p.inventory.get(item,0))>=int(cost[item])
			if not accepted:note("Meridian could not record the service terms; carried supplies were kept.")
			else:
				for item in cost:p.inventory[item]-=int(cost[item])
				data.service_choice=choice;registrar.state=choice;_open_service_choice(floor_at(z),choice)
				if choice=="city":
					for colonist in data.pawns:
						if colonist.hp>0:colonist.morale=min(100.0,float(colonist.morale)+5.0)
					note(p.name+" completed a municipal utility shift. Meridian opens city quarters where idle colonists recover fatigue and leaves a worker allotment.")
				else:
					note(p.name+" surrendered 3 scrap and 2 glowstone for an independent field charter. The shielded berth cuts this floor's camp pressure and contains basic stores.")
				_remember_nearby(index,"discovery","Chose the expedition's standing inside Meridian with {other}.",7.0,6)
				note("Registrar Rook opens the lower service lock. Meridian is shelter, but every safe door has terms.")
				events.append({"kind":"service"})
		"foundry":
			var forewoman=foundry_landmark();var action=str(extra.get("action",""))
			if action=="accept":
				var can_assign=not forewoman.is_empty() and forewoman.get("state","")=="waiting" and data.foundry_state=="" and data.service_choice=="city"
				if not can_assign:note("Foundry Ward could not issue the municipal repair; the work slate changed.")
				else:
					data.foundry_state="assigned";forewoman.state="assigned";_open_foundry_line(floor_at(z));_add_foundry(floor_at(z),"assigned",data.service_choice)
					note("Forewoman Kes opens the failed furnace line. Recover its regulator and clear the burrower before the casting hall can restart.")
					events.append({"kind":"foundry"})
			elif action=="deliver":
				var safe=not forewoman.is_empty() and forewoman.get("state","")=="assigned" and data.foundry_state=="assigned" and data.service_choice=="city" and int(p.inventory.get("coil",0))>=1
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):safe=false
				if not safe:note("The municipal repair could not be completed. The foundry regulator was kept.")
				else:
					p.inventory.coil-=1;p.skills.build+=2;data.foundry_state="municipal";_complete_foundry(floor_at(z),"municipal")
					note(p.name+" installed the foundry regulator. Kes records the public repair, grants two practiced building ranks and opens the freight gate.")
					note("A municipal tool issue remains on the ward floor: 3 scrap and one reinforced coat.")
					_remember_nearby(index,"discovery","Restored Foundry Ward's municipal furnace with {other}.",8.0,7)
					events.append({"kind":"foundry"})
			elif action=="contract":
				var bonded=not forewoman.is_empty() and forewoman.get("state","")=="waiting" and data.foundry_state=="" and data.service_choice=="field" and int(p.inventory.get("scrap",0))>=5 and int(p.inventory.get("crystal",0))>=2
				if not bonded:note("Foundry Ward could not record the independent material bond; carried supplies were kept.")
				else:
					p.inventory.scrap-=5;p.inventory.crystal-=2;data.foundry_state="independent";_complete_foundry(floor_at(z),"independent")
					note(p.name+" posted 5 scrap and 2 glowstone as Foundry Ward's independent material bond. No city repair duty was assigned.")
					note("Kes opens the freight gate and leaves contractor surplus: 3 timber, 2 rations and 1 medkit.")
					_remember_nearby(index,"discovery","Kept independent standing through Foundry Ward with {other}.",7.0,6)
					events.append({"kind":"foundry"})
		"archive":
			var archivist=archive_landmark();var action=str(extra.get("action",""))
			if action=="open":
				var can_open=not archivist.is_empty() and archivist.get("state","")=="waiting" and data.archive_choice=="" and data.foundry_state in ["municipal","independent"]
				if not can_open:note("Archive Junction could not release the survey file; the custody index changed.")
				else:
					data.archive_choice="assigned";archivist.state="assigned";_open_archive_vault(floor_at(z));_add_archive(floor_at(z),"assigned")
					note("Archivist Sen opens the sealed survey stacks. Search the file case and carry the traveler's original dossier back for a custody decision.")
					events.append({"kind":"archive"})
			elif action in ["share","preserve"]:
				var can_decide=not archivist.is_empty() and archivist.get("state","")=="assigned" and data.archive_choice=="assigned" and int(p.inventory.get("dossier",0))>=1
				if not can_decide:note("The archive decision could not be recorded. The traveler dossier was kept.")
				else:
					var outcome="shared" if action=="share" else "preserved"
					data.archive_choice=outcome;_complete_archive(floor_at(z),outcome)
					if action=="share":
						p.inventory.dossier-=1
						for colonist in data.pawns:
							if colonist.hp>0:colonist.morale=min(100.0,float(colonist.morale)+6.0)
						note(p.name+" gave the original dossier to Meridian. The vanished surveyor enters the public record; the archive leaves 2 rations, 1 medkit and 1 glowstone as a witness allotment.")
					else:
						note(p.name+" preserved the original dossier in the expedition pack. Sen quietly opens the unindexed route and reveals 3 scrap and 2 glowstone from a hidden survey cache.")
					_remember_nearby(index,"discovery","Found the vanished traveler's Meridian record with {other}.",9.0,8)
					note("The file confirms the traveler was a Meridian route surveyor who chose to keep the safe-city rumor moving after their return line was cut.")
					events.append({"kind":"archive"})
		"wake":
			var contact=wake_landmark();var action=str(extra.get("action",""))
			if action=="start":
				var can_start=not contact.is_empty() and contact.get("state","")=="waiting" and data.wake_state=="" and data.archive_choice in ["shared","preserved"]
				if data.archive_choice=="preserved" and int(p.inventory.get("dossier",0))<1:can_start=false
				if not can_start:note("The final survey recovery could not begin; the route evidence changed.")
				else:
					data.wake_state="assigned";contact.state="assigned";_open_wake_route(floor_at(z),data.archive_choice);_add_wake(floor_at(z),"assigned",data.archive_choice)
					if data.archive_choice=="shared":note("Rescue Marshal Rell opens the marked recovery gallery and holds one flank. Find the missing team's physical survey compass.")
					else:note(p.name+" follows the preserved dossier's margin notes into an unindexed crawl. Find the missing team's physical survey compass.")
					events.append({"kind":"wake"})
			elif action=="finish":
				var can_finish=not contact.is_empty() and contact.get("state","")=="assigned" and data.wake_state=="assigned" and int(p.inventory.get("compass",0))>=1
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):can_finish=false
				if not can_finish:note("The final route could not be aligned. The survey compass was kept.")
				else:
					p.inventory.compass-=1
					var outcome="marshal" if data.archive_choice=="shared" else "waymark"
					data.wake_state=outcome;_complete_wake(floor_at(z),outcome)
					if outcome=="marshal":note(p.name+" returned the survey compass to Rell. Meridian aligns the Quiet Mile descent and leaves 3 rations and 2 medkits for the expedition.")
					else:note(p.name+" aligned the survey compass against the traveler's preserved annotations. The hidden route opens, revealing 4 scrap and 3 glowstone while the dossier remains in the expedition pack.")
					_remember_nearby(index,"discovery","Recovered the missing survey team's last route with {other}.",9.0,8)
					note("The final waymark reads: QUIET MILE · LISTEN BEFORE LIGHT.")
					events.append({"kind":"wake"})
		"quiet":
			var action=str(extra.get("action",""));var silence=quiet_error(index,target)
			if silence!="":note("Quiet Mile calibration failed: "+silence)
			elif action=="tune":
				var stage=int(extra.get("stage",0));var expected=_quiet_rank(str(data.quiet_state))+1;var post=quiet_post(stage)
				if stage!=expected or post.is_empty() or post.get("state","")!="available":note("The listening sequence changed before calibration completed.")
				else:
					var next_state=["","one","two","open"][stage]
					data.quiet_state=next_state;_open_quiet_section(floor_at(z),next_state)
					if stage<3:note(p.name+" tuned listening post "+str(stage)+" in darkness. The next acoustic gate opens—and something beyond it heard the work.")
					else:note(p.name+" tuned the final listening post. The recorder alcove opens; search the traveler's last signal tape and carry it back to the receiver.")
					_remember_nearby(index,"discovery","Held still with {other} while Quiet Mile listened.",6.0,5)
					events.append({"kind":"quiet"})
			elif action=="play":
				if data.quiet_state!="open" or int(p.inventory.get("tape",0))<1:note("The receiver lost the final signal; the physical tape remains where it was.")
				else:
					data.quiet_state="heard";_open_quiet_section(floor_at(z),"heard")
					for colonist in data.pawns:
						if colonist.hp>0:colonist.morale=min(100.0,float(colonist.morale)+5.0)
					note(p.name+" replayed the traveler's final signal without surrendering the tape. Their voice confirms a surviving maintenance route below Meridian: follow the bells, and bring no city light.")
					_remember_nearby(index,"discovery","Heard the vanished traveler's final signal with {other}.",9.0,8)
					events.append({"kind":"quiet"})
		"stillworks":
			var choice=str(extra.get("choice",""));var manifold=stillworks_landmark()
			var valid_choice=not manifold.is_empty() and manifold.get("state","")=="waiting" and data.stillworks_choice=="" and int(p.inventory.get("tape",0))>=1
			if choice=="restore":valid_choice=valid_choice and int(p.inventory.get("scrap",0))>=4 and int(p.inventory.get("crystal",0))>=2
			elif choice=="dark":valid_choice=valid_choice and int(p.inventory.get("timber",0))>=2 and int(p.inventory.get("scrap",0))>=2
			else:valid_choice=false
			if not valid_choice:note("The Stillworks route could not be fixed. All carried materials and the signal tape remain with the expedition.")
			else:
				if choice=="restore":p.inventory.scrap-=4;p.inventory.crystal-=2
				else:p.inventory.timber-=2;p.inventory.scrap-=2
				data.stillworks_choice=choice;_resolve_stillworks(floor_at(z),choice)
				if choice=="restore":note(p.name+" used the traveler's bell pattern and installed 4 scrap plus 2 glowstone. The scrubbers restart, fixed lights wake two Gloam stalkers, and safe idle colonists can recover in the restored air.")
				else:note(p.name+" kept the signal tape and fitted 2 timber plus 2 scrap as acoustic baffles. The dark overflow opens without waking the Gloam and now suppresses camp pressure; the scrubbers remain dead.")
				_remember_nearby(index,"discovery","Chose the Stillworks route with {other}.",7.0,6)
				events.append({"kind":"stillworks"})
		"cistern":
			var action=str(extra.get("action",""));var keeper=cistern_landmark()
			if action=="start":
				var can_start=not keeper.is_empty() and keeper.get("state","")=="waiting" and data.cistern_state=="" and data.stillworks_choice in ["restore","dark"]
				if not can_start:note("The water keepers could not open the reservoir route; their request has changed.")
				else:
					data.cistern_state="assigned";keeper.state="assigned";_open_cistern_route(floor_at(z))
					if data.stillworks_choice=="restore":note("Nera drives the restored pumps against the failed gate. The pressure gallery opens, but water hammer wakes two burrowers. Recover the physical cistern gate seal from its cradle.")
					else:note("Nera opens the unlit keeper spillway fed by the baffled overflow. One Gloam stalker nests near the missing seal; stay dark and recover it from its cradle.")
					events.append({"kind":"cistern"})
			else:
				var can_finish=not keeper.is_empty() and keeper.get("state","")=="assigned" and data.cistern_state=="assigned" and int(p.inventory.get("seal",0))>=1
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):can_finish=false
				if not can_finish:note("Cistern Spine could not secure the reservoir. The physical gate seal was kept.")
				else:
					p.inventory.seal-=1
					var outcome=_cistern_route();data.cistern_state=outcome;_complete_cistern(floor_at(z),outcome)
					if outcome=="pressure":
						for colonist in data.pawns:
							if colonist.hp>0:colonist.hunger=max(0.0,float(colonist.hunger)-20.0)
						note(p.name+" returned and installed the gate seal. Clean water reaches Meridian; living colonists drink, and 3 rations plus 2 medkits remain as physical payment.")
					else:note(p.name+" returned and installed the gate seal through the dark spillway. The reservoir is diverted without relighting the route; 4 scrap and 3 glowstone remain as physical salvage.")
					_remember_nearby(index,"discovery","Secured Meridian's failing reservoir with {other}.",8.0,7)
					note("Water Keeper Nera opens the connected lower reservoir stair.")
					events.append({"kind":"cistern"})
		"drowned":
			var action=str(extra.get("action",""))
			if action=="start":
				var control=drowned_landmark("drowned_control")
				if control.is_empty() or control.get("state","")!="waiting" or data.drowned_state!="" or not data.cistern_state in ["pressure","spillway"]:
					note("The Gallery sluice did not cycle; the reservoir state has changed.")
				else:
					data.drowned_state="warning";data.drowned_timer=24.0;_open_drowned_gallery(floor_at(z))
					var favored="Keeper Olan's rescue wing is clear; a burrower guards the regulator route." if data.cistern_state=="pressure" else "The regulator spillway is clear; a Gloam stalker guards Keeper Olan's rescue wing."
					note(p.name+" cycles the sluice. SURGE IN 24 SECONDS. "+favored+" Retreat behind the dry line if neither objective is safe.")
					events.append({"kind":"drowned"})
			else:
				var mark=drowned_landmark("drowned_rescue" if action=="rescue" else "drowned_salvage")
				if data.drowned_state!="warning" or data.drowned_timer<=0 or mark.is_empty() or mark.get("state","")!="available":
					note("The surge reached that Gallery objective before the work finished.")
				else:
					var outcome="rescued" if action=="rescue" else "salvaged";_resolve_drowned(floor_at(z),outcome,index)
					if outcome=="rescued":note(p.name+" frees Keeper Olan before the wave. The regulator cage washes out; Olan leaves 3 rations and 2 medkits as physical thanks.")
					else:note(p.name+" cuts the regulator cage free before the wave. Keeper Olan's wing is lost; 6 scrap and 3 glowstone remain for physical hauling.")
					events.append({"kind":"drowned"})
		"tidecourt":
			var action=str(extra.get("action",""));var clerk=tidecourt_landmark();var route=_tidecourt_route()
			if action in ["sponsor","contract","start"]:
				var valid=not clerk.is_empty() and clerk.get("state","")=="waiting" and data.tidecourt_state==""
				valid=valid and (action=="sponsor" and route=="sponsor" or action=="contract" and route=="contract" or action=="start" and route=="recovery")
				if action=="contract":valid=valid and int(p.inventory.get("scrap",0))>=3 and int(p.inventory.get("crystal",0))>=2
				if not valid:note("Tidecourt could not record that claim. All physical materials remain with the expedition.")
				elif action=="start":
					data.tidecourt_state="assigned";_open_tidecourt_recovery(floor_at(z))
					note("Sable opens the silted public-record route. A burrower occupies the flooded stacks; recover the one physical water docket from its case and return it to Tidecourt.")
					events.append({"kind":"tidecourt"})
				else:
					var outcome="sponsored" if action=="sponsor" else "contracted"
					if action=="contract":p.inventory.scrap-=3;p.inventory.crystal-=2
					data.tidecourt_state=outcome;_complete_tidecourt(floor_at(z),outcome)
					if outcome=="sponsored":note("Keeper Olan vouches for the expedition. Tidecourt opens a staffed ward, leaves 2 rations and 2 medkits for hauling, and grants safe idle recovery here.")
					else:note(p.name+" posts exactly 3 scrap and 2 glowstone from the recovered regulator claim. Tidecourt opens the quiet exchange, leaves contractor equipment, and suppresses this district's camp pressure.")
					_remember_nearby(index,"discovery","Earned Tidecourt access with {other}.",7.0,6);events.append({"kind":"tidecourt"})
			else:
				var can_finish=not clerk.is_empty() and clerk.get("state","")=="assigned" and data.tidecourt_state=="assigned" and int(p.inventory.get("docket",0))>=1
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):can_finish=false
				if not can_finish:note("The public recovery could not be certified. The physical water docket was kept.")
				else:
					p.inventory.docket-=1;data.tidecourt_state="recovered";_complete_tidecourt(floor_at(z),"recovered")
					note(p.name+" returns the physical water docket. Tidecourt certifies the failed Gallery recovery, leaves 2 rations and 1 medkit, and opens the connected lower stair.")
					_remember_nearby(index,"discovery","Recovered Tidecourt's lost water record with {other}.",8.0,7);events.append({"kind":"tidecourt"})
		"sump":
			var action=str(extra.get("action",""));var pumpwright=sump_landmark();var route=_sump_route()
			if action=="start":
				var valid=not pumpwright.is_empty() and pumpwright.get("state","")=="waiting" and data.sump_state=="" and data.tidecourt_state in ["sponsored","contracted","recovered"]
				if not valid:note("Sump Commons could not open that repair route.")
				else:
					data.sump_state="assigned";_open_sump_route(floor_at(z))
					var warning="Olan's residents hold the gallery gates, but a burrower guards the seized rotor." if route=="resident" else "The contractor crawl stays dark, but a Gloam stalker nests beside the stripped rotor." if route=="service" else "The public silt channel opens without escorts; two burrowers guard the abandoned rotor."
					note("Edda opens the "+route+" pump route. "+warning+" Recover its one physical impeller and carry it back to the Commons.")
					events.append({"kind":"sump"})
			else:
				var can_finish=not pumpwright.is_empty() and pumpwright.get("state","")=="assigned" and data.sump_state=="assigned" and int(p.inventory.get("impeller",0))>=1
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):can_finish=false
				if not can_finish:note("The communal pump could not be repaired. The physical impeller was kept.")
				else:
					p.inventory.impeller-=1;data.sump_state=route;_complete_sump(floor_at(z),route)
					var result="Resident crews leave 3 rations and 2 medkits, and the staffed berth recovers fatigue quickly." if route=="resident" else "Independent pumpwrights leave 5 scrap and 2 glowstone, and the quiet berth strongly suppresses camp pressure." if route=="service" else "The Commons leaves 2 rations, 1 medkit, and 2 scrap at a modestly sheltered public berth."
					note(p.name+" installs the recovered impeller. "+result+" The durable foothold and connected lower mains stair are open.")
					_remember_nearby(index,"discovery","Repaired Sump Commons with {other}.",8.0,7);events.append({"kind":"sump"})
		"market":
			var broker=market_landmark();var route=_market_route();var cost=_market_cost(route);var valid=not broker.is_empty() and broker.get("state","")=="waiting" and data.market_state=="" and not data.market_recruit_joined
			for item in cost:valid=valid and int(p.inventory.get(item,0))>=int(cost[item])
			if not valid:note("Mainspring could not honor the exchange. All carried supplies were kept.")
			else:
				for item in cost:p.inventory[item]-=int(cost[item])
				data.market_state=route;_complete_market(floor_at(z),route,index)
				var result="The shared table takes exactly 2 rations and 1 medkit; makers leave 4 timber and 2 scrap. Tavi joins with practiced scavenging." if route=="resident" else "The freight hoist takes exactly 4 scrap and 2 glowstone; contractors leave 3 rations, 2 medkits, and a reinforced coat. Tavi joins with practiced building." if route=="service" else "The public counter takes exactly 2 scrap and 1 ration; it leaves 2 timber, 1 medkit, and 1 glowstone. Tavi joins as a balanced hand."
				note(p.name+" completes Mainspring's physical bargain. "+result+" Every item stays in a separate pack or on the market floor, and the Clockline stair opens.")
				_remember_nearby(index,"recruit","Welcomed Tavi at Mainspring with {other}.",8.0,7);events.append({"kind":"market"})
		"depot":
			var action=str(extra.get("action",""));var dispatcher=depot_landmark();var route=_depot_route()
			if action=="start":
				var tavi_index=_tavi_index();var valid=not dispatcher.is_empty() and dispatcher.get("state","")=="waiting" and data.depot_state=="" and tavi_index>=0
				valid=valid and int(data.pawns[tavi_index].z)==23 and point(data.pawns[tavi_index]).distance_to(point(dispatcher))<=3.0
				if not valid:note("Dispatcher Jun could not open the specialty route. Bring Tavi beside the depot desk.")
				else:
					data.depot_state="assigned";_open_depot(floor_at(z))
					var warning="Tavi's scavenger reading opens the passenger freight. A Gloam stalker watches the traction case." if route=="resident" else "Tavi's builder reading opens the industrial freight. A burrower guards the brake cradle." if route=="service" else "Tavi's balanced reading opens both public lanes. A Gloam stalker and a burrower hold the mechanisms."
					note(warning+" Recover the 6.5 kg traction drive and brake drum, then bring them back in two separate colonist packs.")
					events.append({"kind":"depot"})
			else:
				var carriers=_depot_carriers(point(dispatcher)) if not dispatcher.is_empty() else []
				var can_finish=not dispatcher.is_empty() and dispatcher.get("state","")=="assigned" and data.depot_state=="assigned" and carriers.size()==2
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):can_finish=false
				if not can_finish:note("Clockline installation stopped. Keep both heavy mechanisms in different packs beside Jun and secure both lanes.")
				else:
					var drive_carrier=data.pawns[carriers[0]];var brake_carrier=data.pawns[carriers[1]]
					drive_carrier.inventory.drive-=1;brake_carrier.inventory.brake-=1;data.depot_state=route;_complete_depot(floor_at(z),route)
					var result="Residents leave 4 rations and 2 medkits at the scouted passenger platform." if route=="resident" else "Contractors leave 6 scrap and 3 glowstone beside the repaired industrial platform." if route=="service" else "The public allotment leaves 2 rations, 1 medkit, 3 scrap, and 1 glowstone."
					note(str(drive_carrier.name)+" and "+str(brake_carrier.name)+" install Clockline's separately carried mechanisms. "+result+" The connected lower platform is open.")
					_remember_nearby(index,"discovery","Reopened Clockline Depot with {other}.",8.0,7);events.append({"kind":"depot"})
		"refuge":
			var choice=str(extra.get("choice",""));var keeper=refuge_landmark();var cost=_refuge_cost(choice)
			var can_complete=not keeper.is_empty() and keeper.get("state","")=="waiting" and data.refuge_state=="" and not cost.is_empty()
			can_complete=can_complete and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0)
			for item in cost:can_complete=can_complete and int(p.inventory.get(item,0))>=int(cost[item])
			if not can_complete:note("The Switchyard evacuation stopped. All physical supplies remain in the selected pack.")
			else:
				for item in cost:p.inventory[item]-=int(cost[item])
				data.refuge_state=choice;_complete_refuge(floor_at(z),choice)
				if choice=="foothold":note(p.name+" provisions the stranded residents with exactly 3 rations, 2 medkits and 1 timber. They anchor a staffed sanctuary; tool stores remain physical, safe idle colonists recover here, and local camp pressure is sheltered.")
				else:note(p.name+" outfits the evacuation train with exactly 4 scrap, 2 glowstone and 1 timber. Residents launch a mobile supply corridor; survival surplus remains physical and moving caches suppress camp pressure at the deepest reached level.")
				_remember_nearby(index,"rescue","Evacuated Switchyard Refuge with {other}.",9.0,8);events.append({"kind":"refuge"})
		"ashrail":
			var steward=ashrail_landmark();var ash_route=_ashrail_route();var ash_cost=_ashrail_cost(ash_route)
			var can_stock=not steward.is_empty() and steward.get("state","")=="waiting" and data.ashrail_state=="" and not ash_cost.is_empty()
			can_stock=can_stock and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0)
			for item in ash_cost:can_stock=can_stock and int(p.inventory.get(item,0))>=int(ash_cost[item])
			if not can_stock:note("Ashrail provisioning stopped. Every physical supply remains in the selected pack.")
			else:
				for item in ash_cost:p.inventory[item]-=int(ash_cost[item])
				data.ashrail_state="stocked";_complete_ashrail(floor_at(z),ash_route)
				if ash_route=="sanctuary":note(p.name+" carries exactly 3 rations and 1 medkit across the cinder gantry. Ashrail stocks the far platform and leaves 4 scrap plus 2 glowstone as physical exchange freight.")
				else:note(p.name+" installs exactly 3 scrap and 1 glowstone along the black-rail bypass. The mobile corridor reaches the far platform and leaves 4 rations plus 2 medkits as physical provisions.")
				_remember_nearby(index,"discovery","Provisioned Ashrail Interchange with {other}.",8.0,7);events.append({"kind":"ashrail"})
		"customs":
			var choice=str(extra.get("choice",""));var captain=customs_landmark();var cost=_customs_cost(choice)
			var can_choose=not captain.is_empty() and captain.get("state","")=="waiting" and data.customs_state=="" and data.ashrail_state=="stocked" and not cost.is_empty()
			for item in cost:can_choose=can_choose and int(p.inventory.get(item,0))>=int(cost[item])
			if not can_choose:note("Emberline's customs decision stopped. Every physical item remains in the selected pack.")
			else:
				for item in cost:p.inventory[item]-=int(cost[item])
				data.customs_state=choice;_complete_customs(floor_at(z),choice)
				if choice=="security":note(p.name+" declares Ashrail's "+_customs_cargo()+" cargo and posts the exact authority tariff. Vara opens the lit patrol platform; one burrower guards its physical patrol issue and lower gate.")
				else:note(p.name+" pays Emberline's quiet tariff and slips Ashrail's "+_customs_cargo()+" cargo off the ledger. Two Gloam stalkers wake along the dark siding, where hidden industrial freight waits physically.")
				_remember_nearby(index,"discovery","Chose Emberline's lower-rail route with {other}.",7.0,6);events.append({"kind":"customs"})
		"railcourt":
			var action=str(extra.get("action",""));var steward=railcourt_landmark();var route=_railcourt_route()
			if route=="authority" and action=="start":
				var valid=not steward.is_empty() and steward.get("state","")=="waiting" and data.railcourt_state==""
				if not valid:note("Railcourt's public contract could not begin.")
				else:
					data.railcourt_state="assigned";_open_railcourt_contract(floor_at(z))
					note("Magistrate Sera unseals the public switchhouse. Two burrowers occupy its evidence line; recover the one physical switch warrant and carry it back to Railcourt.")
					events.append({"kind":"railcourt"})
			elif route=="authority" and action=="finish":
				var can_finish=not steward.is_empty() and steward.get("state","")=="assigned" and data.railcourt_state=="assigned" and int(p.inventory.get("warrant",0))>=1
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):can_finish=false
				if not can_finish:note("Railcourt could not certify the contract. The physical switch warrant was kept.")
				else:
					p.inventory.warrant-=1;data.railcourt_state="licensed";_complete_railcourt(floor_at(z),"licensed")
					note(p.name+" returns the recovered switch warrant. Sera grants public clearance, opens staffed rest bunks, leaves 3 rations, 2 medkits and 1 glowstone as physical issue, and reconnects the lower freight stair.")
					_remember_nearby(index,"discovery","Completed Railcourt's public contract with {other}.",8.0,7);events.append({"kind":"railcourt"})
			elif route=="resident" and action=="trade":
				var can_trade=not steward.is_empty() and steward.get("state","")=="waiting" and data.railcourt_state=="" and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0)
				can_trade=can_trade and int(p.inventory.get("scrap",0))>=3 and int(p.inventory.get("crystal",0))>=2
				if not can_trade:note("The resident compact could not be posted. Every physical material was kept.")
				else:
					p.inventory.scrap-=3;p.inventory.crystal-=2;data.railcourt_state="resident";_complete_railcourt(floor_at(z),"resident")
					note(p.name+" posts exactly 3 scrap and 2 glowstone from Emberline's hidden freight. Pell opens the resident arcade, leaves 4 rations and 2 medkits as physical provisions, shelters local camp pressure, and reconnects the lower freight stair.")
					_remember_nearby(index,"discovery","Joined Railcourt's resident compact with {other}.",8.0,7);events.append({"kind":"railcourt"})
			else:note("That Railcourt outcome is no longer available.")
		"registry":
			var action=str(extra.get("action",""));var clerk=registry_landmark();var route=_registry_route()
			if route=="official" and action=="start":
				var valid=not clerk.is_empty() and clerk.get("state","")=="waiting" and data.registry_state==""
				if not valid:note("Cinder Registry's public audit could not begin.")
				else:
					data.registry_state="assigned";_open_registry_audit(floor_at(z))
					note("Registrar Kade opens the charred audit vault. Two burrowers occupy its plate stacks; recover the one physical registry plate and carry it back.")
					events.append({"kind":"registry"})
			elif route=="official" and action=="finish":
				var can_finish=not clerk.is_empty() and clerk.get("state","")=="assigned" and data.registry_state=="assigned" and int(p.inventory.get("plate",0))>=1
				if floor_at(z).enemies.any(func(enemy):return enemy.hp>0):can_finish=false
				if not can_finish:note("Cinder Registry could not certify the audit. The physical plate was kept.")
				else:
					p.inventory.plate-=1;p.inventory.waybill=int(p.inventory.get("waybill",0))+1;data.registry_state="official";_complete_registry(floor_at(z),"official")
					note(p.name+" returns the registry plate. Kade issues one physical Morrow freight waybill, reveals the lower authority's deepest active destination, leaves exact audit supplies, and opens the dispatch stair.")
					_remember_nearby(index,"discovery","Recovered Cinder Registry's Morrow waybill with {other}.",8.0,7);events.append({"kind":"registry"})
			elif route=="resident" and action=="copy":
				var can_copy=not clerk.is_empty() and clerk.get("state","")=="waiting" and data.registry_state=="" and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0)
				can_copy=can_copy and int(p.inventory.get("scrap",0))>=4 and int(p.inventory.get("crystal",0))>=1
				if not can_copy:note("The off-ledger registry copy could not be made. Every physical material was kept.")
				else:
					p.inventory.scrap-=4;p.inventory.crystal-=1;p.inventory.waybill=int(p.inventory.get("waybill",0))+1;data.registry_state="resident";_complete_registry(floor_at(z),"resident")
					note(p.name+" pays exactly 4 scrap and 1 glowstone for an off-ledger copy. Moss issues one physical Morrow freight waybill, leaves exact provisions, and opens the dark dispatch stair.")
					_remember_nearby(index,"discovery","Copied Cinder Registry's Morrow waybill with {other}.",8.0,7);events.append({"kind":"registry"})
			else:note("That Cinder Registry outcome is no longer available.")
		"morrow":
			var action=str(extra.get("action",""));var dispatcher=morrow_landmark();var route=_morrow_route()
			if action=="start":
				var can_call=not dispatcher.is_empty() and dispatcher.get("state","")=="waiting" and data.morrow_state=="" and data.registry_state in ["official","resident"] and int(p.inventory.get("waybill",0))>=1
				if not can_call:note("Morrow could not call that train. The physical waybill remains in its pack.")
				else:
					_start_morrow_boarding(floor_at(z))
					var warning="The stamped waybill calls a lit authority consist. Two burrowers breach the loading lane." if route=="official" else "The copied waybill calls an unlisted ghost-line consist. Two Gloam stalkers wake in the dark siding."
					note(warning+" Clear it and rally at least two living colonists beside the dispatcher before the 30-second departure.")
					events.append({"kind":"morrow"})
			else:
				var can_depart=not dispatcher.is_empty() and dispatcher.get("state","")=="boarding" and data.morrow_state=="boarding" and float(data.morrow_timer)>0 and int(p.inventory.get("waybill",0))>=1
				can_depart=can_depart and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0) and morrow_gathered()>=2
				if not can_depart:note("Morrow's departure stopped. Keep the waybill physical, secure the lane, and rally two colonists beside the dispatcher.")
				else:
					_complete_morrow(floor_at(z),route,index)
					var reward="Authority loaders leave 4 rations, 2 medkits and 1 glowstone beside a staffed rest platform." if route=="official" else "Ghost-line runners leave 5 scrap, 3 glowstone and 1 medkit beside a pressure-sheltered siding."
					note(p.name+" presents the physical waybill while the gathered expedition catches Morrow's freight train. The waybill stays in the pack. "+reward+" The connected deep line is open.")
					events.append({"kind":"morrow"})
		"terminus":
			var action=str(extra.get("action",""));var speaker=terminus_landmark();var route=_terminus_route()
			if action=="start":
				var can_start=not speaker.is_empty() and speaker.get("state","")=="waiting" and data.terminus_state=="" and route=="official" and int(p.inventory.get("waybill",0))>=1
				if not can_start:note("Cairn Reach's witness request is no longer available. The physical waybill remains in its pack.")
				else:
					data.terminus_state="assigned";_open_terminus_hall(floor_at(z))
					note(p.name+" presents the stamped waybill without surrendering it. Speaker Nera opens Cairn Reach's breached witness hall; recover the physical ledger through two burrowers.")
					events.append({"kind":"terminus"})
			elif action=="finish":
				var can_finish=not speaker.is_empty() and speaker.get("state","")=="assigned" and data.terminus_state=="assigned" and int(p.inventory.get("ledger",0))>=1 and int(p.inventory.get("waybill",0))>=1
				can_finish=can_finish and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0)
				if not can_finish:note("Cairn Reach could not record that witness. Keep both documents physical and secure the hall.")
				else:
					p.inventory.ledger-=1;_complete_terminus(floor_at(z),"chartered",index)
					note(p.name+" returns Cairn Reach's witness ledger while keeping the Morrow waybill. The settlement records its own authority, leaves exact charter supplies, staffs a recovery hall, and opens the far lift.")
					events.append({"kind":"terminus"})
			else:
				var can_pledge=not speaker.is_empty() and speaker.get("state","")=="waiting" and data.terminus_state=="" and route=="resident" and int(p.inventory.get("waybill",0))>=1
				can_pledge=can_pledge and int(p.inventory.get("scrap",0))>=4 and int(p.inventory.get("crystal",0))>=2 and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0)
				if not can_pledge:note("Cairn Reach's free lift still needs a safe siding, the physical waybill, 4 scrap, and 2 glowstone.")
				else:
					p.inventory.scrap-=4;p.inventory.crystal-=2;_complete_terminus(floor_at(z),"free",index)
					note(p.name+" keeps the copied waybill and contributes exactly 4 scrap plus 2 glowstone. Cairn Reach repairs its communal far lift, leaves exact free-siding stores, shelters camp pressure, and opens the descent.")
					events.append({"kind":"terminus"})
		"farline":
			var action=str(extra.get("action",""));var steward=farline_landmark();var route=_farline_route()
			if action=="start":
				var can_start=not steward.is_empty() and steward.get("state","")=="waiting" and data.farline_state=="" and data.terminus_state in ["chartered","free"]
				if not can_start:note("Farline's settlement road is no longer available.")
				else:
					data.farline_state="assigned";_open_farline_route(floor_at(z))
					var warning="Cairn's charter opens the lit witness road. Two burrowers feel movement between its waymarks." if route=="accord" else "Cairn's free standing opens the unlit cacheway. Two Gloam stalkers wake around its hidden stores."
					note(warning+" Recover the physical route braid, clear the road, and rally two colonists beside the steward.")
					events.append({"kind":"farline"})
			else:
				var can_finish=not steward.is_empty() and steward.get("state","")=="assigned" and data.farline_state=="assigned" and int(p.inventory.get("braid",0))>=1
				can_finish=can_finish and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0) and farline_gathered()>=2
				if not can_finish:note("Farline could not bind the road. Keep the route braid physical, secure the path, and rally two colonists beside the steward.")
				else:
					p.inventory.braid-=1;_complete_farline(floor_at(z),route,index)
					var reward="The delegates leave 4 rations, 2 medkits and 1 glowstone beside a staffed commons shelter." if route=="accord" else "The cachekeepers leave 5 scrap, 3 glowstone and 2 timber beside a pressure-sheltered store."
					note(p.name+" binds Farline's physical route braid with the gathered expedition. "+reward+" The independent settlement descent is open.")
					events.append({"kind":"farline"})
		"thimble":
			var action=str(extra.get("action",""));var route=_thimble_route()
			if action in ["defend","evacuate"]:
				var can_start=data.thimble_state=="" and data.farline_state in ["accord","cacheway"]
				if not can_start:note("Thimble's surface warning has already been answered.")
				else:
					var choice="defending" if action=="defend" else "evacuating";_open_thimble_choice(floor_at(z),choice)
					var approach="The public Farline road carries three surface husks toward two armed settlement alarms." if route=="accord" else "The hidden cacheway masks Thimble from all but two surface husks, but offers no prepared alarms."
					var plan="Clear the incursion and rally two colonists at the warning bell." if choice=="defending" else "Search for the physical resident cord and rally two colonists at the evacuation lift; the husks do not need to be defeated."
					note(approach+" Thimble has 28 pauseable seconds before the crossing is overrun. "+plan)
					events.append({"kind":"thimble"})
			elif action=="hold":
				var can_hold=data.thimble_state=="defending" and float(data.thimble_timer)>0 and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("thimble_guard")) and thimble_gathered()>=2
				if not can_hold:note("Thimble's defense failed to seal. Clear the husks and rally two colonists at the bell before the warning expires.")
				else:
					_complete_thimble(floor_at(z),"defended",index)
					note(p.name+" seals Thimble's upper breach with the gathered expedition. The residents keep their homes, staff a recovery hall, leave 4 rations, 3 medkits and 1 glowstone, and open the lower road.")
					events.append({"kind":"thimble"})
			else:
				var can_depart=data.thimble_state=="evacuating" and float(data.thimble_timer)>0 and int(p.inventory.get("roster",0))>=1 and thimble_gathered(true)>=2
				if not can_depart:note("Thimble's evacuation stopped. Keep the resident cord physical and rally two colonists at the lift before the warning expires.")
				else:
					p.inventory.roster-=1;_complete_thimble(floor_at(z),"evacuated",index)
					note(p.name+" carries Thimble's resident cord onto the lift with the gathered expedition. The people escape, the cold crossing shelters future pressure, 6 scrap, 3 timber and 1 medkit remain physical, and the lower road opens.")
					events.append({"kind":"thimble"})
		"latchwater":
			var action=str(extra.get("action",""));var keeper=latchwater_landmark()
			if action=="start":
				var can_start=not keeper.is_empty() and keeper.get("state","")=="waiting" and data.latchwater_state=="" and data.thimble_state in ["defended","evacuated","overrun"]
				if not can_start:note("Latchwater's heater request could not begin.")
				else:
					_open_latchwater_route(floor_at(z))
					var route_text="the lit resident gallery, where two burrowers have nested" if _latchwater_route()=="resident" else "the dark refugee spillway, where a Gloam stalker is listening" if _latchwater_route()=="refugee" else "the public scavenger duct, where two surface husks have descended"
					note("Miri opens "+route_text+". Recover Latchwater's one physical heat exchanger and carry it back for a permanent heater choice.")
					events.append({"kind":"latchwater"})
			else:
				var can_finish=not keeper.is_empty() and keeper.get("state","")=="assigned" and data.latchwater_state=="assigned" and int(p.inventory.get("exchanger",0))>=1
				can_finish=can_finish and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("latchwater_guard"))
				if not can_finish:note("Latchwater's heater could not be set. The physical exchanger remains in the selected pack.")
				else:
					p.inventory.exchanger-=1;_complete_latchwater(floor_at(z),action,index)
					if action=="warm":note(p.name+" installs the physical exchanger at full output. Latchwater becomes a safe recovery ward and leaves exactly 4 rations plus 2 medkits, but its rising heat permanently increases local surface pressure.")
					else:note(p.name+" baffles the physical exchanger. Latchwater stays cold and leaves exactly 5 scrap, 3 timber, and 1 glowstone, while its faint heat signature sharply suppresses local pressure.")
					events.append({"kind":"latchwater"})
		"driftglass":
			var action=str(extra.get("action",""));var keeper=driftglass_landmark()
			if action=="start":
				var can_start=not keeper.is_empty() and keeper.get("state","")=="waiting" and data.driftglass_state=="" and data.latchwater_state in ["warm","cold"]
				if not can_start:note("Driftglass's excavation request could not begin.")
				else:
					_open_driftglass_route(floor_at(z))
					var route_text="the heated cutting gallery, where two Gloam stalkers hunt among fixed work lights" if _driftglass_route()=="powered" else "the cold mirror seam, where one Gloam stalker listens in darkness"
					note("Sela opens "+route_text+". Recover Driftglass's one physical focusing prism and carry it back for a permanent power-or-stealth choice.")
					events.append({"kind":"driftglass"})
			else:
				var can_finish=not keeper.is_empty() and keeper.get("state","")=="assigned" and data.driftglass_state=="assigned" and int(p.inventory.get("prism",0))>=1
				can_finish=can_finish and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("driftglass_guard"))
				if not can_finish:note("Driftglass's lens could not be set. The physical prism remains in the selected pack.")
				else:
					p.inventory.prism-=1;_complete_driftglass(floor_at(z),action,index)
					if action=="powered":note(p.name+" focuses the physical prism into powered cutters. Six scrap and 3 glowstone remain physical, Building rises by two ranks, fixed lights raise local pressure, and two Gloam stalkers wake along the lower seam.")
					else:note(p.name+" shades the physical prism. Driftglass leaves 4 rations, 2 medkits, and 2 timber, while its dark lower seam sharply suppresses local pressure without waking new threats.")
					events.append({"kind":"driftglass"})
		"bellhome":
			var action=str(extra.get("action",""));var route=_bellhome_route()
			if action=="start":
				var can_start=data.bellhome_state=="" and data.driftglass_state in ["powered","shaded"]
				if not can_start:note("Bellhome's convoy warning has already been answered.")
				else:
					_open_bellhome_warning(floor_at(z))
					var approach="The powered glass road exposes a fixed-light convoy to three surface husks." if route=="lampline" else "The shaded glass road hides the convoy from the surface, but two Gloam stalkers hold its dark approach."
					note(approach+" Bellhome has 32 pauseable seconds: carry the physical charter and escort the convoy after clearing the route, or gather at the culvert with exactly 2 timber and 2 scrap to divert it without combat.")
					events.append({"kind":"bellhome"})
			elif action=="escort":
				var can_escort=data.bellhome_state=="warning" and float(data.bellhome_timer)>0 and int(p.inventory.get("charter",0))>=1 and bellhome_gathered()>=2
				can_escort=can_escort and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("bellhome_guard"))
				if not can_escort:note("Bellhome's escort stopped. Keep the charter physical, clear the approach, and rally two colonists before the warning expires.")
				else:
					_complete_bellhome(floor_at(z),"escorted",index)
					var reward="5 scrap, 2 glowstone and 2 rations" if route=="lampline" else "4 rations, 2 medkits and 2 timber"
					note(p.name+" presents Bellhome's physical charter with the gathered escort. The convoy arrives, "+reward+" remain physical, and the settlement road opens. The charter stays in its carrier's pack as proof of passage.")
					events.append({"kind":"bellhome"})
			else:
				var can_divert=data.bellhome_state=="warning" and float(data.bellhome_timer)>0 and int(p.inventory.get("charter",0))>=1 and int(p.inventory.get("timber",0))>=2 and int(p.inventory.get("scrap",0))>=2 and bellhome_gathered(true)>=2
				if not can_divert:note("Bellhome's diversion stopped. Gather two colonists with the charter, 2 timber and 2 scrap at the culvert before the warning expires.")
				else:
					p.inventory.charter-=1;p.inventory.timber-=2;p.inventory.scrap-=2;_complete_bellhome(floor_at(z),"diverted",index)
					note(p.name+" spends the convoy charter, 2 timber and 2 scrap to brace Bellhome's culvert. The convoy slips past every approach threat, 4 scrap, 2 timber and 1 medkit remain physical, and the closed diversion strongly suppresses local pressure.")
					events.append({"kind":"bellhome"})
		"commons":
			var action=str(extra.get("action",""));var steward=commons_landmark();var route=_commons_route()
			if action=="start":
				var can_start=not steward.is_empty() and steward.get("state","")=="waiting" and data.commons_state=="" and data.bellhome_state in ["escorted","diverted","retreated"]
				if not can_start:note("Bellhome Commons' housing contract is no longer available.")
				else:
					_open_commons_route(floor_at(z))
					var approach="Residents open a lamp-lit roof court guarded by one burrower." if route=="resident" else "Culvert keepers open a dark housing row watched by one Gloam stalker." if route=="culvert" else "A wary public ward opens through two surface husks."
					note(approach+" Recover Bellhome's physical four-kilogram wall brace, clear the route, and carry it with the exact repair contribution to the housing frame.")
					events.append({"kind":"commons"})
			else:
				var cost=_commons_cost(route);var can_finish=not steward.is_empty() and data.commons_state=="assigned" and int(p.inventory.get("brace",0))>=1
				can_finish=can_finish and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("commons_guard"))
				for item in cost:can_finish=can_finish and int(p.inventory.get(item,0))>=int(cost[item])
				if not can_finish:note("Bellhome's repair stopped. Keep the heavy brace and exact route-shaped materials in the selected pack until the housing route is secure.")
				else:
					p.inventory.brace-=1
					for item in cost:p.inventory[item]-=int(cost[item])
					_complete_commons(floor_at(z),route,index)
					var result="The residents leave 5 rations, 3 medkits and 1 timber beside a staffed recovery court." if route=="resident" else "The culvert keepers leave 6 scrap, 2 glowstone and 1 medkit beside strong pressure shelter." if route=="culvert" else "The public ward leaves 3 rations, 2 medkits, 3 scrap and 2 timber beside a modest shared shelter."
					note(p.name+" installs Bellhome's physical wall brace and exact repair materials. "+result+" The occupied lower dwellings are safe and the settlement road is open.")
					events.append({"kind":"commons"})
		"yard":
			var action=str(extra.get("action",""));var yardmaster=yard_landmark();var route=_yard_route()
			if action=="start":
				var can_start=not yardmaster.is_empty() and yardmaster.get("state","")=="waiting" and data.yard_state=="" and data.commons_state in ["resident","culvert","public"] and not data.yard_recruit_joined
				if not can_start:note("Hearthline's expansion contract is no longer available.")
				else:
					_open_yard(floor_at(z))
					var approach="Bellhome's resident standing opens a lit thermal lane guarded by one burrower." if route=="resident" else "Bellhome's culvert standing opens a dark winch lane watched by one Gloam stalker." if route=="culvert" else "Bellhome's public standing opens split cargo lanes held by a burrower and a Gloam stalker."
					note(approach+" Pell joins with a separate pack. Recover the seven-kilogram thermal core and seven-kilogram lift winch, keep them with two different carriers, then gather three colonists with Pell at the gantry.")
					_remember_nearby(index,"recruit","Welcomed Pell at Hearthline with {other}.",8.0,7);events.append({"kind":"yard"})
			else:
				var gantry=yard_gantry();var yard_target=point(gantry) if not gantry.is_empty() else point(p);var carriers=_yard_carriers(yard_target);var pell_index=_pell_index()
				var can_finish=not gantry.is_empty() and data.yard_state=="assigned" and carriers.size()==2 and yard_gathered()>=3 and pell_index>=0
				can_finish=can_finish and int(data.pawns[pell_index].z)==37 and point(data.pawns[pell_index]).distance_to(yard_target)<=4.0
				can_finish=can_finish and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("yard_guard"))
				if not can_finish:note("Hearthline's installation stopped. Keep both mechanisms in separate packs and gather Pell with three living colonists at the secure gantry.")
				else:
					data.pawns[int(carriers[0])].inventory.hearth_core-=1;data.pawns[int(carriers[1])].inventory.yard_winch-=1
					_complete_yard(floor_at(z),route,index)
					var result="Residents issue 5 rations, 3 medkits and 2 timber beside a staffed recovery yard." if route=="resident" else "Culvert crews issue 7 scrap, 3 glowstone and 1 medkit beside strong pressure shelter." if route=="culvert" else "Public crews issue 3 rations, 2 medkits, 4 scrap and 2 timber beside a shared shelter."
					note("The two carriers mount Hearthline's physical core and winch while Pell coordinates the gathered crew. "+result+" The communal lift now opens the independent lower line.")
					events.append({"kind":"yard"})
		"kiln":
			var action=str(extra.get("action",""));var route=_kiln_route();var console=kiln_landmark()
			if action=="start":
				var can_start=not console.is_empty() and console.get("state","")=="waiting" and data.kiln_state=="" and data.yard_state in ["resident","culvert","public"] and index==_pell_index()
				if not can_start:note("Kilnreach's controls require Pell's route-shaped specialty before the survey can begin.")
				else:
					_open_kiln(floor_at(z))
					var approach="Pell's scavenging practice opens a lit slag gallery guarded by two burrowers." if route=="forage" else "Pell's building practice opens a dark builder flue watched by one Gloam stalker." if route=="works" else "Pell's balanced practice opens split communal works held by one burrower and one Gloam stalker."
					note(approach+" Recover the physical two-kilogram ignition spindle, clear the route, then choose whether to rebuild the kiln or conceal its heat.")
					events.append({"kind":"kiln"})
			else:
				var cost=_kiln_cost(action);var can_finish=not console.is_empty() and data.kiln_state=="assigned" and int(p.inventory.get("kiln_igniter",0))>=1
				can_finish=can_finish and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("kiln_guard"))
				for item in cost:can_finish=can_finish and int(p.inventory.get(item,0))>=int(cost[item])
				if not can_finish:note("Kilnreach's furnace work stopped. Keep the physical spindle and exact route-shaped materials in the selected pack until the works are secure.")
				else:
					p.inventory.kiln_igniter-=1
					for item in cost:p.inventory[item]-=int(cost[item])
					_complete_kiln(floor_at(z),"built" if action=="build" else "concealed",index)
					if action=="build":note(p.name+" installs Kilnreach's spindle and exact building materials. The fired works leave route-shaped ingots, raise Pell's Building by two ranks, light the lower tram, and draw two surface husks toward its new heat.")
					else:note(p.name+" spends Kilnreach's spindle and exact baffling materials. The hidden works leave route-shaped provisions, keep the tram dark, wake no new threats, and strongly suppress local pressure.")
					events.append({"kind":"kiln"})
		"junction":
			var action=str(extra.get("action",""));var keeper=junction_landmark()
			if action=="start":
				var can_start=not keeper.is_empty() and keeper.get("state","")=="waiting" and data.junction_state=="" and data.kiln_state in ["built","concealed"]
				if not can_start:note("Embervault's independent freight warning is no longer available.")
				else:
					_open_junction_warning(floor_at(z))
					var approach="Kilnreach's hot tram lights the approach and draws three surface husks." if _junction_route()=="hotline" else "Kilnreach's concealed tram opens a dark approach watched by two Gloam stalkers."
					note("Signalkeeper Ren answers from beyond Meridian. "+approach+" Recover the physical signal seal, then receive the freight with two colonists or spend exact materials to shunt it into refuge before thirty seconds pass.")
					events.append({"kind":"junction"})
			else:
				var can_finish=not keeper.is_empty() and data.junction_state=="warning" and float(data.junction_timer)>0 and int(p.inventory.get("junction_seal",0))>=1
				if action=="receive":can_finish=can_finish and junction_gathered()>=2 and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("junction_guard"))
				else:can_finish=can_finish and junction_gathered(true)>=2 and int(p.inventory.get("timber",0))>=2 and int(p.inventory.get("scrap",0))>=2
				if not can_finish:note("Embervault's freight work stopped. Keep the physical seal and gathered crew at the chosen secure route.")
				else:
					if action=="shunt":p.inventory.junction_seal-=1;p.inventory.timber-=2;p.inventory.scrap-=2
					_complete_junction(floor_at(z),"received" if action=="receive" else "shunted",index)
					if action=="receive":note(p.name+" carries Embervault's seal as proof while two colonists receive the independent freight. Ren opens the settlement road and leaves route-shaped cargo.")
					else:note(p.name+" spends Embervault's seal, two timber and two scrap to throw the refuge shunt. The gathered crew saves mixed stores and the hidden road gains strong pressure shelter.")
					events.append({"kind":"junction"})
		"ember_commons":
			var action=str(extra.get("action",""));var keeper=ember_commons_landmark()
			if action=="start":
				var can_start=not keeper.is_empty() and keeper.get("state","")=="waiting" and data.ember_commons_state=="" and data.junction_state in ["received","shunted","missed"]
				if not can_start:note("Embervault's communal signal-house repair is no longer available.")
				else:
					_open_ember_commons_route(floor_at(z))
					var reception="The received freight earns a lit court guarded by one burrower." if _ember_commons_route()=="freight" else "The refuge shunt earns a dark cablewalk watched by one Gloam stalker." if _ember_commons_route()=="refuge" else "The missed train leaves a wary public arcade occupied by two surface husks."
					note("Keeper Sable opens Embervault Commons. "+reception+" Recover the physical signal breaker and carry its exact route-shaped repair materials to the signal house.")
					events.append({"kind":"ember_commons"})
			else:
				var route=_ember_commons_route();var cost=_ember_commons_cost(route);var can_finish=not keeper.is_empty() and data.ember_commons_state=="assigned" and int(p.inventory.get("signal_breaker",0))>=1
				can_finish=can_finish and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("ember_commons_guard"))
				for item in cost:can_finish=can_finish and int(p.inventory.get(item,0))>=int(cost[item])
				if not can_finish:note("Embervault's signal-house work stopped. Keep the physical breaker and exact repair materials in the selected pack until the route is secure.")
				else:
					p.inventory.signal_breaker-=1
					for item in cost:p.inventory[item]-=int(cost[item])
					_complete_ember_commons(floor_at(z),route,index)
					note(p.name+" installs Embervault's physical signal breaker and exact repair contribution. The communal signal house opens the lower stair and leaves route-shaped resident stores.")
					events.append({"kind":"ember_commons"})
		"deepcoil":
			var action=str(extra.get("action",""));var caller=deepcoil_landmark()
			if action=="start":
				var can_start=not caller.is_empty() and caller.get("state","")=="waiting" and data.deepcoil_state=="" and data.ember_commons_state in ["freight","refuge","public"]
				if not can_start:note("Deepcoil's paired relay expedition is no longer available.")
				else:
					_open_deepcoil_route(floor_at(z))
					var answer="Keeper Vey answers on the staffed line; two burrowers guard a lamp-lit relay pair." if _deepcoil_route()=="keepers" else "Freeband Tern answers through darkness; two Gloam stalkers watch the split coils." if _deepcoil_route()=="freeband" else "An unknown voice answers the public signal; a burrower and Gloam stalker divide the galleries."
					note(answer+" Recover both six-and-a-half-kilogram coils in separate packs, clear both branches, and rally the carriers at the synchronizer.")
					events.append({"kind":"deepcoil"})
			else:
				var sync=deepcoil_sync();var sync_target=point(sync) if not sync.is_empty() else Vector2i(-99,-99);var carriers=_deepcoil_carriers(sync_target)
				var can_finish=not caller.is_empty() and data.deepcoil_state=="assigned" and carriers.size()==2
				can_finish=can_finish and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("deepcoil_guard"))
				if not can_finish:note("Deepcoil synchronization stopped. Keep one physical coil in each of two separate packs and gather both carriers at the safe synchronizer.")
				else:
					var route=_deepcoil_route();_complete_deepcoil(floor_at(z),route,index,carriers)
					note(p.name+" synchronizes Deepcoil's separately carried crown and root coils. The answer from below becomes part of the route history, physical stores arrive, and the connected descent opens.")
					events.append({"kind":"deepcoil"})
		"coilward":
			var action=str(extra.get("action",""));var caller=coilward_landmark()
			if action=="start":
				var can_start=not caller.is_empty() and caller.get("state","")=="waiting" and data.coilward_state=="" and data.deepcoil_state in ["keepers","freeband","echo"]
				if not can_start:note("Coilward's community charter is no longer available.")
				else:
					_open_coilward_route(floor_at(z))
					var reception="Steward Oris opens a lamp-lit keeper hall guarded by one burrower." if _coilward_route()=="keepers" else "Speaker Wren opens a dark cableway watched by one Gloam stalker." if _coilward_route()=="freeband" else "The Open Assembly unlocks a wary arcade occupied by two surface husks."
					note(reception+" Recover the physical community charter, clear the route, and carry its exact contribution to the council seal.")
					events.append({"kind":"coilward"})
			else:
				var route=_coilward_route();var cost=_coilward_cost(route);var can_finish=not caller.is_empty() and data.coilward_state=="assigned" and int(p.inventory.get("ward_charter",0))>=1
				can_finish=can_finish and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("coilward_guard"))
				for item in cost:can_finish=can_finish and int(p.inventory.get(item,0))>=int(cost[item])
				if not can_finish:note("Coilward's charter work stopped. Keep the physical charter and exact contribution in the selected pack until the route is secure.")
				else:
					for item in cost:p.inventory[item]-=int(cost[item])
					_complete_coilward(floor_at(z),route,index)
					note(p.name+" ratifies Coilward's charter with the exact route-shaped contribution. The signed charter remains in the pack as physical evidence, resident stores arrive, and the lower road opens.")
					events.append({"kind":"coilward"})
		"charterwell":
			var action=str(extra.get("action",""));var caller=charterwell_landmark()
			if action=="start":
				var can_start=not caller.is_empty() and caller.get("state","")=="waiting" and data.charterwell_state=="" and data.coilward_state in ["keepers","freeband","echo"] and int(p.inventory.get("ward_charter",0))>=1
				if not can_start:note("Charterwell's delegation warning is no longer available, or its charter bearer is missing.")
				else:
					_open_charterwell_warning(floor_at(z))
					var approach="A lamp-lit council road is held by two burrowers." if _charterwell_route()=="council" else "A dark underroad is watched by two Gloam stalkers." if _charterwell_route()=="underroad" else "A wary public arcade is occupied by three surface husks."
					note(p.name+" presents Coilward's signed charter. "+approach+" Clear it and rally three colonists for an escort, or bring exact supplies and two colonists to the passage gate before thirty seconds pass.")
					events.append({"kind":"charterwell"})
			else:
				var can_finish=not caller.is_empty() and data.charterwell_state=="warning" and float(data.charterwell_timer)>0 and int(p.inventory.get("ward_charter",0))>=1
				if action=="escort":can_finish=can_finish and charterwell_gathered()>=3 and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("charterwell_guard"))
				else:
					can_finish=can_finish and charterwell_gathered(true)>=2
					var cost=_charterwell_cost()
					for item in cost:can_finish=can_finish and int(p.inventory.get(item,0))>=int(cost[item])
				if not can_finish:note("Charterwell's delegation work stopped. Keep the signed charter and gathered crew at the chosen secure route.")
				else:
					if action=="supply":
						for item in _charterwell_cost():p.inventory[item]-=int(_charterwell_cost()[item])
					_complete_charterwell(floor_at(z),"escorted" if action=="escort" else "supplied",index)
					if action=="escort":note(p.name+" retains Coilward's charter while three colonists escort the delegation. A signed writ and route-shaped issue remain, and the lower road opens.")
					else:note(p.name+" retains Coilward's charter after spending exact passage supplies with a two-colonist crew. The guards withdraw, a signed writ remains, and the lower road gains pressure shelter.")
					events.append({"kind":"charterwell"})
		"writwell":
			var action=str(extra.get("action",""));var speaker=writwell_landmark()
			if action=="start":
				var can_start=not speaker.is_empty() and speaker.get("state","")=="waiting" and data.writwell_state=="" and data.charterwell_state in ["escorted","supplied","missed"] and int(p.inventory.get("delegate_writ",0))>=1
				if not can_start:note("Writwell's vote is no longer available, or its writ bearer is missing.")
				else:
					_open_writwell_vote(floor_at(z))
					var approach="A lamp-lit delegate gallery is held by two burrowers." if _writwell_route()=="delegates" else "A dark exchange cloister is watched by two Gloam stalkers." if _writwell_route()=="exchange" else "A mixed-light public aisle is occupied by three surface husks."
					note(p.name+" presents Charterwell's physical writ. "+approach+" Clear it, rally three colonists, and divide the exact pledge across at least two packs before calling the vote.")
					events.append({"kind":"writwell"})
			else:
				var can_finish=not speaker.is_empty() and data.writwell_state=="assigned" and int(p.inventory.get("delegate_writ",0))>=1 and writwell_crew().size()>=3 and writwell_contributors()>=2
				can_finish=can_finish and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("writwell_guard"))
				for item in _writwell_cost():can_finish=can_finish and writwell_available(item)>=int(_writwell_cost()[item])
				if not can_finish:note("Writwell's vote stopped. Keep the physical writ present, clear the gallery, and divide the exact pledge across two of three gathered packs.")
				else:
					_consume_writwell_pledge()
					_complete_writwell(floor_at(z),index)
					note(p.name+" calls Writwell's three-colonist vote. The exact pledge is drawn across distinct packs, Charterwell's writ remains physical, an assembly mandate is issued, and the lower road opens.")
					events.append({"kind":"writwell"})
		"concordance":
			var action=str(extra.get("action",""));var speaker=concordance_landmark()
			if action=="start":
				var can_start=not speaker.is_empty() and speaker.get("state","")=="waiting" and data.concordance_state=="" and data.writwell_state in ["delegates","exchange","commons"] and int(p.inventory.get("assembly_mandate",0))>=1
				if can_start:
					_open_concordance(floor_at(z))
					var approach="A lamp-lit council guardline is held by two burrowers." if _concordance_route()=="council" else "A dark shadow approach is watched by two Gloam stalkers." if _concordance_route()=="shadow" else "A mixed-light public breach is occupied by three surface husks."
					note(p.name+" presents Writwell's physical mandate. "+approach+" Clear it and build a fixed bastion, or withdraw past it to provision a mobile reserve.")
					events.append({"kind":"concordance"})
			else:
				var gathered=concordance_gathered(action=="reserve");var needed=2 if action=="reserve" else 3
				var can_finish=not speaker.is_empty() and data.concordance_state=="assigned" and int(p.inventory.get("assembly_mandate",0))>=1 and gathered>=needed
				if action=="bastion":can_finish=can_finish and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("concordance_guard"))
				for item in _concordance_cost(action):can_finish=can_finish and int(p.inventory.get(item,0))>=int(_concordance_cost(action)[item])
				if not can_finish:note("Concordance's defense work stopped. Keep the mandate and exact chosen supplies with the selected colonist, then rally the required crew.")
				else:
					for item in _concordance_cost(action):p.inventory[item]=int(p.inventory.get(item,0))-int(_concordance_cost(action)[item])
					_complete_concordance(floor_at(z),action,index)
					note(p.name+" anchors Concordance's fixed bastion. Its exact construction stores are consumed, the gate gains recovery shelter, and its heat increases surface pressure." if action=="bastion" else p.name+" provisions Concordance's mobile reserve. The guards are bypassed, the exact medical stores are consumed, and the deepest reached road gains pressure shelter.")
					events.append({"kind":"concordance"})
		"reservefall":
			var action=str(extra.get("action",""));var speaker=reservefall_landmark()
			if action=="start":
				var can_start=not speaker.is_empty() and speaker.get("state","")=="waiting" and data.reservefall_state=="" and data.concordance_state in ["bastion","reserve"] and int(p.inventory.get("concordance_token",0))>=1
				if not can_start:note("Reservefall's warning is no longer available, or its response-token bearer is missing.")
				else:
					_open_reservefall_warning(floor_at(z))
					var approach="Four surface husks descend the lamp-lit hot tram." if _reservefall_route()=="bastion" else "Two surface husks break through the reserve's dark interception road."
					note(p.name+" presents Concordance's physical response token. "+approach+" Hold with three colonists, or withdraw two colonists with exact materials before thirty seconds pass.")
					events.append({"kind":"reservefall"})
			else:
				var can_finish=not speaker.is_empty() and data.reservefall_state=="warning" and float(data.reservefall_timer)>0 and int(p.inventory.get("concordance_token",0))>=1
				if action=="hold":can_finish=can_finish and reservefall_gathered()>=3 and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("reservefall_guard"))
				else:
					can_finish=can_finish and reservefall_gathered(true)>=2
					for item in _reservefall_cost():can_finish=can_finish and int(p.inventory.get(item,0))>=int(_reservefall_cost()[item])
				if not can_finish:note("Reservefall's response stopped. Keep the token bearer and required crew at the chosen position before the warning expires.")
				else:
					if action=="withdraw":
						for item in _reservefall_cost():p.inventory[item]=int(p.inventory.get(item,0))-int(_reservefall_cost()[item])
					_complete_reservefall(floor_at(z),"held" if action=="hold" else "withdrawn",index)
					note(p.name+" holds Reservefall's line with three colonists. The response token remains physical, resident stores issue a quarter pass, and the inhabited lower road opens." if action=="hold" else p.name+" withdraws Reservefall's residents behind a material-backed fallback. Live husks are bypassed, the response token remains physical, and a quarter pass opens the sheltered lower road.")
					events.append({"kind":"reservefall"})
		"reserve_commons":
			var action=str(extra.get("action",""));var steward=reserve_commons_landmark()
			if action=="start":
				var can_start=not steward.is_empty() and steward.get("state","")=="waiting" and data.reserve_commons_state=="" and data.reservefall_state in ["held","withdrawn","breached"] and int(p.inventory.get("quarter_pass",0))>=1
				if not can_start:note("Reservefall Commons no longer recognizes this pass or repair request.")
				else:
					_open_reserve_commons(floor_at(z))
					var route=_reserve_commons_route();var reception="a lamp-lit resident court guarded by one burrower" if route=="guarded" else "a dark refuge culvert watched by one Gloam stalker" if route=="sheltered" else "a wary public arcade occupied by two surface husks"
					note(p.name+" presents the physical quarter pass. The junction's history opens "+reception+". Recover the 4 kg communal shield, clear the route and bring its exact materials to the repair court.")
					events.append({"kind":"reserve_commons"})
			else:
				var route=_reserve_commons_route();var cost=_reserve_commons_cost(route)
				var can_finish=not steward.is_empty() and data.reserve_commons_state=="assigned" and int(p.inventory.get("quarter_pass",0))>=1 and int(p.inventory.get("quarter_shield",0))>=1 and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("reserve_commons_guard"))
				for item in cost:can_finish=can_finish and int(p.inventory.get(item,0))>=int(cost[item])
				if not can_finish:note("The communal repair stopped. Keep the quarter pass, shield and exact materials with the selected colonist after securing the reception road.")
				else:
					p.inventory.quarter_shield-=1
					for item in cost:p.inventory[item]=int(p.inventory.get(item,0))-int(cost[item])
					_complete_reserve_commons(floor_at(z),route,index)
					note(p.name+" installs Reservefall's communal shield and exact materials. The quarter pass remains physical, route-shaped resident stores open, and Shieldline descent becomes connected.")
					events.append({"kind":"reserve_commons"})
		"shieldline":
			var action=str(extra.get("action",""));var master=shieldline_landmark();var route=_shieldline_route()
			if action=="start":
				var can_start=not master.is_empty() and master.get("state","")=="waiting" and data.shieldline_state=="" and data.reserve_commons_state in ["guarded","sheltered","public"] and not data.shieldline_recruit_joined and int(p.inventory.get("quarter_pass",0))>=1
				if not can_start:note("Shieldline's carriage contract is no longer available, or its quarter-pass bearer is missing.")
				else:
					_open_shieldline(floor_at(z))
					var approach="Reservefall's guard court opens lamp-lit component lanes held by two burrowers." if route=="guarded" else "Reservefall's refuge opens dark component lanes watched by two Gloam stalkers." if route=="sheltered" else "Reservefall's public defense opens split lanes held by a burrower and a Gloam stalker."
					note(p.name+" presents the physical quarter pass. "+approach+" Kest joins with a separate pack. Recover the six-kilogram folding frame and axle in two packs, then gather three colonists with Kest at the carriage.")
					_remember_nearby(index,"recruit","Welcomed Kest at Shieldline with {other}.",8.0,8);events.append({"kind":"shieldline"})
			else:
				var carriage=shieldline_carriage();var assembly_point=point(carriage) if not carriage.is_empty() else point(p);var carriers=_shieldline_carriers(assembly_point);var kest_index=_kest_index()
				var can_finish=not carriage.is_empty() and data.shieldline_state=="assigned" and carriers.size()==2 and shieldline_gathered()>=3 and kest_index>=0
				can_finish=can_finish and int(data.pawns[kest_index].z)==48 and point(data.pawns[kest_index]).distance_to(assembly_point)<=4.0
				can_finish=can_finish and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("shieldline_guard"))
				if not can_finish:note("Shieldline's assembly stopped. Keep both heavy parts in separate packs and gather Kest with three living colonists at the secure carriage.")
				else:
					data.pawns[int(carriers[0])].inventory.shield_frame-=1;data.pawns[int(carriers[1])].inventory.shield_axle-=1
					_complete_shieldline(floor_at(z),route,index)
					note("The two carriers mount Shieldline's physical frame and axle while Kest coordinates the crew. The folding shieldwall blueprint is now available everywhere, route-shaped stores remain physical, and the lower works road opens.")
					events.append({"kind":"shieldline"})
		"marchhold":
			var action=str(extra.get("action",""));var speaker=marchhold_landmark()
			if action=="start":
				var can_start=not speaker.is_empty() and speaker.get("state","")=="waiting" and data.marchhold_state=="" and data.shieldline_state in ["guarded","sheltered","public"] and _kest_index()>=0
				if not can_start:note("Marchhold's mobile-camp warning is no longer available, or Kest is missing.")
				else:
					_open_marchhold_warning(floor_at(z))
					var approach="Shieldline's guarded carriage reaches a lamp-lit bridge as four surface husks descend." if _marchhold_route()=="guarded" else "Shieldline's concealed carriage reaches a dark service span with two husks closing in." if _marchhold_route()=="sheltered" else "Shieldline's public carriage reaches a broken mixed-light crossing with three husks."
					note(approach+" Recover the physical folded wall. Clear the crossing and deploy with Kest plus three colonists, or carry it away with two colonists and exact provisions before thirty-two seconds pass.")
					events.append({"kind":"marchhold"})
			else:
				var can_finish=not speaker.is_empty() and data.marchhold_state=="warning" and float(data.marchhold_timer)>0 and int(p.inventory.get("march_wall",0))>=1
				if action=="deploy":
					can_finish=can_finish and marchhold_gathered()>=3 and _marchhold_kest_ready(point(p)) and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("marchhold_guard"))
					for item in _marchhold_deploy_cost():can_finish=can_finish and int(p.inventory.get(item,0))>=int(_marchhold_deploy_cost()[item])
				else:
					can_finish=can_finish and marchhold_gathered(true)>=2
					for item in _marchhold_retreat_cost():can_finish=can_finish and int(p.inventory.get(item,0))>=int(_marchhold_retreat_cost()[item])
				if not can_finish:note("Marchhold's response stopped. Keep the folded wall, exact supplies and required crew together at the chosen line before the warning expires.")
				elif action=="deploy":
					p.inventory.march_wall-=1
					for item in _marchhold_deploy_cost():p.inventory[item]-=int(_marchhold_deploy_cost()[item])
					var kest_index=_kest_index();data.pawns[kest_index].skills.build=int(data.pawns[kest_index].skills.build)+1
					_complete_marchhold(floor_at(z),"deployed",index)
					note(p.name+" and Kest lock the folded wall into three physical shield sections. Exact construction materials are consumed, the camp holds, and a crossing seal opens the lower road.")
					events.append({"kind":"marchhold"})
				else:
					for item in _marchhold_retreat_cost():p.inventory[item]-=int(_marchhold_retreat_cost()[item])
					_complete_marchhold(floor_at(z),"retreated",index)
					note(p.name+" carries the folded wall through Marchhold's retreat ramp with exact provisions. The wall remains physical in its pack, the husks lose the mobile camp, and a crossing seal opens the lower road.")
					events.append({"kind":"marchhold"})
		"march_refuge":
			var action=str(extra.get("action",""));var keeper=march_refuge_landmark();var route=_march_refuge_route()
			if action=="start":
				var can_start=not keeper.is_empty() and keeper.get("state","")=="waiting" and data.march_refuge_state=="" and data.marchhold_state in ["deployed","retreated","overrun"] and int(p.inventory.get("crossing_seal",0))>=1
				if not can_start:note("Marchhold Refuge no longer accepts this crossing-seal audience.")
				else:
					_open_march_refuge(floor_at(z))
					var approach="Marchhold's deployed wall earns a guarded, lamp-lit reception watched by a burrower." if route=="guarded" else "Marchhold's retreat opens a dark shelter road watched by a Gloam stalker." if route=="sheltered" else "Marchhold's overrun opens a damaged public road held by two surface husks."
					note(p.name+" presents the physical crossing seal. "+approach+" Recover the four-kilogram refuge brace, clear the road and bring exact repair materials. A sheltered crew may instead donate its still-mobile folded wall.")
					events.append({"kind":"march_refuge"})
			else:
				var can_finish=not keeper.is_empty() and data.march_refuge_state=="assigned" and int(p.inventory.get("crossing_seal",0))>=1 and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("march_refuge_guard"))
				if action=="donate":
					can_finish=can_finish and route=="sheltered" and int(p.inventory.get("march_wall",0))>=1 and int(p.inventory.get("timber",0))>=1 and int(p.inventory.get("scrap",0))>=1
				else:
					can_finish=can_finish and int(p.inventory.get("refuge_brace",0))>=1
					for item in _march_refuge_cost(route):can_finish=can_finish and int(p.inventory.get(item,0))>=int(_march_refuge_cost(route)[item])
				if not can_finish:note("Marchhold Refuge's repair stopped. Keep the crossing seal and chosen physical defense with exact supplies after clearing the reception road.")
				elif action=="donate":
					p.inventory.march_wall-=1;p.inventory.timber-=1;p.inventory.scrap-=1
					_complete_march_refuge(floor_at(z),"walled",index)
					note(p.name+" donates the still-mobile folded wall with 1 timber and 1 scrap. Three communal shield sections now guard the refuge; the crossing seal remains physical in its carrier's pack.")
					events.append({"kind":"march_refuge"})
				else:
					p.inventory.refuge_brace-=1
					for item in _march_refuge_cost(route):p.inventory[item]-=int(_march_refuge_cost(route)[item])
					_complete_march_refuge(floor_at(z),route,index)
					note(p.name+" installs the refuge brace and exact route-shaped materials. The crossing seal and any carried folded wall remain physical, resident stores open and the lower road connects.")
					events.append({"kind":"march_refuge"})
		"wallward":
			var action=str(extra.get("action",""));var post=wallward_landmark();var route=_wallward_route()
			if action=="start":
				var can_start=not post.is_empty() and post.get("state","")=="waiting" and data.wallward_state=="" and data.march_refuge_state in ["guarded","sheltered","public","walled"] and int(p.inventory.get("crossing_seal",0))>=1
				if not can_start:note("Wallward's convoy warning is no longer available, or its seal bearer is missing.")
				else:
					_open_wallward_warning(floor_at(z))
					var approach="Three surface husks descend the lamp-lit guard road." if route=="guarded" else "Two surface husks push against the wall-keeper road." if route=="walled" else "Two Gloam stalkers watch the dark convoy cut." if route=="sheltered" else "Three surface husks occupy the broken public descent."
					note(p.name+" presents Marchhold's physical crossing seal. "+approach+" Recover the 3 kg beacon and either clear the route with three colonists or screen it with exact materials and two colonists before thirty seconds pass.")
					events.append({"kind":"wallward"})
			else:
				var can_finish=not post.is_empty() and data.wallward_state=="warning" and float(data.wallward_timer)>0 and int(p.inventory.get("crossing_seal",0))>=1 and int(p.inventory.get("wallward_beacon",0))>=1
				if action=="escort":can_finish=can_finish and wallward_gathered()>=3 and not floor_at(z).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("wallward_guard"))
				else:can_finish=can_finish and wallward_gathered(true)>=2 and int(p.inventory.get("timber",0))>=2 and int(p.inventory.get("scrap",0))>=2
				if not can_finish:note("Wallward's convoy work stopped. Keep the crossing seal, physical beacon and required crew at the chosen rendezvous before the warning expires.")
				else:
					p.inventory.wallward_beacon-=1
					if action=="screen":p.inventory.timber-=2;p.inventory.scrap-=2
					_complete_wallward(floor_at(z),"escorted" if action=="escort" else "screened",index)
					note(p.name+" escorts Wallward's convoy with three colonists. The beacon is handed over, the crossing seal remains physical, a convoy tally is issued and the lower road opens." if action=="escort" else p.name+" screens Wallward's convoy with two colonists and exact materials. Live threats are bypassed, the beacon is handed over, the crossing seal remains physical and the lower road gains pressure shelter.")
					events.append({"kind":"wallward"})
		"travel":
			var destination = int(extra.destination)
			var nz = z + (1 if destination > z else -1)
			ensure_floor(nz)
			var landing = vec(floor_at(nz).up if nz > z else floor_at(nz).down)
			p.z = nz; p.x = landing.x; p.y = landing.y
			for other in data.pawns:
				if other != p and other.z == nz and point(other) == landing:
					for d in DIRS:
						if walkable(nz,landing+d): p.x += d.x; p.y += d.y; break
			data.deepest = max(int(data.deepest),nz)
			note(p.name+" reached depth "+str(nz+1)+": "+theme_for(nz)+".")
			events.append({"kind":"stairs"})
			if destination != nz:
				var travel_problem=order_travel(index,destination)
				if travel_problem!="":note(p.name+" stopped traveling: "+travel_problem)
		"rest":
			p.hp = min(100.0,p.hp+25.0)
			p.injury=max(0,int(p.injury)-1)
			p.fatigue=max(0.0,float(p.fatigue)-85.0)
			note(p.name+" rested at the bedroll. Fatigue and injuries eased.")
		"tend":
			var patient_index=int(extra.get("patient",-1))
			if patient_index<0 or patient_index>=data.pawns.size():note("Tending stopped; the patient is gone.")
			else:
				var patient=data.pawns[patient_index];var bed=pawn_at_bed(patient)
				if patient.hp<=0 or bed.is_empty() or point(patient)!=target:note("Tending stopped; the patient is no longer at the bedroll.")
				elif not _safe_for_colony_work(z):note("Tending stopped when the floor became unsafe. The medkit was kept.")
				elif int(p.inventory.get("medkit",0))<1:note("Tending stopped; the medkit is missing.")
				else:
					p.inventory.medkit-=1
					patient.hp=max(45.0,float(patient.hp))
					patient.injury=min(2,int(patient.injury))
					patient.fatigue=max(70.0,float(patient.fatigue))
					patient.bed_id=-1
					record_shared_memory(index,patient_index,"rescue","Carried {other} out and survived the wound together.",8.0,7)
					note(p.name+" tended "+patient.name+" with a medkit. They can move again, but still need recovery.")
					events.append({"kind":"find"})
		"wayfarer":
			var action=str(extra.get("action",""));var speaker=wayfarer_landmark()
			if action=="start":
				var can_start=z==52 and not speaker.is_empty() and speaker.get("state","")=="waiting" and data.wayfarer_state=="" and data.wallward_state in ["escorted","screened","missed"] and int(p.inventory.get("convoy_tally",0))>=1
				if not can_start:note("Wayfarer's audience stopped. Keep the physical convoy tally with its bearer.")
				else:
					_open_wayfarer(floor_at(z))
					note("Roadkeeper Senn reads the carried convoy tally. Clear the reception lane, recover the 6 kg roadstead jack, and gather two fit colonists with exact timber and scrap at the shared repair court.")
					events.append({"kind":"wayfarer"})
			else:
				var repair_error=wayfarer_repair_error(index)
				if repair_error!="":note("Wayfarer repair stopped without consuming supplies. "+repair_error)
				else:
					_complete_wayfarer(floor_at(z),index,_wayfarer_delivery())
					note("Two carriers set Wayfarer's jack and exact shared materials into the roadstead. The tally stays in its owner's pack, resident stores open, and the Underway road becomes connected.")
					events.append({"kind":"wayfarer"})
		"underway":
			var action=str(extra.get("action",""))
			if action=="start":
				var speaker=underway_landmark()
				var can_start=z==53 and not speaker.is_empty() and speaker.get("state","")=="waiting" and data.underway_state=="" and data.wayfarer_state in ["resident","hidden","public"] and int(p.inventory.get("convoy_tally",0))>=1
				if not can_start:note("The Underway survey stopped. Keep the physical convoy tally with its bearer.")
				else:
					_open_underway(floor_at(z))
					note("The survey post reads Wayfarer's tally. Clear the approach, recover the 2 kg survey kit, then choose the warned waylight bridge or concealed bypass.")
					events.append({"kind":"underway"})
			else:
				var survey_error=underway_error(index,action)
				if survey_error!="":note("Underway work stopped without consuming supplies. "+survey_error)
				else:
					_complete_underway(floor_at(z),index,action)
					note(("The waylights burn and two warned surface husks enter the lower gallery." if action=="lit" else "The shrouded bypass opens without a new incursion.")+" The physical route token stays with its surveyor.")
					events.append({"kind":"underway"})
		"spring":
			var spring={}
			for mark in floor_at(z).landmarks:
				if mark.get("kind","")=="spring" and point(mark)==target:spring=mark;break
			if spring.is_empty() or spring.get("state","")!="untouched":note("The luminous spring has already been changed.")
			elif extra.get("choice","")=="drink":
				spring.state="drunk";p.hp=min(100.0,float(p.hp)+35.0);p.hunger=max(0.0,float(p.hunger)-35.0);p.injury=max(0,int(p.injury)-1)
				note(p.name+" drank from the luminous spring. The water cleared, leaving bare stone.")
			else:
				spring.state="harvested"
				var cache=container_at(z,target)
				if cache.is_empty():floor_at(z).containers.append({"id":next_id(),"x":target.x,"y":target.y,"name":"Spring crystal harvest","searched":true,"items":{"crystal":3},"kind":"ground"})
				else:cache.items.crystal=int(cache.items.get("crystal",0))+3
				note(p.name+" drained the luminous spring. Three glowstones remain on the cavern floor.")
			_remember_nearby(index,"discovery","Resolved the luminous spring with {other}.",5.0,4)
			events.append({"kind":"find"})
		"pump":
			var console={}
			for mark in floor_at(z).landmarks:
				if mark.get("kind","")=="pump_console" and point(mark)==target:console=mark;break
			if console.is_empty() or console.get("state","")!="idle":note("The emergency pump is already silent.")
			else:
				var choice=str(extra.get("choice",""));_drain_sunken_branch(floor_at(z),choice)
				var place="residential shelter" if choice=="residences" else "utility substation"
				note(p.name+" rerouted the emergency pump. The "+place+" branch is draining; the other route is lost.")
				_remember_nearby(index,"discovery","Reclaimed the Sunken Quarter with {other}.",5.0,4)
			events.append({"kind":"find"})
	reveal_all()

func _finish_rescue(index:int):
	var rescuer=data.pawns[index];var job=rescuer.job
	if job.is_empty() or job.get("kind","")!="rescue":return
	var extra=job.get("extra",{});var patient_index=int(extra.get("patient",-1));var bed_id=int(extra.get("bed",-1));var z=int(rescuer.z)
	if patient_index<0 or patient_index>=data.pawns.size():rescuer.job={};note("Rescue stopped; the patient is gone.");return
	var patient=data.pawns[patient_index];var bed=structure_by_id(z,bed_id)
	if patient.hp<=0 or not incapacitated(patient):rescuer.job={};note("Rescue stopped; the patient can no longer be carried.");return
	if bed.is_empty() or bed.get("kind","")!="bed":rescuer.job={};note("Rescue stopped; the assigned bedroll is gone.");return
	if not bool(extra.get("carrying",false)):
		if point(rescuer).distance_to(point(patient))>1.01:rescuer.job={};note("Rescue stopped; the patient could not be reached.");return
		var route=path_to(z,point(rescuer),point(bed),false)
		if route.is_empty():rescuer.job={};note("Rescue stopped; the bedroll is no longer reachable.");return
		extra.carrying=true;job.target=arr(point(bed));job.path=route.slice(1);job.elapsed=0.0;job.duration=1.0;patient.x=rescuer.x;patient.y=rescuer.y
		note(rescuer.name+" lifted "+patient.name+" and is carrying them to a bedroll.")
		return
	if point(rescuer)!=point(bed):rescuer.job={};note("Rescue stopped before the bedroll.");return
	patient.x=bed.x;patient.y=bed.y;patient.z=z;patient.bed_id=bed_id
	rescuer.job={};rescuer.move_clock=0.0
	note(rescuer.name+" brought "+patient.name+" to a bedroll. A safe colonist with a medkit must tend them.")
	events.append({"kind":"find"})
	reveal_all()

func _finish_retreat(index:int):
	var pawn=data.pawns[index];var job=pawn.job
	if job.is_empty() or job.get("kind","")!="retreat":return
	var extra=job.get("extra",{});var source=int(extra.get("source",pawn.z));var destination=int(extra.get("destination",source));var group=int(extra.get("group",-1));var target=vec(job.target)
	if int(pawn.z)!=source or point(pawn)!=target:
		pawn.job={};note(pawn.name+" could not reach the retreat point.");return
	var ready:Array=[]
	for member_value in extra.get("members",[]):
		var member_index=int(member_value)
		if member_index<0 or member_index>=data.pawns.size():continue
		var member=data.pawns[member_index]
		if member.hp<=0 or int(member.z)!=source:continue
		var member_job=member.get("job",{})
		if member_job.get("kind","")!="retreat" or int(member_job.get("extra",{}).get("group",-2))!=group:continue
		ready.append(member_index)
		if not member_job.get("path",[]).is_empty() or point(member)!=target:
			pawn.job.elapsed=0.0
			return
	if ready.is_empty():pawn.job={};return
	ensure_floor(destination)
	var landing=vec(floor_at(destination).up if destination>source else floor_at(destination).down)
	var spots:Array=[landing]
	for direction in DIRS:
		if walkable(destination,landing+direction):spots.append(landing+direction)
	var names:Array=[]
	for at in ready.size():
		var member=data.pawns[ready[at]];var spot=spots[min(at,spots.size()-1)]
		member.job={};member.move_clock=0.0;member.z=destination;member.x=spot.x;member.y=spot.y
		names.append(str(member.name))
	for first in ready.size():
		for second in range(first+1,ready.size()):
			record_shared_memory(ready[first],ready[second],"retreat","Made the descent to depth "+str(destination+1)+" with {other}.",6.0,5)
	data.deepest=max(int(data.deepest),destination)
	note(", ".join(names)+" moved together to depth "+str(destination+1)+": "+theme_for(destination)+".")
	events.append({"kind":"stairs"})
	reveal_all()

func _move_pawn(p: Dictionary, dt: float):
	var job = p.job
	if job.path.is_empty(): return
	p.move_clock += dt
	var duration = (0.16 if p.drafted else 0.20)*(1.0+int(p.injury)*0.20)*(1.0+float(p.fatigue)*0.004)*morale_action_multiplier(p)
	if job.get("kind","")=="rescue" and bool(job.get("extra",{}).get("carrying",false)):duration*=1.45
	if p.move_clock < duration: return
	p.move_clock -= duration
	var dest = vec(job.path[0])
	if not walkable(p.z,dest) or point(p).distance_to(dest) > 1.01:
		p.job = {}
		note(p.name+" stopped: the route changed.")
		return
	p.facing = 1 if dest.x >= p.x else -1
	p.x = dest.x; p.y = dest.y
	if job.get("kind","")=="rescue" and bool(job.get("extra",{}).get("carrying",false)):
		var patient_index=int(job.extra.get("patient",-1))
		if patient_index>=0 and patient_index<data.pawns.size():
			var patient=data.pawns[patient_index];patient.x=p.x;patient.y=p.y;patient.z=p.z
	job.path.pop_front()

func spawn_enemy(z: int, p: Vector2i, enemy_name: String):
	floor_at(z).enemies.append({"id":next_id(),"x":p.x,"y":p.y,"hp":24.0 if enemy_name == "Burrower" else 30.0,"name":enemy_name,"clock":0.0,"attack":0.0})

func pressure_report(z:int)->Dictionary:
	var f=floor_at(z);var report={"rate":-0.025,"lanterns":0,"relays":0,"beacons":0,"alarms":0,"ringing":0,"stored":0.0}
	for s in f.structures:
		if s.hp<=0:continue
		match str(s.kind):
			"lamp":report.lanterns+=1;report.rate+=0.13
			"relay":report.relays+=1;report.rate+=0.24
			"decoy":report.beacons+=1;report.rate+=0.32
			"tripwire":
				report.alarms+=1
				if s.get("state","armed")=="ringing":report.ringing+=1
	for c in f.containers:
		if c.kind=="stockpile":
			var contribution=min(0.1,weight(c.items)*0.002)
			report.stored+=contribution;report.rate+=contribution
	if z==12 and data.service_choice=="field":report.rate=-0.025+(float(report.rate)+0.025)*0.45
	if z==17 and data.stillworks_choice=="dark":report.rate=-0.025+(float(report.rate)+0.025)*0.40
	if z==20 and data.tidecourt_state=="contracted":report.rate=-0.025+(float(report.rate)+0.025)*0.50
	if z==21 and data.sump_state in ["resident","service","public"]:report.rate=-0.025+(float(report.rate)+0.025)*(0.35 if data.sump_state=="service" else 0.70)
	if z==24 and data.refuge_state=="foothold":report.rate=-0.025+(float(report.rate)+0.025)*0.40
	if data.refuge_state=="corridor" and z>=24 and z==int(data.deepest):report.rate=-0.025+(float(report.rate)+0.025)*0.55
	if z==26 and data.customs_state=="security":report.rate=-0.025+(float(report.rate)+0.025)*0.55
	if z==27 and data.railcourt_state=="resident":report.rate=-0.025+(float(report.rate)+0.025)*0.50
	if z==29 and data.morrow_state=="resident":report.rate=-0.025+(float(report.rate)+0.025)*0.45
	if z==30 and data.terminus_state=="free":report.rate=-0.025+(float(report.rate)+0.025)*0.40
	if z==31 and data.farline_state=="cacheway":report.rate=-0.025+(float(report.rate)+0.025)*0.35
	if z==32 and data.thimble_state=="evacuated":report.rate=-0.025+(float(report.rate)+0.025)*0.30
	if z==33 and data.latchwater_state=="cold":report.rate=-0.025+(float(report.rate)+0.025)*0.25
	if z==33 and data.latchwater_state=="warm":report.rate+=0.12
	if z==34 and data.driftglass_state=="shaded":report.rate=-0.025+(float(report.rate)+0.025)*0.20
	if z==34 and data.driftglass_state=="powered":report.rate+=0.14
	if z==35 and data.bellhome_state=="diverted":report.rate=-0.025+(float(report.rate)+0.025)*0.25
	if z==35 and data.bellhome_state=="escorted" and _bellhome_route()=="darkway":report.rate=-0.025+(float(report.rate)+0.025)*0.55
	if z==35 and data.bellhome_state=="escorted" and _bellhome_route()=="lampline":report.rate+=0.08
	if z==36 and data.commons_state=="culvert":report.rate=-0.025+(float(report.rate)+0.025)*0.25
	if z==36 and data.commons_state=="public":report.rate=-0.025+(float(report.rate)+0.025)*0.70
	if z==37 and data.yard_state=="culvert":report.rate=-0.025+(float(report.rate)+0.025)*0.22
	if z==37 and data.yard_state=="public":report.rate=-0.025+(float(report.rate)+0.025)*0.70
	if z==38 and data.kiln_state=="concealed":report.rate=-0.025+(float(report.rate)+0.025)*0.20
	if z==38 and data.kiln_state=="built":report.rate+=0.16
	if z==39 and data.junction_state=="shunted":report.rate=-0.025+(float(report.rate)+0.025)*0.25
	if z==39 and data.junction_state=="received" and _junction_route()=="shadowline":report.rate=-0.025+(float(report.rate)+0.025)*0.55
	if z==39 and data.junction_state=="received" and _junction_route()=="hotline":report.rate+=0.08
	if z==40 and data.ember_commons_state=="refuge":report.rate=-0.025+(float(report.rate)+0.025)*0.22
	if z==40 and data.ember_commons_state=="public":report.rate=-0.025+(float(report.rate)+0.025)*0.70
	if z==41 and data.deepcoil_state=="freeband":report.rate=-0.025+(float(report.rate)+0.025)*0.20
	if z==41 and data.deepcoil_state=="echo":report.rate=-0.025+(float(report.rate)+0.025)*0.68
	if z==42 and data.coilward_state=="freeband":report.rate=-0.025+(float(report.rate)+0.025)*0.20
	if z==42 and data.coilward_state=="echo":report.rate=-0.025+(float(report.rate)+0.025)*0.68
	if z==43 and data.charterwell_state=="supplied":report.rate=-0.025+(float(report.rate)+0.025)*0.20
	if z==43 and data.charterwell_state=="escorted" and _charterwell_route()=="council":report.rate+=0.06
	if z==44 and data.writwell_state=="exchange":report.rate=-0.025+(float(report.rate)+0.025)*0.18
	if z==44 and data.writwell_state=="commons":report.rate=-0.025+(float(report.rate)+0.025)*0.65
	if z==44 and data.writwell_state=="delegates":report.rate+=0.05
	if z==45 and data.concordance_state=="bastion":report.rate+=0.08
	if data.concordance_state=="reserve" and z>=45 and z==int(data.deepest):report.rate=-0.025+(float(report.rate)+0.025)*0.28
	if z==46 and data.reservefall_state=="withdrawn":report.rate=-0.025+(float(report.rate)+0.025)*0.18
	if z==46 and data.reservefall_state=="breached":report.rate=-0.025+(float(report.rate)+0.025)*0.68
	if z==47 and data.reserve_commons_state=="sheltered":report.rate=-0.025+(float(report.rate)+0.025)*0.18
	if z==47 and data.reserve_commons_state=="public":report.rate=-0.025+(float(report.rate)+0.025)*0.68
	if z==48 and data.shieldline_state=="sheltered":report.rate=-0.025+(float(report.rate)+0.025)*0.18
	if z==48 and data.shieldline_state=="public":report.rate=-0.025+(float(report.rate)+0.025)*0.68
	if z==49 and data.marchhold_state=="retreated":report.rate=-0.025+(float(report.rate)+0.025)*0.18
	if z==49 and data.marchhold_state=="overrun":report.rate=-0.025+(float(report.rate)+0.025)*0.78
	if z==50 and data.march_refuge_state in ["sheltered","walled"]:report.rate=-0.025+(float(report.rate)+0.025)*(0.12 if data.march_refuge_state=="walled" else 0.18)
	if z==50 and data.march_refuge_state=="public":report.rate=-0.025+(float(report.rate)+0.025)*0.68
	if z==51 and data.wallward_state=="screened":report.rate=-0.025+(float(report.rate)+0.025)*0.16
	if z==51 and data.wallward_state=="missed":report.rate=-0.025+(float(report.rate)+0.025)*0.72
	if z==52 and data.wayfarer_state=="hidden":report.rate=-0.025+(float(report.rate)+0.025)*0.16
	if z==52 and data.wayfarer_state=="public":report.rate=-0.025+(float(report.rate)+0.025)*0.62
	if z==53 and data.underway_state=="hidden":report.rate=-0.025+(float(report.rate)+0.025)*0.14
	return report

func active_decoy(z:int,listener:Vector2i=Vector2i(-100,-100))->Dictionary:
	var closest:Dictionary={};var distance=INF
	for structure in floor_at(z).structures:
		if structure.kind!="decoy" or structure.hp<=0:continue
		var candidate=point(structure).distance_to(listener)
		if listener.x>-100 and candidate>DECOY_RADIUS:continue
		if candidate<distance:closest=structure;distance=candidate
	return closest

func active_tripwire(z:int,listener:Vector2i=Vector2i(-100,-100))->Dictionary:
	var closest:Dictionary={};var distance=INF
	for structure in floor_at(z).structures:
		if structure.kind!="tripwire" or structure.hp<=0 or structure.get("state","armed")!="ringing" or float(structure.get("ring",0))<=0:continue
		var candidate=point(structure).distance_to(listener)
		if listener.x>-100 and candidate>TRIPWIRE_RADIUS:continue
		if candidate<distance:closest=structure;distance=candidate
	return closest

func lantern_lit(z:int,at:Vector2i)->bool:
	for structure in floor_at(z).structures:
		if structure.kind=="lamp" and structure.hp>0 and point(structure).distance_to(at)<5.0 and line_of_sight(z,point(structure),at):return true
	for mark in floor_at(z).landmarks:
		if mark.get("kind","")=="stillworks_light" and mark.get("state","")=="lit" and point(mark).distance_to(at)<7.0 and line_of_sight(z,point(mark),at):return true
	return false

func enemy_intent(z:int,enemy:Dictionary)->Dictionary:
	var origin=point(enemy)
	if enemy.name=="Surface husk":
		var lure=active_decoy(z,origin)
		if not lure.is_empty():return {"kind":"decoy","cue":"HEARS LURE","target":lure,"goal":point(lure)}
		var alarm=active_tripwire(z,origin)
		if not alarm.is_empty():return {"kind":"alarm","cue":"HEARS ALARM","target":alarm,"goal":point(alarm)}
		var target:Dictionary={};var target_cue="";var best=INF
		for pawn in data.pawns:
			if pawn.hp<=0 or int(pawn.z)!=z:continue
			var distance=origin.distance_to(point(pawn))
			var adjacent=distance<=3.0
			var sees=distance<=HUSK_SIGHT_RADIUS and lantern_lit(z,point(pawn)) and line_of_sight(z,origin,point(pawn))
			var hears=distance<=HUSK_HEARING_RADIUS and not pawn.job.is_empty()
			if (adjacent or sees or hears) and distance<best:
				target=pawn;best=distance;target_cue="SEES LIGHT" if sees else "HEARS WORK" if hears else "CLOSE SCENT"
		if not target.is_empty():return {"kind":"pawn","cue":target_cue,"target":target,"goal":point(target)}
		return {"kind":"trail","cue":"FOLLOWS TRAIL","target":{},"goal":vec(floor_at(z).down)}
	if enemy.name=="Gloam stalker":
		var lure=active_decoy(z,origin)
		if not lure.is_empty():return {"kind":"decoy","cue":"HEARS LURE","target":lure,"goal":point(lure)}
		var ringing=active_tripwire(z,origin)
		if not ringing.is_empty():return {"kind":"alarm","cue":"HEARS ALARM","target":ringing,"goal":point(ringing)}
		var stalk_target:Dictionary={};var stalk_cue="";var stalk_best=INF
		for pawn in data.pawns:
			if pawn.hp<=0 or int(pawn.z)!=z:continue
			var distance=origin.distance_to(point(pawn))
			var close=distance<=2.25
			var sees=distance<=14.0 and lantern_lit(z,point(pawn)) and line_of_sight(z,origin,point(pawn))
			var hears=distance<=10.0 and not pawn.job.is_empty()
			if (close or sees or hears) and distance<stalk_best:
				stalk_target=pawn;stalk_best=distance;stalk_cue="SEES LIGHT" if sees else "HEARS WORK" if hears else "CLOSE"
		if not stalk_target.is_empty():return {"kind":"pawn","cue":stalk_cue,"target":stalk_target,"goal":point(stalk_target)}
		return {"kind":"listen","cue":"LOST IN DARK","target":{},"goal":origin}
	var vibration_alarm=active_tripwire(z,origin)
	if not vibration_alarm.is_empty():return {"kind":"alarm","cue":"FEELS ALARM","target":vibration_alarm,"goal":point(vibration_alarm)}
	var burrow_target:Dictionary={};var burrow_cue="";var burrow_best=INF
	for pawn in data.pawns:
		if pawn.hp<=0 or int(pawn.z)!=z:continue
		var distance=origin.distance_to(point(pawn))
		var feels_heat=distance<=2.25
		var feels_steps=distance<=BURROWER_VIBRATION_RADIUS and not pawn.job.is_empty()
		if (feels_heat or feels_steps) and distance<burrow_best:
			burrow_target=pawn;burrow_best=distance;burrow_cue="FEELS STEPS" if feels_steps else "FEELS HEAT"
	if not burrow_target.is_empty():return {"kind":"pawn","cue":burrow_cue,"target":burrow_target,"goal":point(burrow_target)}
	return {"kind":"listen","cue":"LISTENING","target":{},"goal":origin}

func enemy_readout(z:int,enemy:Dictionary)->String:
	var intent=enemy_intent(z,enemy)
	if enemy.name=="Burrower":return "Burrower · "+str(intent.cue).to_lower()+" · blind; feels nearby movement through walls"
	if enemy.name=="Gloam stalker":return "Gloam stalker · "+str(intent.cue).to_lower()+" · hunts lantern light and nearby work; still darkness hides you"
	return "Surface husk · "+str(intent.cue).to_lower()+" · sees lantern light and hears nearby work"

func _trigger_tripwire(z:int,enemy:Dictionary)->bool:
	for structure in floor_at(z).structures:
		if structure.kind!="tripwire" or structure.hp<=0 or structure.get("state","armed")!="armed" or point(structure)!=point(enemy):continue
		structure.state="ringing";structure.ring=TRIPWIRE_RING_TIME;structure.triggered_by=str(enemy.name)
		data.paused=true
		note("TRIPWIRE · "+str(enemy.name)+" crossed depth "+str(z+1)+". The expedition is paused — choose whether to fight, divert, or retreat.")
		events.append({"kind":"alarm"})
		return true
	return false

func _tripwire_alarms(z:int,dt:float):
	for structure in floor_at(z).structures:
		if structure.kind!="tripwire" or structure.get("state","armed")!="ringing":continue
		structure.ring=max(0.0,float(structure.get("ring",0))-dt)
		if structure.ring<=0:
			structure.state="spent"
			note("The tripwire alarm on depth "+str(z+1)+" fell silent. A colonist must reset it.")

func _hurt_pawn(p: Dictionary, damage: float):
	if p.hp<=0:return
	var was_incapacitated=incapacitated(p)
	var protected_damage=damage*0.65 if p.equipment.body=="armor" else damage
	p.hp = max(0.0,p.hp-protected_damage)
	var severity=3 if p.hp<20 else 2 if p.hp<45 else 1 if p.hp<75 else 0
	if severity>int(p.injury):
		p.injury=severity
		note(p.name+" is now "+INJURY_LEVELS[severity].to_lower()+".")
	if incapacitated(p) and not was_incapacitated:
		p.job={};p.orders.clear();p.drafted=false;p.bed_id=-1
		note(p.name+" collapsed. Another colonist must carry them to a bedroll.")
		events.append({"kind":"alarm"})
	if p.hp <= 0:
		var lost_index=data.pawns.find(p)
		for survivor_index in data.pawns.size():
			var survivor=data.pawns[survivor_index]
			if survivor_index!=lost_index and survivor.hp>0 and int(survivor.z)==int(p.z):
				_record_memory_one(survivor_index,lost_index,"loss","Lost {other} on depth "+str(int(p.z)+1)+".",-25.0,0)
		p.job = {}
		p.orders.clear()
		var lost_items=p.inventory.duplicate(true)
		if p.equipment.body=="armor":lost_items.armor=int(lost_items.get("armor",0))+1
		var c = {"id":next_id(),"x":p.x,"y":p.y,"name":p.name+"'s pack","searched":true,"items":lost_items,"kind":"ground"}
		floor_at(p.z).containers.append(c)
		p.inventory.clear()
		p.equipment.body=""
		p.bed_id=-1
		note(p.name+" was lost. Their pack remains where they fell.")

func _combat(p: Dictionary, dt: float):
	p.attack_clock = max(0.0,p.attack_clock-dt)
	var target: Dictionary = {}
	var requested = int(p.job.get("extra",{}).get("enemy",-1)) if p.job.get("kind","") == "attack" else -1
	for enemy in floor_at(p.z).enemies:
		if enemy.hp <= 0: continue
		if (requested < 0 and point(p).distance_to(point(enemy)) <= 1.01) or enemy.id == requested:
			target = enemy
			break
	if target.is_empty():
		if requested >= 0: p.job = {}
		return
	if point(p).distance_to(point(target)) <= 1.01:
		if p.attack_clock <= 0:
			p.attack_clock = 0.85 if p.drafted else 1.5
			target.hp -= (10.0 if p.drafted else 7.0) + int(p.skills.combat) * 0.2
			events.append({"kind":"hit"})
			if target.hp <= 0:
				p.skills.combat += 1
				data.kills += 1
				note(p.name+" killed a "+target.name.to_lower()+".")
				_remember_nearby(data.pawns.find(p),"survival","Survived the fighting on depth "+str(int(p.z)+1)+" with {other}.",4.0,4)
				if requested >= 0: p.job = {}
	elif requested >= 0:
		if not is_visible(p.z,point(target)):
			p.job = {}; note("Target lost in the dark."); return
		p.move_clock += dt
		if p.move_clock >= 0.18:
			p.move_clock = 0.0
			var path = path_to(p.z,point(p),point(target),true)
			if path.size() > 1: p.x = path[1][0]; p.y = path[1][1]

func _pressure(z: int, dt: float):
	var f = floor_at(z)
	var heat_rate = float(pressure_report(z).rate)
	f.heat = clampf(f.heat+heat_rate*dt,0,100)
	if f.alarm < 0 and f.heat >= 60:
		f.alarm = 30.0
		note("Warm air is rising from depth "+str(z+1)+". Scratching above. About 30 seconds to prepare.")
		events.append({"kind":"alarm"})
	if f.alarm >= 0:
		f.alarm -= dt
		if f.alarm <= 0:
			f.alarm = -1.0
			f.heat = 25.0
			f.waves += 1
			for i in range(min(2+int(f.waves),6)): spawn_enemy(0,vec(floor_at(0).up)+Vector2i(i%2,i/2),"Surface husk")
			note("Surface husks have entered the upper shelter. They follow the colony's trail down.")

func _mine_hazards(z:int,dt:float):
	var f=floor_at(z)
	for mark in f.landmarks:
		if mark.get("kind","")!="unstable_roof" or mark.get("state","")=="collapsed":continue
		if mark.state=="armed":
			for pawn in data.pawns:
				if pawn.hp>0 and int(pawn.z)==z and point(pawn).distance_to(point(mark))<=1.5:
					mark.state="warning";mark.timer=3.0
					note("Stone shifts in the old mine. Cave-in in about 3 seconds — get clear!")
					events.append({"kind":"alarm"})
					break
		elif mark.state=="warning":
			mark.timer=max(0.0,float(mark.timer)-dt)
			if mark.timer<=0:
				mark.state="collapsed"
				var struck:Array=[]
				for pawn in data.pawns:
					if pawn.hp>0 and int(pawn.z)==z and point(pawn).distance_to(point(mark))<=2.25:
						struck.append(str(pawn.name));_hurt_pawn(pawn,30.0)
				var rubble=container_at(z,point(mark))
				if rubble.is_empty():f.containers.append({"id":next_id(),"x":int(mark.x),"y":int(mark.y),"name":"Fresh cave-in salvage","searched":true,"items":{"scrap":2,"crystal":1},"kind":"ground"})
				else:
					rubble.items.scrap=int(rubble.items.get("scrap",0))+2
					rubble.items.crystal=int(rubble.items.get("crystal",0))+1
				note((", ".join(struck)+" caught the collapse. " if not struck.is_empty() else "The roof collapsed safely. ")+"Glowstone and scrap are exposed in the rubble.")

func _enemies(z: int, dt: float):
	var f = floor_at(z)
	var migrants: Array = []
	for e in f.enemies:
		if e.hp <= 0: continue
		if _trigger_tripwire(z,e):return
		e.clock += dt
		e.attack = max(0.0,e.attack-dt)
		var intent=enemy_intent(z,e)
		var target:Dictionary=intent.target
		var pursuing_structure=intent.kind in ["decoy","alarm"]
		var distance=point(target).distance_squared_to(point(e)) if not target.is_empty() else INF
		if not target.is_empty() and distance <= 1.01:
			if e.attack <= 0:
				e.attack = 2.1 if e.name=="Burrower" else 1.65 if e.name=="Gloam stalker" else 1.8
				if pursuing_structure:
					target.hp=max(0.0,float(target.hp)-10.0)
					if target.hp<=0:
						note("The clatter beacon is torn apart. The husks turn toward the colony." if intent.kind=="decoy" else "The ringing tripwire is ripped from its posts.")
				else:_hurt_pawn(target,7.0 if e.name=="Burrower" else 6.0 if e.name=="Gloam stalker" else 5.0)
			continue
		var step_time=.35 if e.name=="Burrower" else .42 if e.name=="Gloam stalker" else .5
		if e.clock < step_time: continue
		e.clock = 0.0
		var goal:Vector2i=intent.goal
		if intent.kind=="listen" or (intent.kind=="trail" and z>=int(data.deepest)):continue
		if point(e)==goal and intent.kind=="trail" and data.floors.has(str(z+1)):
			migrants.append(e)
			continue
		var path = path_to(z,point(e),goal,not target.is_empty())
		if path.size() > 1:
			e.x = path[1][0]; e.y = path[1][1]
			if _trigger_tripwire(z,e):return
		elif path.is_empty():
			for s in f.structures:
				if point(e).distance_to(point(s)) <= 1.01 and s.kind in ["barricade","shieldwall"]: s.hp -= 5.0
	for e in migrants:
		f.enemies.erase(e)
		var landing = vec(floor_at(z+1).up)
		e.x = landing.x; e.y = landing.y
		floor_at(z+1).enemies.append(e)
	f.enemies = f.enemies.filter(func(e): return e.hp > 0)
	f.structures = f.structures.filter(func(s): return s.hp > 0)

func tick(dt: float):
	if data.paused or dt <= 0 or not is_finite(dt): return
	dt = min(dt,0.25)
	data.seconds += dt
	for index in data.pawns.size():
		var p = data.pawns[index]
		if p.hp <= 0: continue
		p.hunger = min(100.0,p.hunger+dt*0.018)
		if incapacitated(p):
			p.job={};p.orders.clear();p.drafted=false
			if p.hunger >= 100: _hurt_pawn(p,dt*0.07)
			continue
		p.fatigue=clampf(float(p.fatigue)+dt*fatigue_rate(index),0.0,100.0)
		if p.hunger >= 65 and p.inventory.get("rations",0) > 0: use_item(index,"rations")
		if p.hunger >= 100: _hurt_pawn(p,dt*0.07)
		if p.job.is_empty() and p.orders.is_empty() and not claim_recovery(index):claim_colony_work(index)
		if p.job.is_empty() and not p.orders.is_empty(): start_next(index)
		_combat(p,dt)
		if p.job.is_empty() or p.job.kind == "attack": continue
		if not p.job.path.is_empty(): _move_pawn(p,dt)
		else:
			p.job.elapsed += dt
			if p.job.elapsed >= p.job.duration: _finish(index)
	for z_key in data.floors.keys():
		_pressure(int(z_key),dt)
		_mine_hazards(int(z_key),dt)
		_tripwire_alarms(int(z_key),dt)
		_enemies(int(z_key),dt)
	_drowned_surge(dt)
	_morrow_departure(dt)
	_thimble_warning(dt)
	_bellhome_warning(dt)
	_junction_warning(dt)
	_charterwell_warning(dt)
	_reservefall_warning(dt)
	_marchhold_warning(dt)
	_wallward_warning(dt)
	visibility_clock += dt
	if visibility_clock >= 0.2:
		visibility_clock = 0.0
		reveal_all()
	if data.pawns.all(func(p): return p.hp <= 0):
		data.paused = true
		note("The expedition is lost. Start a new seed when you are ready.")

func objective() -> String:
	if data.underway_state=="lit":return "Underway's waylights are installed. The route token remains carried; clear the two warned husks or follow the deeper road."
	if data.underway_state=="hidden":return "Underway's shrouded bypass shelters pressure. The route token remains carried; haul the concealed stores or continue below."
	if data.underway_state=="assigned":return "Clear Underway's approach, recover the 2 kg survey kit, then choose the warned lit bridge or concealed bypass with exact supplies."
	if data.wayfarer_state in ["resident","hidden","public"] and int(data.deepest)>=53:return "At Underway Fork, present Wayfarer's physical convoy tally to the survey post."
	if data.wayfarer_state in ["resident","hidden","public"]:return "Wayfarer's shared roadstead is repaired. The convoy tally remains carried; haul the resident stores or follow the Underway road."
	if data.wayfarer_state=="assigned":return "Clear Wayfarer's reception road. Gather two fit colonists with the convoy tally, 6 kg jack and exact supplies at the shared repair court."
	if data.wallward_state in ["escorted","screened","missed"] and int(data.deepest)>=52:return "At Wayfarer Commons, present the physical convoy tally to Roadkeeper Senn."
	if data.wallward_state=="escorted":return "Wallward's escorted convoy grants recovery. Haul its physical tally and issue or follow the Wayfarer road."
	if data.wallward_state=="screened":return "Wallward's screened convoy shelters pressure. Haul its physical tally and stores or follow the Wayfarer road."
	if data.wallward_state=="missed":return "Wallward's convoy was missed, but its cache and physical tally keep the Wayfarer road open."
	if data.wallward_state=="warning":return "Wallward warning: "+str(int(ceil(float(data.wallward_timer))))+" seconds. Clear the route and escort with three colonists, or screen with the beacon, 2 timber, 2 scrap and two colonists."
	if data.march_refuge_state in ["guarded","sheltered","public","walled"] and data.deepest>=51:return "At Wallward Descent, present the physical crossing seal and answer the warned convoy rendezvous."
	if data.march_refuge_state=="walled":return "Marchhold Refuge keeps the donated folded wall as three communal shield sections. Haul the wall-keeper issue or follow the deep resident road."
	if data.march_refuge_state=="guarded":return "Marchhold Refuge's guarded repair grants recovery. Haul its stores or follow the deep resident road."
	if data.march_refuge_state=="sheltered":return "Marchhold Refuge's dark repair shelters pressure while the folded wall remains expedition-owned. Haul its stores or continue below."
	if data.march_refuge_state=="public":return "Marchhold Refuge's public defense is repaired. Haul the mixed stores or follow the deep resident road."
	if data.march_refuge_state=="assigned":
		var refuge_threats=floor_at(50).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("march_refuge_guard")).size()
		if _march_refuge_route()=="sheltered":return "Marchhold Refuge: clear "+str(refuge_threats)+" reception threat, then repair with the 4 kg brace and exact goods or donate the carried folded wall with 1 timber and 1 scrap."
		return "Marchhold Refuge: clear "+str(refuge_threats)+" reception threats, recover the 4 kg brace, and carry it with the crossing seal plus exact route materials to the communal yard."
	if data.marchhold_state in ["deployed","retreated","overrun"] and data.deepest>=50:return "At Marchhold Refuge, present the physical crossing seal and settle the mobile community's defense."
	if data.marchhold_state=="deployed":return "Marchhold's three shield sections hold the crossing. Haul the defense issue and follow the sealed lower road."
	if data.marchhold_state=="retreated":return "Marchhold's folded wall remains mobile after retreat. Haul the stores and follow the sheltered lower road."
	if data.marchhold_state=="overrun":return "Marchhold was overrun, but the refuge alcoves held. Recover the crossing seal and continue below."
	if data.marchhold_state=="warning":return "Marchhold warning: "+str(int(ceil(float(data.marchhold_timer))))+" seconds. Deploy with Kest and three colonists after clearing the crossing, or retreat with the folded wall and two colonists."
	if data.shieldline_state in ["guarded","sheltered","public"] and data.deepest>=49:return "At Marchhold Crossing, answer the mobile camp's warned defense with Kest."
	if data.shieldline_state=="guarded":return "Shieldline's guarded walking wall is assembled. Haul the resident issue, build folding shieldwalls, or follow the lower works road."
	if data.shieldline_state=="sheltered":return "Shieldline's concealed walking wall shelters pressure. Haul its freight, build folding shieldwalls, or continue below."
	if data.shieldline_state=="public":return "Shieldline's public walking wall is assembled. Haul mixed stores, build folding shieldwalls, or follow the lower works road."
	if data.shieldline_state=="assigned":
		var threats=floor_at(48).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("shieldline_guard")).size()
		if threats>0:return "Clear Shieldline's "+str(threats)+" route threats before assembling the walking wall."
		var carriage=shieldline_carriage();var target=point(carriage) if not carriage.is_empty() else Vector2i(-99,-99)
		if _shieldline_carriers(target).size()!=2:return "Recover Shieldline's 6 kg frame and 6 kg axle in two separate packs and bring both carriers to the carriage."
		if shieldline_gathered()<3:return "Rally three living colonists including Kest beside Shieldline's assembly carriage."
		return "Assemble Shieldline's walking wall while both heavy parts remain in separate physical packs."
	if data.reserve_commons_state in ["guarded","sheltered","public"] and data.deepest>=48:return "At Shieldline Works, present Reservefall's physical quarter pass and accept Kest's mobile-defense expedition."
	if data.reserve_commons_state=="guarded":return "Reservefall Commons' repaired shield court grants recovery. Haul its resident stores or follow Shieldline descent."
	if data.reserve_commons_state=="sheltered":return "Reservefall Commons' repaired refuge shelters pressure. Haul its stores or follow Shieldline descent."
	if data.reserve_commons_state=="public":return "Reservefall Commons' public defense is repaired. Haul the mixed stores or follow Shieldline descent."
	if data.reserve_commons_state=="assigned":
		var threats=floor_at(47).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("reserve_commons_guard")).size()
		return "Reservefall Commons: clear "+str(threats)+" reception threats, recover the 4 kg communal shield, and carry the quarter pass plus exact route materials to the repair court."
	if data.reservefall_state in ["held","withdrawn","breached"] and data.deepest>=47:return "At Reservefall Commons, present the physical quarter pass and accept the communal-defense repair."
	if data.reservefall_state=="held":return "Reservefall's defense line holds. Haul its physical quarter pass and stores or follow the open inhabited lower road."
	if data.reservefall_state=="withdrawn":return "Reservefall's residents withdrew behind a sheltered fallback. Haul the physical quarter pass or continue below."
	if data.reservefall_state=="breached":return "Reservefall was breached, but its safe rooms held and an emergency quarter pass keeps the lower road open."
	if data.reservefall_state=="warning":
		var threats=floor_at(46).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("reservefall_guard")).size()
		return "RESERVEFALL INCURSION · %d seconds · %d surface husks · hold with 3 crew or withdraw 2 with 2 timber + 2 scrap."%[int(ceil(float(data.reservefall_timer))),threats]
	if data.concordance_state in ["bastion","reserve"] and data.deepest>=46:return "At Reservefall Junction, present Concordance's physical response token before the warned surface incursion."
	if data.concordance_state=="bastion":return "Concordance's fixed bastion is staffed. Haul the physical response token and stores or follow the open coordinated lower road."
	if data.concordance_state=="reserve":return "Concordance's mobile reserve shelters the deepest reached road. Haul its response token and freight or continue below."
	if data.concordance_state=="assigned":
		var threats=floor_at(45).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("concordance_guard")).size()
		return "Choose Concordance's defense: clear "+str(threats)+" route threats, rally 3, and carry 4 timber + 3 scrap for the bastion; or rally 2 with 4 rations + 2 medkits for a mobile reserve."
	if data.writwell_state in ["delegates","exchange","commons"] and data.deepest>=45:return "At Concordance Gate, present the physical assembly mandate and choose a fixed bastion or mobile reserve."
	if data.writwell_state=="delegates":return "Writwell's delegate pledge is ratified. Haul the physical assembly mandate or follow the open lower road; Charterwell's writ remains carried."
	if data.writwell_state=="exchange":return "Writwell's exchange pledge is ratified. Haul the mandate and freight or use the pressure-sheltered lower road."
	if data.writwell_state=="commons":return "Writwell's public pledge is ratified. Haul the mandate and common allotment or continue down the connected road."
	if data.writwell_state=="assigned":
		var threats=floor_at(44).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("writwell_guard")).size()
		if threats>0:return "Clear Writwell's route-shaped gallery before the multi-settlement vote."
		if not data.pawns.any(func(pawn):return int(pawn.z)==44 and int(pawn.inventory.get("delegate_writ",0))>0):return "Carry Charterwell's physical delegation writ to Writwell's common table."
		var cost_copy="4 rations + 2 medkits" if _writwell_route()=="delegates" else "5 scrap + 2 glowstone" if _writwell_route()=="exchange" else "3 timber + 3 rations"
		return "Rally 3 colonists and split "+cost_copy+" across at least 2 packs for Writwell's vote."
	if data.charterwell_state in ["escorted","supplied","missed"] and data.deepest>=44:return "At Writwell Assembly, present the physical delegation writ to convene the shared-supply vote."
	if data.charterwell_state=="escorted":return "Charterwell's delegation is safely escorted. Haul the physical writ and route-shaped issue or follow the open lower road; Coilward's charter remains carried."
	if data.charterwell_state=="supplied":return "Charterwell's passage is funded. Haul the physical writ or use the pressure-sheltered lower road; Coilward's charter remains carried."
	if data.charterwell_state=="missed":return "Charterwell's delegation departed, but its emergency writ and connected lower road keep the expedition moving."
	if data.charterwell_state=="warning":
		var threats=floor_at(43).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("charterwell_guard")).size()
		return "CHARTERWELL DELEGATION · %d seconds · %d route threats · escort with 3 crew or supply passage with 2 crew."%[int(ceil(float(data.charterwell_timer))),threats]
	if data.coilward_state in ["keepers","freeband","echo"] and data.deepest>=43:return "At Charterwell Station, present Coilward's physical charter before the delegation departs."
	if data.coilward_state=="keepers":return "Coilward's keeper charter is ratified. Haul the recovery issue or follow the open lower road; the signed charter remains in its carrier's pack."
	if data.coilward_state=="freeband":return "Coilward's freeband charter is ratified. Haul the hidden stores or use the pressure-sheltered lower road; the charter remains physical."
	if data.coilward_state=="echo":return "Coilward's public charter is ratified. Haul the mixed allotment or continue down the connected road with the physical charter."
	if data.coilward_state=="assigned":
		if floor_at(42).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("coilward_guard")):return "Clear Coilward's "+("burrower from the lamp-lit keeper hall." if _coilward_route()=="keepers" else "Gloam stalker from the dark freeband cableway." if _coilward_route()=="freeband" else "surface husks from the wary public arcade.")
		if not data.pawns.any(func(pawn):return int(pawn.z)==42 and int(pawn.inventory.get("ward_charter",0))>0):return "Recover and carry Coilward's physical community charter."
		return "Carry the charter with exactly 2 rations and 1 medkit to Coilward's council seal." if _coilward_route()=="keepers" else "Carry the charter with exactly 3 scrap and 1 glowstone to Coilward's council seal." if _coilward_route()=="freeband" else "Carry the charter with exactly 2 timber and 2 scrap to Coilward's council seal."
	if data.deepcoil_state in ["keepers","freeband","echo"] and data.deepest>=42:return "At Coilward Commons, accept the community charter shaped by Deepcoil's answer."
	if data.deepcoil_state=="keepers":return "Keeper Vey answered through Deepcoil's synchronized relays. Haul the staffed issue or follow the open descent."
	if data.deepcoil_state=="freeband":return "Freeband Tern answered through Deepcoil's dark relays. Haul the hidden freight or use the pressure-sheltered descent."
	if data.deepcoil_state=="echo":return "Deepcoil's unknown voice is fixed in the route history. Haul the mixed cache or continue down the answered descent."
	if data.deepcoil_state=="assigned":
		if floor_at(41).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("deepcoil_guard")):return "Clear both Deepcoil relay galleries before tuning the paired signal."
		var sync=deepcoil_sync();var target=point(sync) if not sync.is_empty() else Vector2i(-99,-99);var carriers=_deepcoil_carriers(target)
		if carriers.size()!=2:return "Recover the two 6.5 kg Deepcoil coils in separate packs and rally both carriers at the synchronizer."
		return "Tune Deepcoil's paired relays while both physical coil carriers remain together."
	if data.ember_commons_state in ["freight","refuge","public"] and data.deepest>=41:return "At Deepcoil Relay, answer the reception-shaped signal from below."
	if data.ember_commons_state=="freight":return "Embervault's freight signal house is restored. Haul the recovery allotment or follow the open lower stair."
	if data.ember_commons_state=="refuge":return "Embervault's refuge signal house is restored. Haul the industrial stores or use the pressure-sheltered lower stair."
	if data.ember_commons_state=="public":return "Embervault's public signal house is restored. Haul the mixed stores or continue down the connected stair."
	if data.ember_commons_state=="assigned":
		if floor_at(40).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("ember_commons_guard")):return "Clear Embervault Commons' "+("burrower from the lit freight court." if _ember_commons_route()=="freight" else "Gloam stalker from the dark refuge cablewalk." if _ember_commons_route()=="refuge" else "surface husks from the wary public arcade.")
		if not data.pawns.any(func(pawn):return int(pawn.z)==40 and int(pawn.inventory.get("signal_breaker",0))>0):return "Recover and carry Embervault Commons' physical three-kilogram signal breaker."
		var ember_cost=_ember_commons_cost();return "Carry the signal breaker with exactly %d timber and %d scrap to Embervault's signal house."%[int(ember_cost.timber),int(ember_cost.scrap)]
	if data.junction_state in ["received","shunted","missed"] and data.deepest>=40:return "At Embervault Commons, accept Keeper Sable's reception-shaped signal-house repair."
	if data.junction_state=="received":return "Embervault received its independent freight. Haul the route-shaped cargo or follow Ren's open settlement road; the physical signal seal remains with its carrier."
	if data.junction_state=="shunted":return "Embervault's freight is sheltered on the refuge shunt. Haul the mixed stores or follow the pressure-sheltered settlement road."
	if data.junction_state=="missed":return "The Embervault freight was missed, but Ren kept the settlement road open. Regroup or descend."
	if data.junction_state=="warning":
		var threats=floor_at(39).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("junction_guard")).size()
		if data.pawns.any(func(pawn):return int(pawn.z)==39 and int(pawn.inventory.get("junction_seal",0))>0):return "EMBERVAULT FREIGHT · %d seconds · %d route threats · receive with 2 crew or shunt with 2 timber + 2 scrap."%[int(ceil(float(data.junction_timer))),threats]
		return "EMBERVAULT FREIGHT · %d seconds · recover and carry the physical signal seal."%int(ceil(float(data.junction_timer)))
	if data.kiln_state in ["built","concealed"] and data.deepest>=39:return "At Embervault Junction, answer Signalkeeper Ren's warned independent freight arrival."
	if data.kiln_state=="built":
		if floor_at(38).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("kiln_awakened")):return "Kilnreach's rebuilt furnace drew two surface husks. Clear the lit lower tram before descending."
		return "Kilnreach is rebuilt and warm. Haul its fired ingots or follow the open lower tram; the furnace raises local pressure."
	if data.kiln_state=="concealed":return "Kilnreach's flues are concealed. Haul its hidden stores or follow the pressure-sheltered lower tram."
	if data.kiln_state=="assigned":
		if floor_at(38).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("kiln_guard")):return "Clear Kilnreach's "+("burrowers from the lit slag gallery." if _kiln_route()=="forage" else "Gloam stalker from the dark builder flue." if _kiln_route()=="works" else "burrower and Gloam stalker from the split communal works.")
		if not data.pawns.any(func(pawn):return int(pawn.z)==38 and int(pawn.inventory.get("kiln_igniter",0))>0):return "Recover and carry Kilnreach's physical two-kilogram ignition spindle."
		return "Rebuild Kilnreach for productive heat, or conceal its flues for a dark pressure-sheltered tram."
	if data.yard_state in ["resident","culvert","public"] and data.deepest>=38:return "At Kilnreach Works, have Pell survey the abandoned heatworks controls."
	if data.yard_state=="resident":return "Hearthline's resident lift is running. Haul its recovery issue or follow the open independent lower line."
	if data.yard_state=="culvert":return "Hearthline's culvert lift is running. Haul its industrial freight or use the pressure-sheltered lower line."
	if data.yard_state=="public":return "Hearthline's public lift is running. Haul its mixed stores or continue through the shared lower line."
	if data.yard_state=="assigned":
		if floor_at(37).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("yard_guard")):return "Clear Hearthline's "+("burrower from the lit thermal lane." if _yard_route()=="resident" else "Gloam stalker from the dark winch lane." if _yard_route()=="culvert" else "burrower and Gloam stalker from the split cargo lanes.")
		var gantry=yard_gantry();var target=point(gantry) if not gantry.is_empty() else Vector2i(-99,-99)
		if _yard_carriers(target).size()!=2:return "Recover Hearthline's seven-kilogram thermal core and lift winch, then bring them to the gantry in two different packs."
		var pell_index=_pell_index()
		if pell_index<0 or int(data.pawns[pell_index].z)!=37 or point(data.pawns[pell_index]).distance_to(target)>4.0:return "Bring Pell beside Hearthline's expansion gantry."
		if yard_gathered()<3:return "Rally three living colonists beside Hearthline's gantry with both separately carried mechanisms."
		return "Install Hearthline's separately carried core and winch with Pell and the gathered crew."
	if data.commons_state in ["resident","culvert","public"] and data.deepest>=37:return "At Hearthline Yard, accept the settlement expansion and recruit Pell."
	if data.commons_state=="resident":return "Bellhome's resident homes are braced. Haul the recovery allotment or follow the open lower dwellings road."
	if data.commons_state=="culvert":return "Bellhome's culvert row is braced. Haul its industrial surplus or use the pressure-sheltered lower road."
	if data.commons_state=="public":return "Bellhome's public ward is braced. Haul its mixed stores or continue through the occupied lower dwellings."
	if data.commons_state=="assigned":
		if floor_at(36).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("commons_guard")):return "Clear Bellhome's "+("burrower from the lit roof court." if _commons_route()=="resident" else "Gloam stalker from the dark culvert row." if _commons_route()=="culvert" else "surface husks from the shuttered public ward.")
		if not data.pawns.any(func(pawn):return int(pawn.z)==36 and int(pawn.inventory.get("brace",0))>0):return "Recover and carry Bellhome Commons' physical four-kilogram wall brace."
		var cost=_commons_cost();return "Carry the wall brace with exactly %d timber and %d scrap to Bellhome's housing frame."%[int(cost.timber),int(cost.scrap)]
	if data.bellhome_state in ["escorted","diverted","retreated"] and data.deepest>=36:return "At Bellhome Commons, accept the reception-shaped housing repair contract."
	if data.bellhome_state=="escorted":return "Bellhome's convoy arrived. Haul its freight or follow the open settlement road; the physical charter remains with its carrier."
	if data.bellhome_state=="diverted":return "Bellhome's convoy passed through the quiet culvert. Haul its stores or take the pressure-sheltered settlement road."
	if data.bellhome_state=="retreated":return "Bellhome's convoy withdrew, but the settlement road remains open. Regroup or descend."
	if data.bellhome_state=="warning":
		var bellhome_threats=floor_at(35).enemies.filter(func(enemy):return enemy.hp>0 and enemy.has("bellhome_guard")).size()
		if data.pawns.any(func(pawn):return int(pawn.z)==35 and int(pawn.inventory.get("charter",0))>0):
			return "BELLHOME CONVOY · %d seconds · %d route threats · escort at muster or divert with 2 timber + 2 scrap."%[int(ceil(float(data.bellhome_timer))),bellhome_threats]
		return "BELLHOME CONVOY · %d seconds · recover and carry the physical convoy charter."%int(ceil(float(data.bellhome_timer)))
	if data.driftglass_state in ["powered","shaded"] and data.deepest>=35:return "At Bellhome Gate, answer Orra's warned convoy request."
	if data.driftglass_state=="powered":
		if floor_at(34).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("driftglass_awakened")):return "Powered Driftglass cutters woke two Gloam stalkers. Clear the lit lower seam before descending."
		return "Driftglass runs brightly powered. Haul its cuttings or take the lower seam; fixed work lights raise local pressure."
	if data.driftglass_state=="shaded":return "Driftglass stays dark and difficult to trace. Haul its provisions or take the quiet lower seam."
	if data.driftglass_state=="assigned":
		if floor_at(34).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("driftglass_guard")):return "Clear Driftglass's "+("Gloam stalkers from the heated cutting gallery." if _driftglass_route()=="powered" else "Gloam stalker from the cold mirror seam.")
		if not data.pawns.any(func(pawn):return int(pawn.z)==34 and int(pawn.inventory.get("prism",0))>0):return "Recover and carry Driftglass's physical focusing prism."
		return "Set Driftglass's prism for powered excavation, or shade it for a dark stealth road."
	if data.latchwater_state in ["warm","cold"] and data.deepest>=34:return "At Driftglass Hall, ask Sela to open the light-sensitive excavation."
	if data.latchwater_state=="warm":return "Latchwater is warm and recovering. Haul its medical allotment or take the lower settlement road; the heater raises local pressure."
	if data.latchwater_state=="cold":return "Latchwater stays cold and difficult to trace. Haul its material stores or take the lower settlement road."
	if data.latchwater_state=="assigned":
		if floor_at(33).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("latchwater_guard")):return "Clear Latchwater's "+("burrowers from the lit service gallery." if _latchwater_route()=="resident" else "Gloam stalker from the dark spillway." if _latchwater_route()=="refugee" else "surface husks from the public duct.")
		if not data.pawns.any(func(pawn):return int(pawn.z)==33 and int(pawn.inventory.get("exchanger",0))>0):return "Recover and carry Latchwater's physical heat exchanger."
		return "Install Latchwater's exchanger for full warmth, or baffle it for cold low-pressure shelter."
	if data.thimble_state in ["defended","evacuated","overrun"] and data.deepest>=33:return "At Latchwater Ward, ask Miri to open the failing shared heater route."
	if data.thimble_state=="defended":return "Thimble Crossing held. Haul its defender allotment or take the lower settlement road."
	if data.thimble_state=="evacuated":return "Thimble's residents escaped. Haul the stores they left or take the lower settlement road."
	if data.thimble_state=="overrun":return "Thimble was overrun, but its lower road remains open. Regroup or descend."
	if data.thimble_state=="defending":
		if floor_at(32).enemies.any(func(enemy):return enemy.hp>0 and enemy.has("thimble_guard")):return "THIMBLE WARNING · %d seconds · clear the surface husks."%int(ceil(float(data.thimble_timer)))
		if thimble_gathered()<2:return "THIMBLE WARNING · %d seconds · rally two colonists beside the warning bell."%int(ceil(float(data.thimble_timer)))
		return "THIMBLE WARNING · %d seconds · seal the breach with the gathered defenders."%int(ceil(float(data.thimble_timer)))
	if data.thimble_state=="evacuating":
		if not data.pawns.any(func(pawn):return int(pawn.z)==32 and int(pawn.inventory.get("roster",0))>0):return "THIMBLE WARNING · %d seconds · recover the physical resident cord."%int(ceil(float(data.thimble_timer)))
		if thimble_gathered(true)<2:return "THIMBLE WARNING · %d seconds · carry the cord and rally two colonists at the evacuation lift."%int(ceil(float(data.thimble_timer)))
		return "THIMBLE WARNING · %d seconds · send the gathered residents down the lift."%int(ceil(float(data.thimble_timer)))
	if data.farline_state in ["accord","cacheway"] and data.deepest>=32:return "At Thimble Crossing, choose whether to defend the settlement or evacuate its residents before the surface warning expires."
	if data.farline_state in ["accord","cacheway"]:return "Farline's settlement road is bound. Haul its physical network stores or descend."
	if data.farline_state=="assigned":
		if floor_at(31).enemies.any(func(enemy):return enemy.hp>0):return "Clear the "+("burrowers from Farline's witness road." if _farline_route()=="accord" else "Gloam stalkers from Farline's cacheway.")
		if not data.pawns.any(func(pawn):return int(pawn.z)==31 and int(pawn.inventory.get("braid",0))>0):return "Recover Farline's physical route braid from the chosen road."
		if farline_gathered()<2:return "Carry Farline's route braid and rally two living colonists beside the steward."
		return "Bind Farline's physical route braid with the gathered expedition."
	if data.terminus_state in ["chartered","free"] and data.deepest>=31:return "At Farline Commons, ask its steward to open the "+("witness road." if data.terminus_state=="chartered" else "free cacheway.")
	if data.terminus_state in ["chartered","free"]:return "Cairn Reach trusts the expedition. Haul its physical settlement stores or descend by the far lift."
	if data.terminus_state=="assigned":
		if floor_at(30).enemies.any(func(enemy):return enemy.hp>0):return "Clear the burrowers from Cairn Reach's breached witness hall."
		return "Recover and physically return Cairn Reach's witness ledger while keeping the Morrow waybill."
	if data.morrow_state in ["official","resident"] and data.deepest>=30:
		if data.morrow_state=="resident" and floor_at(30).enemies.any(func(enemy):return enemy.hp>0):return "Clear the Gloam stalker from Cairn Reach's free siding."
		return "Present the stamped waybill for Cairn Reach's witness request." if data.morrow_state=="official" else "Carry 4 scrap and 2 glowstone to repair Cairn Reach's communal far lift."
	if data.morrow_state in ["official","resident"]:return "Morrow's deep freight line is open. Haul its physical train issue or descend."
	if data.morrow_state=="boarding":
		if floor_at(29).enemies.any(func(enemy):return enemy.hp>0):return "MORROW DEPARTURE · %d seconds · clear the loading lane, then rally two colonists beside the dispatcher."%int(ceil(float(data.morrow_timer)))
		if morrow_gathered()<2:return "MORROW DEPARTURE · %d seconds · rally at least two living colonists beside the dispatcher."%int(ceil(float(data.morrow_timer)))
		return "MORROW DEPARTURE · %d seconds · present the physical waybill and board together."%int(ceil(float(data.morrow_timer)))
	if data.registry_state in ["official","resident"] and data.deepest>=29:return "At Morrow Exchange, bring the physical waybill to call the "+("authority" if data.registry_state=="official" else "ghost-line")+" freight train."
	if not data.rumor:return "FIRST STEPS 1/4 · Tap the traveler. Ash will walk over and speak on arrival."
	if data.built_total==0:
		if data.deepest==0:
			var shelter=floor_at(0).containers.filter(func(container):return container.get("name","")=="Shelter supplies")
			if not shelter.is_empty() and not bool(shelter[0].get("searched",false)):return "FIRST STEPS 2/4 · Tap Shelter supplies, then Search this container."
			var ready=data.pawns.any(func(pawn):return int(pawn.z)==0 and int(pawn.inventory.get("timber",0))>=4 and int(pawn.inventory.get("scrap",0))>=2)
			if not ready:return "FIRST STEPS 3/4 · Inventory: move 4 timber + 2 scrap from Shelter supplies into one colonist's pack."
			return "FIRST STEPS 4/4 · Build → Selected Colonist → Workbench, then tap a clear floor tile."
		return "Search the shelter supplies. Build your first camp."
	if data.registry_state in ["official","resident"]:return "The physical Morrow freight waybill names the lower authority's deepest active destination. Haul its supplies or descend."
	if data.registry_state=="assigned":
		if floor_at(28).enemies.any(func(enemy):return enemy.hp>0):return "Clear the burrowers from Cinder Registry's charred audit vault."
		return "Recover and return Cinder Registry's physical plate."
	if data.railcourt_state in ["licensed","resident"] and data.deepest>=28:
		if data.railcourt_state=="resident" and floor_at(28).enemies.any(func(enemy):return enemy.hp>0):return "Clear the Gloam stalker from Cinder Registry's resident copy room."
		return "Accept Cinder Registry's public audit." if data.railcourt_state=="licensed" else "Carry 4 scrap and 1 glowstone for Cinder Registry's off-ledger freight copy."
	if data.railcourt_state in ["licensed","resident"]:return "Railcourt's lower freight stair is open. Haul the physical "+("contract issue" if data.railcourt_state=="licensed" else "resident provisions")+" or descend."
	if data.railcourt_state=="assigned":
		if floor_at(27).enemies.any(func(enemy):return enemy.hp>0):return "Clear the burrowers from Railcourt's seized switchhouse."
		return "Recover and return Railcourt's physical switch warrant."
	if data.customs_state in ["security","smuggle"] and data.deepest>=27:
		if data.customs_state=="smuggle" and floor_at(27).enemies.any(func(enemy):return enemy.hp>0):return "Clear the Gloam stalker from Railcourt's resident undercroft."
		return "Accept Railcourt's public switchhouse contract." if data.customs_state=="security" else "Carry 3 scrap and 2 glowstone to join Railcourt's resident compact."
	if data.customs_state in ["security","smuggle"]:
		if floor_at(26).enemies.any(func(enemy):return enemy.hp>0):return "Clear Emberline's "+("burrower breach on the authority platform." if data.customs_state=="security" else "Gloam stalkers along the ghost siding.")
		return "Emberline's lower authority gate is open. Haul the physical route reward or descend."
	if data.ashrail_state=="stocked" and data.deepest>=26:return "At Emberline Customs, declare Ashrail's cargo for security or move it through the ghost siding."
	if data.ashrail_state=="stocked":return "Ashrail's far platform is provisioned. Haul its physical exchange freight or use the connected lower stair."
	if data.refuge_state in ["foothold","corridor"] and data.deepest>=25:
		if floor_at(25).enemies.any(func(enemy):return enemy.hp>0):return "Clear Ashrail's "+("vibration-sensing burrowers." if data.refuge_state=="foothold" else "light-hunting Gloam stalkers.")
		return "Carry "+("3 rations and 1 medkit" if data.refuge_state=="foothold" else "3 scrap and 1 glowstone")+" to provision Ashrail's far platform."
	if data.refuge_state=="foothold":return "Switchyard's second foothold is staffed. Haul its physical tool stores or use the connected outbound stair."
	if data.refuge_state=="corridor":return "The mobile supply corridor is running. Haul its physical survival surplus or follow its moving caches deeper."
	if data.depot_state in ["resident","service","public"] and data.deepest>=24:
		if floor_at(24).enemies.any(func(enemy):return enemy.hp>0):return "Clear the Switchyard creatures threatening Esi's resident evacuation."
		return "At Switchyard Refuge, provision a fixed sanctuary or outfit a mobile supply corridor."
	if data.depot_state in ["resident","service","public"]:return "Clockline Depot is open. Haul its physical freight allotment or use the connected lower platform."
	if data.depot_state=="assigned":
		var dispatcher=depot_landmark();var target=point(dispatcher) if not dispatcher.is_empty() else Vector2i(-99,-99)
		if _depot_carriers(target).size()==2:return "Clear both freight lanes, then install the separately carried traction drive and brake drum beside Jun."
		if data.pawns.any(func(pawn):return pawn.hp>0 and (int(pawn.inventory.get("drive",0))>0 or int(pawn.inventory.get("brake",0))>0)):return "Bring the traction drive and brake drum to Jun in two different colonist packs."
		return "Search Clockline's two freight lanes for the physical traction drive and brake drum."
	if data.market_state in ["resident","service","public"] and data.deepest>=23:return "Bring Tavi beside Dispatcher Jun and begin Clockline Depot's specialty freight recovery."
	if data.market_state in ["resident","service","public"]:return "Mainspring's exchange is complete and Tavi has joined. Haul the physical market goods or follow the Clockline stair."
	if data.sump_state in ["resident","service","public"] and data.deepest>=22:
		var market_route=_market_route();var cost=_market_cost(market_route)
		if market_route=="resident":return "At Mainspring, carry 2 rations and 1 medkit to provision the resident exchange."
		if market_route=="service":return "At Mainspring, carry 4 scrap and 2 glowstone to restore the independent freight hoist."
		return "At Mainspring, carry 2 scrap and 1 ration to post the public exchange."
	if data.sump_state in ["resident","service","public"]:return "Sump Commons is a durable foothold. Haul its physical stores or follow the lower mains stair."
	if data.sump_state=="assigned":
		if data.pawns.any(func(pawn):return pawn.hp>0 and int(pawn.inventory.get("impeller",0))>0):return "Clear the service route and carry the physical pump impeller back to Edda."
		return "Search the seized pump rotor for Sump Commons' unique physical impeller."
	if data.tidecourt_state in ["sponsored","contracted","recovered"] and data.deepest>=21:return "At Sump Commons, accept Edda's standing-shaped communal pump repair."
	if data.tidecourt_state in ["sponsored","contracted","recovered"]:return "Tidecourt access is secured. Haul its physical payment or follow the lower water district stair."
	if data.tidecourt_state=="assigned":
		if data.pawns.any(func(pawn):return pawn.hp>0 and int(pawn.inventory.get("docket",0))>0):return "Clear the silted route and carry Tidecourt's physical water docket back to Clerk Sable."
		return "Search the silted water court case for its unique physical docket."
	if data.drowned_state in ["rescued","salvaged","flooded"] and data.deepest>=20:
		if data.drowned_state=="rescued":return "At Tidecourt, ask Keeper Olan to sponsor lower-district access."
		if data.drowned_state=="salvaged":return "At Tidecourt, carry 3 scrap and 2 glowstone to post the regulator material bond."
		return "At Tidecourt, accept public recovery to replace the records lost in the surge."
	if data.drowned_state in ["rescued","salvaged","flooded"]:return "The Drowned Gallery has drained. Haul what remains or follow its connected lower stair."
	if data.drowned_state=="warning":return "RESERVOIR SURGE · %d seconds · rescue Keeper Olan, recover the regulator, or retreat behind the dry line."%int(ceil(float(data.drowned_timer)))
	if data.cistern_state in ["pressure","spillway"] and data.deepest>=19:return "At the Drowned Gallery, cycle the sluice only when the expedition is ready for its warned surge."
	if data.cistern_state in ["pressure","spillway"]:return "Cistern Spine is secured. Haul the water keepers' payment or follow the lower reservoir stair."
	if data.cistern_state=="assigned":
		if data.pawns.any(func(pawn):return pawn.hp>0 and int(pawn.inventory.get("seal",0))>0):return "Secure the reservoir route and carry the cistern gate seal back to Water Keeper Nera."
		return "Search the opened reservoir route for Cistern Spine's physical gate seal."
	if data.stillworks_choice!="" and data.deepest>=18:return "Meet Water Keeper Nera and accept Cistern Spine's reservoir request."
	if data.stillworks_choice=="restore":return "The Stillworks scrubbers are running. Clear the lit intake or descend through its restored pressure lock."
	if data.stillworks_choice=="dark":return "The Stillworks overflow remains dark. Search the traveler's cache or follow the muffled stair below."
	if data.quiet_state=="heard" and data.deepest>=17:return "At the Stillworks, choose restored air and fixed light or a safer dark overflow route."
	if data.quiet_state=="heard":return "The traveler's final signal points below Meridian. Follow the maintenance bells without city light."
	if data.quiet_state=="open":
		if data.pawns.any(func(pawn):return pawn.hp>0 and int(pawn.inventory.get("tape",0))>0):return "Carry the traveler's signal tape back to Quiet Mile's receiver and replay it in still darkness."
		return "Search the opened recorder alcove for the traveler's physical signal tape."
	if data.quiet_state in ["one","two"]:return "Tune listening post "+str(_quiet_rank(str(data.quiet_state))+1)+" in darkness while nearby companions remain still."
	if data.wake_state in ["marshal","waymark"] and data.deepest>=16:return "Tune Quiet Mile's first listening post in darkness while nearby companions remain still."
	if data.wake_state in ["marshal","waymark"]:return "The Quiet Mile route is aligned. Follow the traveler's final instruction: listen before light."
	if data.wake_state=="assigned":
		if data.pawns.any(func(pawn):return pawn.hp>0 and int(pawn.inventory.get("compass",0))>0):return "Clear the recovery route and carry the survey compass back to "+("Marshal Rell." if data.archive_choice=="shared" else "the annotated waymark.")
		return "Search the missing survey team's field case for its physical compass."
	if data.archive_choice in ["shared","preserved"] and data.deepest>=15:return "Begin the final survey recovery at Surveyor's Wake."
	if data.archive_choice in ["shared","preserved"]:return "The traveler's record is "+("public" if data.archive_choice=="shared" else "safe in the expedition pack")+". Follow the lower catalog gate."
	if data.archive_choice=="assigned":
		if data.pawns.any(func(pawn):return pawn.hp>0 and int(pawn.inventory.get("dossier",0))>0):return "Carry the traveler dossier to Archivist Sen and choose whether to share or preserve it."
		return "Search the opened survey stacks for the traveler's physical dossier."
	if data.foundry_state in ["municipal","independent"] and data.deepest>=14:return "Meet Archivist Sen and request the vanished traveler's route survey file."
	if data.foundry_state in ["municipal","independent"]:return "Foundry Ward's freight gate is open. Continue to Archive Junction."
	if data.foundry_state=="assigned":
		if data.pawns.any(func(pawn):return pawn.hp>0 and int(pawn.inventory.get("coil",0))>0):return "Carry the foundry regulator back to Forewoman Kes after clearing the furnace line."
		return "Search the opened municipal furnace line for its foundry regulator."
	if data.service_choice!="" and data.deepest>=13:return "Meet Forewoman Kes and complete Foundry Ward's "+("municipal repair." if data.service_choice=="city" else "independent material bond.")
	if data.service_choice!="":return "Meridian's lower service lock is open. Continue to Foundry Ward."
	if data.ashline_state=="cleared" and data.deepest>=12:return "Meet Registrar Rook. Choose city quarters or an independent field charter."
	if data.ashline_state=="cleared":return "Ashline grants provisional passage into Meridian's service ring. Continue below."
	if data.ashline_state=="assigned":
		if data.pawns.any(func(pawn):return pawn.hp>0 and int(pawn.inventory.get("filter",0))>0):return "Carry the purifier cartridge back to Officer Tamsin at Ashline."
		return "Recover Ashline's purifier cartridge from the opened scrubber wing."
	if data.spindle_contact!="" and data.deepest>=11:return "Submit to Ashline screening and accept Meridian's scrubber request."
	if data.spindle_contact!="":return "Meridian is real. The Gate Watch directs the expedition toward Ashline checkpoint below."
	if data.bellwether_choice!="" and data.deepest>=9:
		if data.bellwether_choice=="maintenance" and data.floors.has("9") and data.floors["9"].enemies.any(func(enemy):return enemy.hp>0):return "Clear the burrower breach, then answer the Gate Watch at Spindle."
		return "Reach Gate Watch Mara and make first contact at Spindle's perimeter."
	if data.bellwether_choice!="":return "Bellwether confirms recent safe-city traffic toward Spindle Gate. Continue below."
	if data.outpost_choice!="" and data.deepest>=7:return "Inspect Bellwether Lift. Choose the courier cage or maintenance bypass."
	if data.outpost_choice!="":return "Compact couriers marked Bellwether Lift at depth 8. Follow three white bars below."
	if data.deepest>=5:return "Meet the Lantern Compact at Low Lantern. Choose aid or trade."
	if not data.station_met:return "Explore the transit ruins. Someone is keeping a light below."
	if not data.recruit_joined:return "Bring Vale 2 rations and 1 medkit at Cinder Waystation."
	if data.deepest < 2: return "Find the stairs and descend below the transit ruins."
	if not data.signal: return "Find glowstone. Build a signal relay at depth 3 or lower."
	return "The relay voice points below the Sunken Quarter. Descend to depth 6."

func serialize() -> String:
	var copy = data.duplicate(true)
	for p in copy.pawns:
		if not p.job.is_empty() and p.job.get("kind","") != "attack":
			p.orders.push_front({"kind":p.job.kind,"target":p.job.target.duplicate(),"extra":p.job.get("extra",{}).duplicate(true),"z":int(p.z)})
		p.job = {}; p.move_clock = 0.0
	return JSON.stringify(copy)

func _integer(value) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == int(value)

func _materials_valid(inventory) -> bool:
	if not inventory is Dictionary: return false
	for item in inventory:
		if not ITEMS.has(item) or not _integer(inventory[item]) or inventory[item] < 0: return false
		inventory[item] = int(inventory[item])
	return true

func _position_valid(object) -> bool:
	return object is Dictionary and _integer(object.get("x",null)) and _integer(object.get("y",null)) and valid(point(object))

func _order_valid(order, floors: Dictionary) -> bool:
	if not order is Dictionary or not order.get("kind",null) is String: return false
	if not order.kind in ["interact","walk","search","transfer","build","construct","dismantle","reset_alarm","talk","recruit","outpost","bellwether","spindle","ashline","service","foundry","archive","wake","quiet","stillworks","cistern","drowned","tidecourt","sump","market","depot","refuge","ashrail","customs","railcourt","registry","morrow","terminus","farline","thimble","latchwater","driftglass","bellhome","commons","yard","kiln","junction","ember_commons","deepcoil","coilward","charterwell","writwell","concordance","reservefall","reserve_commons","shieldline","marchhold","march_refuge","wallward","wayfarer","underway","spring","pump","travel","retreat","rest","rescue","tend"]: return false
	if not order.get("target",null) is Array or order.target.size()!=2: return false
	for i in 2:
		if not _integer(order.target[i]): return false
		order.target[i]=int(order.target[i])
	if not valid(vec(order.target)) or not _integer(order.get("z",null)) or not floors.has(str(int(order.z))): return false
	order.z=int(order.z)
	if not order.get("extra",null) is Dictionary: return false
	var extra=order.extra
	if extra.has("automatic") and not extra.automatic is bool:return false
	match order.kind:
		"interact":
			if not extra.get("type","") in ["container","blueprint","structure","landmark"]:return false
			if extra.type=="landmark":
				if not extra.get("mark",null) is String or extra.mark.is_empty():return false
			else:
				if not _integer(extra.get("id",null)) or extra.id<1:return false
				extra.id=int(extra.id)
		"search":
			if not _integer(extra.get("container",null)) or extra.container<1:return false
			extra.container=int(extra.container)
		"transfer":
			if not _integer(extra.get("container",null)) or extra.container<1:return false
			if not extra.get("direction","") in ["take","store"] or not ITEMS.has(extra.get("item","")):return false
			if not _integer(extra.get("quantity",null)) or extra.quantity<=0:return false
			extra.container=int(extra.container);extra.quantity=int(extra.quantity)
		"build":
			if not RECIPES.has(extra.get("recipe","")):return false
		"construct":
			if not RECIPES.has(extra.get("recipe","")) or not _integer(extra.get("blueprint",null)) or extra.blueprint<1:return false
			extra.blueprint=int(extra.blueprint)
		"dismantle":
			if not _integer(extra.get("structure",null)) or extra.structure<1 or not RECIPES.has(extra.get("recipe","")):return false
			extra.structure=int(extra.structure)
		"reset_alarm":
			if not _integer(extra.get("structure",null)) or extra.structure<1:return false
			extra.structure=int(extra.structure)
		"spring":
			if not extra.get("choice","") in ["drink","harvest"]:return false
		"pump":
			if not extra.get("choice","") in ["residences","substation"]:return false
		"outpost":
			if not extra.get("choice","") in ["aid","trade"]:return false
		"bellwether":
			if not extra.get("choice","") in ["courier","maintenance"]:return false
		"thimble":
			if not extra.get("action","") in ["defend","evacuate","hold","depart"]:return false
		"latchwater":
			if not extra.get("action","") in ["start","warm","cold"]:return false
		"driftglass":
			if not extra.get("action","") in ["start","powered","shaded"]:return false
		"bellhome":
			if not extra.get("action","") in ["start","escort","divert"]:return false
		"commons":
			if not extra.get("action","") in ["start","finish"]:return false
		"yard":
			if not extra.get("action","") in ["start","finish"]:return false
		"kiln":
			if not extra.get("action","") in ["start","build","conceal"]:return false
		"junction":
			if not extra.get("action","") in ["start","receive","shunt"]:return false
		"ashline":
			if not extra.get("action","") in ["accept","deliver"]:return false
		"service":
			if not extra.get("choice","") in ["city","field"]:return false
		"foundry":
			if not extra.get("action","") in ["accept","deliver","contract"]:return false
		"archive":
			if not extra.get("action","") in ["open","share","preserve"]:return false
		"wake":
			if not extra.get("action","") in ["start","finish"]:return false
		"quiet":
			if not extra.get("action","") in ["tune","play"]:return false
			if extra.action=="tune":
				if not _integer(extra.get("stage",null)) or int(extra.stage)<1 or int(extra.stage)>3:return false
				extra.stage=int(extra.stage)
			elif extra.has("stage"):return false
		"stillworks":
			if not extra.get("choice","") in ["restore","dark"]:return false
		"cistern":
			if not extra.get("action","") in ["start","finish"]:return false
		"drowned":
			if not extra.get("action","") in ["start","rescue","salvage"]:return false
		"tidecourt":
			if not extra.get("action","") in ["sponsor","contract","start","finish"]:return false
		"sump":
			if not extra.get("action","") in ["start","finish"]:return false
		"depot":
			if not extra.get("action","") in ["start","finish"]:return false
		"refuge":
			if not extra.get("choice","") in ["foothold","corridor"]:return false
		"customs":
			if not extra.get("choice","") in ["security","smuggle"]:return false
		"railcourt":
			if not extra.get("action","") in ["start","finish","trade"]:return false
		"registry":
			if not extra.get("action","") in ["start","finish","copy"]:return false
		"morrow":
			if not extra.get("action","") in ["start","depart"]:return false
		"terminus":
			if not extra.get("action","") in ["start","finish","pledge"]:return false
		"farline":
			if not extra.get("action","") in ["start","finish"]:return false
		"ember_commons","deepcoil","coilward":
			if not extra.get("action","") in ["start","finish"]:return false
		"charterwell":
			if not extra.get("action","") in ["start","escort","supply"]:return false
		"writwell":
			if not extra.get("action","") in ["start","pledge"]:return false
		"concordance":
			if not extra.get("action","") in ["start","bastion","reserve"]:return false
		"reservefall":
			if not extra.get("action","") in ["start","hold","withdraw"]:return false
		"reserve_commons":
			if not extra.get("action","") in ["start","finish"]:return false
		"shieldline":
			if not extra.get("action","") in ["start","finish"]:return false
		"marchhold":
			if not extra.get("action","") in ["start","deploy","retreat"]:return false
		"march_refuge":
			if not extra.get("action","") in ["start","repair","donate"]:return false
		"wallward":
			if not extra.get("action","") in ["start","escort","screen"]:return false
		"wayfarer":
			if not extra.get("action","") in ["start","repair"]:return false
		"underway":
			if not extra.get("action","") in ["start","lit","hidden"]:return false
		"travel":
			if not _integer(extra.get("destination",null)) or extra.destination<0:return false
			extra.destination=int(extra.destination)
		"retreat":
			for field in ["destination","source","group"]:
				if not _integer(extra.get(field,null)) or int(extra[field])<0:return false
				extra[field]=int(extra[field])
			if abs(int(extra.destination)-int(extra.source))!=1 or not floors.has(str(extra.source)):return false
			if not extra.get("members",null) is Array or extra.members.is_empty():return false
			var unique_members:Dictionary={}
			for member in extra.members:
				if not _integer(member) or int(member)<0 or unique_members.has(int(member)):return false
				unique_members[int(member)]=true
			extra.members=unique_members.keys()
		"rest":
			for key in extra:
				if key!="automatic":return false
		"rescue":
			if not _integer(extra.get("patient",null)) or int(extra.patient)<0:return false
			if not _integer(extra.get("bed",null)) or int(extra.bed)<1:return false
			if not extra.get("carrying",null) is bool:return false
			extra.patient=int(extra.patient);extra.bed=int(extra.bed)
			for key in extra:
				if not key in ["patient","bed","carrying","automatic"]:return false
		"tend":
			if not _integer(extra.get("patient",null)) or int(extra.patient)<0:return false
			if not _integer(extra.get("bed",null)) or int(extra.bed)<1:return false
			extra.patient=int(extra.patient);extra.bed=int(extra.bed)
			for key in extra:
				if not key in ["patient","bed","automatic"]:return false
		_:
			if not extra.is_empty():return false
	return true

func restore(text: String) -> bool:
	var json = JSON.new()
	if json.parse(text) != OK: return false
	var saved = json.data
	if not saved is Dictionary or int(saved.get("version",0)) != SAVE_VERSION: return false
	for field in ["seed","next_id","deepest","built_total","kills","version"]:
		if not _integer(saved.get(field,null)) or saved[field] < 0: return false
		saved[field] = int(saved[field])
	if not saved.has("station_met"):saved.station_met=false
	if not saved.has("recruit_joined"):saved.recruit_joined=false
	if not saved.has("outpost_choice"):saved.outpost_choice=""
	if not saved.has("bellwether_choice"):saved.bellwether_choice=""
	if not saved.has("spindle_contact"):saved.spindle_contact=""
	if not saved.has("ashline_state"):saved.ashline_state=""
	if not saved.has("service_choice"):saved.service_choice=""
	if not saved.has("foundry_state"):saved.foundry_state=""
	if not saved.has("archive_choice"):saved.archive_choice=""
	if not saved.has("wake_state"):saved.wake_state=""
	if not saved.has("quiet_state"):saved.quiet_state=""
	if not saved.has("stillworks_choice"):saved.stillworks_choice=""
	if not saved.has("cistern_state"):saved.cistern_state=""
	if not saved.has("drowned_state"):saved.drowned_state=""
	if not saved.has("drowned_timer"):saved.drowned_timer=0.0
	if not saved.has("tidecourt_state"):saved.tidecourt_state=""
	if not saved.has("sump_state"):saved.sump_state=""
	if not saved.has("market_state"):saved.market_state=""
	if not saved.has("market_recruit_joined"):saved.market_recruit_joined=false
	if not saved.has("depot_state"):saved.depot_state=""
	if not saved.has("refuge_state"):saved.refuge_state=""
	if not saved.has("ashrail_state"):saved.ashrail_state=""
	if not saved.has("customs_state"):saved.customs_state=""
	if not saved.has("railcourt_state"):saved.railcourt_state=""
	if not saved.has("registry_state"):saved.registry_state=""
	if not saved.has("morrow_state"):saved.morrow_state=""
	if not saved.has("morrow_timer"):saved.morrow_timer=0.0
	if not saved.has("terminus_state"):saved.terminus_state=""
	if not saved.has("farline_state"):saved.farline_state=""
	if not saved.has("thimble_state"):saved.thimble_state=""
	if not saved.has("thimble_timer"):saved.thimble_timer=0.0
	if not saved.has("latchwater_state"):saved.latchwater_state=""
	if not saved.has("driftglass_state"):saved.driftglass_state=""
	if not saved.has("bellhome_state"):saved.bellhome_state=""
	if not saved.has("bellhome_timer"):saved.bellhome_timer=0.0
	if not saved.has("commons_state"):saved.commons_state=""
	if not saved.has("yard_state"):saved.yard_state=""
	if not saved.has("yard_recruit_joined"):saved.yard_recruit_joined=false
	if not saved.has("kiln_state"):saved.kiln_state=""
	if not saved.has("junction_state"):saved.junction_state=""
	if not saved.has("junction_timer"):saved.junction_timer=0.0
	if not saved.has("ember_commons_state"):saved.ember_commons_state=""
	if not saved.has("deepcoil_state"):saved.deepcoil_state=""
	if not saved.has("coilward_state"):saved.coilward_state=""
	if not saved.has("charterwell_state"):saved.charterwell_state=""
	if not saved.has("charterwell_timer"):saved.charterwell_timer=0.0
	if not saved.has("writwell_state"):saved.writwell_state=""
	if not saved.has("concordance_state"):saved.concordance_state=""
	if not saved.has("reservefall_state"):saved.reservefall_state=""
	if not saved.has("reservefall_timer"):saved.reservefall_timer=0.0
	if not saved.has("reserve_commons_state"):saved.reserve_commons_state=""
	if not saved.has("shieldline_state"):saved.shieldline_state=""
	if not saved.has("shieldline_recruit_joined"):saved.shieldline_recruit_joined=false
	if not saved.has("marchhold_state"):saved.marchhold_state=""
	if not saved.has("marchhold_timer"):saved.marchhold_timer=0.0
	if not saved.has("march_refuge_state"):saved.march_refuge_state=""
	if not saved.has("wallward_state"):saved.wallward_state=""
	if not saved.has("wallward_timer"):saved.wallward_timer=0.0
	if not saved.has("wayfarer_state"):saved.wayfarer_state=""
	if not saved.has("underway_state"):saved.underway_state=""
	if not saved.outpost_choice is String or not saved.outpost_choice in ["","aid","trade"]:return false
	if not saved.bellwether_choice is String or not saved.bellwether_choice in ["","courier","maintenance"]:return false
	if not saved.spindle_contact is String or not saved.spindle_contact in ["","recognized","breach"]:return false
	if not saved.ashline_state is String or not saved.ashline_state in ["","assigned","cleared"]:return false
	if not saved.service_choice is String or not saved.service_choice in ["","city","field"]:return false
	if not saved.foundry_state is String or not saved.foundry_state in ["","assigned","municipal","independent"]:return false
	if not saved.archive_choice is String or not saved.archive_choice in ["","assigned","shared","preserved"]:return false
	if not saved.wake_state is String or not saved.wake_state in ["","assigned","marshal","waymark"]:return false
	if not saved.quiet_state is String or not saved.quiet_state in ["","one","two","open","heard"]:return false
	if not saved.stillworks_choice is String or not saved.stillworks_choice in ["","restore","dark"]:return false
	if not saved.cistern_state is String or not saved.cistern_state in ["","assigned","pressure","spillway"]:return false
	if not saved.drowned_state is String or not saved.drowned_state in ["","warning","rescued","salvaged","flooded"]:return false
	if not saved.tidecourt_state is String or not saved.tidecourt_state in ["","assigned","sponsored","contracted","recovered"]:return false
	if not saved.sump_state is String or not saved.sump_state in ["","assigned","resident","service","public"]:return false
	if not saved.market_state is String or not saved.market_state in ["","resident","service","public"]:return false
	if not saved.depot_state is String or not saved.depot_state in ["","assigned","resident","service","public"]:return false
	if not saved.refuge_state is String or not saved.refuge_state in ["","foothold","corridor"]:return false
	if not saved.ashrail_state is String or not saved.ashrail_state in ["","stocked"]:return false
	if not saved.customs_state is String or not saved.customs_state in ["","security","smuggle"]:return false
	if not saved.railcourt_state is String or not saved.railcourt_state in ["","assigned","licensed","resident"]:return false
	if not saved.registry_state is String or not saved.registry_state in ["","assigned","official","resident"]:return false
	if not saved.morrow_state is String or not saved.morrow_state in ["","boarding","official","resident"]:return false
	if not saved.terminus_state is String or not saved.terminus_state in ["","assigned","chartered","free"]:return false
	if not saved.farline_state is String or not saved.farline_state in ["","assigned","accord","cacheway"]:return false
	if not saved.thimble_state is String or not saved.thimble_state in ["","defending","evacuating","defended","evacuated","overrun"]:return false
	if not saved.latchwater_state is String or not saved.latchwater_state in ["","assigned","warm","cold"]:return false
	if not saved.driftglass_state is String or not saved.driftglass_state in ["","assigned","powered","shaded"]:return false
	if not saved.bellhome_state is String or not saved.bellhome_state in ["","warning","escorted","diverted","retreated"]:return false
	if not saved.commons_state is String or not saved.commons_state in ["","assigned","resident","culvert","public"]:return false
	if not saved.yard_state is String or not saved.yard_state in ["","assigned","resident","culvert","public"]:return false
	if not saved.kiln_state is String or not saved.kiln_state in ["","assigned","built","concealed"]:return false
	if not saved.junction_state is String or not saved.junction_state in ["","warning","received","shunted","missed"]:return false
	if not saved.ember_commons_state is String or not saved.ember_commons_state in ["","assigned","freight","refuge","public"]:return false
	if not saved.deepcoil_state is String or not saved.deepcoil_state in ["","assigned","keepers","freeband","echo"]:return false
	if not saved.coilward_state is String or not saved.coilward_state in ["","assigned","keepers","freeband","echo"]:return false
	if not saved.charterwell_state is String or not saved.charterwell_state in ["","warning","escorted","supplied","missed"]:return false
	if not saved.writwell_state is String or not saved.writwell_state in ["","assigned","delegates","exchange","commons"]:return false
	if not saved.concordance_state is String or not saved.concordance_state in ["","assigned","bastion","reserve"]:return false
	if not saved.reservefall_state is String or not saved.reservefall_state in ["","warning","held","withdrawn","breached"]:return false
	if not saved.reserve_commons_state is String or not saved.reserve_commons_state in ["","assigned","guarded","sheltered","public"]:return false
	if not saved.shieldline_state is String or not saved.shieldline_state in ["","assigned","guarded","sheltered","public"]:return false
	if not saved.marchhold_state is String or not saved.marchhold_state in ["","warning","deployed","retreated","overrun"]:return false
	if not saved.march_refuge_state is String or not saved.march_refuge_state in ["","assigned","guarded","sheltered","public","walled"]:return false
	if not saved.wallward_state is String or not saved.wallward_state in ["","warning","escorted","screened","missed"]:return false
	if not saved.wayfarer_state is String or not saved.wayfarer_state in ["","assigned","resident","hidden","public"]:return false
	if not saved.underway_state is String or not saved.underway_state in ["","assigned","lit","hidden"]:return false
	if not saved.drowned_timer is float and not saved.drowned_timer is int:return false
	if not is_finite(float(saved.drowned_timer)) or float(saved.drowned_timer)<0 or float(saved.drowned_timer)>24:return false
	saved.drowned_timer=float(saved.drowned_timer)
	if saved.drowned_state=="warning" and saved.drowned_timer<=0:return false
	if saved.drowned_state!="warning" and saved.drowned_timer!=0:return false
	if not saved.morrow_timer is float and not saved.morrow_timer is int:return false
	if not is_finite(float(saved.morrow_timer)) or float(saved.morrow_timer)<0 or float(saved.morrow_timer)>30:return false
	saved.morrow_timer=float(saved.morrow_timer)
	if saved.morrow_state=="boarding" and saved.morrow_timer<=0:return false
	if saved.morrow_state!="boarding" and saved.morrow_timer!=0:return false
	if not saved.reservefall_timer is float and not saved.reservefall_timer is int:return false
	if not is_finite(float(saved.reservefall_timer)) or float(saved.reservefall_timer)<0 or float(saved.reservefall_timer)>30:return false
	saved.reservefall_timer=float(saved.reservefall_timer)
	if saved.reservefall_state=="warning" and saved.reservefall_timer<=0:return false
	if saved.reservefall_state!="warning" and saved.reservefall_timer!=0:return false
	if not saved.marchhold_timer is float and not saved.marchhold_timer is int:return false
	if not is_finite(float(saved.marchhold_timer)) or float(saved.marchhold_timer)<0 or float(saved.marchhold_timer)>32:return false
	saved.marchhold_timer=float(saved.marchhold_timer)
	if saved.marchhold_state=="warning" and saved.marchhold_timer<=0:return false
	if saved.marchhold_state!="warning" and saved.marchhold_timer!=0:return false
	if not saved.wallward_timer is float and not saved.wallward_timer is int:return false
	if not is_finite(float(saved.wallward_timer)) or float(saved.wallward_timer)<0 or float(saved.wallward_timer)>30:return false
	saved.wallward_timer=float(saved.wallward_timer)
	if saved.wallward_state=="warning" and saved.wallward_timer<=0:return false
	if saved.wallward_state!="warning" and saved.wallward_timer!=0:return false
	if not saved.thimble_timer is float and not saved.thimble_timer is int:return false
	if not is_finite(float(saved.thimble_timer)) or float(saved.thimble_timer)<0 or float(saved.thimble_timer)>28:return false
	saved.thimble_timer=float(saved.thimble_timer)
	if saved.thimble_state in ["defending","evacuating"] and saved.thimble_timer<=0:return false
	if not saved.thimble_state in ["defending","evacuating"] and saved.thimble_timer!=0:return false
	if not saved.bellhome_timer is float and not saved.bellhome_timer is int:return false
	if not is_finite(float(saved.bellhome_timer)) or float(saved.bellhome_timer)<0 or float(saved.bellhome_timer)>32:return false
	saved.bellhome_timer=float(saved.bellhome_timer)
	if saved.bellhome_state=="warning" and saved.bellhome_timer<=0:return false
	if saved.bellhome_state!="warning" and saved.bellhome_timer!=0:return false
	if not saved.junction_timer is float and not saved.junction_timer is int:return false
	if not is_finite(float(saved.junction_timer)) or float(saved.junction_timer)<0 or float(saved.junction_timer)>30:return false
	saved.junction_timer=float(saved.junction_timer)
	if saved.junction_state=="warning" and saved.junction_timer<=0:return false
	if saved.junction_state!="warning" and saved.junction_timer!=0:return false
	if not saved.charterwell_timer is float and not saved.charterwell_timer is int:return false
	if not is_finite(float(saved.charterwell_timer)) or float(saved.charterwell_timer)<0 or float(saved.charterwell_timer)>30:return false
	saved.charterwell_timer=float(saved.charterwell_timer)
	if saved.charterwell_state=="warning" and saved.charterwell_timer<=0:return false
	if saved.charterwell_state!="warning" and saved.charterwell_timer!=0:return false
	if saved.bellwether_choice!="" and saved.outpost_choice=="":return false
	if saved.spindle_contact!="" and saved.bellwether_choice=="":return false
	if saved.ashline_state!="" and saved.spindle_contact=="":return false
	if saved.service_choice!="" and saved.ashline_state!="cleared":return false
	if saved.foundry_state!="" and saved.service_choice=="":return false
	if saved.foundry_state in ["assigned","municipal"] and saved.service_choice!="city":return false
	if saved.foundry_state=="independent" and saved.service_choice!="field":return false
	if saved.archive_choice!="" and not saved.foundry_state in ["municipal","independent"]:return false
	if saved.wake_state!="" and not saved.archive_choice in ["shared","preserved"]:return false
	if saved.wake_state=="marshal" and saved.archive_choice!="shared":return false
	if saved.wake_state=="waymark" and saved.archive_choice!="preserved":return false
	if saved.quiet_state!="" and not saved.wake_state in ["marshal","waymark"]:return false
	if saved.stillworks_choice!="" and saved.quiet_state!="heard":return false
	if saved.cistern_state!="" and saved.stillworks_choice=="":return false
	if saved.cistern_state=="pressure" and saved.stillworks_choice!="restore":return false
	if saved.cistern_state=="spillway" and saved.stillworks_choice!="dark":return false
	if saved.drowned_state!="" and not saved.cistern_state in ["pressure","spillway"]:return false
	if saved.tidecourt_state!="" and not saved.drowned_state in ["rescued","salvaged","flooded"]:return false
	if saved.tidecourt_state=="sponsored" and saved.drowned_state!="rescued":return false
	if saved.tidecourt_state=="contracted" and saved.drowned_state!="salvaged":return false
	if saved.tidecourt_state in ["assigned","recovered"] and saved.drowned_state!="flooded":return false
	if saved.sump_state!="" and not saved.tidecourt_state in ["sponsored","contracted","recovered"]:return false
	if saved.sump_state=="resident" and saved.tidecourt_state!="sponsored":return false
	if saved.sump_state=="service" and saved.tidecourt_state!="contracted":return false
	if saved.sump_state=="public" and saved.tidecourt_state!="recovered":return false
	if saved.market_state!="" and not saved.sump_state in ["resident","service","public"]:return false
	if saved.market_state!="" and saved.market_state!=saved.sump_state:return false
	if bool(saved.market_recruit_joined)!=(saved.market_state in ["resident","service","public"]):return false
	if saved.depot_state!="" and not saved.market_state in ["resident","service","public"]:return false
	if saved.depot_state in ["resident","service","public"] and saved.depot_state!=saved.market_state:return false
	if saved.refuge_state!="" and not saved.depot_state in ["resident","service","public"]:return false
	if saved.ashrail_state!="" and not saved.refuge_state in ["foothold","corridor"]:return false
	if saved.customs_state!="" and saved.ashrail_state!="stocked":return false
	if saved.railcourt_state!="" and not saved.customs_state in ["security","smuggle"]:return false
	if saved.railcourt_state in ["assigned","licensed"] and saved.customs_state!="security":return false
	if saved.railcourt_state=="resident" and saved.customs_state!="smuggle":return false
	if saved.registry_state!="" and not saved.railcourt_state in ["licensed","resident"]:return false
	if saved.registry_state in ["assigned","official"] and saved.railcourt_state!="licensed":return false
	if saved.registry_state=="resident" and saved.railcourt_state!="resident":return false
	if saved.morrow_state!="" and not saved.registry_state in ["official","resident"]:return false
	if saved.morrow_state=="official" and saved.registry_state!="official":return false
	if saved.morrow_state=="resident" and saved.registry_state!="resident":return false
	if saved.terminus_state!="" and not saved.morrow_state in ["official","resident"]:return false
	if saved.terminus_state in ["assigned","chartered"] and saved.morrow_state!="official":return false
	if saved.terminus_state=="free" and saved.morrow_state!="resident":return false
	if saved.farline_state!="" and not saved.terminus_state in ["chartered","free"]:return false
	if saved.farline_state=="accord" and saved.terminus_state!="chartered":return false
	if saved.farline_state=="cacheway" and saved.terminus_state!="free":return false
	if saved.thimble_state!="" and not saved.farline_state in ["accord","cacheway"]:return false
	if saved.latchwater_state!="" and not saved.thimble_state in ["defended","evacuated","overrun"]:return false
	if saved.driftglass_state!="" and not saved.latchwater_state in ["warm","cold"]:return false
	if saved.bellhome_state!="" and not saved.driftglass_state in ["powered","shaded"]:return false
	if saved.commons_state!="" and not saved.bellhome_state in ["escorted","diverted","retreated"]:return false
	if saved.commons_state in ["resident","culvert","public"] and saved.commons_state!=_commons_route(saved.bellhome_state):return false
	if saved.yard_state!="" and not saved.commons_state in ["resident","culvert","public"]:return false
	if saved.yard_state in ["resident","culvert","public"] and saved.yard_state!=_yard_route(saved.commons_state):return false
	if bool(saved.yard_recruit_joined)!=(saved.yard_state in ["assigned","resident","culvert","public"]):return false
	if saved.kiln_state!="" and not saved.yard_state in ["resident","culvert","public"]:return false
	if saved.junction_state!="" and not saved.kiln_state in ["built","concealed"]:return false
	if saved.ember_commons_state!="" and not saved.junction_state in ["received","shunted","missed"]:return false
	if saved.ember_commons_state in ["freight","refuge","public"] and saved.ember_commons_state!=_ember_commons_route(saved.junction_state):return false
	if saved.deepcoil_state!="" and not saved.ember_commons_state in ["freight","refuge","public"]:return false
	if saved.deepcoil_state in ["keepers","freeband","echo"] and saved.deepcoil_state!=_deepcoil_route(saved.ember_commons_state):return false
	if saved.coilward_state!="" and not saved.deepcoil_state in ["keepers","freeband","echo"]:return false
	if saved.coilward_state in ["keepers","freeband","echo"] and saved.coilward_state!=_coilward_route(saved.deepcoil_state):return false
	if saved.charterwell_state!="" and not saved.coilward_state in ["keepers","freeband","echo"]:return false
	if saved.writwell_state!="" and not saved.charterwell_state in ["escorted","supplied","missed"]:return false
	if saved.writwell_state in ["delegates","exchange","commons"] and saved.writwell_state!=_writwell_route(saved.charterwell_state):return false
	if saved.concordance_state!="" and not saved.writwell_state in ["delegates","exchange","commons"]:return false
	if saved.reservefall_state!="" and not saved.concordance_state in ["bastion","reserve"]:return false
	if saved.reserve_commons_state!="" and not saved.reservefall_state in ["held","withdrawn","breached"]:return false
	if saved.reserve_commons_state in ["guarded","sheltered","public"] and saved.reserve_commons_state!=_reserve_commons_route(saved.reservefall_state):return false
	if saved.shieldline_state!="" and not saved.reserve_commons_state in ["guarded","sheltered","public"]:return false
	if saved.shieldline_state in ["guarded","sheltered","public"] and saved.shieldline_state!=_shieldline_route(saved.reserve_commons_state):return false
	if bool(saved.shieldline_recruit_joined)!=(saved.shieldline_state in ["assigned","guarded","sheltered","public"]):return false
	if saved.marchhold_state!="" and not saved.shieldline_state in ["guarded","sheltered","public"]:return false
	if saved.march_refuge_state!="" and not saved.marchhold_state in ["deployed","retreated","overrun"]:return false
	if saved.march_refuge_state in ["guarded","sheltered","public"] and saved.march_refuge_state!=_march_refuge_route(saved.marchhold_state):return false
	if saved.march_refuge_state=="walled" and saved.marchhold_state!="retreated":return false
	if saved.wallward_state!="" and not saved.march_refuge_state in ["guarded","sheltered","public","walled"]:return false
	if saved.wayfarer_state!="" and not saved.wallward_state in ["escorted","screened","missed"]:return false
	if saved.wayfarer_state in ["resident","hidden","public"] and saved.wayfarer_state!=_wayfarer_route(saved.wallward_state):return false
	if saved.underway_state!="" and not saved.wayfarer_state in ["resident","hidden","public"]:return false
	for field in ["traveler","rumor","signal","station_met","recruit_joined","market_recruit_joined","yard_recruit_joined","shieldline_recruit_joined","paused"]:
		if not saved.get(field,null) is bool: return false
	if not saved.get("seconds",null) is float and not saved.get("seconds",null) is int: return false
	if not is_finite(saved.seconds) or saved.seconds < 0: return false
	if not saved.get("log",null) is Array: return false
	for entry in saved.log:
		if not entry is String: return false
	if not saved.get("floors",null) is Dictionary or not saved.get("pawns",null) is Array or saved.pawns.is_empty(): return false
	if not saved.floors.has("0"): return false
	var largest_id = 0
	for z_key in saved.floors:
		var f = saved.floors[z_key]
		if not f is Dictionary or not _integer(f.get("z",null)) or str(int(f.z)) != z_key: return false
		f.z = int(f.z)
		if not f.get("name",null) is String or not f.get("seen",null) is Dictionary: return false
		if not f.get("grid",null) is Array or f.grid.size() != H: return false
		for row in f.grid:
			if not row is Array or row.size() != W: return false
			for x in W:
				if row[x] != 0 and row[x] != 1: return false
				row[x] = int(row[x])
		for field in ["up","down"]:
			if not f.get(field,null) is Array or f[field].size() != 2: return false
			for i in 2:
				if not _integer(f[field][i]): return false
				f[field][i] = int(f[field][i])
			if not valid(vec(f[field])) or f.grid[f[field][1]][f[field][0]] != 1: return false
		for field in ["containers","structures","enemies","landmarks","rooms"]:
			if not f.get(field,null) is Array: return false
		for field in ["heat","alarm"]:
			if not f.get(field,null) is float and not f.get(field,null) is int: return false
			if not is_finite(f[field]): return false
			f[field] = float(f[field])
		if f.heat < 0 or f.heat > 100 or f.alarm < -1 or f.alarm > 30: return false
		if not _integer(f.get("waves",null)) or f.waves < 0: return false
		f.waves = int(f.waves)
		for c in f.containers:
			if not _position_valid(c) or not _materials_valid(c.get("items",null)): return false
			if not c.get("searched",null) is bool or not c.get("name",null) is String or not c.get("kind",null) is String: return false
			if not _integer(c.get("id",null)) or c.id < 1: return false
			for k in ["id","x","y"]: c[k] = int(c[k])
			if c.kind=="stockpile":
				if not c.has("auto_haul"):c.auto_haul=true
				if not c.auto_haul is bool:return false
				if not c.has("filters"):c.filters={}
				if not c.filters is Dictionary:return false
				for item in c.filters:
					if not ITEMS.has(item) or not c.filters[item] is bool:return false
				for item in ITEMS:
					if not c.filters.has(item):c.filters[item]=true
			elif c.kind=="blueprint":
				if not RECIPES.has(c.get("recipe","")):return false
				if c.get("recipe","")=="shieldwall" and not saved.shieldline_state in ["guarded","sheltered","public"]:return false
				for item in c.items:
					if not RECIPES[c.recipe].cost.has(item) or int(c.items[item])>int(RECIPES[c.recipe].cost[item]):return false
			largest_id = max(largest_id,c.id)
		for list in [f.structures,f.enemies]:
			for obj in list:
				if not _position_valid(obj) or not _integer(obj.get("id",null)): return false
				if not obj.get("hp",null) is float and not obj.get("hp",null) is int: return false
				var maximum_hp=150.0 if obj.get("kind","")=="shieldwall" else 100.0
				if not is_finite(obj.hp) or obj.hp < 0 or obj.hp > maximum_hp: return false
				for k in ["id","x","y"]: obj[k] = int(obj[k])
				largest_id = max(largest_id,obj.id)
		for obj in f.structures:
			if not RECIPES.has(obj.get("kind","")): return false
			if obj.get("kind","")=="shieldwall" and not saved.shieldline_state in ["guarded","sheltered","public"]:return false
			if obj.kind=="tripwire":
				if not obj.get("state",null) in ["armed","ringing","spent"]:return false
				if not obj.get("triggered_by",null) is String:return false
				if not obj.get("ring",null) is float and not obj.get("ring",null) is int:return false
				if not is_finite(float(obj.ring)) or float(obj.ring)<0 or float(obj.ring)>TRIPWIRE_RING_TIME:return false
				obj.ring=float(obj.ring)
				if obj.state!="ringing" and obj.ring!=0:return false
		for obj in f.enemies:
			if not obj.get("name",null) is String: return false
			for k in ["clock","attack"]:
				if not obj.get(k,null) is float and not obj.get(k,null) is int: return false
				if not is_finite(obj[k]) or obj[k] < 0: return false
		for obj in f.landmarks:
			if not _position_valid(obj) or not obj.get("kind",null) is String or not obj.get("name",null) is String: return false
			obj.x = int(obj.x); obj.y = int(obj.y)
			if obj.kind=="unstable_roof":
				if not obj.get("state","") in ["armed","warning","collapsed"]:return false
				if not obj.get("timer",null) is float and not obj.get("timer",null) is int:return false
				if not is_finite(float(obj.timer)) or float(obj.timer)<0 or float(obj.timer)>3:return false
				obj.timer=float(obj.timer)
				if obj.state=="armed" and obj.timer!=0:return false
				if obj.state=="collapsed" and obj.timer!=0:return false
			elif obj.kind=="spring":
				if not obj.get("state","") in ["untouched","drunk","harvested"]:return false
			elif obj.kind=="pump_console":
				if not obj.get("state","") in ["idle","residences","substation"]:return false
			elif obj.kind=="flooded_route":
				if not obj.get("branch","") in ["residences","substation"] or not obj.get("state","") in ["flooded","drained","sealed"]:return false
			elif obj.kind=="outpost":
				if not obj.get("state","") in ["waiting","aid","trade"]:return false
			elif obj.kind=="bellwether":
				if not obj.get("state","") in ["waiting","courier","maintenance"]:return false
			elif obj.kind=="bellwether_route":
				if not obj.get("route","") in ["courier","maintenance"] or not obj.get("state","") in ["sealed","open","locked"]:return false
			elif obj.kind=="spindle":
				if not obj.get("state","") in ["waiting","recognized","breach"]:return false
			elif obj.kind=="spindle_route":
				if not obj.get("route","") in ["courier","maintenance"] or not obj.get("state","") in ["arrived","closed"]:return false
			elif obj.kind=="ashline":
				if not obj.get("state","") in ["waiting","assigned","cleared"]:return false
			elif obj.kind=="ashline_route":
				if not obj.get("route","") in ["purifier","threshold"] or not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="service_ring":
				if not obj.get("state","") in ["waiting","city","field"]:return false
			elif obj.kind=="service_option":
				if not obj.get("option","") in ["city","field"] or not obj.get("state","") in ["available","chosen","closed"]:return false
			elif obj.kind=="service_route":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="foundry":
				if not obj.get("state","") in ["waiting","assigned","municipal","independent"]:return false
			elif obj.kind=="foundry_contract":
				if not obj.get("contract","") in ["municipal","independent"] or not obj.get("state","") in ["available","open","complete","closed"]:return false
			elif obj.kind=="foundry_route":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="archive":
				if not obj.get("state","") in ["waiting","assigned","shared","preserved"]:return false
			elif obj.kind=="archive_choice":
				if not obj.get("choice","") in ["shared","preserved"] or not obj.get("state","") in ["sealed","available","chosen","closed"]:return false
			elif obj.kind=="archive_route":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="wake":
				if not obj.get("state","") in ["waiting","assigned","marshal","waymark"]:return false
			elif obj.kind=="wake_route":
				if not obj.get("route","") in ["official","unindexed"] or not obj.get("state","") in ["sealed","open","closed"]:return false
			elif obj.kind=="wake_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="quiet_receiver":
				if not obj.get("state","") in ["ready","heard"]:return false
			elif obj.kind=="quiet_post":
				if not _integer(obj.get("stage",null)) or int(obj.stage)<1 or int(obj.stage)>3:return false
				obj.stage=int(obj.stage)
				if not obj.get("state","") in ["locked","available","complete"]:return false
			elif obj.kind=="quiet_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="stillworks":
				if not obj.get("state","") in ["waiting","restore","dark"]:return false
			elif obj.kind=="stillworks_option":
				if not obj.get("choice","") in ["restore","dark"] or not obj.get("state","") in ["available","chosen","closed"]:return false
			elif obj.kind=="stillworks_exit":
				if not obj.get("route","") in ["restore","dark"] or not obj.get("state","") in ["sealed","open","closed"]:return false
			elif obj.kind=="stillworks_light":
				if obj.get("state","")!="lit":return false
			elif obj.kind=="cistern":
				if not obj.get("state","") in ["waiting","assigned","pressure","spillway"]:return false
				if not obj.get("route","") in ["pressure","spillway"]:return false
			elif obj.kind=="cistern_route":
				if not obj.get("route","") in ["pressure","spillway"] or not obj.get("state","") in ["sealed","open","closed","complete"]:return false
			elif obj.kind=="cistern_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="drowned_control":
				if not obj.get("state","") in ["waiting","warning","rescued","salvaged","flooded"]:return false
			elif obj.kind=="drowned_rescue":
				if not obj.get("state","") in ["sealed","available","safe","lost"]:return false
			elif obj.kind=="drowned_salvage":
				if not obj.get("state","") in ["sealed","available","claimed","washed"]:return false
			elif obj.kind=="drowned_safe":
				if obj.get("state","")!="safe":return false
			elif obj.kind=="drowned_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="tidecourt":
				if not obj.get("state","") in ["waiting","assigned","sponsored","contracted","recovered"] or not obj.get("route","") in ["sponsor","contract","recovery"]:return false
			elif obj.kind=="tidecourt_route":
				if not obj.get("route","") in ["sponsor","contract"] or not obj.get("state","") in ["available","open","closed"]:return false
			elif obj.kind=="tidecourt_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="sump":
				if not obj.get("state","") in ["waiting","assigned","resident","service","public"] or not obj.get("route","") in ["resident","service","public"]:return false
			elif obj.kind=="sump_route":
				if not obj.get("route","") in ["resident","service","public"] or not obj.get("state","") in ["sealed","open","complete"]:return false
			elif obj.kind=="sump_foothold":
				if not obj.get("route","") in ["resident","service","public"] or not obj.get("state","") in ["sealed","active"]:return false
			elif obj.kind=="sump_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="market":
				if not obj.get("state","") in ["waiting","resident","service","public"] or not obj.get("route","") in ["resident","service","public"]:return false
			elif obj.kind=="market_arcade":
				if not obj.get("route","") in ["resident","service","public"] or not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="market_recruit":
				if obj.get("state","")!="waiting" or not obj.get("route","") in ["resident","service","public"]:return false
			elif obj.kind=="market_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="depot":
				if not obj.get("state","") in ["waiting","assigned","resident","service","public"] or not obj.get("route","") in ["resident","service","public"]:return false
			elif obj.kind=="depot_lane":
				if not obj.get("cargo","") in ["drive","brake"] or not obj.get("route","") in ["resident","service","public"] or not obj.get("state","") in ["sealed","open","complete"]:return false
			elif obj.kind=="depot_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="refuge":
				if not obj.get("state","") in ["waiting","foothold","corridor"] or not obj.get("route","") in ["resident","service","public"]:return false
			elif obj.kind=="refuge_option":
				if not obj.get("choice","") in ["foothold","corridor"] or not obj.get("state","") in ["available","active","closed"]:return false
			elif obj.kind=="refuge_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="ashrail":
				if not obj.get("state","") in ["waiting","stocked"] or not obj.get("route","") in ["sanctuary","corridor"]:return false
			elif obj.kind=="ashrail_route":
				if not obj.get("state","") in ["open","complete"] or not obj.get("route","") in ["sanctuary","corridor"]:return false
			elif obj.kind=="ashrail_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="customs":
				if not obj.get("state","") in ["waiting","security","smuggle"] or not obj.get("cargo","") in ["industrial","provisions"]:return false
			elif obj.kind=="customs_route":
				if not obj.get("choice","") in ["security","smuggle"] or not obj.get("state","") in ["available","open","closed"]:return false
			elif obj.kind=="customs_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="railcourt":
				if not obj.get("state","") in ["waiting","assigned","licensed","resident"] or not obj.get("route","") in ["authority","resident"]:return false
			elif obj.kind=="railcourt_route":
				if not obj.get("state","") in ["sealed","open","complete"] or not obj.get("route","") in ["authority","resident"]:return false
			elif obj.kind=="railcourt_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="registry":
				if not obj.get("state","") in ["waiting","assigned","official","resident"] or not obj.get("route","") in ["official","resident"]:return false
			elif obj.kind=="registry_route":
				if not obj.get("state","") in ["sealed","open","complete"] or not obj.get("route","") in ["official","resident"]:return false
			elif obj.kind=="registry_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="morrow":
				if not obj.get("state","") in ["waiting","boarding","official","resident"] or not obj.get("route","") in ["official","resident"]:return false
			elif obj.kind=="morrow_route":
				if not obj.get("state","") in ["sealed","boarding","complete"] or not obj.get("route","") in ["official","resident"]:return false
			elif obj.kind=="morrow_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="terminus":
				if not obj.get("state","") in ["waiting","assigned","chartered","free"] or not obj.get("route","") in ["official","resident"]:return false
			elif obj.kind=="terminus_route":
				if not obj.get("state","") in ["sealed","open","complete"] or not obj.get("route","") in ["official","resident"]:return false
			elif obj.kind=="terminus_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="farline":
				if not obj.get("state","") in ["waiting","assigned","accord","cacheway"] or not obj.get("route","") in ["accord","cacheway"]:return false
			elif obj.kind=="farline_route":
				if not obj.get("state","") in ["sealed","open","complete"] or not obj.get("route","") in ["accord","cacheway"]:return false
			elif obj.kind=="farline_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="thimble":
				if not obj.get("state","") in ["waiting","defending","evacuating","defended","evacuated","overrun"] or not obj.get("route","") in ["accord","cacheway"]:return false
			elif obj.kind=="thimble_breach":
				if not obj.get("state","") in ["sealed","warning","held","lost"] or not obj.get("route","") in ["accord","cacheway"]:return false
			elif obj.kind=="thimble_evacuation":
				if not obj.get("state","") in ["sealed","fallback","available","safe","closed","lost"]:return false
			elif obj.kind=="thimble_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="latchwater":
				if not obj.get("state","") in ["waiting","assigned","warm","cold"] or not obj.get("route","") in ["resident","refugee","public"]:return false
			elif obj.kind=="latchwater_route":
				if not obj.get("state","") in ["sealed","open","complete"] or not obj.get("route","") in ["resident","refugee","public"]:return false
			elif obj.kind=="latchwater_option":
				if not obj.get("state","") in ["sealed","available","warm","cold"]:return false
			elif obj.kind=="latchwater_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="driftglass":
				if not obj.get("state","") in ["waiting","assigned","powered","shaded"] or not obj.get("route","") in ["powered","shaded"]:return false
			elif obj.kind=="driftglass_route":
				if not obj.get("state","") in ["sealed","open","complete"] or not obj.get("route","") in ["powered","shaded"]:return false
			elif obj.kind=="driftglass_option":
				if not obj.get("state","") in ["sealed","available","powered","shaded"]:return false
			elif obj.kind=="driftglass_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="bellhome":
				if not obj.get("state","") in ["waiting","warning","escorted","diverted","retreated"] or not obj.get("route","") in ["lampline","darkway"]:return false
			elif obj.kind=="bellhome_route":
				if not obj.get("state","") in ["sealed","warning","safe"] or not obj.get("route","") in ["lampline","darkway"]:return false
			elif obj.kind=="bellhome_convoy":
				if not obj.get("state","") in ["sealed","ready","arrived","diverted","withdrawn"]:return false
			elif obj.kind=="bellhome_diversion":
				if not obj.get("state","") in ["sealed","available","open","closed"]:return false
			elif obj.kind=="bellhome_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="commons":
				if not obj.get("state","") in ["waiting","assigned","resident","culvert","public"] or not obj.get("route","") in ["resident","culvert","public"]:return false
			elif obj.kind=="commons_route":
				if not obj.get("state","") in ["sealed","open","repaired"] or not obj.get("route","") in ["resident","culvert","public"]:return false
			elif obj.kind=="commons_repair":
				if not obj.get("state","") in ["sealed","available","complete"]:return false
			elif obj.kind=="commons_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="yard":
				if not obj.get("state","") in ["waiting","assigned","resident","culvert","public"] or not obj.get("route","") in ["resident","culvert","public"]:return false
			elif obj.kind=="yard_lane":
				if not obj.get("state","") in ["sealed","open","recovered"] or not obj.get("route","") in ["resident","culvert","public"] or not obj.get("cargo","") in ["hearth_core","yard_winch"]:return false
			elif obj.kind=="yard_gantry":
				if not obj.get("state","") in ["sealed","ready","complete"]:return false
			elif obj.kind=="yard_recruit":
				if obj.get("state","")!="waiting" or not obj.get("route","") in ["resident","culvert","public"]:return false
			elif obj.kind=="yard_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="kiln":
				if not obj.get("state","") in ["waiting","assigned","built","concealed"] or not obj.get("route","") in ["forage","works","shared"]:return false
			elif obj.kind=="kiln_route":
				if not obj.get("state","") in ["sealed","open","complete"] or not obj.get("route","") in ["forage","works","shared"]:return false
			elif obj.kind=="kiln_option":
				if not obj.get("state","") in ["sealed","available","built","concealed"]:return false
			elif obj.kind=="kiln_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="junction":
				if not obj.get("state","") in ["waiting","warning","received","shunted","missed"] or not obj.get("route","") in ["hotline","shadowline"]:return false
			elif obj.kind=="junction_route":
				if not obj.get("state","") in ["sealed","warning","complete"] or not obj.get("route","") in ["hotline","shadowline"]:return false
			elif obj.kind in ["junction_platform","junction_shunt"]:
				if not obj.get("state","") in ["sealed","warning","received","shunted","missed"]:return false
			elif obj.kind=="junction_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="wayfarer":
				if not obj.get("state","") in ["waiting","assigned","resident","hidden","public"] or not obj.get("route","") in ["resident","hidden","public"]:return false
			elif obj.kind=="wayfarer_route":
				if not obj.get("state","") in ["sealed","open","complete"] or not obj.get("route","") in ["resident","hidden","public"]:return false
			elif obj.kind=="wayfarer_cache":
				if not obj.get("state","") in ["sealed","open","installed"]:return false
			elif obj.kind=="wayfarer_repair":
				if not obj.get("state","") in ["sealed","available","complete"]:return false
			elif obj.kind=="wayfarer_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
			elif obj.kind=="underway":
				if not obj.get("state","") in ["waiting","assigned","lit","hidden"] or not obj.get("route","") in ["resident","hidden","public"]:return false
			elif obj.kind=="underway_route":
				if not obj.get("state","") in ["sealed","open","complete"] or not obj.get("route","") in ["resident","hidden","public"]:return false
			elif obj.kind=="underway_cache":
				if not obj.get("state","") in ["sealed","open","installed"]:return false
			elif obj.kind in ["underway_light","underway_hide"]:
				if not obj.get("state","") in ["sealed","available","complete"]:return false
			elif obj.kind=="underway_exit":
				if not obj.get("state","") in ["sealed","open"]:return false
		var pump_marks=f.landmarks.filter(func(mark):return mark.get("kind","")=="pump_console")
		if not pump_marks.is_empty():
			var routes=f.landmarks.filter(func(mark):return mark.get("kind","")=="flooded_route")
			if pump_marks.size()!=1 or routes.size()!=2:return false
			var pump_state=str(pump_marks[0].state)
			for branch in ["residences","substation"]:
				var matching=routes.filter(func(mark):return mark.get("branch","")==branch)
				if matching.size()!=1:return false
				var expected="flooded" if pump_state=="idle" else "drained" if pump_state==branch else "sealed"
				if matching[0].state!=expected:return false
		for room in f.rooms:
			if not room is Array or room.size()!=4: return false
			for i in 4:
				if not _integer(room[i]): return false
				room[i] = int(room[i])
	if saved.next_id <= largest_id: return false
	for pawn_index in saved.pawns.size():
		var p=saved.pawns[pawn_index]
		if not _position_valid(p) or not _integer(p.get("z",null)) or not saved.floors.has(str(int(p.z))): return false
		for k in ["x","y","z"]: p[k] = int(p[k])
		if not _materials_valid(p.get("inventory",null)) or weight(p.inventory) > CAPACITY + 0.01: return false
		if not p.has("fatigue"):p.fatigue=0.0
		if not p.has("morale"):p.morale=60.0
		if not p.has("bonds"):p.bonds={}
		if not p.has("memories"):p.memories=[]
		for field in ["hp","hunger","fatigue","morale"]:
			if not p.get(field,null) is float and not p.get(field,null) is int: return false
			if not is_finite(p[field]) or p[field] < 0 or p[field] > 100: return false
		if not p.bonds is Dictionary:return false
		for other_name in p.bonds:
			if not other_name is String or not _integer(p.bonds[other_name]) or int(p.bonds[other_name])<0 or int(p.bonds[other_name])>100:return false
			p.bonds[other_name]=int(p.bonds[other_name])
		if not p.memories is Array or p.memories.size()>6:return false
		for memory in p.memories:
			if not memory is Dictionary or not memory.get("kind","") in MEMORY_KINDS:return false
			if not memory.get("with",null) is String or not memory.get("text",null) is String or memory.text.length()>160:return false
			if not _integer(memory.get("depth",null)) or not saved.floors.has(str(int(memory.depth))):return false
			if not _integer(memory.get("value",null)) or int(memory.value)<-25 or int(memory.value)>10:return false
			if not memory.get("time",null) is float and not memory.get("time",null) is int:return false
			if not is_finite(float(memory.time)) or float(memory.time)<0 or float(memory.time)>float(saved.seconds):return false
			memory.depth=int(memory.depth);memory.value=int(memory.value);memory.time=float(memory.time)
		if not p.get("name",null) is String or not p.get("color",null) is String or not p.get("drafted",null) is bool: return false
		if not p.has("injury"):p.injury=0
		if not _integer(p.injury) or int(p.injury)<0 or int(p.injury)>=INJURY_LEVELS.size():return false
		p.injury=int(p.injury)
		if not p.has("bed_id"):p.bed_id=-1
		if not _integer(p.bed_id) or int(p.bed_id)<-1:return false
		p.bed_id=int(p.bed_id)
		if not p.has("equipment"):p.equipment={"body":""}
		if not p.equipment is Dictionary or not p.equipment.get("body",null) is String or not p.equipment.body in ["","armor"]:return false
		for slot in p.equipment:
			if slot!="body":return false
		if not p.get("skills",null) is Dictionary: return false
		for skill in ["scavenge","build","combat"]:
			if not _integer(p.skills.get(skill,null)) or p.skills[skill] < 0: return false
			p.skills[skill] = int(p.skills[skill])
		if not p.has("work"):p.work={"haul":1,"build":1}
		if not p.work is Dictionary:return false
		for role in p.work:
			if not role in ["haul","build"]:return false
		for role in ["haul","build"]:
			if not _integer(p.work.get(role,null)) or int(p.work[role])<0 or int(p.work[role])>=WORK_LEVELS.size():return false
			p.work[role]=int(p.work[role])
		if not p.has("orders"): p.orders=[]
		if not p.orders is Array or p.orders.size()>5:return false
		for order in p.orders:
			if not _order_valid(order,saved.floors):return false
			if order.kind=="retreat":
				if not order.extra.members.has(pawn_index):return false
				for member in order.extra.members:
					if int(member)>=saved.pawns.size():return false
			elif order.kind in ["rescue","tend"]:
				if int(order.extra.patient)>=saved.pawns.size() or int(order.extra.patient)==pawn_index:return false
				var order_bed={}
				for structure in saved.floors[str(int(order.z))].structures:
					if int(structure.id)==int(order.extra.bed):order_bed=structure;break
				if order_bed.is_empty() or order_bed.kind!="bed":return false
		p.job = {}; p.move_clock = 0.0; p.attack_clock = 0.0; p.facing = int(p.get("facing",1))
	var pawn_name_counts:Dictionary={}
	for pawn in saved.pawns:pawn_name_counts[pawn.name]=int(pawn_name_counts.get(pawn.name,0))+1
	for pawn in saved.pawns:
		if int(pawn.bed_id)>0:
			var assigned_bed={}
			for structure in saved.floors[str(int(pawn.z))].structures:
				if int(structure.id)==int(pawn.bed_id):assigned_bed=structure;break
			if assigned_bed.is_empty() or assigned_bed.kind!="bed" or point(assigned_bed)!=point(pawn) or not incapacitated(pawn):return false
		for other_name in pawn.bonds:
			if other_name==pawn.name or int(pawn_name_counts.get(other_name,0))!=1:return false
		for memory in pawn.memories:
			if memory.with==pawn.name or int(pawn_name_counts.get(memory.with,0))!=1:return false
	var vale_count=saved.pawns.filter(func(pawn):return pawn.name=="Vale").size()
	if saved.recruit_joined!=bool(vale_count==1) or vale_count>1 or (saved.recruit_joined and not saved.station_met):return false
	var tavi_count=saved.pawns.filter(func(pawn):return pawn.name=="Tavi").size()
	if saved.market_recruit_joined!=bool(tavi_count==1) or tavi_count>1:return false
	var pell_count=saved.pawns.filter(func(pawn):return pawn.name=="Pell").size()
	if saved.yard_recruit_joined!=bool(pell_count==1) or pell_count>1:return false
	var kest_count=saved.pawns.filter(func(pawn):return pawn.name=="Kest").size()
	if saved.shieldline_recruit_joined!=bool(kest_count==1) or kest_count>1:return false
	if saved.floors.has("1"):_add_waystation(saved.floors["1"],saved.recruit_joined)
	if saved.floors.has("5"):
		var outpost_marks=saved.floors["5"].landmarks.filter(func(mark):return mark.get("kind","")=="outpost")
		if outpost_marks.size()>1:return false
		if not outpost_marks.is_empty():
			var expected_state=saved.outpost_choice if saved.outpost_choice!="" else "waiting"
			if outpost_marks[0].state!=expected_state:return false
		_add_outpost(saved.floors["5"],saved.outpost_choice)
	if saved.floors.has("7"):
		var bellwether_marks=saved.floors["7"].landmarks.filter(func(mark):return mark.get("kind","")=="bellwether")
		if bellwether_marks.size()>1:return false
		if not bellwether_marks.is_empty():
			var expected_bellwether=saved.bellwether_choice if saved.bellwether_choice!="" else "waiting"
			if bellwether_marks[0].state!=expected_bellwether:return false
		_add_bellwether(saved.floors["7"],saved.bellwether_choice)
	if saved.floors.has("9"):
		var spindle_marks=saved.floors["9"].landmarks.filter(func(mark):return mark.get("kind","")=="spindle")
		if spindle_marks.size()>1:return false
		if not spindle_marks.is_empty():
			var expected_spindle=saved.spindle_contact if saved.spindle_contact!="" else "waiting"
			if spindle_marks[0].state!=expected_spindle:return false
		_add_spindle(saved.floors["9"],saved.spindle_contact,saved.bellwether_choice)
	if saved.floors.has("11"):
		var ashline_marks=saved.floors["11"].landmarks.filter(func(mark):return mark.get("kind","")=="ashline")
		if ashline_marks.size()>1:return false
		if not ashline_marks.is_empty():
			var expected_ashline=saved.ashline_state if saved.ashline_state!="" else "waiting"
			if ashline_marks[0].state!=expected_ashline:return false
		_add_ashline(saved.floors["11"],saved.ashline_state)
	if saved.floors.has("12"):
		var service_marks=saved.floors["12"].landmarks.filter(func(mark):return mark.get("kind","")=="service_ring")
		if service_marks.size()>1:return false
		if not service_marks.is_empty():
			var expected_service=saved.service_choice if saved.service_choice!="" else "waiting"
			if service_marks[0].state!=expected_service:return false
		_add_service_ring(saved.floors["12"],saved.service_choice)
	if saved.floors.has("13"):
		var foundry_marks=saved.floors["13"].landmarks.filter(func(mark):return mark.get("kind","")=="foundry")
		if foundry_marks.size()>1:return false
		if not foundry_marks.is_empty():
			var expected_foundry=saved.foundry_state if saved.foundry_state!="" else "waiting"
			if foundry_marks[0].state!=expected_foundry:return false
		_add_foundry(saved.floors["13"],saved.foundry_state,saved.service_choice)
	if saved.floors.has("14"):
		var archive_marks=saved.floors["14"].landmarks.filter(func(mark):return mark.get("kind","")=="archive")
		if archive_marks.size()>1:return false
		if not archive_marks.is_empty():
			var expected_archive=saved.archive_choice if saved.archive_choice!="" else "waiting"
			if archive_marks[0].state!=expected_archive:return false
		_add_archive(saved.floors["14"],saved.archive_choice)
	if saved.floors.has("15"):
		var wake_marks=saved.floors["15"].landmarks.filter(func(mark):return mark.get("kind","")=="wake")
		if wake_marks.size()>1:return false
		if not wake_marks.is_empty():
			var expected_wake=saved.wake_state if saved.wake_state!="" else "waiting"
			if wake_marks[0].state!=expected_wake:return false
		_add_wake(saved.floors["15"],saved.wake_state,saved.archive_choice)
	if saved.floors.has("16"):
		var quiet_receivers=saved.floors["16"].landmarks.filter(func(mark):return mark.get("kind","")=="quiet_receiver")
		if quiet_receivers.size()>1:return false
		_add_quiet(saved.floors["16"],saved.quiet_state)
	if saved.floors.has("17"):
		var stillworks_marks=saved.floors["17"].landmarks.filter(func(mark):return mark.get("kind","")=="stillworks")
		if stillworks_marks.size()>1:return false
		_add_stillworks(saved.floors["17"],saved.stillworks_choice)
	if saved.floors.has("18"):
		var cistern_marks=saved.floors["18"].landmarks.filter(func(mark):return mark.get("kind","")=="cistern")
		if cistern_marks.size()>1:return false
		_add_cistern(saved.floors["18"],saved.cistern_state)
	if saved.floors.has("19"):
		var drowned_controls=saved.floors["19"].landmarks.filter(func(mark):return mark.get("kind","")=="drowned_control")
		if drowned_controls.size()>1:return false
		if not drowned_controls.is_empty():
			var expected_drowned=saved.drowned_state if saved.drowned_state!="" else "waiting"
			if drowned_controls[0].state!=expected_drowned:return false
		_add_drowned(saved.floors["19"],saved.drowned_state)
	if saved.floors.has("20"):
		var tidecourt_marks=saved.floors["20"].landmarks.filter(func(mark):return mark.get("kind","")=="tidecourt")
		if tidecourt_marks.size()>1:return false
		if not tidecourt_marks.is_empty():
			var expected_tidecourt=saved.tidecourt_state if saved.tidecourt_state!="" else "waiting"
			if tidecourt_marks[0].state!=expected_tidecourt:return false
		_add_tidecourt(saved.floors["20"],saved.tidecourt_state,saved.drowned_state)
	if saved.floors.has("21"):
		var sump_marks=saved.floors["21"].landmarks.filter(func(mark):return mark.get("kind","")=="sump")
		if sump_marks.size()>1:return false
		if not sump_marks.is_empty():
			var expected_sump=saved.sump_state if saved.sump_state!="" else "waiting"
			if sump_marks[0].state!=expected_sump:return false
		_add_sump(saved.floors["21"],saved.sump_state,saved.tidecourt_state)
	if saved.floors.has("22"):
		var market_marks=saved.floors["22"].landmarks.filter(func(mark):return mark.get("kind","")=="market")
		if market_marks.size()>1:return false
		if not market_marks.is_empty():
			var expected_market=saved.market_state if saved.market_state!="" else "waiting"
			if market_marks[0].state!=expected_market:return false
		_add_market(saved.floors["22"],saved.market_state,saved.sump_state,saved.market_recruit_joined)
	if saved.floors.has("23"):
		var depot_marks=saved.floors["23"].landmarks.filter(func(mark):return mark.get("kind","")=="depot")
		if depot_marks.size()>1:return false
		if not depot_marks.is_empty():
			var expected_depot=saved.depot_state if saved.depot_state!="" else "waiting"
			if depot_marks[0].state!=expected_depot:return false
		_add_depot(saved.floors["23"],saved.depot_state,saved.market_state)
	if saved.floors.has("24"):
		var refuge_marks=saved.floors["24"].landmarks.filter(func(mark):return mark.get("kind","")=="refuge")
		if refuge_marks.size()>1:return false
		if not refuge_marks.is_empty():
			var expected_refuge=saved.refuge_state if saved.refuge_state!="" else "waiting"
			if refuge_marks[0].state!=expected_refuge:return false
		_add_refuge(saved.floors["24"],saved.refuge_state,saved.depot_state)
		saved.floors["24"].name=theme_for(24)
	if saved.floors.has("25"):
		var ashrail_marks=saved.floors["25"].landmarks.filter(func(mark):return mark.get("kind","")=="ashrail")
		if ashrail_marks.size()>1:return false
		if not ashrail_marks.is_empty():
			var expected_ashrail="stocked" if saved.ashrail_state=="stocked" else "waiting"
			if ashrail_marks[0].state!=expected_ashrail or ashrail_marks[0].route!=_ashrail_route(saved.refuge_state):return false
		_add_ashrail(saved.floors["25"],saved.ashrail_state,saved.refuge_state)
		saved.floors["25"].name=theme_for(25)
	if saved.floors.has("26"):
		var customs_marks=saved.floors["26"].landmarks.filter(func(mark):return mark.get("kind","")=="customs")
		if customs_marks.size()>1:return false
		if not customs_marks.is_empty():
			var expected_customs=saved.customs_state if saved.customs_state!="" else "waiting"
			if customs_marks[0].state!=expected_customs or customs_marks[0].cargo!=_customs_cargo(saved.refuge_state):return false
		_add_customs(saved.floors["26"],saved.customs_state,saved.refuge_state)
		saved.floors["26"].name=theme_for(26)
	if saved.floors.has("27"):
		var railcourt_marks=saved.floors["27"].landmarks.filter(func(mark):return mark.get("kind","")=="railcourt")
		if railcourt_marks.size()>1:return false
		if not railcourt_marks.is_empty():
			var expected_railcourt=saved.railcourt_state if saved.railcourt_state!="" else "waiting"
			if railcourt_marks[0].state!=expected_railcourt or railcourt_marks[0].route!=_railcourt_route(saved.customs_state):return false
		_add_railcourt(saved.floors["27"],saved.railcourt_state,saved.customs_state)
		saved.floors["27"].name=theme_for(27)
	if saved.floors.has("28"):
		var registry_marks=saved.floors["28"].landmarks.filter(func(mark):return mark.get("kind","")=="registry")
		if registry_marks.size()>1:return false
		if not registry_marks.is_empty():
			var expected_registry=saved.registry_state if saved.registry_state!="" else "waiting"
			if registry_marks[0].state!=expected_registry or registry_marks[0].route!=_registry_route(saved.railcourt_state):return false
		_add_registry(saved.floors["28"],saved.registry_state,saved.railcourt_state)
		saved.floors["28"].name=theme_for(28)
	if saved.floors.has("29"):
		var morrow_marks=saved.floors["29"].landmarks.filter(func(mark):return mark.get("kind","")=="morrow")
		if morrow_marks.size()>1:return false
		if not morrow_marks.is_empty():
			var expected_morrow=saved.morrow_state if saved.morrow_state!="" else "waiting"
			if morrow_marks[0].state!=expected_morrow or morrow_marks[0].route!=_morrow_route(saved.registry_state):return false
		_add_morrow(saved.floors["29"],saved.morrow_state,saved.registry_state)
		saved.floors["29"].name=theme_for(29)
	if saved.floors.has("30"):
		var terminus_marks=saved.floors["30"].landmarks.filter(func(mark):return mark.get("kind","")=="terminus")
		if terminus_marks.size()>1:return false
		if not terminus_marks.is_empty():
			var expected_terminus=saved.terminus_state if saved.terminus_state!="" else "waiting"
			if terminus_marks[0].state!=expected_terminus or terminus_marks[0].route!=_terminus_route(saved.morrow_state):return false
		_add_terminus(saved.floors["30"],saved.terminus_state,saved.morrow_state)
		saved.floors["30"].name=theme_for(30)
	if saved.floors.has("31"):
		var farline_marks=saved.floors["31"].landmarks.filter(func(mark):return mark.get("kind","")=="farline")
		if farline_marks.size()>1:return false
		if not farline_marks.is_empty():
			var expected_farline=saved.farline_state if saved.farline_state!="" else "waiting"
			if farline_marks[0].state!=expected_farline or farline_marks[0].route!=_farline_route(saved.terminus_state):return false
		_add_farline(saved.floors["31"],saved.farline_state,saved.terminus_state)
		saved.floors["31"].name=theme_for(31)
	if saved.floors.has("32"):
		var thimble_marks=saved.floors["32"].landmarks.filter(func(mark):return mark.get("kind","")=="thimble")
		if thimble_marks.size()>1:return false
		if not thimble_marks.is_empty():
			var expected_thimble=saved.thimble_state if saved.thimble_state!="" else "waiting"
			if thimble_marks[0].state!=expected_thimble or thimble_marks[0].route!=_thimble_route(saved.farline_state):return false
		_add_thimble(saved.floors["32"],saved.thimble_state,saved.farline_state)
		saved.floors["32"].name=theme_for(32)
	if saved.floors.has("33"):
		var latchwater_marks=saved.floors["33"].landmarks.filter(func(mark):return mark.get("kind","")=="latchwater")
		if latchwater_marks.size()>1:return false
		if not latchwater_marks.is_empty():
			var expected_latchwater=saved.latchwater_state if saved.latchwater_state!="" else "waiting"
			if latchwater_marks[0].state!=expected_latchwater or latchwater_marks[0].route!=_latchwater_route(saved.thimble_state):return false
		saved.floors["33"].name=theme_for(33)
		_add_latchwater(saved.floors["33"],saved.latchwater_state,saved.thimble_state)
	if saved.floors.has("34"):
		var driftglass_marks=saved.floors["34"].landmarks.filter(func(mark):return mark.get("kind","")=="driftglass")
		if driftglass_marks.size()>1:return false
		if not driftglass_marks.is_empty():
			var expected_driftglass=saved.driftglass_state if saved.driftglass_state!="" else "waiting"
			if driftglass_marks[0].state!=expected_driftglass or driftglass_marks[0].route!=_driftglass_route(saved.latchwater_state):return false
		saved.floors["34"].name=theme_for(34)
		_add_driftglass(saved.floors["34"],saved.driftglass_state,saved.latchwater_state)
	if saved.floors.has("35"):
		var bellhome_marks=saved.floors["35"].landmarks.filter(func(mark):return mark.get("kind","")=="bellhome")
		if bellhome_marks.size()>1:return false
		if not bellhome_marks.is_empty():
			var expected_bellhome=saved.bellhome_state if saved.bellhome_state!="" else "waiting"
			if bellhome_marks[0].state!=expected_bellhome or bellhome_marks[0].route!=_bellhome_route(saved.driftglass_state):return false
		saved.floors["35"].name=theme_for(35)
		_add_bellhome(saved.floors["35"],saved.bellhome_state,saved.driftglass_state)
	if saved.floors.has("36"):
		var commons_marks=saved.floors["36"].landmarks.filter(func(mark):return mark.get("kind","")=="commons")
		if commons_marks.size()>1:return false
		if not commons_marks.is_empty():
			var expected_commons=saved.commons_state if saved.commons_state!="" else "waiting"
			if commons_marks[0].state!=expected_commons or commons_marks[0].route!=_commons_route(saved.bellhome_state):return false
		saved.floors["36"].name=theme_for(36)
		_add_commons(saved.floors["36"],saved.commons_state,saved.bellhome_state)
	if saved.floors.has("37"):
		var yard_marks=saved.floors["37"].landmarks.filter(func(mark):return mark.get("kind","")=="yard")
		if yard_marks.size()>1:return false
		if not yard_marks.is_empty():
			var expected_yard=saved.yard_state if saved.yard_state!="" else "waiting"
			if yard_marks[0].state!=expected_yard or yard_marks[0].route!=_yard_route(saved.commons_state):return false
		saved.floors["37"].name=theme_for(37)
		_add_yard(saved.floors["37"],saved.yard_state,saved.commons_state,saved.yard_recruit_joined)
	if saved.floors.has("38"):
		var kiln_marks=saved.floors["38"].landmarks.filter(func(mark):return mark.get("kind","")=="kiln")
		if kiln_marks.size()>1:return false
		if not kiln_marks.is_empty():
			var expected_kiln=saved.kiln_state if saved.kiln_state!="" else "waiting"
			if kiln_marks[0].state!=expected_kiln or kiln_marks[0].route!=_kiln_route(saved.yard_state):return false
		saved.floors["38"].name=theme_for(38)
		_add_kiln(saved.floors["38"],saved.kiln_state,saved.yard_state)
	if saved.floors.has("39"):
		var junction_marks=saved.floors["39"].landmarks.filter(func(mark):return mark.get("kind","")=="junction")
		if junction_marks.size()>1:return false
		if not junction_marks.is_empty():
			var expected_junction=saved.junction_state if saved.junction_state!="" else "waiting"
			if junction_marks[0].state!=expected_junction or junction_marks[0].route!=_junction_route(saved.kiln_state):return false
		saved.floors["39"].name=theme_for(39)
		_add_junction(saved.floors["39"],saved.junction_state,saved.kiln_state)
	if saved.floors.has("40"):
		var ember_marks=saved.floors["40"].landmarks.filter(func(mark):return mark.get("kind","")=="ember_commons")
		if ember_marks.size()>1:return false
		if not ember_marks.is_empty():
			var expected_ember=saved.ember_commons_state if saved.ember_commons_state!="" else "waiting"
			if ember_marks[0].state!=expected_ember or ember_marks[0].route!=_ember_commons_route(saved.junction_state):return false
		saved.floors["40"].name=theme_for(40)
		_add_ember_commons(saved.floors["40"],saved.ember_commons_state,saved.junction_state)
	if saved.floors.has("41"):
		var deepcoil_marks=saved.floors["41"].landmarks.filter(func(mark):return mark.get("kind","")=="deepcoil")
		if deepcoil_marks.size()>1:return false
		if not deepcoil_marks.is_empty():
			var expected_deepcoil=saved.deepcoil_state if saved.deepcoil_state!="" else "waiting"
			if deepcoil_marks[0].state!=expected_deepcoil or deepcoil_marks[0].route!=_deepcoil_route(saved.ember_commons_state):return false
		saved.floors["41"].name=theme_for(41)
		_add_deepcoil(saved.floors["41"],saved.deepcoil_state,saved.ember_commons_state)
	if saved.floors.has("42"):
		var coilward_marks=saved.floors["42"].landmarks.filter(func(mark):return mark.get("kind","")=="coilward")
		if coilward_marks.size()>1:return false
		if not coilward_marks.is_empty():
			var expected_coilward=saved.coilward_state if saved.coilward_state!="" else "waiting"
			if coilward_marks[0].state!=expected_coilward or coilward_marks[0].route!=_coilward_route(saved.deepcoil_state):return false
		saved.floors["42"].name=theme_for(42)
		_add_coilward(saved.floors["42"],saved.coilward_state,saved.deepcoil_state)
	if saved.floors.has("43"):
		var charterwell_marks=saved.floors["43"].landmarks.filter(func(mark):return mark.get("kind","")=="charterwell")
		if charterwell_marks.size()>1:return false
		if not charterwell_marks.is_empty():
			var expected_charterwell=saved.charterwell_state if saved.charterwell_state!="" else "waiting"
			if charterwell_marks[0].state!=expected_charterwell or charterwell_marks[0].route!=_charterwell_route(saved.coilward_state):return false
		saved.floors["43"].name=theme_for(43)
		_add_charterwell(saved.floors["43"],saved.charterwell_state,saved.coilward_state)
	if saved.floors.has("44"):
		var writwell_marks=saved.floors["44"].landmarks.filter(func(mark):return mark.get("kind","")=="writwell")
		if writwell_marks.size()>1:return false
		if not writwell_marks.is_empty():
			var expected_writwell=saved.writwell_state if saved.writwell_state!="" else "waiting"
			if writwell_marks[0].state!=expected_writwell or writwell_marks[0].route!=_writwell_route(saved.charterwell_state):return false
		saved.floors["44"].name=theme_for(44)
		_add_writwell(saved.floors["44"],saved.writwell_state,saved.charterwell_state)
	if saved.floors.has("45"):
		var concordance_marks=saved.floors["45"].landmarks.filter(func(mark):return mark.get("kind","")=="concordance")
		if concordance_marks.size()>1:return false
		if not concordance_marks.is_empty():
			var expected_concordance=saved.concordance_state if saved.concordance_state!="" else "waiting"
			if concordance_marks[0].state!=expected_concordance or concordance_marks[0].route!=_concordance_route(saved.writwell_state):return false
		saved.floors["45"].name=theme_for(45)
		_add_concordance(saved.floors["45"],saved.concordance_state,saved.writwell_state)
	if saved.floors.has("46"):
		var reservefall_marks=saved.floors["46"].landmarks.filter(func(mark):return mark.get("kind","")=="reservefall")
		if reservefall_marks.size()>1:return false
		if not reservefall_marks.is_empty():
			var expected_reservefall=saved.reservefall_state if saved.reservefall_state!="" else "waiting"
			if reservefall_marks[0].state!=expected_reservefall or reservefall_marks[0].route!=_reservefall_route(saved.concordance_state):return false
		saved.floors["46"].name=theme_for(46)
		_add_reservefall(saved.floors["46"],saved.reservefall_state,saved.concordance_state)
	if saved.floors.has("47"):
		var reserve_commons_marks=saved.floors["47"].landmarks.filter(func(mark):return mark.get("kind","")=="reserve_commons")
		if reserve_commons_marks.size()>1:return false
		if not reserve_commons_marks.is_empty():
			var expected_reserve_commons=saved.reserve_commons_state if saved.reserve_commons_state!="" else "waiting"
			if reserve_commons_marks[0].state!=expected_reserve_commons or reserve_commons_marks[0].route!=_reserve_commons_route(saved.reservefall_state):return false
		saved.floors["47"].name=theme_for(47)
		_add_reserve_commons(saved.floors["47"],saved.reserve_commons_state,saved.reservefall_state)
	if saved.floors.has("48"):
		var shieldline_marks=saved.floors["48"].landmarks.filter(func(mark):return mark.get("kind","")=="shieldline")
		if shieldline_marks.size()>1:return false
		if not shieldline_marks.is_empty():
			var expected_shieldline=saved.shieldline_state if saved.shieldline_state!="" else "waiting"
			if shieldline_marks[0].state!=expected_shieldline or shieldline_marks[0].route!=_shieldline_route(saved.reserve_commons_state):return false
		saved.floors["48"].name=theme_for(48)
		_add_shieldline(saved.floors["48"],saved.shieldline_state,saved.reserve_commons_state,saved.shieldline_recruit_joined)
	if saved.floors.has("49"):
		var marchhold_marks=saved.floors["49"].landmarks.filter(func(mark):return mark.get("kind","")=="marchhold")
		if marchhold_marks.size()>1:return false
		if not marchhold_marks.is_empty():
			var expected_marchhold=saved.marchhold_state if saved.marchhold_state!="" else "waiting"
			if marchhold_marks[0].state!=expected_marchhold or marchhold_marks[0].route!=_marchhold_route(saved.shieldline_state):return false
		saved.floors["49"].name=theme_for(49)
		_add_marchhold(saved.floors["49"],saved.marchhold_state,saved.shieldline_state)
	if saved.floors.has("50"):
		var march_refuge_marks=saved.floors["50"].landmarks.filter(func(mark):return mark.get("kind","")=="march_refuge")
		if march_refuge_marks.size()>1:return false
		if not march_refuge_marks.is_empty():
			var expected_march_refuge=saved.march_refuge_state if saved.march_refuge_state!="" else "waiting"
			if march_refuge_marks[0].state!=expected_march_refuge or march_refuge_marks[0].route!=_march_refuge_route(saved.marchhold_state):return false
		saved.floors["50"].name=theme_for(50)
		_add_march_refuge(saved.floors["50"],saved.march_refuge_state,saved.marchhold_state)
	if saved.floors.has("51"):
		var wallward_marks=saved.floors["51"].landmarks.filter(func(mark):return mark.get("kind","")=="wallward")
		if wallward_marks.size()>1:return false
		if not wallward_marks.is_empty():
			var expected_wallward=saved.wallward_state if saved.wallward_state!="" else "waiting"
			if wallward_marks[0].state!=expected_wallward or wallward_marks[0].route!=_wallward_route(saved.march_refuge_state):return false
		saved.floors["51"].name=theme_for(51)
		_add_wallward(saved.floors["51"],saved.wallward_state,saved.march_refuge_state)
	if saved.floors.has("52"):
		var wayfarer_marks=saved.floors["52"].landmarks.filter(func(mark):return mark.get("kind","")=="wayfarer")
		if wayfarer_marks.size()>1:return false
		if not wayfarer_marks.is_empty():
			var expected_wayfarer=saved.wayfarer_state if saved.wayfarer_state!="" else "waiting"
			if wayfarer_marks[0].state!=expected_wayfarer or wayfarer_marks[0].route!=_wayfarer_route(saved.wallward_state):return false
		saved.floors["52"].name=theme_for(52)
		_add_wayfarer(saved.floors["52"],saved.wayfarer_state,saved.wallward_state)
	if saved.floors.has("53"):
		var underway_marks=saved.floors["53"].landmarks.filter(func(mark):return mark.get("kind","")=="underway")
		if underway_marks.size()>1:return false
		if not underway_marks.is_empty():
			var expected_underway=saved.underway_state if saved.underway_state!="" else "waiting"
			if underway_marks[0].state!=expected_underway or underway_marks[0].route!=_underway_route(saved.wayfarer_state):return false
		saved.floors["53"].name=theme_for(53)
		_add_underway(saved.floors["53"],saved.underway_state,saved.wayfarer_state)
	data = saved
	navigation_cache.clear()
	data.paused = true
	events.clear()
	reveal_all()
	return true
