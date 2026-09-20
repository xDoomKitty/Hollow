extends Control
signal tile_clicked(tile: Vector2i, right: bool)
var world: HollowWorld
var selected = 0
var depth = 0
var zoom = 1.0
var focus = Vector2(7,7)
var follow = true
var building = ""
var hovered = Vector2i(-1,-1)
var press = Vector2.ZERO
var last_pointer = Vector2.ZERO
var dragging = false
var held = false
var clock = 0.0
var font = ThemeDB.fallback_font
const TILE = 40.0
const PALETTES = [[Color("222e2d"),Color("3f4944"),Color("92a184")],[Color("233238"),Color("43555a"),Color("9cafac")],[Color("302a26"),Color("574b3b"),Color("b09a71")],[Color("223134"),Color("3f5556"),Color("74aea3")],[Color("302c34"),Color("564b54"),Color("b9a1ad")]]

func _ready():
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_input_map)

func _process(dt):
	clock += dt
	if world and follow and selected < world.data.pawns.size():
		var p = world.data.pawns[selected]
		if p.z == depth: focus = focus.lerp(Vector2(p.x+0.5,p.y+0.5),min(1.0,dt*10))
	queue_redraw()

func screen(p: Vector2) -> Vector2:
	return (p-focus)*TILE*zoom+size*0.5

func tile_at(pos: Vector2) -> Vector2i:
	return Vector2i(((pos-size*0.5)/(TILE*zoom)+focus).floor())

func _input_map(event):
	if event is InputEventMouseButton:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN] and event.pressed:
			zoom = clampf(zoom*(1.12 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.89),0.45,1.8)
		if event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]:
			if event.pressed:
				press = event.position; last_pointer = press; dragging = false; held = true
			else:
				if not held: return
				held = false
				if not dragging: tile_clicked.emit(tile_at(event.position),event.button_index == MOUSE_BUTTON_RIGHT)
	if event is InputEventMouseMotion:
		hovered = tile_at(event.position)
		if held:
			if event.position.distance_to(press) > 7: dragging = true
			if dragging:
				follow = false
				focus -= (event.position-last_pointer)/(TILE*zoom)
				focus = focus.clamp(Vector2.ZERO,Vector2(HollowWorld.W,HollowWorld.H))
			last_pointer = event.position

func label_at(p: Vector2, text: String, color: Color, small: int = 14):
	var width = font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,small).x
	draw_rect(Rect2(p+Vector2(-width/2-5,-small),Vector2(width+10,small+6)),Color(0.025,0.04,0.04,0.9))
	draw_string(font,p+Vector2(-width/2,0),text,HORIZONTAL_ALIGNMENT_LEFT,-1,small,color)

func _draw():
	draw_rect(Rect2(Vector2.ZERO,size),Color("0c1316"))
	if not world: return
	var f = world.floor_at(depth)
	var palette = PALETTES[depth%5]
	var t = TILE*zoom
	var first = tile_at(Vector2.ZERO)-Vector2i.ONE
	var last = tile_at(size)+Vector2i.ONE
	for y in range(max(0,first.y),min(HollowWorld.H,last.y+1)):
		for x in range(max(0,first.x),min(HollowWorld.W,last.x+1)):
			var at = Vector2i(x,y)
			if not f.seen.has(world.cell_key(at)): continue
			var pos = screen(Vector2(x,y))
			var visible = world.is_visible(depth,at)
			var shade = 1.0 if visible else 0.34
			var hash_value = posmod(x*71+y*139+depth*23,17)
			var base: Color = palette[0]
			base = base.lightened(float(hash_value)/280)
			if f.grid[y][x] == 1:
				draw_rect(Rect2(pos,Vector2(t+0.5,t+0.5)),base*Color(shade,shade,shade,1))
				draw_line(pos+Vector2(0,t-1),pos+Vector2(t,t-1),Color(0.7,0.8,0.75,0.025*shade),1)
				if hash_value % 4 == 0:
					draw_line(pos+Vector2(t*.2,t*.35),pos+Vector2(t*.45,t*.4),Color(0.6,0.65,0.56,0.12*shade),1)
				if depth%5 == 1 and y in [9,10,27,28]:
					var rail=Color(0.58,0.55,0.47,0.48*shade)
					draw_line(pos+Vector2(0,t*.25),pos+Vector2(t,t*.25),rail,2*zoom)
					draw_line(pos+Vector2(0,t*.72),pos+Vector2(t,t*.72),rail,2*zoom)
					if x%2==0:draw_line(pos+Vector2(t*.5,t*.18),pos+Vector2(t*.5,t*.8),Color(0.32,0.27,0.2,0.42*shade),3*zoom)
				if depth%5==1 and y in [12,25]:draw_line(pos+Vector2(0,t*.88),pos+Vector2(t,t*.88),Color(0.86,0.67,0.25,0.42*shade),3*zoom)
				if depth%5==2 and depth!=7 and ((y==9 and x>=14) or (y==26 and x>=7)):
					draw_line(pos+Vector2(0,t*.28),pos+Vector2(t,t*.28),Color(0.53,0.46,0.34,0.45*shade),2*zoom)
					draw_line(pos+Vector2(0,t*.72),pos+Vector2(t,t*.72),Color(0.53,0.46,0.34,0.45*shade),2*zoom)
					if x%2==0:draw_line(pos+Vector2(t*.5,t*.2),pos+Vector2(t*.5,t*.8),Color(0.28,0.24,0.19,0.48*shade),3*zoom)
				if depth%5==2 and depth!=7 and x in [26,27] and y>=12 and y<=28:
					draw_line(pos+Vector2(t*.26,0),pos+Vector2(t*.26,t),Color(0.56,0.48,0.33,0.5*shade),2*zoom)
					draw_line(pos+Vector2(t*.74,0),pos+Vector2(t*.74,t),Color(0.56,0.48,0.33,0.5*shade),2*zoom)
				if depth%5==3 and depth!=13:
					if hash_value%5==0:draw_circle(pos+Vector2(t*.64,t*.38),2.5*zoom,Color(0.45,0.82,0.76,0.24*shade))
					if hash_value%7==0:draw_arc(pos+Vector2(t*.45,t*.6),t*.2,-2.8,-.2,8,Color(0.74,0.83,0.69,0.18*shade),1.5*zoom)
				if depth==13:
					draw_line(pos+Vector2(0,t*.22),pos+Vector2(t,t*.22),Color(0.84,0.38,0.18,0.24*shade),2*zoom)
					draw_line(pos+Vector2(0,t*.78),pos+Vector2(t,t*.78),Color(0.43,0.66,0.63,0.24*shade),2*zoom)
					if (x+y)%4==0:draw_circle(pos+Vector2(t*.5,t*.5),3*zoom,Color(0.92,0.61,0.27,0.24*shade))
				if depth%5 == 4:
					if y in [6,7,25,26]:draw_line(pos+Vector2(0,t*.5),pos+Vector2(t,t*.5),Color(0.58,0.7,0.69,0.2*shade),2*zoom)
					if (x+y)%2==0:draw_rect(Rect2(pos+Vector2.ONE*4*zoom,Vector2.ONE*(t-8*zoom)),Color(0.6,0.45,0.48,0.07*shade))
				if depth==5:
					if (x+y)%3==0:draw_circle(pos+Vector2(t*.5,t*.5),2.2*zoom,Color(0.95,0.68,0.30,0.28*shade))
					if x in [24,25,32,33]:draw_line(pos+Vector2(t*.5,0),pos+Vector2(t*.5,t),Color(0.76,0.78,0.66,0.18*shade),2*zoom)
				if depth==7:
					if x in [27,28,34,35]:draw_line(pos+Vector2(t*.5,0),pos+Vector2(t*.5,t),Color(0.67,0.76,0.71,0.28*shade),2*zoom)
					if y in [8,20,31]:draw_line(pos+Vector2(0,t*.52),pos+Vector2(t,t*.52),Color(0.85,0.66,0.28,0.24*shade),2*zoom)
					if (x+y)%4==0:draw_circle(pos+Vector2(t*.5,t*.5),2.1*zoom,Color(0.83,0.88,0.75,0.24*shade))
			else:
				var wall: Color = palette[1]
				draw_rect(Rect2(pos+Vector2(0,3*zoom),Vector2(t,t)),Color("0a1114"))
				draw_rect(Rect2(pos,Vector2(t,t-5*zoom)),wall*Color(shade,shade,shade,1))
				draw_line(pos+Vector2(2,1)*zoom,pos+Vector2(t-2*zoom,zoom),palette[2]*Color(shade*.7,shade*.7,shade*.7,1),2*zoom)
				draw_line(pos+Vector2(t-1,1),pos+Vector2(t-1,t-7*zoom),Color(0.04,0.06,0.06,0.6),2*zoom)
				if depth%5 in [2,3] and hash_value%6==0:
					draw_colored_polygon(PackedVector2Array([pos+Vector2(.4,.15)*t,pos+Vector2(.57,.5)*t,pos+Vector2(.34,.57)*t]),Color("69afa6")*Color(shade,shade,shade,1))
	for stair in ["up","down"]:
		var p = world.vec(f[stair])
		if not f.seen.has(world.cell_key(p)): continue
		var pos = screen(Vector2(p))
		draw_rect(Rect2(pos+Vector2.ONE*3*zoom,Vector2.ONE*(t-6*zoom)),Color("111c20"))
		for i in 6:
			var width = (t-10*zoom)*(1.0-float(i)*.065)
			draw_rect(Rect2(pos+Vector2(5*zoom,t*.16+i*t*.115),Vector2(width,3*zoom)),Color("7e948e"))
		var text = "SURFACE / SEALED" if stair == "up" and depth == 0 else "UP" if stair == "up" else "DEEPER"
		label_at(pos+Vector2(t/2,-7*zoom),text,Color("9ad6c9"),12)
	for s in f.structures:
		if not f.seen.has(world.cell_key(world.point(s))): continue
		_draw_structure(s,t,world.is_visible(depth,world.point(s)))
	for c in f.containers:
		if not f.seen.has(world.cell_key(world.point(c))):continue
		var pos = screen(Vector2(c.x+.5,c.y+.5))
		var dim = 1.0 if world.is_visible(depth,world.point(c)) else .35
		if c.kind=="blueprint":
			var half=Vector2(15,15)*zoom
			var color=Color("75caba")*Color(dim,dim,dim,.9)
			for edge in [[pos-half,pos+Vector2(half.x,-half.y)],[pos+Vector2(half.x,-half.y),pos+half],[pos+half,pos+Vector2(-half.x,half.y)],[pos+Vector2(-half.x,half.y),pos-half]]:
				draw_dashed_line(edge[0],edge[1],color,2*zoom,5*zoom)
			var supplied=0;var needed=0
			for item in HollowWorld.RECIPES[c.recipe].cost:
				supplied+=min(int(c.items.get(item,0)),int(HollowWorld.RECIPES[c.recipe].cost[item]));needed+=int(HollowWorld.RECIPES[c.recipe].cost[item])
			draw_rect(Rect2(pos+Vector2(-15,18)*zoom,Vector2(30,4)*zoom),Color("18282b"))
			draw_rect(Rect2(pos+Vector2(-15,18)*zoom,Vector2(30*float(supplied)/max(1,needed),4)*zoom),color)
			label_at(pos+Vector2(0,-22)*zoom,str(HollowWorld.RECIPES[c.recipe].name).to_upper()+" "+str(supplied)+"/"+str(needed),color,10)
			continue
		if c.kind == "stockpile":continue
		var color = Color("9e835b") if not c.searched else Color("677e70")
		color *= Color(dim,dim,dim,1)
		draw_circle(pos+Vector2(2,8)*zoom,13*zoom,Color(0,0,0,.3))
		if c.kind == "ground":
			draw_colored_polygon(PackedVector2Array([pos+Vector2(-11,8)*zoom,pos+Vector2(-6,-5)*zoom,pos+Vector2(7,-8)*zoom,pos+Vector2(13,8)*zoom]),color)
		else:
			draw_rect(Rect2(pos-Vector2(13,12)*zoom,Vector2(26,24)*zoom),Color("152024"))
			draw_rect(Rect2(pos-Vector2(12,14)*zoom,Vector2(24,20)*zoom),color)
			draw_line(pos+Vector2(-11,-4)*zoom,pos+Vector2(11,-4)*zoom,Color("d0b886")*Color(dim,dim,dim,1),2*zoom)
			draw_line(pos+Vector2(-6,-13)*zoom,pos+Vector2(-6,5)*zoom,Color("423e30"),2*zoom)
			draw_line(pos+Vector2(6,-13)*zoom,pos+Vector2(6,5)*zoom,Color("423e30"),2*zoom)
		if world.is_visible(depth,world.point(c)):
			if not c.searched:
				label_at(pos+Vector2(0,-21)*zoom,"SEARCH",Color("e8c487"),11)
			elif c.kind != "ground":
				var count=0
				for item in c.items:count+=int(c.items[item])
				label_at(pos+Vector2(0,-21)*zoom,str(count)+" ITEMS",Color("9fc5b4"),10)
	for mark in f.landmarks:
		if not world.is_visible(depth,world.point(mark)): continue
		var pos = screen(Vector2(mark.x+.5,mark.y+.5))
		if mark.kind == "traveler":
			draw_circle(pos+Vector2(0,6)*zoom,11*zoom,Color("070e12"))
			draw_colored_polygon(PackedVector2Array([pos+Vector2(-11,8)*zoom,pos+Vector2(-5,-12)*zoom,pos+Vector2(5,-12)*zoom,pos+Vector2(11,8)*zoom]),Color("82938b"))
			draw_circle(pos+Vector2(0,-11)*zoom,6*zoom,Color("293735"))
			label_at(pos+Vector2(0,-23)*zoom,"TRAVELER",Color("d9decd"),12)
		elif mark.kind=="station":
			draw_rect(Rect2(pos+Vector2(-17,-12)*zoom,Vector2(34,25)*zoom),Color("283b3c"))
			draw_line(pos+Vector2(-15,-9)*zoom,pos+Vector2(15,-9)*zoom,Color("9b7750"),3*zoom)
			draw_circle(pos+Vector2(0,-3)*zoom,5*zoom,Color("e9b65f"))
			label_at(pos+Vector2(0,-24)*zoom,"CINDER WAYSTATION",Color("e4c582"),10)
		elif mark.kind=="recruit":
			draw_circle(pos+Vector2(0,6)*zoom,11*zoom,Color("070e12"))
			draw_colored_polygon(PackedVector2Array([pos+Vector2(-10,8)*zoom,pos+Vector2(-7,-5)*zoom,pos+Vector2(7,-5)*zoom,pos+Vector2(10,8)*zoom]),Color("9b6f55"))
			draw_circle(pos+Vector2(0,-10)*zoom,6*zoom,Color("c4aa8a"))
			label_at(pos+Vector2(0,-22)*zoom,"VALE",Color("d9decd"),11)
		elif mark.kind=="outpost":
			var waiting=mark.get("state","")=="waiting"
			draw_rect(Rect2(pos-Vector2(18,12)*zoom,Vector2(36,25)*zoom),Color("2c3d3b"))
			draw_line(pos+Vector2(-15,-8)*zoom,pos+Vector2(15,-8)*zoom,Color("d7b15c"),3*zoom)
			for bar in [-7,0,7]:draw_line(pos+Vector2(bar,-7)*zoom,pos+Vector2(bar,8)*zoom,Color("d9ddc8"),2*zoom)
			draw_circle(pos+Vector2(0,4)*zoom,5*zoom,Color("f0b857") if waiting else Color("79b8a0"))
			label_at(pos+Vector2(0,-24)*zoom,"LOW LANTERN" if waiting else "COMPACT · "+str(mark.state).to_upper(),Color("ecc878"),10)
		elif mark.kind=="outpost_lore":
			for bar in [-7,0,7]:draw_line(pos+Vector2(bar,-10)*zoom,pos+Vector2(bar,11)*zoom,Color("d9ddc8"),3*zoom)
			draw_circle(pos+Vector2(0,11)*zoom,4*zoom,Color("e4a94f"))
			label_at(pos+Vector2(0,-22)*zoom,"COMPACT MARK",Color("d9d7b9"),10)
		elif mark.kind=="bellwether":
			var waiting=mark.get("state","")=="waiting"
			draw_circle(pos,17*zoom,Color("172b30"))
			draw_circle(pos,12*zoom,Color("657772"))
			draw_line(pos+Vector2(-8,7)*zoom,pos+Vector2(8,-7)*zoom,Color("efbd57") if waiting else Color("72bca5"),4*zoom)
			for bar in [-6,0,6]:draw_line(pos+Vector2(bar,-9)*zoom,pos+Vector2(bar,9)*zoom,Color("d9ddc8"),2*zoom)
			label_at(pos+Vector2(0,-26)*zoom,"LIFT CONTROL" if waiting else str(mark.state).to_upper()+" ROUTE",Color("ecc878"),10)
		elif mark.kind=="bellwether_evidence":
			draw_rect(Rect2(pos-Vector2(12,14)*zoom,Vector2(24,28)*zoom),Color("596764"))
			for i in 4:draw_line(pos+Vector2(-8,-8+i*5)*zoom,pos+Vector2(8,-8+i*5)*zoom,Color("d6d1ac"),1.5*zoom)
			for bar in [-5,0,5]:draw_line(pos+Vector2(bar,9)*zoom,pos+Vector2(bar,14)*zoom,Color("e3e7d4"),2*zoom)
			label_at(pos+Vector2(0,-25)*zoom,"FRESH EVIDENCE",Color("d8d2ab"),10)
		elif mark.kind=="bellwether_route":
			var route_state=str(mark.get("state","sealed"));var route_color=Color("79bda7") if route_state=="open" else Color("5d6664") if route_state=="locked" else Color("d2a857")
			draw_rect(Rect2(pos-Vector2(15,12)*zoom,Vector2(30,24)*zoom),Color("26363a"))
			for bar in [-7,0,7]:draw_line(pos+Vector2(bar,-9)*zoom,pos+Vector2(bar,9)*zoom,route_color,3*zoom)
			label_at(pos+Vector2(0,-23)*zoom,("COURIER" if mark.get("route","")=="courier" else "BYPASS")+" · "+route_state.to_upper(),route_color,9)
		elif mark.kind=="spindle":
			var waiting=mark.get("state","")=="waiting";var gate_color=Color("efbd57") if waiting else Color("78bea9")
			draw_rect(Rect2(pos-Vector2(20,14)*zoom,Vector2(40,28)*zoom),Color("17292e"))
			draw_rect(Rect2(pos-Vector2(15,9)*zoom,Vector2(30,18)*zoom),Color("52666a"))
			for bar in [-9,0,9]:draw_line(pos+Vector2(bar,-9)*zoom,pos+Vector2(bar,9)*zoom,gate_color,3*zoom)
			draw_circle(pos+Vector2(0,1)*zoom,4*zoom,Color("d8e6dc"))
			label_at(pos+Vector2(0,-27)*zoom,"GATE WATCH" if waiting else "MERIDIAN CONTACT",gate_color,10)
		elif mark.kind=="spindle_lore":
			draw_rect(Rect2(pos-Vector2(13,11)*zoom,Vector2(26,22)*zoom),Color("455b60"))
			draw_circle(pos,7*zoom,Color("a9c7c3"))
			for bar in [-4,0,4]:draw_line(pos+Vector2(bar,-6)*zoom,pos+Vector2(bar,6)*zoom,Color("e4eadf"),2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"CITY EVIDENCE",Color("c7ddd5"),9)
		elif mark.kind=="spindle_route":
			var arrived=mark.get("state","")=="arrived";var route_color=Color("78bea9") if arrived else Color("566467")
			draw_line(pos+Vector2(-15,9)*zoom,pos+Vector2(15,9)*zoom,route_color,4*zoom)
			draw_line(pos+Vector2(-15,-8)*zoom,pos+Vector2(-15,9)*zoom,route_color,3*zoom)
			draw_line(pos+Vector2(15,-8)*zoom,pos+Vector2(15,9)*zoom,route_color,3*zoom)
			label_at(pos+Vector2(0,-20)*zoom,("MARKED LANE" if mark.get("route","")=="courier" else "SERVICE INTAKE")+" · "+str(mark.state).to_upper(),route_color,8)
		elif mark.kind=="ashline":
			var ash_state=str(mark.get("state","waiting"));var ash_color=Color("efbd57") if ash_state=="waiting" else Color("75c6b1") if ash_state=="cleared" else Color("dd915f")
			draw_rect(Rect2(pos-Vector2(19,13)*zoom,Vector2(38,26)*zoom),Color("1b2d31"))
			draw_rect(Rect2(pos-Vector2(14,8)*zoom,Vector2(28,16)*zoom),Color("728184"))
			for bar in [-8,0,8]:draw_line(pos+Vector2(bar,-8)*zoom,pos+Vector2(bar,8)*zoom,ash_color,3*zoom)
			draw_line(pos+Vector2(-14,0)*zoom,pos+Vector2(14,0)*zoom,Color("dce6df"),2*zoom)
			label_at(pos+Vector2(0,-26)*zoom,"ASHLINE" if ash_state=="waiting" else "REQUEST" if ash_state=="assigned" else "CLEARED",ash_color,10)
		elif mark.kind=="ashline_lore":
			draw_rect(Rect2(pos-Vector2(13,12)*zoom,Vector2(26,24)*zoom),Color("536468"))
			for i in 3:draw_line(pos+Vector2(-8,-6+i*6)*zoom,pos+Vector2(8,-6+i*6)*zoom,Color("d9e2dc"),1.5*zoom)
			draw_circle(pos+Vector2(9,-8)*zoom,3*zoom,Color("e2ae5b"))
			label_at(pos+Vector2(0,-22)*zoom,"QUARANTINE",Color("c7ddd5"),9)
		elif mark.kind=="ashline_route":
			var route_open=mark.get("state","")=="open";var ash_route_color=Color("72c4ad") if route_open else Color("806459")
			draw_rect(Rect2(pos-Vector2(16,12)*zoom,Vector2(32,24)*zoom),Color("243438"))
			draw_circle(pos,8*zoom,ash_route_color)
			draw_circle(pos,4*zoom,Color("1c292c"))
			label_at(pos+Vector2(0,-22)*zoom,("SCRUBBER" if mark.get("route","")=="purifier" else "CITY DOOR")+" · "+str(mark.state).to_upper(),ash_route_color,8)
		elif mark.kind=="service_ring":
			var ring_state=str(mark.get("state","waiting"));var ring_color=Color("efbd57") if ring_state=="waiting" else Color("78c3ad")
			draw_rect(Rect2(pos-Vector2(20,13)*zoom,Vector2(40,26)*zoom),Color("1c3034"))
			for x in [-13,-5,5,13]:draw_line(pos+Vector2(x,-10)*zoom,pos+Vector2(x,10)*zoom,Color("71878a"),3*zoom)
			draw_circle(pos,7*zoom,ring_color);draw_circle(pos,3*zoom,Color("1c292c"))
			label_at(pos+Vector2(0,-26)*zoom,"REGISTRAR" if ring_state=="waiting" else ring_state.to_upper()+" STANDING",ring_color,9)
		elif mark.kind=="service_lore":
			draw_rect(Rect2(pos-Vector2(14,11)*zoom,Vector2(28,22)*zoom),Color("4e6467"))
			for i in 4:draw_line(pos+Vector2(-9,-7+i*5)*zoom,pos+Vector2(9,-7+i*5)*zoom,Color("d8dfd7"),1.5*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"LIVING CITY",Color("c9ddd6"),9)
		elif mark.kind=="service_option":
			var option_state=str(mark.get("state","available"));var option_color=Color("e4b45c") if option_state=="available" else Color("76c0aa") if option_state=="chosen" else Color("5b6666")
			draw_rect(Rect2(pos-Vector2(16,12)*zoom,Vector2(32,24)*zoom),Color("263a3d"))
			if mark.get("option","")=="city":
				draw_line(pos+Vector2(-10,7)*zoom,pos+Vector2(10,7)*zoom,option_color,3*zoom)
				for x in [-7,0,7]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,option_color,3*zoom)
			else:
				draw_colored_polygon(PackedVector2Array([pos+Vector2(-11,8)*zoom,pos+Vector2(0,-9)*zoom,pos+Vector2(11,8)*zoom]),option_color)
			label_at(pos+Vector2(0,-22)*zoom,("CITY QUARTERS" if mark.get("option","")=="city" else "FIELD BERTH")+" · "+option_state.to_upper(),option_color,8)
		elif mark.kind=="service_route":
			var lock_open=mark.get("state","")=="open";var lock_color=Color("72c4ad") if lock_open else Color("85685b")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("213438"))
			for y in [-7,0,7]:draw_line(pos+Vector2(-13,y)*zoom,pos+Vector2(13,y)*zoom,lock_color,3*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"SERVICE LOCK · "+str(mark.state).to_upper(),lock_color,8)
		elif mark.kind=="foundry":
			var foundry_state=str(mark.get("state","waiting"));var foundry_color=Color("efb657") if foundry_state=="waiting" else Color("df8855") if foundry_state=="assigned" else Color("75c2aa")
			draw_rect(Rect2(pos-Vector2(20,13)*zoom,Vector2(40,26)*zoom),Color("2f2826"))
			for x in [-12,-4,4,12]:draw_line(pos+Vector2(x,-9)*zoom,pos+Vector2(x,9)*zoom,Color("9a6653"),3*zoom)
			draw_circle(pos,7*zoom,foundry_color);draw_circle(pos,3*zoom,Color("251d1b"))
			label_at(pos+Vector2(0,-26)*zoom,"FOREWOMAN KES" if foundry_state=="waiting" else "REPAIR ASSIGNED" if foundry_state=="assigned" else foundry_state.to_upper()+" CONTRACT",foundry_color,8)
		elif mark.kind=="foundry_lore":
			draw_rect(Rect2(pos-Vector2(14,11)*zoom,Vector2(28,22)*zoom),Color("5b4840"))
			for i in 3:draw_circle(pos+Vector2(-8+i*8,0)*zoom,4*zoom,Color("df8b43"))
			label_at(pos+Vector2(0,-21)*zoom,"WORKING FOUNDRY",Color("e0b477"),8)
		elif mark.kind=="foundry_contract":
			var contract_state=str(mark.get("state","available"));var contract_color=Color("e3af55") if contract_state=="available" else Color("dc7c50") if contract_state=="open" else Color("73bfa8") if contract_state=="complete" else Color("5e6260")
			draw_rect(Rect2(pos-Vector2(16,12)*zoom,Vector2(32,24)*zoom),Color("352c29"))
			if mark.get("contract","")=="municipal":
				draw_circle(pos,9*zoom,contract_color);draw_circle(pos,4*zoom,Color("241f1d"))
			else:
				draw_colored_polygon(PackedVector2Array([pos+Vector2(-11,8)*zoom,pos+Vector2(0,-9)*zoom,pos+Vector2(11,8)*zoom]),contract_color)
			label_at(pos+Vector2(0,-22)*zoom,("CITY LINE" if mark.get("contract","")=="municipal" else "MATERIAL BOND")+" · "+contract_state.to_upper(),contract_color,8)
		elif mark.kind=="foundry_route":
			var freight_open=mark.get("state","")=="open";var freight_color=Color("72c3aa") if freight_open else Color("8a6657")
			draw_rect(Rect2(pos-Vector2(18,12)*zoom,Vector2(36,24)*zoom),Color("2b2524"))
			for x in [-12,-4,4,12]:draw_line(pos+Vector2(x,-9)*zoom,pos+Vector2(x,9)*zoom,freight_color,3*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"FREIGHT GATE · "+str(mark.state).to_upper(),freight_color,8)
		elif mark.kind=="archive":
			var archive_state=str(mark.get("state","waiting"));var archive_color=Color("dfbd6b") if archive_state=="waiting" else Color("d88d5c") if archive_state=="assigned" else Color("75c2aa")
			draw_rect(Rect2(pos-Vector2(20,13)*zoom,Vector2(40,26)*zoom),Color("282c34"))
			for y in [-8,-2,4,10]:draw_line(pos+Vector2(-15,y)*zoom,pos+Vector2(15,y)*zoom,Color("7a8291"),1.5*zoom)
			draw_circle(pos,6*zoom,archive_color);draw_circle(pos,2.5*zoom,Color("20242b"))
			label_at(pos+Vector2(0,-26)*zoom,"ARCHIVIST SEN" if archive_state=="waiting" else "DOSSIER RELEASED" if archive_state=="assigned" else archive_state.to_upper()+" RECORD",archive_color,8)
		elif mark.kind=="archive_lore":
			draw_rect(Rect2(pos-Vector2(14,11)*zoom,Vector2(28,22)*zoom),Color("414854"))
			for i in 4:draw_line(pos+Vector2(-9,-7+i*5)*zoom,pos+Vector2(9,-7+i*5)*zoom,Color("d3c89f"),1.5*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"ROUTE RECORD",Color("d7c98e"),8)
		elif mark.kind=="archive_choice":
			var evidence_state=str(mark.get("state","sealed"));var evidence_color=Color("e0b35e") if evidence_state=="available" else Color("76c0aa") if evidence_state=="chosen" else Color("626975")
			draw_rect(Rect2(pos-Vector2(16,12)*zoom,Vector2(32,24)*zoom),Color("2a3039"))
			if mark.get("choice","")=="shared":
				draw_line(pos+Vector2(-10,-7)*zoom,pos+Vector2(10,-7)*zoom,evidence_color,3*zoom);draw_line(pos+Vector2(-10,0)*zoom,pos+Vector2(10,0)*zoom,evidence_color,3*zoom);draw_line(pos+Vector2(-10,7)*zoom,pos+Vector2(10,7)*zoom,evidence_color,3*zoom)
			else:
				draw_colored_polygon(PackedVector2Array([pos+Vector2(-10,8)*zoom,pos+Vector2(0,-9)*zoom,pos+Vector2(10,8)*zoom]),evidence_color)
			label_at(pos+Vector2(0,-22)*zoom,("PUBLIC FILE" if mark.get("choice","")=="shared" else "PRESERVED COPY")+" · "+evidence_state.to_upper(),evidence_color,8)
		elif mark.kind=="archive_route":
			var catalog_open=mark.get("state","")=="open";var catalog_color=Color("72c3aa") if catalog_open else Color("6e6972")
			draw_rect(Rect2(pos-Vector2(18,12)*zoom,Vector2(36,24)*zoom),Color("262b32"))
			for x in [-12,-4,4,12]:draw_line(pos+Vector2(x,-9)*zoom,pos+Vector2(x,9)*zoom,catalog_color,2.5*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"CATALOG GATE · "+str(mark.state).to_upper(),catalog_color,8)
		elif mark.kind=="wake":
			var wake_state=str(mark.get("state","waiting"));var wake_color=Color("e0bd70") if wake_state=="waiting" else Color("de8758") if wake_state=="assigned" else Color("76c3ae")
			draw_circle(pos,13*zoom,Color("253038"));draw_circle(pos,8*zoom,wake_color);draw_circle(pos,3*zoom,Color("182126"))
			for angle in [0.0,PI*.5,PI,PI*1.5]:draw_line(pos+Vector2(cos(angle),sin(angle))*8*zoom,pos+Vector2(cos(angle),sin(angle))*13*zoom,wake_color,2*zoom)
			label_at(pos+Vector2(0,-26)*zoom,("MARSHAL RELL" if str(mark.name).contains("Rell") else "ANNOTATED WAYMARK") if wake_state=="waiting" else "RECOVERY ACTIVE" if wake_state=="assigned" else "ROUTE ALIGNED",wake_color,8)
		elif mark.kind=="wake_lore":
			draw_rect(Rect2(pos-Vector2(15,10)*zoom,Vector2(30,20)*zoom),Color("3d474e"))
			for i in 3:draw_line(pos+Vector2(-10,-6+i*6)*zoom,pos+Vector2(10,-6+i*6)*zoom,Color("c6bb91"),1.5*zoom)
			label_at(pos+Vector2(0,-20)*zoom,"LAST SURVEY",Color("d6c895"),8)
		elif mark.kind=="wake_route":
			var route_state=str(mark.get("state","sealed"));var route_color=Color("d99a56") if route_state=="open" else Color("5f6970")
			draw_rect(Rect2(pos-Vector2(17,11)*zoom,Vector2(34,22)*zoom),Color("222d33"))
			if mark.get("route","")=="official":
				for x in [-10,0,10]:draw_line(pos+Vector2(x,-8)*zoom,pos+Vector2(x,8)*zoom,route_color,3*zoom)
			else:draw_colored_polygon(PackedVector2Array([pos+Vector2(-12,8)*zoom,pos+Vector2(0,-9)*zoom,pos+Vector2(12,8)*zoom]),route_color)
			label_at(pos+Vector2(0,-21)*zoom,("MARKED GALLERY" if mark.get("route","")=="official" else "HIDDEN CRAWL")+" · "+route_state.to_upper(),route_color,8)
		elif mark.kind=="wake_exit":
			var wake_open=mark.get("state","")=="open";var exit_color=Color("75c6b0") if wake_open else Color("667078")
			draw_circle(pos,14*zoom,Color("202a30"));draw_circle(pos,10*zoom,exit_color);draw_circle(pos,6*zoom,Color("202a30"));draw_line(pos+Vector2(0,-10)*zoom,pos+Vector2(0,10)*zoom,exit_color,2*zoom)
			label_at(pos+Vector2(0,-24)*zoom,"QUIET MILE · "+str(mark.state).to_upper(),exit_color,8)
		elif mark.kind=="quiet_receiver":
			var receiver_color=Color("75c9b1") if mark.get("state","")=="heard" else Color("c7ad69")
			draw_circle(pos,14*zoom,Color("17282d"));draw_arc(pos,11*zoom,-2.5,2.5,24,receiver_color,3*zoom)
			draw_circle(pos,4*zoom,receiver_color);draw_line(pos+Vector2(0,4)*zoom,pos+Vector2(0,13)*zoom,receiver_color,3*zoom)
			label_at(pos+Vector2(0,-25)*zoom,"FINAL SIGNAL" if mark.get("state","")=="heard" else "RECEIVER",receiver_color,9)
		elif mark.kind=="quiet_post":
			var post_state=str(mark.get("state","locked"));var post_color=Color("d5a95e") if post_state=="available" else Color("75c3ab") if post_state=="complete" else Color("59666b")
			draw_circle(pos,12*zoom,Color("1a292e"));draw_arc(pos,9*zoom,0,TAU,24,post_color,2.5*zoom)
			for angle in [-.8,0.0,.8]:draw_line(pos+Vector2(cos(angle),sin(angle))*4*zoom,pos+Vector2(cos(angle),sin(angle))*10*zoom,post_color,2*zoom)
			label_at(pos+Vector2(0,-23)*zoom,"LISTEN "+str(mark.get("stage",0))+" · "+post_state.to_upper(),post_color,8)
		elif mark.kind=="quiet_lore":
			draw_rect(Rect2(pos-Vector2(15,10)*zoom,Vector2(30,20)*zoom),Color("202b31"))
			for i in 4:draw_line(pos+Vector2(-10+i*7,-7)*zoom,pos+Vector2(-10+i*7,7)*zoom,Color("66747a"),2*zoom)
			label_at(pos+Vector2(0,-20)*zoom,"NO LIGHT",Color("c9b77e"),8)
		elif mark.kind=="quiet_exit":
			var quiet_open=mark.get("state","")=="open";var quiet_color=Color("73c5ad") if quiet_open else Color("566166")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("18272c"))
			for x in [-11,-4,4,11]:draw_line(pos+Vector2(x,-9)*zoom,pos+Vector2(x,9)*zoom,quiet_color,2.5*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"LOWER STAIR · "+str(mark.state).to_upper(),quiet_color,8)
		elif mark.kind=="stillworks":
			var works_state=str(mark.get("state","waiting"));var works_color=Color("d7ae63") if works_state=="waiting" else Color("7cc9b1")
			draw_circle(pos,14*zoom,Color("1c292d"));draw_arc(pos,10*zoom,0,TAU,32,works_color,3*zoom)
			for angle in [0.0,PI*.5,PI,PI*1.5]:draw_line(pos+Vector2(cos(angle),sin(angle))*4*zoom,pos+Vector2(cos(angle),sin(angle))*11*zoom,works_color,2*zoom)
			label_at(pos+Vector2(0,-25)*zoom,"BELL MANIFOLD · "+works_state.to_upper(),works_color,8)
		elif mark.kind=="stillworks_option":
			var option_state=str(mark.get("state","available"));var option_color=Color("e0a05c") if option_state=="available" else Color("72c2aa") if option_state=="chosen" else Color("596268")
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("202b30"))
			if mark.get("choice","")=="restore":
				for x in [-10,0,10]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,option_color,3*zoom)
			else:draw_arc(pos,10*zoom,.2,PI-.2,20,option_color,3*zoom)
			label_at(pos+Vector2(0,-21)*zoom,("RESTORE" if mark.choice=="restore" else "DARK BYPASS")+" · "+option_state.to_upper(),option_color,8)
		elif mark.kind=="stillworks_light":
			for radius in range(18,3,-4):draw_circle(pos,radius*zoom,Color(1.0,.72,.35,.025))
			draw_circle(pos,6*zoom,Color("efbd63"));draw_line(pos+Vector2(0,5)*zoom,pos+Vector2(0,13)*zoom,Color("b98d4b"),3*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"FIXED LIGHT",Color("e3bd73"),8)
		elif mark.kind=="stillworks_lore":
			draw_rect(Rect2(pos-Vector2(15,10)*zoom,Vector2(30,20)*zoom),Color("263239"))
			for i in 3:draw_arc(pos+Vector2(0,i*3-3)*zoom,(5+i*3)*zoom,-2.6,-.5,12,Color("baa873"),1.5*zoom)
			label_at(pos+Vector2(0,-20)*zoom,"BELL LEDGER",Color("ccb980"),8)
		elif mark.kind=="stillworks_exit":
			var works_open=mark.get("state","")=="open";var exit_color=Color("78c8af") if works_open else Color("586268")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("18272c"))
			for x in [-11,-4,4,11]:draw_line(pos+Vector2(x,-9)*zoom,pos+Vector2(x,9)*zoom,exit_color,2.5*zoom)
			label_at(pos+Vector2(0,-22)*zoom,("PRESSURE STAIR" if mark.route=="restore" else "DARK STAIR")+" · "+str(mark.state).to_upper(),exit_color,8)
		elif mark.kind=="cistern":
			var keeper_state=str(mark.get("state","waiting"));var keeper_color=Color("d7b365") if keeper_state=="waiting" else Color("df8757") if keeper_state=="assigned" else Color("72c5ad")
			draw_circle(pos,15*zoom,Color("17292e"));draw_arc(pos,11*zoom,0,TAU,32,keeper_color,3*zoom)
			for y in [-7,0,7]:draw_line(pos+Vector2(-10,y)*zoom,pos+Vector2(10,y)*zoom,keeper_color,2*zoom)
			label_at(pos+Vector2(0,-26)*zoom,"WATER KEEPER · "+keeper_state.to_upper(),keeper_color,8)
		elif mark.kind=="cistern_route":
			var route_state=str(mark.get("state","sealed"));var route_color=Color("df9d59") if route_state=="open" else Color("72c3aa") if route_state=="complete" else Color("58656a")
			draw_rect(Rect2(pos-Vector2(17,11)*zoom,Vector2(34,22)*zoom),Color("1d3035"))
			if mark.get("route","")=="pressure":
				for x in [-10,0,10]:draw_arc(pos+Vector2(x,0)*zoom,6*zoom,-PI*.5,PI*.5,12,route_color,2.5*zoom)
			else:
				draw_arc(pos,12*zoom,.15,PI-.15,20,route_color,3*zoom);draw_line(pos+Vector2(-11,5)*zoom,pos+Vector2(11,5)*zoom,route_color,2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,("PRESSURE" if mark.route=="pressure" else "SPILLWAY")+" · "+route_state.to_upper(),route_color,8)
		elif mark.kind=="cistern_lore":
			draw_rect(Rect2(pos-Vector2(14,11)*zoom,Vector2(28,22)*zoom),Color("31474b"))
			for i in 4:draw_line(pos+Vector2(-9,-7+i*5)*zoom,pos+Vector2(9,-7+i*5)*zoom,Color("b8d1c7"),1.5*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"WATER TALLY",Color("bcd9cf"),8)
		elif mark.kind=="cistern_exit":
			var cistern_open=mark.get("state","")=="open";var cistern_color=Color("73c5ad") if cistern_open else Color("59656a")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("182a30"))
			for x in [-11,-4,4,11]:draw_line(pos+Vector2(x,-9)*zoom,pos+Vector2(x,9)*zoom,cistern_color,2.5*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"RESERVOIR STAIR · "+str(mark.state).to_upper(),cistern_color,8)
		elif mark.kind=="drowned_control":
			var surge_state=str(mark.get("state","waiting"));var surge_color=Color("ef865c") if surge_state=="warning" else Color("d8af67") if surge_state=="waiting" else Color("72c5ad")
			draw_circle(pos,15*zoom,Color("172a30"));draw_arc(pos,11*zoom,0,TAU,32,surge_color,3*zoom)
			for angle in [0.0,PI*.5,PI,PI*1.5]:draw_line(pos+Vector2(cos(angle),sin(angle))*4*zoom,pos+Vector2(cos(angle),sin(angle))*11*zoom,surge_color,2*zoom)
			label_at(pos+Vector2(0,-26)*zoom,"SLUICE · "+surge_state.to_upper(),surge_color,8)
		elif mark.kind=="drowned_rescue":
			var rescue_state=str(mark.get("state","sealed"));var rescue_color=Color("f0a061") if rescue_state=="available" else Color("76cbb2") if rescue_state=="safe" else Color("59656a")
			draw_circle(pos,12*zoom,Color("1d3035"));draw_line(pos+Vector2(-7,0)*zoom,pos+Vector2(7,0)*zoom,rescue_color,3*zoom);draw_line(pos+Vector2(0,-7)*zoom,pos+Vector2(0,7)*zoom,rescue_color,3*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"RESCUE · "+rescue_state.to_upper(),rescue_color,8)
		elif mark.kind=="drowned_salvage":
			var salvage_state=str(mark.get("state","sealed"));var salvage_color=Color("e4a85f") if salvage_state=="available" else Color("76cbb2") if salvage_state=="claimed" else Color("59656a")
			draw_rect(Rect2(pos-Vector2(14,10)*zoom,Vector2(28,20)*zoom),Color("1c2d32"));draw_arc(pos,8*zoom,0,TAU,24,salvage_color,3*zoom);draw_circle(pos,3*zoom,salvage_color)
			label_at(pos+Vector2(0,-21)*zoom,"REGULATOR · "+salvage_state.to_upper(),salvage_color,8)
		elif mark.kind=="drowned_safe":
			draw_line(pos+Vector2(-18,-8)*zoom,pos+Vector2(-18,8)*zoom,Color("7ad0b5"),4*zoom);draw_line(pos+Vector2(18,-8)*zoom,pos+Vector2(18,8)*zoom,Color("7ad0b5"),4*zoom)
			draw_line(pos+Vector2(-18,0)*zoom,pos+Vector2(18,0)*zoom,Color("7ad0b5"),2*zoom);label_at(pos+Vector2(0,-20)*zoom,"DRY RETREAT",Color("9fe0c9"),8)
		elif mark.kind=="drowned_exit":
			var drowned_open=mark.get("state","")=="open";var drowned_color=Color("73c5ad") if drowned_open else Color("59656a")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("182a30"))
			for x in [-11,-4,4,11]:draw_line(pos+Vector2(x,-9)*zoom,pos+Vector2(x,9)*zoom,drowned_color,2.5*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"DRAINED STAIR · "+str(mark.state).to_upper(),drowned_color,8)
		elif mark.kind=="tidecourt":
			var court_state=str(mark.get("state","waiting"));var court_color=Color("d9b56d") if court_state=="waiting" else Color("df8d5f") if court_state=="assigned" else Color("74c8af")
			draw_circle(pos,15*zoom,Color("192b30"));draw_arc(pos,11*zoom,0,TAU,32,court_color,3*zoom)
			for x in [-7,0,7]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,court_color,2*zoom)
			label_at(pos+Vector2(0,-26)*zoom,"TIDECOURT · "+court_state.to_upper(),court_color,8)
		elif mark.kind=="tidecourt_route":
			var court_route_state=str(mark.get("state","closed"));var court_route_color=Color("e1a35e") if court_route_state=="available" else Color("75c5ad") if court_route_state=="open" else Color("59656a")
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("203238"))
			if mark.get("route","")=="sponsor":draw_circle(pos,7*zoom,court_route_color);draw_line(pos+Vector2(-10,0)*zoom,pos+Vector2(10,0)*zoom,court_route_color,2*zoom)
			else:draw_arc(pos,8*zoom,0,TAU,24,court_route_color,3*zoom);draw_circle(pos,3*zoom,court_route_color)
			label_at(pos+Vector2(0,-21)*zoom,("SPONSOR" if mark.route=="sponsor" else "EXCHANGE")+" · "+court_route_state.to_upper(),court_route_color,8)
		elif mark.kind=="tidecourt_lore":
			draw_rect(Rect2(pos-Vector2(14,11)*zoom,Vector2(28,22)*zoom),Color("31474b"))
			for i in 3:draw_line(pos+Vector2(-9,-6+i*6)*zoom,pos+Vector2(9,-6+i*6)*zoom,Color("c6d7c9"),1.5*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"WATER BOARD",Color("c7d9d0"),8)
		elif mark.kind=="tidecourt_exit":
			var court_open=mark.get("state","")=="open";var court_exit_color=Color("73c5ad") if court_open else Color("59656a")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("182a30"))
			for x in [-11,-4,4,11]:draw_line(pos+Vector2(x,-9)*zoom,pos+Vector2(x,9)*zoom,court_exit_color,2.5*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"LOWER WATER · "+str(mark.state).to_upper(),court_exit_color,8)
		elif mark.kind=="sump":
			var sump_state=str(mark.get("state","waiting"));var sump_color=Color("d9b56d") if sump_state=="waiting" else Color("df8d5f") if sump_state=="assigned" else Color("74c8af")
			draw_circle(pos,15*zoom,Color("192b30"));draw_arc(pos,11*zoom,0,TAU,32,sump_color,3*zoom);draw_circle(pos,4*zoom,sump_color)
			for angle in [0.0,PI*.5,PI,PI*1.5]:draw_line(pos+Vector2(cos(angle),sin(angle))*5*zoom,pos+Vector2(cos(angle),sin(angle))*11*zoom,sump_color,2*zoom)
			label_at(pos+Vector2(0,-26)*zoom,"SUMP PUMP · "+sump_state.to_upper(),sump_color,8)
		elif mark.kind=="sump_route":
			var sump_route_state=str(mark.get("state","sealed"));var sump_route_color=Color("e0a35f") if sump_route_state=="open" else Color("74c8af") if sump_route_state=="complete" else Color("59656a")
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("203238"));draw_arc(pos,8*zoom,0,TAU,24,sump_route_color,3*zoom);draw_circle(pos,3*zoom,sump_route_color)
			label_at(pos+Vector2(0,-21)*zoom,str(mark.get("route","public")).to_upper()+" ROUTE · "+sump_route_state.to_upper(),sump_route_color,8)
		elif mark.kind=="sump_foothold":
			var berth_active=mark.get("state","")=="active";var berth_color=Color("79ccb3") if berth_active else Color("59656a")
			draw_rect(Rect2(pos-Vector2(16,11)*zoom,Vector2(32,22)*zoom),Color("1b3034"));draw_line(pos+Vector2(-11,5)*zoom,pos+Vector2(11,5)*zoom,berth_color,3*zoom);draw_line(pos+Vector2(-9,-6)*zoom,pos+Vector2(-9,6)*zoom,berth_color,2*zoom);draw_line(pos+Vector2(9,-6)*zoom,pos+Vector2(9,6)*zoom,berth_color,2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"COMMONS BERTH · "+str(mark.state).to_upper(),berth_color,8)
		elif mark.kind=="sump_exit":
			var sump_open=mark.get("state","")=="open";var sump_exit_color=Color("73c5ad") if sump_open else Color("59656a")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("182a30"))
			for x in [-11,-4,4,11]:draw_line(pos+Vector2(x,-9)*zoom,pos+Vector2(x,9)*zoom,sump_exit_color,2.5*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"LOWER MAINS · "+str(mark.state).to_upper(),sump_exit_color,8)
		elif mark.kind=="market":
			var market_state=str(mark.get("state","waiting"));var market_color=Color("e2bb70") if market_state=="waiting" else Color("77cbb2")
			draw_rect(Rect2(pos-Vector2(16,12)*zoom,Vector2(32,24)*zoom),Color("23343a"));draw_arc(pos,10*zoom,PI,TAU,20,market_color,3*zoom)
			for x in [-9,-3,3,9]:draw_line(pos+Vector2(x,-1)*zoom,pos+Vector2(x,9)*zoom,market_color,2*zoom)
			label_at(pos+Vector2(0,-23)*zoom,"MAINSPRING · "+market_state.to_upper(),market_color,8)
		elif mark.kind=="market_arcade":
			var arcade_open=mark.get("state","")=="open";var arcade_color=Color("7bcdb5") if arcade_open else Color("59656a")
			draw_rect(Rect2(pos-Vector2(17,10)*zoom,Vector2(34,20)*zoom),Color("1d3035"));draw_line(pos+Vector2(-13,-5)*zoom,pos+Vector2(13,-5)*zoom,arcade_color,3*zoom)
			for x in [-10,0,10]:draw_line(pos+Vector2(x,-5)*zoom,pos+Vector2(x,8)*zoom,arcade_color,2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,str(mark.get("route","public")).to_upper()+" ARCADE · "+str(mark.state).to_upper(),arcade_color,8)
		elif mark.kind=="market_recruit":
			draw_circle(pos,10*zoom,Color("76558f"));draw_circle(pos+Vector2(0,-5)*zoom,3*zoom,Color("d7c5e7"));draw_line(pos+Vector2(0,-1)*zoom,pos+Vector2(0,7)*zoom,Color("d7c5e7"),2*zoom)
			label_at(pos+Vector2(0,-20)*zoom,"TAVI · WAITING",Color("d7c5e7"),8)
		elif mark.kind=="market_exit":
			var clock_open=mark.get("state","")=="open";var clock_color=Color("73c5ad") if clock_open else Color("59656a")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("182a30"));draw_circle(pos,8*zoom,clock_color,false,2.5*zoom);draw_line(pos,pos+Vector2(0,-6)*zoom,clock_color,2*zoom);draw_line(pos,pos+Vector2(5,2)*zoom,clock_color,2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"CLOCKLINE · "+str(mark.state).to_upper(),clock_color,8)
		elif mark.kind=="depot":
			var depot_state=str(mark.get("state","waiting"));var depot_color=Color("e3b868") if depot_state=="waiting" else Color("df8b59") if depot_state=="assigned" else Color("76cab1")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("1c2d32"));draw_circle(pos,9*zoom,depot_color,false,3*zoom)
			for angle in [0.0,PI*.5,PI,PI*1.5]:draw_line(pos+Vector2(cos(angle),sin(angle))*4*zoom,pos+Vector2(cos(angle),sin(angle))*10*zoom,depot_color,2*zoom)
			label_at(pos+Vector2(0,-24)*zoom,"DISPATCH · "+depot_state.to_upper(),depot_color,8)
		elif mark.kind=="depot_lane":
			var lane_state=str(mark.get("state","sealed"));var lane_color=Color("e3a35e") if lane_state=="open" else Color("77c9b0") if lane_state=="complete" else Color("59656a")
			draw_rect(Rect2(pos-Vector2(17,10)*zoom,Vector2(34,20)*zoom),Color("203238"));draw_circle(pos,7*zoom,lane_color,false,3*zoom);draw_line(pos+Vector2(-13,0)*zoom,pos+Vector2(13,0)*zoom,lane_color,2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,("TRACTION" if mark.get("cargo","")=="drive" else "BRAKE")+" · "+lane_state.to_upper(),lane_color,8)
		elif mark.kind=="depot_exit":
			var depot_open=mark.get("state","")=="open";var platform_color=Color("73c5ad") if depot_open else Color("59656a")
			draw_rect(Rect2(pos-Vector2(18,12)*zoom,Vector2(36,24)*zoom),Color("182a30"));draw_line(pos+Vector2(-14,6)*zoom,pos+Vector2(14,6)*zoom,platform_color,3*zoom)
			for x in [-10,0,10]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,8)*zoom,platform_color,2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"LOWER PLATFORM · "+str(mark.state).to_upper(),platform_color,8)
		elif mark.kind=="refuge":
			var refuge_state=str(mark.get("state","waiting"));var refuge_color=Color("e4b86b") if refuge_state=="waiting" else Color("76cbb2")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("203036"));draw_arc(pos,10*zoom,PI,TAU,24,refuge_color,3*zoom)
			for x in [-9,0,9]:draw_line(pos+Vector2(x,-1)*zoom,pos+Vector2(x,9)*zoom,refuge_color,2*zoom)
			label_at(pos+Vector2(0,-24)*zoom,"SWITCHYARD · "+refuge_state.to_upper(),refuge_color,8)
		elif mark.kind=="refuge_option":
			var option_state=str(mark.get("state","available"));var option_color=Color("e1a35f") if option_state=="available" else Color("78cbb2") if option_state=="active" else Color("59656a")
			draw_rect(Rect2(pos-Vector2(17,10)*zoom,Vector2(34,20)*zoom),Color("1c3035"))
			if mark.get("choice","")=="foothold":draw_line(pos+Vector2(-11,6)*zoom,pos+Vector2(11,6)*zoom,option_color,3*zoom);draw_line(pos+Vector2(-8,-6)*zoom,pos+Vector2(-8,7)*zoom,option_color,2*zoom);draw_line(pos+Vector2(8,-6)*zoom,pos+Vector2(8,7)*zoom,option_color,2*zoom)
			else:draw_line(pos+Vector2(-12,5)*zoom,pos+Vector2(12,5)*zoom,option_color,3*zoom);draw_circle(pos+Vector2(-8,8)*zoom,3*zoom,option_color);draw_circle(pos+Vector2(8,8)*zoom,3*zoom,option_color)
			label_at(pos+Vector2(0,-21)*zoom,("SANCTUARY" if mark.get("choice","")=="foothold" else "MOBILE LINE")+" · "+option_state.to_upper(),option_color,8)
		elif mark.kind=="refuge_exit":
			var switch_open=mark.get("state","")=="open";var switch_color=Color("73c5ad") if switch_open else Color("59656a")
			draw_rect(Rect2(pos-Vector2(18,12)*zoom,Vector2(36,24)*zoom),Color("182a30"));draw_line(pos+Vector2(-13,7)*zoom,pos+Vector2(13,-7)*zoom,switch_color,3*zoom);draw_line(pos+Vector2(-13,-7)*zoom,pos+Vector2(13,7)*zoom,switch_color,2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"OUTBOUND · "+str(mark.state).to_upper(),switch_color,8)
		elif mark.kind=="refuge_lore":
			draw_rect(Rect2(pos-Vector2(15,10)*zoom,Vector2(30,20)*zoom),Color("304148"));draw_line(pos+Vector2(-10,-4)*zoom,pos+Vector2(10,-4)*zoom,Color("d4c292"),2*zoom);draw_line(pos+Vector2(-10,3)*zoom,pos+Vector2(6,3)*zoom,Color("d4c292"),2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"DEPARTURES",Color("d4c292"),8)
		elif mark.kind=="ashrail":
			var ash_state=str(mark.get("state","waiting"));var ash_color=Color("e59a58") if ash_state=="waiting" else Color("79c7ad")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("262b2d"));draw_circle(pos,10*zoom,Color("4d342c"),false,3*zoom)
			for angle in [-.8,0.0,.8]:draw_line(pos+Vector2(cos(angle),sin(angle))*3*zoom,pos+Vector2(cos(angle),sin(angle))*12*zoom,ash_color,2*zoom)
			label_at(pos+Vector2(0,-24)*zoom,"ASHRAIL · "+ash_state.to_upper(),ash_color,8)
		elif mark.kind=="ashrail_route":
			var rail_state=str(mark.get("state","open"));var rail_color=Color("df9857") if rail_state=="open" else Color("78c7ae")
			draw_rect(Rect2(pos-Vector2(18,10)*zoom,Vector2(36,20)*zoom),Color("202d30"));draw_line(pos+Vector2(-15,-5)*zoom,pos+Vector2(15,-5)*zoom,rail_color,3*zoom);draw_line(pos+Vector2(-15,6)*zoom,pos+Vector2(15,6)*zoom,rail_color,3*zoom)
			for x in range(-12,13,8):draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,8)*zoom,rail_color,2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,("CINDER GANTRY" if mark.get("route","")=="sanctuary" else "BLACK RAIL")+" · "+rail_state.to_upper(),rail_color,8)
		elif mark.kind=="ashrail_exit":
			var exchange_open=mark.get("state","")=="open";var exchange_color=Color("74c6ad") if exchange_open else Color("5d6262")
			draw_rect(Rect2(pos-Vector2(18,12)*zoom,Vector2(36,24)*zoom),Color("1c292c"));draw_arc(pos,11*zoom,PI,TAU,18,exchange_color,3*zoom);draw_line(pos+Vector2(-12,7)*zoom,pos+Vector2(12,7)*zoom,exchange_color,3*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"LOWER EXCHANGE · "+str(mark.state).to_upper(),exchange_color,8)
		elif mark.kind=="ashrail_lore":
			draw_circle(pos,11*zoom,Color("bd8a55"),false,3*zoom);draw_line(pos,pos+Vector2(7,-7)*zoom,Color("e4c084"),2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"ASHFALL CLOCK",Color("d6af76"),8)
		elif mark.kind=="customs":
			var customs_state=str(mark.get("state","waiting"));var customs_color=Color("e4a25f") if customs_state=="waiting" else Color("76c7ae")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("252e31"));draw_colored_polygon(PackedVector2Array([pos+Vector2(0,-10)*zoom,pos+Vector2(10,6)*zoom,pos+Vector2(-10,6)*zoom]),Color("4e3b32"))
			draw_line(pos+Vector2(-12,8)*zoom,pos+Vector2(12,8)*zoom,customs_color,3*zoom);label_at(pos+Vector2(0,-24)*zoom,"CUSTOMS · "+customs_state.to_upper(),customs_color,8)
		elif mark.kind=="customs_route":
			var customs_route_state=str(mark.get("state","available"));var customs_route_color=Color("e0a05c") if customs_route_state=="available" else Color("75c5ad") if customs_route_state=="open" else Color("5b6264")
			draw_rect(Rect2(pos-Vector2(18,10)*zoom,Vector2(36,20)*zoom),Color("1d2b2f"));draw_line(pos+Vector2(-14,6)*zoom,pos+Vector2(14,6)*zoom,customs_route_color,3*zoom)
			if mark.get("choice","")=="security":draw_rect(Rect2(pos-Vector2(7,7)*zoom,Vector2(14,11)*zoom),customs_route_color,false,2*zoom)
			else:draw_line(pos+Vector2(-12,-5)*zoom,pos+Vector2(12,3)*zoom,customs_route_color,2*zoom);draw_line(pos+Vector2(-12,3)*zoom,pos+Vector2(12,-5)*zoom,customs_route_color,2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,("INSPECTION" if mark.get("choice","")=="security" else "GHOST SIDING")+" · "+customs_route_state.to_upper(),customs_route_color,8)
		elif mark.kind=="customs_exit":
			var authority_open=mark.get("state","")=="open";var authority_color=Color("73c5ad") if authority_open else Color("596165")
			draw_rect(Rect2(pos-Vector2(18,12)*zoom,Vector2(36,24)*zoom),Color("18272b"));draw_line(pos+Vector2(-14,-5)*zoom,pos+Vector2(14,-5)*zoom,authority_color,3*zoom);draw_line(pos+Vector2(-14,6)*zoom,pos+Vector2(14,6)*zoom,authority_color,3*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"LOWER GATE · "+str(mark.state).to_upper(),authority_color,8)
		elif mark.kind=="customs_lore":
			draw_rect(Rect2(pos-Vector2(14,10)*zoom,Vector2(28,20)*zoom),Color("3c3431"));for x in [-8,0,8]:draw_line(pos+Vector2(x,-6)*zoom,pos+Vector2(x,6)*zoom,Color("c28a5e"),2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"SEIZED GOODS",Color("d7aa73"),8)
		elif mark.kind=="railcourt":
			var court_state=str(mark.get("state","waiting"));var court_color=Color("e0b26b") if court_state in ["waiting","assigned"] else Color("77c9b0")
			draw_colored_polygon(PackedVector2Array([pos+Vector2(-16,8)*zoom,pos+Vector2(0,-12)*zoom,pos+Vector2(16,8)*zoom]),Color("354045"))
			draw_line(pos+Vector2(-16,9)*zoom,pos+Vector2(16,9)*zoom,court_color,3*zoom);draw_circle(pos+Vector2(0,-2)*zoom,4*zoom,court_color,false,2*zoom)
			label_at(pos+Vector2(0,-24)*zoom,"RAILCOURT · "+court_state.to_upper(),court_color,8)
		elif mark.kind=="railcourt_route":
			var rail_state=str(mark.get("state","sealed"));var rail_color=Color("78c8b0") if rail_state in ["open","complete"] else Color("5a6265")
			draw_rect(Rect2(pos-Vector2(18,10)*zoom,Vector2(36,20)*zoom),Color("1c2b2e"));draw_line(pos+Vector2(-15,6)*zoom,pos+Vector2(15,6)*zoom,rail_color,3*zoom)
			if mark.get("route","")=="authority":draw_rect(Rect2(pos-Vector2(6,7)*zoom,Vector2(12,11)*zoom),rail_color,false,2*zoom)
			else:draw_circle(pos+Vector2(-7,-1)*zoom,4*zoom,rail_color,false,2*zoom);draw_circle(pos+Vector2(7,-1)*zoom,4*zoom,rail_color,false,2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,("SWITCHHOUSE" if mark.get("route","")=="authority" else "RESIDENT ARCADE")+" · "+rail_state.to_upper(),rail_color,8)
		elif mark.kind=="railcourt_exit":
			var freight_open=mark.get("state","")=="open";var freight_color=Color("73c5ad") if freight_open else Color("596165")
			draw_rect(Rect2(pos-Vector2(18,12)*zoom,Vector2(36,24)*zoom),Color("18272b"));draw_line(pos+Vector2(-14,-5)*zoom,pos+Vector2(14,-5)*zoom,freight_color,3*zoom);draw_line(pos+Vector2(-14,6)*zoom,pos+Vector2(14,6)*zoom,freight_color,3*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"FREIGHT STAIR · "+str(mark.state).to_upper(),freight_color,8)
		elif mark.kind=="railcourt_lore":
			draw_rect(Rect2(pos-Vector2(13,10)*zoom,Vector2(26,20)*zoom),Color("304044"));draw_line(pos+Vector2(-9,6)*zoom,pos+Vector2(9,-6)*zoom,Color("c9a76c"),3*zoom);draw_line(pos+Vector2(-9,-6)*zoom,pos+Vector2(9,6)*zoom,Color("7ac5ad"),3*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"SPLIT JURISDICTION",Color("d5bc88"),8)
		elif mark.kind=="registry":
			var registry_state=str(mark.get("state","waiting"));var registry_color=Color("e3ad67") if registry_state in ["waiting","assigned"] else Color("76c8af")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("302f2d"));for y in [-6,0,6]:draw_line(pos+Vector2(-12,y)*zoom,pos+Vector2(12,y)*zoom,registry_color,2*zoom)
			draw_circle(pos+Vector2(0,-1)*zoom,5*zoom,registry_color,false,2*zoom);label_at(pos+Vector2(0,-24)*zoom,"CINDER REGISTRY · "+registry_state.to_upper(),registry_color,8)
		elif mark.kind=="registry_route":
			var registry_route_state=str(mark.get("state","sealed"));var registry_route_color=Color("77c7ae") if registry_route_state in ["open","complete"] else Color("5b6263")
			draw_rect(Rect2(pos-Vector2(18,10)*zoom,Vector2(36,20)*zoom),Color("202a2d"));draw_line(pos+Vector2(-14,6)*zoom,pos+Vector2(14,6)*zoom,registry_route_color,3*zoom)
			if mark.get("route","")=="official":draw_rect(Rect2(pos-Vector2(8,7)*zoom,Vector2(16,11)*zoom),registry_route_color,false,2*zoom);draw_line(pos+Vector2(-5,-3)*zoom,pos+Vector2(5,1)*zoom,registry_route_color,2*zoom)
			else:draw_line(pos+Vector2(-12,-5)*zoom,pos+Vector2(12,3)*zoom,registry_route_color,2*zoom);draw_circle(pos+Vector2(8,-4)*zoom,3*zoom,registry_route_color,false,2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,("AUDIT VAULT" if mark.get("route","")=="official" else "COPY ROOM")+" · "+registry_route_state.to_upper(),registry_route_color,8)
		elif mark.kind=="registry_exit":
			var registry_open=mark.get("state","")=="open";var registry_exit_color=Color("73c5ad") if registry_open else Color("596165")
			draw_rect(Rect2(pos-Vector2(18,12)*zoom,Vector2(36,24)*zoom),Color("18272b"));draw_arc(pos,11*zoom,PI,TAU,18,registry_exit_color,3*zoom);draw_line(pos+Vector2(-12,7)*zoom,pos+Vector2(12,7)*zoom,registry_exit_color,3*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"MORROW STAIR · "+str(mark.state).to_upper(),registry_exit_color,8)
		elif mark.kind=="registry_lore":
			draw_rect(Rect2(pos-Vector2(15,9)*zoom,Vector2(30,18)*zoom),Color("3a302c"));draw_line(pos+Vector2(-11,2)*zoom,pos+Vector2(11,2)*zoom,Color("d18a5b"),3*zoom);draw_circle(pos+Vector2(9,-4)*zoom,3*zoom,Color("b74e43"))
			label_at(pos+Vector2(0,-20)*zoom,"MORROW",Color("dcaa71"),9)
		elif mark.kind=="morrow":
			var morrow_state=str(mark.get("state","waiting"));var morrow_color=Color("f0b45f") if morrow_state=="waiting" else Color("ed7757") if morrow_state=="boarding" else Color("76c8af")
			draw_rect(Rect2(pos-Vector2(18,12)*zoom,Vector2(36,24)*zoom),Color("263238"));draw_line(pos+Vector2(-14,-5)*zoom,pos+Vector2(14,-5)*zoom,morrow_color,3*zoom);draw_line(pos+Vector2(-14,6)*zoom,pos+Vector2(14,6)*zoom,morrow_color,3*zoom)
			for x in range(-10,11,10):draw_line(pos+Vector2(x,-8)*zoom,pos+Vector2(x,9)*zoom,morrow_color,2*zoom)
			label_at(pos+Vector2(0,-24)*zoom,"MORROW · "+morrow_state.to_upper(),morrow_color,8)
		elif mark.kind=="morrow_route":
			var train_state=str(mark.get("state","sealed"));var train_color=Color("ef7658") if train_state=="boarding" else Color("75c6ad") if train_state=="complete" else Color("596165")
			draw_colored_polygon(PackedVector2Array([pos+Vector2(-18,8)*zoom,pos+Vector2(-14,-8)*zoom,pos+Vector2(13,-8)*zoom,pos+Vector2(18,8)*zoom]),Color("39464a"))
			for x in [-8,3]:draw_rect(Rect2(pos+Vector2(x,-4)*zoom,Vector2(7,7)*zoom),Color("131d20"))
			draw_circle(pos+Vector2(-10,9)*zoom,4*zoom,train_color);draw_circle(pos+Vector2(10,9)*zoom,4*zoom,train_color)
			label_at(pos+Vector2(0,-22)*zoom,("AUTHORITY TRAIN" if mark.get("route","")=="official" else "GHOST TRAIN")+" · "+train_state.to_upper(),train_color,8)
		elif mark.kind=="morrow_exit":
			var deep_open=mark.get("state","")=="open";var deep_color=Color("73c5ad") if deep_open else Color("596165")
			draw_rect(Rect2(pos-Vector2(18,12)*zoom,Vector2(36,24)*zoom),Color("17262a"));draw_line(pos+Vector2(-15,-6)*zoom,pos+Vector2(15,-6)*zoom,deep_color,3*zoom);draw_line(pos+Vector2(-15,7)*zoom,pos+Vector2(15,7)*zoom,deep_color,3*zoom)
			for x in range(-12,13,8):draw_line(pos+Vector2(x,-9)*zoom,pos+Vector2(x,10)*zoom,deep_color,2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"DEEP LINE · "+str(mark.state).to_upper(),deep_color,8)
		elif mark.kind=="morrow_lore":
			draw_rect(Rect2(pos-Vector2(15,10)*zoom,Vector2(30,20)*zoom),Color("403831"));for y in [-5,1,7]:draw_line(pos+Vector2(-11,y)*zoom,pos+Vector2(11,y)*zoom,Color("d2b680"),2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"NO RETURNS",Color("d8ae73"),8)
		elif mark.kind=="terminus":
			var terminus_state=str(mark.get("state","waiting"));var terminus_color=Color("e3b56f") if terminus_state in ["waiting","assigned"] else Color("75c6ad")
			draw_circle(pos,13*zoom,Color("2f3d3d"));draw_circle(pos,10*zoom,terminus_color,false,2*zoom);draw_rect(Rect2(pos+Vector2(-5,-4)*zoom,Vector2(10,9)*zoom),Color("172326"))
			draw_line(pos+Vector2(-9,8)*zoom,pos+Vector2(9,8)*zoom,terminus_color,3*zoom);label_at(pos+Vector2(0,-23)*zoom,"CAIRN REACH · "+terminus_state.to_upper(),terminus_color,8)
		elif mark.kind=="terminus_route":
			var terminus_route_state=str(mark.get("state","sealed"));var terminus_route_color=Color("ed7658") if terminus_route_state in ["open","assigned"] else Color("75c6ad") if terminus_route_state=="complete" else Color("596165")
			draw_rect(Rect2(pos-Vector2(18,11)*zoom,Vector2(36,22)*zoom),Color("243033"));draw_line(pos+Vector2(-14,6)*zoom,pos+Vector2(14,6)*zoom,terminus_route_color,3*zoom)
			if mark.get("route","")=="official":
				for x in [-9,0,9]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,terminus_route_color,2*zoom)
			else:
				draw_arc(pos+Vector2(0,4)*zoom,9*zoom,PI,TAU,12,terminus_route_color,3*zoom);draw_circle(pos+Vector2(0,-4)*zoom,3*zoom,terminus_route_color)
			label_at(pos+Vector2(0,-22)*zoom,("WITNESS HALL" if mark.get("route","")=="official" else "FREE SIDING")+" · "+terminus_route_state.to_upper(),terminus_route_color,8)
		elif mark.kind=="terminus_exit":
			var terminus_open=mark.get("state","")=="open";var terminus_exit_color=Color("73c5ad") if terminus_open else Color("596165")
			draw_rect(Rect2(pos-Vector2(16,13)*zoom,Vector2(32,26)*zoom),Color("17262a"));draw_line(pos+Vector2(-11,-8)*zoom,pos+Vector2(-11,9)*zoom,terminus_exit_color,3*zoom);draw_line(pos+Vector2(11,-8)*zoom,pos+Vector2(11,9)*zoom,terminus_exit_color,3*zoom)
			for y in [-7,-1,5]:draw_line(pos+Vector2(-11,y)*zoom,pos+Vector2(11,y)*zoom,terminus_exit_color,2*zoom)
			label_at(pos+Vector2(0,-23)*zoom,"CAIRN FAR LIFT · "+str(mark.state).to_upper(),terminus_exit_color,8)
		elif mark.kind=="terminus_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("3a342d"));for x in [-10,-3,4,11]:draw_circle(pos+Vector2(x,(x%3)-1)*zoom,3*zoom,Color("c19b65"))
			draw_line(pos+Vector2(-13,6)*zoom,pos+Vector2(13,-6)*zoom,Color("d86e58"),3*zoom);label_at(pos+Vector2(0,-21)*zoom,"BEYOND JURISDICTION",Color("d6b67d"),8)
		elif mark.kind=="farline":
			var farline_state=str(mark.get("state","waiting"));var farline_color=Color("e2b66f") if farline_state in ["waiting","assigned"] else Color("75c7ae")
			draw_circle(pos,14*zoom,Color("29383a"));for angle in [0.0,TAU/3.0,TAU*2.0/3.0]:draw_line(pos,pos+Vector2(cos(angle),sin(angle))*12*zoom,farline_color,3*zoom)
			draw_circle(pos,5*zoom,farline_color,false,2*zoom);label_at(pos+Vector2(0,-24)*zoom,"FARLINE · "+farline_state.to_upper(),farline_color,8)
		elif mark.kind=="farline_route":
			var farline_route_state=str(mark.get("state","sealed"));var farline_route_color=Color("ed7658") if farline_route_state=="open" else Color("75c6ad") if farline_route_state=="complete" else Color("596165")
			draw_rect(Rect2(pos-Vector2(19,10)*zoom,Vector2(38,20)*zoom),Color("213033"));draw_line(pos+Vector2(-15,5)*zoom,pos+Vector2(15,5)*zoom,farline_route_color,3*zoom)
			for x in [-12,-4,4,12]:draw_circle(pos+Vector2(x,-3)*zoom,3*zoom,farline_route_color,false,2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,("WITNESS ROAD" if mark.get("route","")=="accord" else "CACHEWAY")+" · "+farline_route_state.to_upper(),farline_route_color,8)
		elif mark.kind=="farline_exit":
			var farline_open=mark.get("state","")=="open";var farline_exit_color=Color("73c5ad") if farline_open else Color("596165")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("17262a"));draw_line(pos+Vector2(-13,-7)*zoom,pos+Vector2(13,7)*zoom,farline_exit_color,3*zoom);draw_line(pos+Vector2(-13,7)*zoom,pos+Vector2(13,-7)*zoom,farline_exit_color,3*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"SETTLEMENT DESCENT · "+str(mark.state).to_upper(),farline_exit_color,8)
		elif mark.kind=="farline_lore":
			draw_rect(Rect2(pos-Vector2(17,10)*zoom,Vector2(34,20)*zoom),Color("3c342d"));for y in [-6,0,6]:draw_arc(pos+Vector2(0,y)*zoom,8*zoom,0,TAU,16,Color("c5a66d"),2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"LIVING ROUTES",Color("d8b779"),8)
		elif mark.kind=="thimble":
			var thimble_state=str(mark.get("state","waiting"));var warning=thimble_state in ["defending","evacuating"];var thimble_color=Color("ef7658") if warning else Color("75c7ae") if thimble_state in ["defended","evacuated"] else Color("d9b66f")
			draw_circle(pos,14*zoom,Color("2d3838"));draw_arc(pos,10*zoom,-2.6,-.55,18,thimble_color,3*zoom);draw_line(pos+Vector2(-9,5)*zoom,pos+Vector2(9,5)*zoom,thimble_color,3*zoom);draw_circle(pos+Vector2(0,8)*zoom,3*zoom,thimble_color)
			label_at(pos+Vector2(0,-24)*zoom,"THIMBLE · "+thimble_state.to_upper(),thimble_color,8)
		elif mark.kind=="thimble_breach":
			var breach_state=str(mark.get("state","sealed"));var breach_color=Color("ef7658") if breach_state=="warning" else Color("75c7ae") if breach_state=="held" else Color("665d55")
			for x in [-12,-4,4,12]:draw_line(pos+Vector2(x,-10)*zoom,pos+Vector2(x-3,10)*zoom,breach_color,3*zoom)
			draw_line(pos+Vector2(-15,7)*zoom,pos+Vector2(15,-7)*zoom,breach_color,3*zoom);label_at(pos+Vector2(0,-22)*zoom,"UPPER BREACH · "+breach_state.to_upper(),breach_color,8)
		elif mark.kind=="thimble_evacuation":
			var lift_state=str(mark.get("state","sealed"));var lift_color=Color("efb35e") if lift_state in ["available","fallback"] else Color("75c7ae") if lift_state=="safe" else Color("666d6a")
			draw_rect(Rect2(pos-Vector2(15,12)*zoom,Vector2(30,24)*zoom),Color("1c292b"));for y in [-7,0,7]:draw_line(pos+Vector2(-11,y)*zoom,pos+Vector2(11,y)*zoom,lift_color,2*zoom)
			label_at(pos+Vector2(0,-23)*zoom,"EVAC LIFT · "+lift_state.to_upper(),lift_color,8)
		elif mark.kind=="thimble_exit":
			var road_open=mark.get("state","")=="open";var road_color=Color("75c7ae") if road_open else Color("596165")
			draw_line(pos+Vector2(-16,8)*zoom,pos+Vector2(16,8)*zoom,road_color,4*zoom);draw_line(pos+Vector2(-11,-8)*zoom,pos+Vector2(11,-8)*zoom,road_color,3*zoom);for x in [-9,0,9]:draw_line(pos+Vector2(x,-8)*zoom,pos+Vector2(x,8)*zoom,road_color,2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"LOWER ROAD · "+str(mark.state).to_upper(),road_color,8)
		elif mark.kind=="thimble_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("46342d"));for x in range(-12,13,6):draw_line(pos+Vector2(x,7)*zoom,pos+Vector2(x+3,-7)*zoom,Color("d15f55"),2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"HEAT TALLY",Color("e29a76"),8)
		elif mark.kind=="latchwater":
			var heater_state=str(mark.get("state","waiting"));var heater_color=Color("e49b58") if heater_state in ["waiting","assigned"] else Color("efb85f") if heater_state=="warm" else Color("79bfd0")
			draw_circle(pos,15*zoom,Color("253137"));draw_arc(pos,11*zoom,0,TAU,28,heater_color,3*zoom);for angle in [0.0,PI*.5,PI,PI*1.5]:draw_line(pos+Vector2(cos(angle),sin(angle))*4*zoom,pos+Vector2(cos(angle),sin(angle))*10*zoom,heater_color,2*zoom)
			label_at(pos+Vector2(0,-25)*zoom,"LATCHWATER · "+heater_state.to_upper(),heater_color,8)
		elif mark.kind=="latchwater_route":
			var route_state=str(mark.get("state","sealed"));var route_color=Color("df8058") if route_state=="open" else Color("75c6ad") if route_state=="complete" else Color("59656a")
			draw_rect(Rect2(pos-Vector2(18,11)*zoom,Vector2(36,22)*zoom),Color("1c2c31"));for x in [-12,-4,4,12]:draw_line(pos+Vector2(x,-8)*zoom,pos+Vector2(x,8)*zoom,route_color,2.5*zoom)
			label_at(pos+Vector2(0,-22)*zoom,("SERVICE" if mark.get("route","")=="resident" else "SPILLWAY" if mark.get("route","")=="refugee" else "PUBLIC DUCT")+" · "+route_state.to_upper(),route_color,8)
		elif mark.kind=="latchwater_option":
			var manifold_state=str(mark.get("state","sealed"));var manifold_color=Color("e6a15d") if manifold_state=="available" else Color("efbd64") if manifold_state=="warm" else Color("76c2d0") if manifold_state=="cold" else Color("596165")
			draw_circle(pos,13*zoom,Color("202b30"));draw_arc(pos,9*zoom,-2.7,2.7,24,manifold_color,3*zoom);draw_line(pos+Vector2(-9,5)*zoom,pos+Vector2(9,5)*zoom,manifold_color,3*zoom)
			label_at(pos+Vector2(0,-23)*zoom,"HEATER MANIFOLD · "+manifold_state.to_upper(),manifold_color,8)
		elif mark.kind=="latchwater_exit":
			var latch_open=mark.get("state","")=="open";var latch_color=Color("75c7ae") if latch_open else Color("596165")
			draw_line(pos+Vector2(-16,8)*zoom,pos+Vector2(16,8)*zoom,latch_color,4*zoom);for x in [-10,0,10]:draw_line(pos+Vector2(x,-8)*zoom,pos+Vector2(x,8)*zoom,latch_color,2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"LOWER ROAD · "+str(mark.state).to_upper(),latch_color,8)
		elif mark.kind=="latchwater_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("3d3630"));for y in [-6,0,6]:draw_line(pos+Vector2(-11,y)*zoom,pos+Vector2(11,y)*zoom,Color("d7b676"),2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"WARMTH LEDGER",Color("e1c388"),8)
		elif mark.kind=="driftglass":
			var glass_state=str(mark.get("state","waiting"));var glass_color=Color("d89b63") if glass_state in ["waiting","assigned"] else Color("f0c35e") if glass_state=="powered" else Color("78c7cf")
			var diamond=PackedVector2Array([pos+Vector2(0,-15)*zoom,pos+Vector2(14,0)*zoom,pos+Vector2(0,15)*zoom,pos+Vector2(-14,0)*zoom]);draw_colored_polygon(diamond,Color("1c2b31"));for i in 4:draw_line(diamond[i],diamond[(i+1)%4],glass_color,3*zoom)
			draw_line(pos+Vector2(-8,0)*zoom,pos+Vector2(8,0)*zoom,glass_color,2*zoom);label_at(pos+Vector2(0,-25)*zoom,"DRIFTGLASS · "+glass_state.to_upper(),glass_color,8)
		elif mark.kind=="driftglass_route":
			var glass_route_state=str(mark.get("state","sealed"));var glass_route_color=Color("e37d58") if glass_route_state=="open" else Color("75c7ae") if glass_route_state=="complete" else Color("59656a")
			draw_rect(Rect2(pos-Vector2(18,11)*zoom,Vector2(36,22)*zoom),Color("19282e"));for x in [-12,-4,4,12]:draw_line(pos+Vector2(x,-8)*zoom,pos+Vector2(-x,8)*zoom,glass_route_color,2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,("CUTTING GALLERY" if mark.get("route","")=="powered" else "MIRROR SEAM")+" · "+glass_route_state.to_upper(),glass_route_color,8)
		elif mark.kind=="driftglass_option":
			var lens_state=str(mark.get("state","sealed"));var lens_color=Color("e4a65d") if lens_state=="available" else Color("efc45d") if lens_state=="powered" else Color("78c7cf") if lens_state=="shaded" else Color("596165")
			draw_circle(pos,13*zoom,Color("1c292f"));draw_arc(pos,10*zoom,0,TAU,24,lens_color,3*zoom);draw_line(pos+Vector2(-10,0)*zoom,pos+Vector2(10,0)*zoom,lens_color,3*zoom)
			label_at(pos+Vector2(0,-23)*zoom,"LENS CRADLE · "+lens_state.to_upper(),lens_color,8)
		elif mark.kind=="driftglass_exit":
			var seam_open=mark.get("state","")=="open";var seam_color=Color("75c7ae") if seam_open else Color("596165")
			draw_line(pos+Vector2(-16,8)*zoom,pos+Vector2(16,8)*zoom,seam_color,4*zoom);draw_line(pos+Vector2(-13,-8)*zoom,pos+Vector2(13,-8)*zoom,seam_color,2*zoom);for x in [-9,0,9]:draw_line(pos+Vector2(x,-8)*zoom,pos+Vector2(x,8)*zoom,seam_color,2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"LOWER SEAM · "+str(mark.state).to_upper(),seam_color,8)
		elif mark.kind=="driftglass_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("273139"));for x in [-9,0,9]:draw_colored_polygon(PackedVector2Array([pos+Vector2(x,-7)*zoom,pos+Vector2(x+5,0)*zoom,pos+Vector2(x,7)*zoom,pos+Vector2(x-5,0)*zoom]),Color("85bfc7"))
			label_at(pos+Vector2(0,-21)*zoom,"WITNESS GLASS",Color("9ad0d5"),8)
		elif mark.kind=="bellhome":
			var bell_state=str(mark.get("state","waiting"));var bell_color=Color("ef7658") if bell_state=="warning" else Color("77c7ae") if bell_state in ["escorted","diverted"] else Color("a9a39a") if bell_state=="retreated" else Color("e4ad62")
			draw_circle(pos,15*zoom,Color("202d31"));draw_arc(pos,11*zoom,PI,TAU,24,bell_color,3*zoom);draw_line(pos+Vector2(-11,1)*zoom,pos+Vector2(11,1)*zoom,bell_color,3*zoom);draw_circle(pos+Vector2(0,10)*zoom,3*zoom,bell_color)
			label_at(pos+Vector2(0,-25)*zoom,"BELLHOME · "+bell_state.to_upper(),bell_color,8)
		elif mark.kind=="bellhome_route":
			var bell_route_state=str(mark.get("state","sealed"));var bell_route_color=Color("ef7658") if bell_route_state=="warning" else Color("76c6ad") if bell_route_state=="safe" else Color("59656a")
			draw_rect(Rect2(pos-Vector2(18,11)*zoom,Vector2(36,22)*zoom),Color("1b292e"));for x in [-12,-4,4,12]:draw_line(pos+Vector2(x,-8)*zoom,pos+Vector2(x,8)*zoom,bell_route_color,2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,("LAMPLINE" if mark.get("route","")=="lampline" else "DARKWAY")+" · "+bell_route_state.to_upper(),bell_route_color,8)
		elif mark.kind=="bellhome_convoy":
			var convoy_state=str(mark.get("state","sealed"));var convoy_color=Color("ef805d") if convoy_state=="ready" else Color("76c7ae") if convoy_state=="arrived" else Color("c3a266") if convoy_state=="diverted" else Color("727b7c")
			draw_rect(Rect2(pos-Vector2(17,9)*zoom,Vector2(34,18)*zoom),Color("263236"));draw_circle(pos+Vector2(-9,10)*zoom,4*zoom,convoy_color);draw_circle(pos+Vector2(9,10)*zoom,4*zoom,convoy_color);draw_line(pos+Vector2(-13,-4)*zoom,pos+Vector2(13,-4)*zoom,convoy_color,3*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"CONVOY · "+convoy_state.to_upper(),convoy_color,8)
		elif mark.kind=="bellhome_diversion":
			var culvert_state=str(mark.get("state","sealed"));var culvert_color=Color("d9aa62") if culvert_state=="available" else Color("75c7ae") if culvert_state=="open" else Color("707a7b")
			draw_arc(pos,14*zoom,PI,TAU,24,culvert_color,4*zoom);draw_line(pos+Vector2(-14,1)*zoom,pos+Vector2(14,1)*zoom,culvert_color,4*zoom);for x in [-8,0,8]:draw_line(pos+Vector2(x,-8)*zoom,pos+Vector2(x,1)*zoom,culvert_color,2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"CULVERT · "+culvert_state.to_upper(),culvert_color,8)
		elif mark.kind=="bellhome_exit":
			var road_open=mark.get("state","")=="open";var road_color=Color("75c7ae") if road_open else Color("596165")
			draw_line(pos+Vector2(-16,8)*zoom,pos+Vector2(16,8)*zoom,road_color,4*zoom);for y in [-5,2]:draw_line(pos+Vector2(-13,y)*zoom,pos+Vector2(13,y)*zoom,road_color,2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"SETTLEMENT ROAD · "+str(mark.state).to_upper(),road_color,8)
		elif mark.kind=="bellhome_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("39342e"));for x in [-9,0,9]:draw_circle(pos+Vector2(x,0)*zoom,5*zoom,Color("d3aa67"));draw_line(pos+Vector2(-13,7)*zoom,pos+Vector2(13,7)*zoom,Color("806f55"),2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,"ROAD-BELL COVENANT",Color("dec07f"),8)
		elif mark.kind=="commons":
			var home_state=str(mark.get("state","waiting"));var home_color=Color("75c7ae") if home_state in ["resident","culvert","public"] else Color("e2ad62")
			draw_colored_polygon(PackedVector2Array([pos+Vector2(-16,2)*zoom,pos+Vector2(0,-13)*zoom,pos+Vector2(16,2)*zoom,pos+Vector2(13,13)*zoom,pos+Vector2(-13,13)*zoom]),Color("283537"));draw_line(pos+Vector2(-16,2)*zoom,pos+Vector2(0,-13)*zoom,home_color,3*zoom);draw_line(pos+Vector2(0,-13)*zoom,pos+Vector2(16,2)*zoom,home_color,3*zoom)
			label_at(pos+Vector2(0,-24)*zoom,"COMMONS · "+home_state.to_upper(),home_color,8)
		elif mark.kind=="commons_route":
			var quarter_state=str(mark.get("state","sealed"));var quarter_color=Color("75c7ae") if quarter_state=="repaired" else Color("dba85e") if quarter_state=="open" else Color("59656a")
			draw_rect(Rect2(pos-Vector2(18,11)*zoom,Vector2(36,22)*zoom),Color("202c30"));for x in [-12,0,12]:draw_line(pos+Vector2(x,-8)*zoom,pos+Vector2(x,8)*zoom,quarter_color,3*zoom)
			label_at(pos+Vector2(0,-22)*zoom,str(mark.get("route","public")).to_upper()+" ROW · "+quarter_state.to_upper(),quarter_color,8)
		elif mark.kind=="commons_repair":
			var frame_state=str(mark.get("state","sealed"));var frame_color=Color("75c7ae") if frame_state=="complete" else Color("e1a85e") if frame_state=="available" else Color("596165")
			draw_rect(Rect2(pos-Vector2(15,12)*zoom,Vector2(30,24)*zoom),Color("273034"));draw_line(pos+Vector2(-12,-9)*zoom,pos+Vector2(12,9)*zoom,frame_color,5*zoom);draw_line(pos+Vector2(12,-9)*zoom,pos+Vector2(-12,9)*zoom,frame_color,3*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"HOUSING FRAME · "+frame_state.to_upper(),frame_color,8)
		elif mark.kind=="commons_exit":
			var dwell_open=mark.get("state","")=="open";var dwell_color=Color("75c7ae") if dwell_open else Color("596165")
			draw_line(pos+Vector2(-16,8)*zoom,pos+Vector2(16,8)*zoom,dwell_color,4*zoom);for x in [-10,0,10]:draw_colored_polygon(PackedVector2Array([pos+Vector2(x-5,5)*zoom,pos+Vector2(x,-5)*zoom,pos+Vector2(x+5,5)*zoom]),dwell_color)
			label_at(pos+Vector2(0,-22)*zoom,"LOWER DWELLINGS · "+str(mark.state).to_upper(),dwell_color,8)
		elif mark.kind=="commons_lore":
			draw_rect(Rect2(pos-Vector2(17,8)*zoom,Vector2(34,16)*zoom),Color("3b322b"));for x in [-10,0,10]:draw_line(pos+Vector2(x,-6)*zoom,pos+Vector2(x,6)*zoom,Color("c99b62"),3*zoom)
			label_at(pos+Vector2(0,-20)*zoom,"BRACE-NAME LINTEL",Color("dfba7b"),8)
		elif mark.kind=="yard":
			var yard_state=str(mark.get("state","waiting"));var yard_color=Color("76c7ae") if yard_state in ["resident","culvert","public"] else Color("e2a95e")
			draw_rect(Rect2(pos-Vector2(16,12)*zoom,Vector2(32,24)*zoom),Color("263236"));draw_arc(pos+Vector2(0,-2)*zoom,10*zoom,0,TAU,24,yard_color,3*zoom);draw_line(pos+Vector2(-15,10)*zoom,pos+Vector2(15,10)*zoom,yard_color,4*zoom)
			label_at(pos+Vector2(0,-23)*zoom,"HEARTHLINE · "+yard_state.to_upper(),yard_color,8)
		elif mark.kind=="yard_lane":
			var cargo_state=str(mark.get("state","sealed"));var cargo_color=Color("75c7ae") if cargo_state=="recovered" else Color("dda65b") if cargo_state=="open" else Color("596165")
			draw_rect(Rect2(pos-Vector2(17,10)*zoom,Vector2(34,20)*zoom),Color("202d31"));draw_circle(pos,8*zoom,cargo_color);draw_line(pos+Vector2(-13,0)*zoom,pos+Vector2(13,0)*zoom,Color("27383b"),3*zoom)
			label_at(pos+Vector2(0,-21)*zoom,("THERMAL CORE" if mark.get("cargo","")=="hearth_core" else "LIFT WINCH")+" · "+cargo_state.to_upper(),cargo_color,8)
		elif mark.kind=="yard_gantry":
			var gantry_state=str(mark.get("state","sealed"));var gantry_color=Color("75c7ae") if gantry_state=="complete" else Color("e3ae62") if gantry_state=="ready" else Color("596165")
			draw_line(pos+Vector2(-15,12)*zoom,pos+Vector2(-15,-12)*zoom,gantry_color,4*zoom);draw_line(pos+Vector2(15,12)*zoom,pos+Vector2(15,-12)*zoom,gantry_color,4*zoom);draw_line(pos+Vector2(-15,-10)*zoom,pos+Vector2(15,-10)*zoom,gantry_color,4*zoom);draw_circle(pos+Vector2(0,3)*zoom,7*zoom,gantry_color)
			label_at(pos+Vector2(0,-23)*zoom,"EXPANSION GANTRY · "+gantry_state.to_upper(),gantry_color,8)
		elif mark.kind=="yard_recruit":
			draw_circle(pos+Vector2(0,-6)*zoom,7*zoom,Color("d89d64"));draw_rect(Rect2(pos+Vector2(-7,1)*zoom,Vector2(14,14)*zoom),Color("b7774b"));label_at(pos+Vector2(0,-22)*zoom,"PELL · SPECIALIST",Color("e7bc82"),8)
		elif mark.kind=="yard_exit":
			var line_open=mark.get("state","")=="open";var line_color=Color("75c7ae") if line_open else Color("596165")
			draw_line(pos+Vector2(-17,-7)*zoom,pos+Vector2(17,-7)*zoom,line_color,4*zoom);draw_line(pos+Vector2(-17,7)*zoom,pos+Vector2(17,7)*zoom,line_color,4*zoom);for x in [-11,0,11]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,line_color,2*zoom)
			label_at(pos+Vector2(0,-20)*zoom,"LOWER LINE · "+str(mark.state).to_upper(),line_color,8)
		elif mark.kind=="yard_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("3a322b"));draw_line(pos+Vector2(-10,-5)*zoom,pos+Vector2(10,-5)*zoom,Color("d1a56b"),3*zoom);draw_line(pos+Vector2(-10,5)*zoom,pos+Vector2(10,5)*zoom,Color("d1a56b"),3*zoom);label_at(pos+Vector2(0,-21)*zoom,"SHARED-LOAD TALLY",Color("e4be82"),8)
		elif mark.kind=="kiln":
			var kiln_state=str(mark.get("state","waiting"));var kiln_color=Color("75c7ae") if kiln_state in ["built","concealed"] else Color("e09b58")
			draw_circle(pos,15*zoom,Color("2e2926"));draw_arc(pos,11*zoom,PI,TAU,24,kiln_color,4*zoom);draw_line(pos+Vector2(-11,3)*zoom,pos+Vector2(11,3)*zoom,kiln_color,3*zoom);label_at(pos+Vector2(0,-24)*zoom,"KILNREACH · "+kiln_state.to_upper(),kiln_color,8)
		elif mark.kind=="kiln_route":
			var works_state=str(mark.get("state","sealed"));var works_color=Color("75c7ae") if works_state=="complete" else Color("e0a15a") if works_state=="open" else Color("596165")
			draw_rect(Rect2(pos-Vector2(18,11)*zoom,Vector2(36,22)*zoom),Color("2b2927"));for x in [-12,-4,4,12]:draw_line(pos+Vector2(x,-8)*zoom,pos+Vector2(x,8)*zoom,works_color,2*zoom);label_at(pos+Vector2(0,-22)*zoom,str(mark.get("route","shared")).to_upper()+" WORKS · "+works_state.to_upper(),works_color,8)
		elif mark.kind=="kiln_option":
			var crown_state=str(mark.get("state","sealed"));var crown_color=Color("efb25d") if crown_state=="built" else Color("78c7cf") if crown_state=="concealed" else Color("dda15d") if crown_state=="available" else Color("596165")
			draw_circle(pos,13*zoom,Color("292725"));draw_arc(pos,9*zoom,0,TAU,24,crown_color,3*zoom);for angle in [0.0,2.1,4.2]:draw_line(pos+Vector2(cos(angle),sin(angle))*3*zoom,pos+Vector2(cos(angle),sin(angle))*11*zoom,crown_color,2*zoom);label_at(pos+Vector2(0,-23)*zoom,"FURNACE CROWN · "+crown_state.to_upper(),crown_color,8)
		elif mark.kind=="kiln_exit":
			var tram_open=mark.get("state","")=="open";var tram_color=Color("75c7ae") if tram_open else Color("596165")
			draw_line(pos+Vector2(-17,-7)*zoom,pos+Vector2(17,-7)*zoom,tram_color,4*zoom);draw_line(pos+Vector2(-17,7)*zoom,pos+Vector2(17,7)*zoom,tram_color,4*zoom);for x in [-11,0,11]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,tram_color,2*zoom);label_at(pos+Vector2(0,-20)*zoom,"LOWER TRAM · "+str(mark.state).to_upper(),tram_color,8)
		elif mark.kind=="kiln_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("3b312b"));for y in [-6,0,6]:draw_line(pos+Vector2(-11,y)*zoom,pos+Vector2(11,y)*zoom,Color("d39d62"),2*zoom);label_at(pos+Vector2(0,-21)*zoom,"COLD-SHIFT TABLETS",Color("e3b779"),8)
		elif mark.kind=="junction":
			var junction_state=str(mark.get("state","waiting"));var junction_color=Color("75c7ae") if junction_state in ["received","shunted","missed"] else Color("e3a35b")
			draw_rect(Rect2(pos-Vector2(16,12)*zoom,Vector2(32,24)*zoom),Color("242d31"));draw_circle(pos,8*zoom,junction_color);draw_line(pos+Vector2(-15,0)*zoom,pos+Vector2(15,0)*zoom,junction_color,3*zoom);label_at(pos+Vector2(0,-24)*zoom,"EMBERVAULT · "+junction_state.to_upper(),junction_color,8)
		elif mark.kind=="junction_route":
			var approach_state=str(mark.get("state","sealed"));var approach_color=Color("75c7ae") if approach_state=="complete" else Color("e3a35b") if approach_state=="warning" else Color("596165")
			draw_line(pos+Vector2(-17,-7)*zoom,pos+Vector2(17,-7)*zoom,approach_color,4*zoom);draw_line(pos+Vector2(-17,7)*zoom,pos+Vector2(17,7)*zoom,approach_color,4*zoom);for x in [-11,0,11]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,approach_color,2*zoom);label_at(pos+Vector2(0,-21)*zoom,str(mark.get("route","shadowline")).to_upper()+" · "+approach_state.to_upper(),approach_color,8)
		elif mark.kind in ["junction_platform","junction_shunt"]:
			var freight_state=str(mark.get("state","sealed"));var freight_color=Color("75c7ae") if freight_state in ["received","shunted","missed"] else Color("e3a35b") if freight_state=="warning" else Color("596165")
			draw_rect(Rect2(pos-Vector2(17,10)*zoom,Vector2(34,20)*zoom),Color("202c30"));draw_line(pos+Vector2(-13,5)*zoom,pos+Vector2(13,5)*zoom,freight_color,5*zoom);draw_circle(pos+Vector2(-8,-3)*zoom,4*zoom,freight_color);draw_circle(pos+Vector2(8,-3)*zoom,4*zoom,freight_color);label_at(pos+Vector2(0,-21)*zoom,("FREIGHT PLATFORM" if mark.kind=="junction_platform" else "REFUGE SHUNT")+" · "+freight_state.to_upper(),freight_color,8)
		elif mark.kind=="junction_exit":
			var road_open=mark.get("state","")=="open";var road_color=Color("75c7ae") if road_open else Color("596165")
			draw_line(pos+Vector2(-16,9)*zoom,pos+Vector2(16,9)*zoom,road_color,4*zoom);for x in [-11,0,11]:draw_colored_polygon(PackedVector2Array([pos+Vector2(x-5,6)*zoom,pos+Vector2(x,-6)*zoom,pos+Vector2(x+5,6)*zoom]),road_color);label_at(pos+Vector2(0,-21)*zoom,"SETTLEMENT ROAD · "+str(mark.state).to_upper(),road_color,8)
		elif mark.kind=="junction_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("33312d"));draw_arc(pos,8*zoom,0,TAU,24,Color("d8a762"),3*zoom);draw_line(pos+Vector2(-12,0)*zoom,pos+Vector2(12,0)*zoom,Color("d8a762"),2*zoom);label_at(pos+Vector2(0,-21)*zoom,"INDEPENDENT SIGNAL",Color("e5bd7c"),8)
		elif mark.kind=="ember_commons":
			var ember_state=str(mark.get("state","waiting"));var ember_color=Color("75c7ae") if ember_state in ["freight","refuge","public"] else Color("d9aa63")
			draw_rect(Rect2(pos-Vector2(16,12)*zoom,Vector2(32,24)*zoom),Color("283133"));draw_circle(pos,9*zoom,ember_color);draw_line(pos+Vector2(-13,-7)*zoom,pos+Vector2(13,7)*zoom,ember_color,3*zoom);label_at(pos+Vector2(0,-24)*zoom,"COMMONS · "+ember_state.to_upper(),ember_color,8)
		elif mark.kind=="ember_commons_route":
			var district_state=str(mark.get("state","sealed"));var district_color=Color("75c7ae") if district_state=="complete" else Color("d9aa63") if district_state=="open" else Color("596165")
			draw_rect(Rect2(pos-Vector2(18,10)*zoom,Vector2(36,20)*zoom),Color("252d2f"));for x in [-12,-4,4,12]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,district_color,2*zoom);label_at(pos+Vector2(0,-21)*zoom,str(mark.get("route","public")).to_upper()+" COURT · "+district_state.to_upper(),district_color,8)
		elif mark.kind=="ember_commons_repair":
			var house_state=str(mark.get("state","sealed"));var house_color=Color("75c7ae") if house_state in ["freight","refuge","public"] else Color("e2ad61") if house_state=="available" else Color("596165")
			draw_rect(Rect2(pos-Vector2(15,13)*zoom,Vector2(30,26)*zoom),Color("222b2e"));draw_arc(pos,9*zoom,0,TAU,24,house_color,3*zoom);draw_line(pos+Vector2(-13,0)*zoom,pos+Vector2(13,0)*zoom,house_color,3*zoom);label_at(pos+Vector2(0,-24)*zoom,"SIGNAL HOUSE · "+house_state.to_upper(),house_color,8)
		elif mark.kind=="ember_commons_exit":
			var stair_open=mark.get("state","")=="open";var stair_color=Color("75c7ae") if stair_open else Color("596165")
			for i in 4:draw_line(pos+Vector2(-14+i*4,-10+i*5)*zoom,pos+Vector2(14,-10+i*5)*zoom,stair_color,3*zoom);label_at(pos+Vector2(0,-23)*zoom,"LOWER STAIR · "+str(mark.state).to_upper(),stair_color,8)
		elif mark.kind=="ember_commons_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("36312c"));for y in [-6,0,6]:draw_line(pos+Vector2(-11,y)*zoom,pos+Vector2(11,y)*zoom,Color("d6aa6a"),2*zoom);label_at(pos+Vector2(0,-21)*zoom,"RESIDENT BOARD",Color("e5bd7c"),8)
		elif mark.kind=="deepcoil":
			var call_state=str(mark.get("state","waiting"));var call_color=Color("75c7ae") if call_state in ["keepers","freeband","echo"] else Color("c59ae8")
			draw_circle(pos,15*zoom,Color("252735"));draw_arc(pos,11*zoom,0,TAU,32,call_color,3*zoom);draw_circle(pos+Vector2(-5,0)*zoom,4*zoom,call_color);draw_circle(pos+Vector2(5,0)*zoom,4*zoom,call_color);label_at(pos+Vector2(0,-25)*zoom,"DEEPCOIL · "+call_state.to_upper(),call_color,8)
		elif mark.kind in ["deepcoil_crown","deepcoil_root"]:
			var coil_state=str(mark.get("state","sealed"));var coil_color=Color("75c7ae") if coil_state=="complete" else Color("d5a866") if coil_state=="open" else Color("596165")
			draw_circle(pos,13*zoom,Color("242a33"));draw_arc(pos,9*zoom,0,TAU,24,coil_color,3*zoom);for angle in [0.0,PI*.5,PI,PI*1.5]:draw_line(pos+Vector2(cos(angle),sin(angle))*4*zoom,pos+Vector2(cos(angle),sin(angle))*11*zoom,coil_color,2*zoom);label_at(pos+Vector2(0,-23)*zoom,("CROWN COIL" if mark.kind=="deepcoil_crown" else "ROOT COIL")+" · "+coil_state.to_upper(),coil_color,8)
		elif mark.kind=="deepcoil_sync":
			var sync_state=str(mark.get("state","sealed"));var sync_color=Color("75c7ae") if sync_state in ["keepers","freeband","echo"] else Color("d6aa68") if sync_state=="available" else Color("596165")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("232a32"));draw_circle(pos+Vector2(-8,0)*zoom,7*zoom,sync_color);draw_circle(pos+Vector2(8,0)*zoom,7*zoom,sync_color);draw_line(pos+Vector2(-1,0)*zoom,pos+Vector2(1,0)*zoom,sync_color,5*zoom);label_at(pos+Vector2(0,-24)*zoom,"PAIR SYNC · "+sync_state.to_upper(),sync_color,8)
		elif mark.kind=="deepcoil_exit":
			var answer_open=mark.get("state","")=="open";var answer_color=Color("75c7ae") if answer_open else Color("596165")
			draw_arc(pos,14*zoom,PI,TAU,24,answer_color,4*zoom);for x in [-10,0,10]:draw_line(pos+Vector2(x,-1)*zoom,pos+Vector2(x,12)*zoom,answer_color,3*zoom);label_at(pos+Vector2(0,-23)*zoom,"ANSWERED DESCENT · "+str(mark.state).to_upper(),answer_color,8)
		elif mark.kind=="deepcoil_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("34303d"));for x in [-8,8]:draw_arc(pos+Vector2(x,0)*zoom,6*zoom,-2.4,2.4,18,Color("c7a4df"),2*zoom);label_at(pos+Vector2(0,-21)*zoom,"PAIRED CALL",Color("d8b7ea"),8)
		elif mark.kind=="coilward":
			var ward_state=str(mark.get("state","waiting"));var ward_color=Color("79c9aa") if ward_state in ["keepers","freeband","echo"] else Color("d0a35f")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("302d28"));draw_arc(pos,10*zoom,0,TAU,28,ward_color,3*zoom);draw_line(pos+Vector2(-9,0)*zoom,pos+Vector2(9,0)*zoom,ward_color,3*zoom);label_at(pos+Vector2(0,-24)*zoom,"COILWARD · "+ward_state.to_upper(),ward_color,8)
		elif mark.kind=="coilward_route":
			var ward_road_state=str(mark.get("state","sealed"));var ward_road_color=Color("79c9aa") if ward_road_state=="complete" else Color("d0a35f") if ward_road_state=="open" else Color("596165")
			draw_rect(Rect2(pos-Vector2(18,10)*zoom,Vector2(36,20)*zoom),Color("292a27"));for x in [-12,-4,4,12]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,ward_road_color,2*zoom);label_at(pos+Vector2(0,-21)*zoom,str(mark.get("route","echo")).to_upper()+" ROAD · "+ward_road_state.to_upper(),ward_road_color,8)
		elif mark.kind=="coilward_seal":
			var seal_state=str(mark.get("state","sealed"));var seal_color=Color("79c9aa") if seal_state in ["keepers","freeband","echo"] else Color("ddb36f") if seal_state=="available" else Color("596165")
			draw_circle(pos,14*zoom,Color("302c27"));draw_arc(pos,10*zoom,0,TAU,32,seal_color,3*zoom);draw_colored_polygon(PackedVector2Array([pos+Vector2(-5,-5)*zoom,pos+Vector2(6,0)*zoom,pos+Vector2(-5,5)*zoom]),seal_color);label_at(pos+Vector2(0,-24)*zoom,"COUNCIL SEAL · "+seal_state.to_upper(),seal_color,8)
		elif mark.kind=="coilward_exit":
			var ward_open=mark.get("state","")=="open";var ward_exit_color=Color("79c9aa") if ward_open else Color("596165")
			for i in 4:draw_line(pos+Vector2(-14+i*4,-10+i*5)*zoom,pos+Vector2(14,-10+i*5)*zoom,ward_exit_color,3*zoom);label_at(pos+Vector2(0,-23)*zoom,"CHARTERED ROAD · "+str(mark.state).to_upper(),ward_exit_color,8)
		elif mark.kind=="coilward_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("373126"));for y in [-6,0,6]:draw_line(pos+Vector2(-11,y)*zoom,pos+Vector2(11,y)*zoom,Color("d8ad67"),2*zoom);draw_circle(pos+Vector2(11,6)*zoom,3*zoom,Color("78bea2"));label_at(pos+Vector2(0,-21)*zoom,"COMMON ARTICLES",Color("e2bd79"),8)
		elif mark.kind=="charterwell":
			var delegation_state=str(mark.get("state","waiting"));var delegation_color=Color("79c9aa") if delegation_state in ["escorted","supplied","missed"] else Color("e5a45f")
			draw_rect(Rect2(pos-Vector2(17,12)*zoom,Vector2(34,24)*zoom),Color("2f2b29"));draw_circle(pos,8*zoom,delegation_color);draw_line(pos+Vector2(-15,-7)*zoom,pos+Vector2(15,7)*zoom,delegation_color,3*zoom);label_at(pos+Vector2(0,-24)*zoom,"CHARTERWELL · "+delegation_state.to_upper(),delegation_color,8)
		elif mark.kind=="charterwell_route":
			var delegation_road_state=str(mark.get("state","sealed"));var delegation_road_color=Color("79c9aa") if delegation_road_state=="complete" else Color("e5a45f") if delegation_road_state=="warning" else Color("596165")
			draw_line(pos+Vector2(-17,-7)*zoom,pos+Vector2(17,-7)*zoom,delegation_road_color,4*zoom);draw_line(pos+Vector2(-17,7)*zoom,pos+Vector2(17,7)*zoom,delegation_road_color,4*zoom);for x in [-11,0,11]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,delegation_road_color,2*zoom);label_at(pos+Vector2(0,-21)*zoom,str(mark.get("route","public")).to_upper()+" ROAD · "+delegation_road_state.to_upper(),delegation_road_color,8)
		elif mark.kind in ["charterwell_platform","charterwell_supply"]:
			var delegation_gate_state=str(mark.get("state","sealed"));var delegation_gate_color=Color("79c9aa") if delegation_gate_state in ["escorted","supplied","missed"] else Color("e5a45f") if delegation_gate_state=="warning" else Color("596165")
			draw_rect(Rect2(pos-Vector2(17,10)*zoom,Vector2(34,20)*zoom),Color("292b2c"));draw_line(pos+Vector2(-13,5)*zoom,pos+Vector2(13,5)*zoom,delegation_gate_color,5*zoom);for x in [-8,0,8]:draw_circle(pos+Vector2(x,-3)*zoom,3*zoom,delegation_gate_color);label_at(pos+Vector2(0,-21)*zoom,("DELEGATION PLATFORM" if mark.kind=="charterwell_platform" else "SUPPLY GATE")+" · "+delegation_gate_state.to_upper(),delegation_gate_color,8)
		elif mark.kind=="charterwell_safe":
			draw_rect(Rect2(pos-Vector2(16,11)*zoom,Vector2(32,22)*zoom),Color("1e3332"));draw_line(pos+Vector2(-11,0)*zoom,pos+Vector2(11,0)*zoom,Color("79c9aa"),3*zoom);draw_line(pos+Vector2(0,-8)*zoom,pos+Vector2(0,8)*zoom,Color("79c9aa"),3*zoom);label_at(pos+Vector2(0,-22)*zoom,"STORM ROOM",Color("9bdac4"),8)
		elif mark.kind=="charterwell_exit":
			var delegation_open=mark.get("state","")=="open";var delegation_exit_color=Color("79c9aa") if delegation_open else Color("596165")
			for i in 4:draw_line(pos+Vector2(-14+i*4,-10+i*5)*zoom,pos+Vector2(14,-10+i*5)*zoom,delegation_exit_color,3*zoom);label_at(pos+Vector2(0,-23)*zoom,"DELEGATION ROAD · "+str(mark.state).to_upper(),delegation_exit_color,8)
		elif mark.kind=="charterwell_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("373126"));for y in [-6,0,6]:draw_line(pos+Vector2(-11,y)*zoom,pos+Vector2(11,y)*zoom,Color("d8ad67"),2*zoom);draw_colored_polygon(PackedVector2Array([pos+Vector2(7,3)*zoom,pos+Vector2(13,6)*zoom,pos+Vector2(8,9)*zoom]),Color("78bea2"));label_at(pos+Vector2(0,-21)*zoom,"DEPARTURE TABLETS",Color("e2bd79"),8)
		elif mark.kind=="writwell":
			var vote_state=str(mark.get("state","waiting"));var vote_color=Color("7ac9aa") if vote_state in ["delegates","exchange","commons"] else Color("e0a85f")
			draw_circle(pos,15*zoom,Color("302c29"));for angle in [-PI*.5,PI/6.0,PI*5.0/6.0]:draw_circle(pos+Vector2(cos(angle),sin(angle))*8*zoom,4*zoom,vote_color);draw_circle(pos,3*zoom,vote_color);label_at(pos+Vector2(0,-25)*zoom,"WRITWELL · "+vote_state.to_upper(),vote_color,8)
		elif mark.kind=="writwell_route":
			var vote_road_state=str(mark.get("state","sealed"));var vote_road_color=Color("7ac9aa") if vote_road_state=="complete" else Color("e0a85f") if vote_road_state=="open" else Color("596165")
			draw_rect(Rect2(pos-Vector2(18,10)*zoom,Vector2(36,20)*zoom),Color("292b2a"));for y in [-6,0,6]:draw_line(pos+Vector2(-14,y)*zoom,pos+Vector2(14,y)*zoom,vote_road_color,2*zoom);label_at(pos+Vector2(0,-21)*zoom,str(mark.get("route","commons")).to_upper()+" GALLERY · "+vote_road_state.to_upper(),vote_road_color,8)
		elif mark.kind=="writwell_table":
			var table_state=str(mark.get("state","sealed"));var table_color=Color("7ac9aa") if table_state in ["delegates","exchange","commons"] else Color("e0a85f") if table_state=="available" else Color("596165")
			draw_circle(pos,14*zoom,Color("302c29"));draw_arc(pos,11*zoom,0,TAU,32,table_color,3*zoom);for angle in [-PI*.5,PI/6.0,PI*5.0/6.0]:draw_circle(pos+Vector2(cos(angle),sin(angle))*7*zoom,3*zoom,table_color);label_at(pos+Vector2(0,-24)*zoom,"COMMON TABLE · "+table_state.to_upper(),table_color,8)
		elif mark.kind=="writwell_stores":
			var stores_open=mark.get("state","")=="open";var stores_color=Color("7ac9aa") if stores_open else Color("596165")
			draw_rect(Rect2(pos-Vector2(16,11)*zoom,Vector2(32,22)*zoom),Color("28302c"));for x in [-9,0,9]:draw_rect(Rect2(pos+Vector2(x-3,-4)*zoom,Vector2(6,10)*zoom),stores_color);label_at(pos+Vector2(0,-22)*zoom,"COMMON STORES · "+str(mark.state).to_upper(),stores_color,8)
		elif mark.kind=="writwell_exit":
			var mandate_open=mark.get("state","")=="open";var mandate_color=Color("7ac9aa") if mandate_open else Color("596165")
			for i in 4:draw_line(pos+Vector2(-14+i*4,-10+i*5)*zoom,pos+Vector2(14,-10+i*5)*zoom,mandate_color,3*zoom);label_at(pos+Vector2(0,-23)*zoom,"MANDATED ROAD · "+str(mark.state).to_upper(),mandate_color,8)
		elif mark.kind=="writwell_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("373126"));for x in [-9,0,9]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,Color("d8ad67"),2*zoom);draw_line(pos+Vector2(-12,0)*zoom,pos+Vector2(12,0)*zoom,Color("78bea2"),3*zoom);label_at(pos+Vector2(0,-21)*zoom,"PLEDGE WALL",Color("e2bd79"),8)
		elif mark.kind=="concordance":
			var gate_state=str(mark.get("state","waiting"));var gate_color=Color("79c9aa") if gate_state in ["bastion","reserve"] else Color("e3a45c")
			draw_arc(pos,15*zoom,PI,TAU,30,gate_color,4*zoom);for x in [-11,0,11]:draw_line(pos+Vector2(x,-1)*zoom,pos+Vector2(x,12)*zoom,gate_color,3*zoom);draw_circle(pos,4*zoom,gate_color);label_at(pos+Vector2(0,-25)*zoom,"CONCORDANCE · "+gate_state.to_upper(),gate_color,8)
		elif mark.kind=="concordance_route":
			var gate_road_state=str(mark.get("state","sealed"));var gate_road_color=Color("79c9aa") if gate_road_state=="complete" else Color("e3a45c") if gate_road_state=="open" else Color("596165")
			draw_rect(Rect2(pos-Vector2(18,10)*zoom,Vector2(36,20)*zoom),Color("292b2a"));for x in [-12,-4,4,12]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,gate_road_color,2*zoom);label_at(pos+Vector2(0,-21)*zoom,str(mark.get("route","public")).to_upper()+" GUARDLINE · "+gate_road_state.to_upper(),gate_road_color,8)
		elif mark.kind in ["concordance_bastion","concordance_reserve"]:
			var defense_state=str(mark.get("state","sealed"));var defense_color=Color("79c9aa") if defense_state in ["complete","bastion","reserve"] else Color("e3a45c") if defense_state=="available" else Color("596165")
			draw_rect(Rect2(pos-Vector2(16,11)*zoom,Vector2(32,22)*zoom),Color("2a302d"))
			if mark.kind=="concordance_bastion":draw_arc(pos,11*zoom,PI,TAU,24,defense_color,4*zoom)
			else:draw_colored_polygon(PackedVector2Array([pos+Vector2(-12,7)*zoom,pos+Vector2(0,-10)*zoom,pos+Vector2(12,7)*zoom]),defense_color)
			label_at(pos+Vector2(0,-23)*zoom,("FIXED BASTION" if mark.kind=="concordance_bastion" else "MOBILE RESERVE")+" · "+defense_state.to_upper(),defense_color,8)
		elif mark.kind=="concordance_stores":
			var issue_open=mark.get("state","")=="open";var issue_color=Color("79c9aa") if issue_open else Color("596165")
			draw_rect(Rect2(pos-Vector2(16,11)*zoom,Vector2(32,22)*zoom),Color("28302c"));draw_rect(Rect2(pos-Vector2(11,6)*zoom,Vector2(22,12)*zoom),issue_color);draw_circle(pos,4*zoom,Color("28302c"));label_at(pos+Vector2(0,-22)*zoom,"RESPONSE ISSUE · "+str(mark.state).to_upper(),issue_color,8)
		elif mark.kind=="concordance_exit":
			var defense_open=mark.get("state","")=="open";var defense_exit_color=Color("79c9aa") if defense_open else Color("596165")
			for i in 4:draw_line(pos+Vector2(-14+i*4,-10+i*5)*zoom,pos+Vector2(14,-10+i*5)*zoom,defense_exit_color,3*zoom);label_at(pos+Vector2(0,-23)*zoom,"COORDINATED ROAD · "+str(mark.state).to_upper(),defense_exit_color,8)
		elif mark.kind=="concordance_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("373126"));draw_arc(pos+Vector2(-7,1)*zoom,7*zoom,PI,TAU,16,Color("d8ad67"),3*zoom);draw_colored_polygon(PackedVector2Array([pos+Vector2(2,7)*zoom,pos+Vector2(8,-7)*zoom,pos+Vector2(14,7)*zoom]),Color("78bea2"));label_at(pos+Vector2(0,-21)*zoom,"GATE COMPACT",Color("e2bd79"),8)
		elif mark.kind=="reservefall":
			var rf_state=str(mark.get("state","waiting"));var rf_color=Color("74c9b7") if rf_state in ["held","withdrawn","breached"] else Color("ef9a55")
			draw_circle(pos,15*zoom,Color("2d3433"));draw_arc(pos,12*zoom,0,TAU,32,rf_color,3*zoom);draw_line(pos+Vector2(-9,6)*zoom,pos+Vector2(9,-6)*zoom,rf_color,3*zoom);label_at(pos+Vector2(0,-25)*zoom,"RESERVEFALL · "+rf_state.to_upper(),rf_color,8)
		elif mark.kind=="reservefall_route":
			var incursion_state=str(mark.get("state","sealed"));var incursion_color=Color("74c9b7") if incursion_state=="complete" else Color("ef7255") if incursion_state=="open" else Color("596165")
			draw_rect(Rect2(pos-Vector2(18,10)*zoom,Vector2(36,20)*zoom),Color("292b2a"));for i in 4:draw_colored_polygon(PackedVector2Array([pos+Vector2(-13+i*8,7)*zoom,pos+Vector2(-9+i*8,-7)*zoom,pos+Vector2(-5+i*8,7)*zoom]),incursion_color);label_at(pos+Vector2(0,-21)*zoom,"SURFACE INCURSION · "+incursion_state.to_upper(),incursion_color,8)
		elif mark.kind in ["reservefall_line","reservefall_fallback"]:
			var response_state=str(mark.get("state","sealed"));var response_color=Color("74c9b7") if response_state=="complete" else Color("efb65e") if response_state=="available" else Color("596165")
			draw_rect(Rect2(pos-Vector2(16,11)*zoom,Vector2(32,22)*zoom),Color("28302e"))
			if mark.kind=="reservefall_line":draw_line(pos+Vector2(-13,5)*zoom,pos+Vector2(13,-5)*zoom,response_color,5*zoom)
			else:draw_arc(pos,12*zoom,PI,TAU,24,response_color,4*zoom)
			label_at(pos+Vector2(0,-23)*zoom,("DEFENSE LINE" if mark.kind=="reservefall_line" else "FALLBACK GATE")+" · "+response_state.to_upper(),response_color,8)
		elif mark.kind=="reservefall_safe":
			var safe_color=Color("74c9b7") if mark.get("state","")=="open" else Color("596165");draw_rect(Rect2(pos-Vector2(15,11)*zoom,Vector2(30,22)*zoom),Color("27302f"));draw_rect(Rect2(pos-Vector2(8,7)*zoom,Vector2(16,14)*zoom),safe_color);draw_circle(pos,3*zoom,Color("27302f"));label_at(pos+Vector2(0,-22)*zoom,"SAFE ROOMS · "+str(mark.state).to_upper(),safe_color,8)
		elif mark.kind=="reservefall_exit":
			var quarter_color=Color("74c9b7") if mark.get("state","")=="open" else Color("596165");for i in 4:draw_line(pos+Vector2(-14+i*4,-10+i*5)*zoom,pos+Vector2(14,-10+i*5)*zoom,quarter_color,3*zoom);label_at(pos+Vector2(0,-23)*zoom,"INHABITED ROAD · "+str(mark.state).to_upper(),quarter_color,8)
		elif mark.kind=="reservefall_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("373126"));for y in [-6,0,6]:draw_line(pos+Vector2(-12,y)*zoom,pos+Vector2(12,y)*zoom,Color("d8ad67"),2*zoom);draw_circle(pos+Vector2(8,0)*zoom,4*zoom,Color("e36f55"));label_at(pos+Vector2(0,-21)*zoom,"SIGNAL BOARD",Color("e2bd79"),8)
		elif mark.kind=="reserve_commons":
			var commons_state=str(mark.get("state","waiting"));var commons_color=Color("79cbb4") if commons_state in ["guarded","sheltered","public"] else Color("dfaa62")
			draw_circle(pos,15*zoom,Color("2b3432"));draw_arc(pos,12*zoom,0,TAU,32,commons_color,3*zoom);draw_rect(Rect2(pos-Vector2(5,8)*zoom,Vector2(10,16)*zoom),commons_color);label_at(pos+Vector2(0,-25)*zoom,"RESERVEFALL COMMONS · "+commons_state.to_upper(),commons_color,8)
		elif mark.kind=="reserve_commons_route":
			var commons_route_state=str(mark.get("state","sealed"));var route_color=Color("79cbb4") if commons_route_state=="complete" else Color("e0aa62") if commons_route_state=="open" else Color("596165")
			for i in 3:draw_arc(pos+Vector2(-9+i*9,0)*zoom,7*zoom,PI,TAU,20,route_color,3*zoom);label_at(pos+Vector2(0,-22)*zoom,"RECEPTION ROAD · "+commons_route_state.to_upper(),route_color,8)
		elif mark.kind=="reserve_commons_cache":
			var cache_color=Color("79cbb4") if mark.get("state","")=="recovered" else Color("dca65e") if mark.get("state","")=="open" else Color("596165");draw_rect(Rect2(pos-Vector2(14,10)*zoom,Vector2(28,20)*zoom),Color("2e3330"));draw_colored_polygon(PackedVector2Array([pos+Vector2(-9,0)*zoom,pos+Vector2(0,-8)*zoom,pos+Vector2(9,0)*zoom,pos+Vector2(0,9)*zoom]),cache_color);label_at(pos+Vector2(0,-22)*zoom,"SHIELD CACHE · "+str(mark.state).to_upper(),cache_color,8)
		elif mark.kind=="reserve_commons_repair":
			var repair_state=str(mark.get("state","sealed"));var repair_color=Color("79cbb4") if repair_state in ["guarded","sheltered","public"] else Color("efb15f") if repair_state=="available" else Color("596165")
			draw_arc(pos,14*zoom,PI,TAU,24,repair_color,5*zoom);draw_line(pos+Vector2(-12,5)*zoom,pos+Vector2(12,5)*zoom,repair_color,4*zoom);label_at(pos+Vector2(0,-23)*zoom,"REPAIR COURT · "+repair_state.to_upper(),repair_color,8)
		elif mark.kind=="reserve_commons_exit":
			var descent_color=Color("79cbb4") if mark.get("state","")=="open" else Color("596165");for i in 4:draw_line(pos+Vector2(-14+i*4,-10+i*5)*zoom,pos+Vector2(14,-10+i*5)*zoom,descent_color,3*zoom);label_at(pos+Vector2(0,-23)*zoom,"SHIELDLINE · "+str(mark.state).to_upper(),descent_color,8)
		elif mark.kind=="reserve_commons_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("373126"));for x in [-9,0,9]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,Color("d8ad67"),2*zoom);label_at(pos+Vector2(0,-21)*zoom,"DEFENSE LEDGER",Color("e2bd79"),8)
		elif mark.kind=="shieldline":
			var shield_state=str(mark.get("state","waiting"));var shield_color=Color("7dd1bd") if shield_state in ["guarded","sheltered","public"] else Color("e2ad63")
			draw_rect(Rect2(pos-Vector2(17,11)*zoom,Vector2(34,22)*zoom),Color("293332"));for i in 3:draw_line(pos+Vector2(-14,-7+i*7)*zoom,pos+Vector2(14,-7+i*7)*zoom,shield_color,3*zoom);draw_circle(pos+Vector2(-10,11)*zoom,4*zoom,shield_color);draw_circle(pos+Vector2(10,11)*zoom,4*zoom,shield_color);label_at(pos+Vector2(0,-25)*zoom,"SHIELDLINE WORKS · "+shield_state.to_upper(),shield_color,8)
		elif mark.kind=="shieldline_lane":
			var lane_state=str(mark.get("state","sealed"));var lane_color=Color("7dd1bd") if lane_state=="recovered" else Color("e2ad63") if lane_state=="open" else Color("596165")
			draw_rect(Rect2(pos-Vector2(14,10)*zoom,Vector2(28,20)*zoom),Color("2a3332"));draw_line(pos+Vector2(-10,-6)*zoom,pos+Vector2(10,6)*zoom,lane_color,5*zoom);draw_circle(pos+Vector2(-10,-6)*zoom,4*zoom,lane_color);draw_circle(pos+Vector2(10,6)*zoom,4*zoom,lane_color);label_at(pos+Vector2(0,-22)*zoom,("FRAME" if mark.get("cargo","")=="shield_frame" else "AXLE")+" · "+lane_state.to_upper(),lane_color,8)
		elif mark.kind=="shieldline_carriage":
			var carriage_state=str(mark.get("state","sealed"));var carriage_color=Color("7dd1bd") if carriage_state=="complete" else Color("efb15f") if carriage_state=="ready" else Color("596165")
			draw_rect(Rect2(pos-Vector2(17,9)*zoom,Vector2(34,18)*zoom),Color("2c3433"));draw_arc(pos,13*zoom,PI,TAU,24,carriage_color,4*zoom);draw_circle(pos+Vector2(-11,9)*zoom,4*zoom,carriage_color);draw_circle(pos+Vector2(11,9)*zoom,4*zoom,carriage_color);label_at(pos+Vector2(0,-23)*zoom,"ASSEMBLY · "+carriage_state.to_upper(),carriage_color,8)
		elif mark.kind=="shieldline_recruit":
			draw_circle(pos,14*zoom,Color("35423f"));draw_circle(pos,8*zoom,Color("90c8bd"));label_at(pos+Vector2(0,-23)*zoom,"KEST · WAITING",Color("9ed8c8"),8)
		elif mark.kind=="shieldline_exit":
			var works_color=Color("7dd1bd") if mark.get("state","")=="open" else Color("596165");for i in 4:draw_line(pos+Vector2(-14+i*4,-10+i*5)*zoom,pos+Vector2(14,-10+i*5)*zoom,works_color,3*zoom);label_at(pos+Vector2(0,-23)*zoom,"LOWER WORKS · "+str(mark.state).to_upper(),works_color,8)
		elif mark.kind=="shieldline_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("373126"));draw_arc(pos,11*zoom,PI,TAU,24,Color("d8ad67"),3*zoom);for x in [-8,8]:draw_circle(pos+Vector2(x,8)*zoom,3*zoom,Color("d8ad67"));label_at(pos+Vector2(0,-21)*zoom,"WALKING WALL",Color("e2bd79"),8)
		elif mark.kind=="marchhold":
			var march_state=str(mark.get("state","waiting"));var march_color=Color("82d2c2") if march_state in ["deployed","retreated","overrun"] else Color("f0aa5d")
			draw_arc(pos,15*zoom,PI,TAU,28,march_color,4*zoom);draw_line(pos+Vector2(-13,4)*zoom,pos+Vector2(13,4)*zoom,march_color,4*zoom);draw_circle(pos+Vector2(-10,10)*zoom,4*zoom,march_color);draw_circle(pos+Vector2(10,10)*zoom,4*zoom,march_color);label_at(pos+Vector2(0,-25)*zoom,"MARCHHOLD · "+march_state.to_upper(),march_color,8)
		elif mark.kind=="marchhold_route":
			var march_route_state=str(mark.get("state","sealed"));var march_route_color=Color("82d2c2") if march_route_state=="complete" else Color("ed7a59") if march_route_state=="open" else Color("596165")
			draw_rect(Rect2(pos-Vector2(18,10)*zoom,Vector2(36,20)*zoom),Color("29302f"));for i in 4:draw_line(pos+Vector2(-14+i*9,7)*zoom,pos+Vector2(-10+i*9,-7)*zoom,march_route_color,3*zoom);label_at(pos+Vector2(0,-22)*zoom,str(mark.get("route","public")).to_upper()+" CROSSING · "+march_route_state.to_upper(),march_route_color,8)
		elif mark.kind=="marchhold_cache":
			var wall_color=Color("82d2c2") if mark.get("state","")=="recovered" else Color("efb15f") if mark.get("state","")=="open" else Color("596165");draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("2c3332"));for y in [-6,0,6]:draw_line(pos+Vector2(-12,y)*zoom,pos+Vector2(12,y)*zoom,wall_color,3*zoom);draw_circle(pos+Vector2(-10,9)*zoom,3*zoom,wall_color);draw_circle(pos+Vector2(10,9)*zoom,3*zoom,wall_color);label_at(pos+Vector2(0,-22)*zoom,"FOLDED WALL · "+str(mark.state).to_upper(),wall_color,8)
		elif mark.kind in ["marchhold_line","marchhold_fallback"]:
			var march_choice_state=str(mark.get("state","sealed"));var march_choice_color=Color("82d2c2") if march_choice_state=="complete" else Color("efb15f") if march_choice_state=="available" else Color("596165")
			draw_rect(Rect2(pos-Vector2(16,11)*zoom,Vector2(32,22)*zoom),Color("293231"))
			if mark.kind=="marchhold_line":
				for x in [-10,0,10]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,march_choice_color,4*zoom)
			else:draw_colored_polygon(PackedVector2Array([pos+Vector2(-13,7)*zoom,pos+Vector2(0,-9)*zoom,pos+Vector2(13,7)*zoom]),march_choice_color)
			label_at(pos+Vector2(0,-23)*zoom,("DEPLOYMENT LINE" if mark.kind=="marchhold_line" else "RETREAT RAMP")+" · "+march_choice_state.to_upper(),march_choice_color,8)
		elif mark.kind=="marchhold_safe":
			var alcove_color=Color("82d2c2") if mark.get("state","")=="open" else Color("596165");draw_arc(pos+Vector2(-7,2)*zoom,8*zoom,PI,TAU,20,alcove_color,4*zoom);draw_arc(pos+Vector2(7,2)*zoom,8*zoom,PI,TAU,20,alcove_color,4*zoom);label_at(pos+Vector2(0,-22)*zoom,"REFUGE ALCOVES · "+str(mark.state).to_upper(),alcove_color,8)
		elif mark.kind=="marchhold_exit":
			var march_exit_color=Color("82d2c2") if mark.get("state","")=="open" else Color("596165");for i in 4:draw_line(pos+Vector2(-14+i*4,-10+i*5)*zoom,pos+Vector2(14,-10+i*5)*zoom,march_exit_color,3*zoom);label_at(pos+Vector2(0,-23)*zoom,"LOWER ROAD · "+str(mark.state).to_upper(),march_exit_color,8)
		elif mark.kind=="marchhold_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("373126"));for x in [-9,-3,3,9]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,Color("d8ad67"),2*zoom);draw_line(pos+Vector2(-12,0)*zoom,pos+Vector2(12,0)*zoom,Color("82c9b8"),3*zoom);label_at(pos+Vector2(0,-21)*zoom,"MOBILE-CAMP TALLY",Color("e2bd79"),8)
		elif mark.kind=="march_refuge":
			var refuge_state=str(mark.get("state","waiting"));var refuge_color=Color("86d3bd") if refuge_state in ["guarded","sheltered","public","walled"] else Color("e7a75e")
			draw_arc(pos,16*zoom,PI,TAU,28,refuge_color,4*zoom);draw_rect(Rect2(pos-Vector2(13,1)*zoom,Vector2(26,10)*zoom),Color("303a37"));for x in [-9,0,9]:draw_line(pos+Vector2(x,-2)*zoom,pos+Vector2(x,9)*zoom,refuge_color,3*zoom);label_at(pos+Vector2(0,-25)*zoom,"MARCHHOLD REFUGE · "+refuge_state.to_upper(),refuge_color,8)
		elif mark.kind=="march_refuge_route":
			var refuge_route_state=str(mark.get("state","sealed"));var refuge_route_color=Color("86d3bd") if refuge_route_state=="complete" else Color("eba65c") if refuge_route_state=="open" else Color("596165")
			for i in 3:draw_arc(pos+Vector2(-9+i*9,1)*zoom,7*zoom,PI,TAU,20,refuge_route_color,3*zoom);label_at(pos+Vector2(0,-22)*zoom,str(mark.get("route","public")).to_upper()+" REFUGE ROAD · "+refuge_route_state.to_upper(),refuge_route_color,8)
		elif mark.kind=="march_refuge_cache":
			var brace_color=Color("86d3bd") if mark.get("state","")=="recovered" else Color("efb15f") if mark.get("state","")=="open" else Color("596165");draw_rect(Rect2(pos-Vector2(14,10)*zoom,Vector2(28,20)*zoom),Color("2c3332"));draw_line(pos+Vector2(-9,-7)*zoom,pos+Vector2(9,7)*zoom,brace_color,5*zoom);draw_line(pos+Vector2(9,-7)*zoom,pos+Vector2(-9,7)*zoom,brace_color,5*zoom);label_at(pos+Vector2(0,-22)*zoom,"REFUGE BRACE · "+str(mark.state).to_upper(),brace_color,8)
		elif mark.kind=="march_refuge_repair":
			var refuge_repair_state=str(mark.get("state","sealed"));var refuge_repair_color=Color("86d3bd") if refuge_repair_state in ["guarded","sheltered","public","walled"] else Color("efb15f") if refuge_repair_state=="available" else Color("596165")
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("293231"));for x in [-10,0,10]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,refuge_repair_color,4*zoom);label_at(pos+Vector2(0,-23)*zoom,"COMMUNAL YARD · "+refuge_repair_state.to_upper(),refuge_repair_color,8)
		elif mark.kind=="march_refuge_exit":
			var refuge_exit_color=Color("86d3bd") if mark.get("state","")=="open" else Color("596165");for i in 4:draw_line(pos+Vector2(-14+i*4,-10+i*5)*zoom,pos+Vector2(14,-10+i*5)*zoom,refuge_exit_color,3*zoom);label_at(pos+Vector2(0,-23)*zoom,"DEEP REFUGE ROAD · "+str(mark.state).to_upper(),refuge_exit_color,8)
		elif mark.kind=="march_refuge_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("373126"));for y in [-6,0,6]:draw_line(pos+Vector2(-12,y)*zoom,pos+Vector2(12,y)*zoom,Color("d8ad67"),2*zoom);draw_circle(pos+Vector2(9,0)*zoom,4*zoom,Color("86c9b7"));label_at(pos+Vector2(0,-21)*zoom,"WALL-KEEPER TALLY",Color("e2bd79"),8)
		elif mark.kind=="wallward":
			var wallward_state=str(mark.get("state","waiting"));var wallward_color=Color("86d3bd") if wallward_state in ["escorted","screened","missed"] else Color("f0aa5d")
			draw_line(pos+Vector2(0,-13)*zoom,pos+Vector2(0,10)*zoom,wallward_color,4*zoom);draw_circle(pos+Vector2(0,-13)*zoom,6*zoom,wallward_color);for x in [-9,9]:draw_line(pos,pos+Vector2(x,7)*zoom,wallward_color,3*zoom);label_at(pos+Vector2(0,-25)*zoom,"WALLWARD · "+wallward_state.to_upper(),wallward_color,8)
		elif mark.kind=="wallward_route":
			var wr_state=str(mark.get("state","sealed"));var wr_color=Color("86d3bd") if wr_state=="complete" else Color("ed7a59") if wr_state=="open" else Color("596165")
			for i in 4:draw_line(pos+Vector2(-14+i*5,-10+i*5)*zoom,pos+Vector2(14,-10+i*5)*zoom,wr_color,3*zoom);label_at(pos+Vector2(0,-23)*zoom,str(mark.get("route","public")).to_upper()+" CONVOY ROAD · "+wr_state.to_upper(),wr_color,8)
		elif mark.kind=="wallward_cache":
			var beacon_color=Color("86d3bd") if mark.get("state","")=="recovered" else Color("efb15f") if mark.get("state","")=="open" else Color("596165");draw_circle(pos,12*zoom,beacon_color);draw_circle(pos,6*zoom,Color("2b3333"));draw_line(pos+Vector2(0,-16)*zoom,pos+Vector2(0,16)*zoom,beacon_color,3*zoom);label_at(pos+Vector2(0,-24)*zoom,"CONVOY BEACON · "+str(mark.state).to_upper(),beacon_color,8)
		elif mark.kind in ["wallward_rally","wallward_screen"]:
			var wc_state=str(mark.get("state","sealed"));var wc_color=Color("86d3bd") if wc_state in ["escorted","screened","missed"] else Color("efb15f") if wc_state=="available" else Color("596165")
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("293231"));for x in [-10,0,10]:draw_circle(pos+Vector2(x,1)*zoom,4*zoom,wc_color);label_at(pos+Vector2(0,-23)*zoom,("CONVOY RALLY" if mark.kind=="wallward_rally" else "SCREENED BYPASS")+" · "+wc_state.to_upper(),wc_color,8)
		elif mark.kind=="wallward_safe":
			draw_arc(pos,13*zoom,PI,TAU,24,Color("82c9b8"),4*zoom);draw_circle(pos+Vector2(0,5)*zoom,4*zoom,Color("82c9b8"));label_at(pos+Vector2(0,-22)*zoom,"REFUGE ALCOVE",Color("82c9b8"),8)
		elif mark.kind=="wallward_exit":
			var way_color=Color("86d3bd") if mark.get("state","")=="open" else Color("596165");for i in 4:draw_line(pos+Vector2(-14+i*4,-10+i*5)*zoom,pos+Vector2(14,-10+i*5)*zoom,way_color,3*zoom);label_at(pos+Vector2(0,-23)*zoom,"WAYFARER ROAD · "+str(mark.state).to_upper(),way_color,8)
		elif mark.kind=="wallward_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("373126"));for x in [-8,0,8]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,Color("d8ad67"),3*zoom);label_at(pos+Vector2(0,-21)*zoom,"CONVOY CHALKBOARD",Color("e2bd79"),8)
		elif mark.kind in ["wayfarer","wayfarer_repair"]:
			var road_state=str(mark.get("state","waiting"));var road_color=Color("8cd9c4") if road_state in ["resident","hidden","public","complete"] else Color("edb266") if road_state!="sealed" else Color("596165")
			draw_rect(Rect2(pos-Vector2(16,9)*zoom,Vector2(32,18)*zoom),Color("263638"))
			for x in [-11,11]:draw_circle(pos+Vector2(x,10)*zoom,5*zoom,road_color)
			if mark.kind=="wayfarer_repair":
				draw_line(pos+Vector2(0,9)*zoom,pos+Vector2(0,-14)*zoom,road_color,4*zoom)
				draw_line(pos+Vector2(-9,-14)*zoom,pos+Vector2(9,-14)*zoom,road_color,3*zoom)
			else:
				for x in [-7,7]:draw_line(pos+Vector2(x,-8)*zoom,pos+Vector2(x,6)*zoom,road_color,3*zoom)
			label_at(pos+Vector2(0,-26)*zoom,("SHARED ROADSTEAD" if mark.kind=="wayfarer_repair" else "ROADKEEPER SENN")+" · "+road_state.to_upper(),road_color,8)
		elif mark.kind=="wayfarer_cache":
			var jack_color=Color("8cd9c4") if mark.get("state","")=="installed" else Color("edb266") if mark.get("state","")=="open" else Color("596165")
			draw_line(pos+Vector2(-12,10)*zoom,pos+Vector2(12,10)*zoom,jack_color,4*zoom);draw_line(pos+Vector2(0,-12)*zoom,pos+Vector2(0,10)*zoom,jack_color,4*zoom)
			for y in [-6,0,6]:draw_line(pos+Vector2(-6,y+2)*zoom,pos+Vector2(6,y-2)*zoom,jack_color,2*zoom)
			draw_line(pos+Vector2(-11,-12)*zoom,pos+Vector2(11,-12)*zoom,jack_color,3*zoom);label_at(pos+Vector2(0,-24)*zoom,"ROADSTEAD JACK · 6 KG",jack_color,8)
		elif mark.kind in ["wayfarer_route","wayfarer_exit"]:
			var lane_color=Color("8cd9c4") if mark.get("state","") in ["open","complete"] else Color("596165")
			for x in [-10,10]:draw_line(pos+Vector2(x,-12)*zoom,pos+Vector2(x,12)*zoom,lane_color,3*zoom)
			for y in [-8,0,8]:draw_line(pos+Vector2(-8,y)*zoom,pos+Vector2(8,y)*zoom,lane_color,2*zoom)
			label_at(pos+Vector2(0,-24)*zoom,("UNDERWAY ROAD" if mark.kind=="wayfarer_exit" else str(mark.get("route","public")).to_upper()+" WAGON LANE")+" · "+str(mark.state).to_upper(),lane_color,8)
		elif mark.kind=="wayfarer_lore":
			draw_rect(Rect2(pos-Vector2(16,10)*zoom,Vector2(32,20)*zoom),Color("373126"));for x in [-7,7]:draw_line(pos+Vector2(x,-7)*zoom,pos+Vector2(x,7)*zoom,Color("e0b76f"),3*zoom);draw_line(pos+Vector2(-12,0)*zoom,pos+Vector2(12,0)*zoom,Color("8cd9c4"),2*zoom);label_at(pos+Vector2(0,-22)*zoom,"SHARED-LOAD LEDGER",Color("e0b76f"),8)
		elif mark.kind=="transit_sign":
			draw_rect(Rect2(pos+Vector2(-15,-9)*zoom,Vector2(30,18)*zoom),Color("29393c"))
			draw_rect(Rect2(pos+Vector2(-12,-6)*zoom,Vector2(24,12)*zoom),Color("b78c49"))
			draw_line(pos+Vector2(-8,0)*zoom,pos+Vector2(7,0)*zoom,Color("1c292b"),2*zoom)
			label_at(pos+Vector2(0,-20)*zoom,"EASTBOUND",Color("e4c582"),10)
		elif mark.kind=="train_wreck":
			draw_colored_polygon(PackedVector2Array([pos+Vector2(-18,9)*zoom,pos+Vector2(-13,-10)*zoom,pos+Vector2(14,-7)*zoom,pos+Vector2(18,9)*zoom]),Color("4b5656"))
			draw_rect(Rect2(pos+Vector2(-8,-5)*zoom,Vector2(6,7)*zoom),Color("151e20"))
			draw_rect(Rect2(pos+Vector2(4,-4)*zoom,Vector2(6,7)*zoom),Color("151e20"))
			label_at(pos+Vector2(0,-20)*zoom,"LAST TRAIN",Color("b9c4b7"),10)
		elif mark.kind=="memorial":
			for i in 3:draw_line(pos+Vector2(-10+i*7,-9)*zoom,pos+Vector2(-8+i*7,7)*zoom,Color("a59a88"),2*zoom)
			draw_circle(pos+Vector2(0,9)*zoom,4*zoom,Color("edb75f"))
			label_at(pos+Vector2(0,-20)*zoom,"REMEMBERED",Color("d2c3a1"),10)
		elif mark.kind=="unstable_roof":
			var warning=mark.get("state","")=="warning"
			var collapsed=mark.get("state","")=="collapsed"
			var hazard_color=Color("d77a58") if warning else Color("655f54") if collapsed else Color("c5a467")
			draw_line(pos+Vector2(-13,12)*zoom,pos+Vector2(-9,-11)*zoom,hazard_color,4*zoom)
			draw_line(pos+Vector2(13,12)*zoom,pos+Vector2(9,-11)*zoom,hazard_color,4*zoom)
			if not collapsed:draw_line(pos+Vector2(-10,-9)*zoom,pos+Vector2(10,-9)*zoom,hazard_color,4*zoom)
			for i in 3:draw_circle(pos+Vector2(-9+i*9,4+i%2*5)*zoom,3*zoom,Color("817668"))
			label_at(pos+Vector2(0,-21)*zoom,("CAVE-IN %.1f"%float(mark.get("timer",0))) if warning else "RUBBLE" if collapsed else "UNSTABLE",Color("ff9b73") if warning else Color("d7bd83"),10)
		elif mark.kind=="spring":
			var untouched=mark.get("state","")=="untouched"
			var water=Color("66ddd0") if untouched else Color("5e756e")
			draw_circle(pos,16*zoom,Color(0.05,0.12,0.13,.78))
			draw_circle(pos,12*zoom,water*Color(1,1,1,.55))
			draw_arc(pos,8*zoom,0,TAU,24,Color("c0fff1") if untouched else Color("87958d"),2*zoom)
			if untouched:
				for i in 4:draw_circle(pos+Vector2.from_angle(clock*.7+i*TAU/4)*8*zoom,2*zoom,Color("d9fff6"))
			label_at(pos+Vector2(0,-25)*zoom,"LUMINOUS SPRING" if untouched else "DRY SPRING",water,10)
		elif mark.kind=="fossil":
			for i in 4:draw_arc(pos,(4+i*3)*zoom,-.8,TAU-.8,18,Color("c8b993")*Color(1,1,1,.75-float(i)*.1),2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"FOSSIL WALL",Color("d4c39c"),10)
		elif mark.kind=="roots":
			for i in 5:
				var end=pos+Vector2(-14+i*7,14 if i%2==0 else 10)*zoom
				draw_line(pos+Vector2((i-2)*3,-13)*zoom,end,Color("c7c6a0"),2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"PALE ROOTS",Color("d8d5ae"),10)
		elif mark.kind=="pump_console":
			var active=mark.get("state","")=="idle"
			draw_rect(Rect2(pos-Vector2(14,12)*zoom,Vector2(28,24)*zoom),Color("243b40"))
			draw_circle(pos+Vector2(-6,-2)*zoom,4*zoom,Color("e8b95e") if active else Color("554f45"))
			draw_line(pos+Vector2(2,-6)*zoom,pos+Vector2(10,7)*zoom,Color("8fbeb7") if active else Color("596b68"),3*zoom)
			label_at(pos+Vector2(0,-23)*zoom,"EMERGENCY PUMP" if active else "PUMP SPENT",Color("e6c77d") if active else Color("899894"),10)
		elif mark.kind=="flooded_route":
			var state=str(mark.get("state","flooded"));var water=Color("4f9aa0") if state=="flooded" else Color("75b6a3") if state=="drained" else Color("4a5960")
			for i in 3:draw_arc(pos+Vector2(0,(i-1)*5)*zoom,12*zoom,-2.9,-.25,12,water,2*zoom)
			label_at(pos+Vector2(0,-22)*zoom,"WATERLOCK" if state=="flooded" else "OPEN ROUTE" if state=="drained" else "SEALED",water,10)
		elif mark.kind=="quarter_lore":
			draw_rect(Rect2(pos-Vector2(11,13)*zoom,Vector2(22,26)*zoom),Color("5b6665"))
			for i in 3:draw_line(pos+Vector2(-7,-7+i*6)*zoom,pos+Vector2(7,-7+i*6)*zoom,Color("c3bd9d"),1.5*zoom)
			label_at(pos+Vector2(0,-23)*zoom,"CITY RECORD",Color("d2c8a7"),10)
		else: draw_string(font,pos,"?",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("72c9c1"))
	if selected < world.data.pawns.size():
		var p = world.data.pawns[selected]
		if p.z == depth and not p.job.is_empty() and p.job.has("path"):
			var previous = screen(Vector2(p.x+.5,p.y+.5))
			for a in p.job.path:
				var next = screen(Vector2(a[0]+.5,a[1]+.5))
				if f.seen.has(world.cell_key(world.vec(a))): draw_line(previous,next,Color(.75,.73,.45,.35),2*zoom)
				previous = next
			var job_target=world.vec(p.job.target)
			if f.seen.has(world.cell_key(job_target)):
				label_at(screen(Vector2(job_target)+Vector2(.5,.5))+Vector2(0,-25)*zoom,_order_name(p.job),Color("e6c47e"),11)
		if p.z==depth and not p.orders.is_empty():
			var previous=screen(Vector2(p.x+.5,p.y+.5))
			if not p.job.is_empty() and not p.job.get("path",[]).is_empty():
				var path_last=p.job.path[-1]
				previous=screen(Vector2(path_last[0]+.5,path_last[1]+.5))
			var number=1
			for order in p.orders:
				if int(order.get("z",depth))!=depth:continue
				var target=world.vec(order.target)
				if not f.seen.has(world.cell_key(target)):continue
				var at=screen(Vector2(target)+Vector2(.5,.5))
				draw_dashed_line(previous,at,Color(.53,.78,.70,.35),2*zoom,7*zoom)
				draw_circle(at,10*zoom,Color("274947"))
				draw_arc(at,10*zoom,0,TAU,18,Color("a5d2c2"),2*zoom)
				draw_string(font,at+Vector2(-4,5)*zoom,str(number),HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e5e2c8"))
				previous=at;number+=1
	for e in f.enemies:
		if not world.is_visible(depth,world.point(e)): continue
		var pos = screen(Vector2(e.x+.5,e.y+.5))
		draw_circle(pos+Vector2(0,7)*zoom,12*zoom,Color(0,0,0,.4))
		if e.name=="Burrower":
			draw_colored_polygon(PackedVector2Array([pos+Vector2(-16,7)*zoom,pos+Vector2(-10,-5)*zoom,pos+Vector2(0,-9)*zoom,pos+Vector2(12,-4)*zoom,pos+Vector2(17,8)*zoom]),Color("647568"))
			draw_line(pos+Vector2(-10,4)*zoom,pos+Vector2(-18,11)*zoom,Color("a5b19b"),3*zoom)
			draw_line(pos+Vector2(10,4)*zoom,pos+Vector2(18,11)*zoom,Color("a5b19b"),3*zoom)
			draw_arc(pos+Vector2(0,-5)*zoom,7*zoom,-2.7,-.45,12,Color("bed1b8"),2*zoom)
		elif e.name=="Gloam stalker":
			draw_colored_polygon(PackedVector2Array([pos+Vector2(-15,8)*zoom,pos+Vector2(-8,-7)*zoom,pos+Vector2(0,-12)*zoom,pos+Vector2(9,-6)*zoom,pos+Vector2(15,8)*zoom]),Color("35454b"))
			draw_arc(pos+Vector2(0,-5)*zoom,8*zoom,-2.7,-.45,12,Color("a8c9bd"),2*zoom)
			draw_circle(pos+Vector2(-5,-6)*zoom,1.8*zoom,Color("e4b767"));draw_circle(pos+Vector2(5,-6)*zoom,1.8*zoom,Color("e4b767"))
		else:
			draw_colored_polygon(PackedVector2Array([pos+Vector2(-13,5)*zoom,pos+Vector2(-6,-8)*zoom,pos+Vector2(4,-10)*zoom,pos+Vector2(13,3)*zoom,pos+Vector2(5,9)*zoom]),Color("955c55"))
			draw_circle(pos+Vector2(-4,-5)*zoom,2*zoom,Color("ffac6a"))
			draw_circle(pos+Vector2(4,-5)*zoom,2*zoom,Color("ffac6a"))
		draw_rect(Rect2(pos+Vector2(-12,-17)*zoom,Vector2(24,3)*zoom),Color("34272a"))
		var enemy_max=36.0 if e.name=="Gloam stalker" else 30.0
		draw_rect(Rect2(pos+Vector2(-12,-17)*zoom,Vector2(24*e.hp/enemy_max,3)*zoom),Color("d97661"))
		var intent=world.enemy_intent(depth,e)
		label_at(pos+Vector2(0,-24)*zoom,str(intent.cue),Color("d8c58e") if e.name=="Surface husk" else Color("c8b675") if e.name=="Gloam stalker" else Color("a9d1bb"),9)
	for i in world.data.pawns.size():
		var p = world.data.pawns[i]
		if p.z != depth: continue
		var pos = screen(Vector2(p.x+.5,p.y+.5))
		if p.hp <= 0:
			draw_line(pos-Vector2(8,8)*zoom,pos+Vector2(8,8)*zoom,Color("97645a"),3*zoom)
			continue
		if world.incapacitated(p):
			draw_circle(pos+Vector2(0,8)*zoom,13*zoom,Color(0,0,0,.45))
			draw_colored_polygon(PackedVector2Array([pos+Vector2(-16,5)*zoom,pos+Vector2(-9,-4)*zoom,pos+Vector2(12,-2)*zoom,pos+Vector2(17,7)*zoom]),Color("8f655b"))
			draw_circle(pos+Vector2(-12,-3)*zoom,6*zoom,Color("c7ad8d"))
			if i==selected:draw_arc(pos,18*zoom,0,TAU,32,Color("ef8b68"),2*zoom)
			label_at(pos+Vector2(0,-21)*zoom,p.name.to_upper()+" · DOWN",Color("ef9879"),11)
			continue
		var moving = not p.job.is_empty() and not p.job.get("path",[]).is_empty()
		var bob = sin(clock*13)*1.5 if moving else sin(clock*2)*.6
		draw_circle(pos+Vector2(0,7)*zoom,12*zoom,Color(0,0,0,.45))
		if i == selected:
			draw_arc(pos,17*zoom,0,TAU,32,Color("ecc686"),2*zoom)
			draw_arc(pos,21*zoom,clock*.3,clock*.3+1.5,16,Color(.9,.75,.48,.4),zoom)
		var coat = Color("c2995c") if p.color == "amber" else Color("9b6f55") if p.color=="rust" else Color("5b9d98")
		draw_rect(Rect2(pos+Vector2(-7,3+bob)*zoom,Vector2(5,8)*zoom),Color("1c282b"))
		draw_rect(Rect2(pos+Vector2(3,3-bob)*zoom,Vector2(5,8)*zoom),Color("1c282b"))
		draw_style_box(_coat_box(coat),Rect2(pos+Vector2(-9,-5+bob)*zoom,Vector2(18,14)*zoom))
		if p.equipment.body=="armor":
			draw_rect(Rect2(pos+Vector2(-10,-4+bob)*zoom,Vector2(20,8)*zoom),Color("47585a"),true)
			draw_line(pos+Vector2(-8,-1+bob)*zoom,pos+Vector2(8,-1+bob)*zoom,Color("9aada8"),2*zoom)
		draw_circle(pos+Vector2(0,-10+bob)*zoom,7*zoom,Color("ccb595"))
		draw_arc(pos+Vector2(0,-11+bob)*zoom,7*zoom,PI,TAU,12,Color("44473e"),4*zoom)
		draw_circle(pos+Vector2(p.facing*4,-12+bob)*zoom,2.5*zoom,Color("fae3a6"))
		if world.weight(p.inventory) > 3: draw_rect(Rect2(pos+Vector2(-12,-3)*zoom,Vector2(6,12)*zoom),Color("675d42"))
		if p.drafted: draw_line(pos+Vector2(9,1)*zoom,pos+Vector2(18,-6)*zoom,Color("d1d8c9"),3*zoom)
		label_at(pos+Vector2(0,31)*zoom,p.name.to_upper(),Color("e8dfc4") if i == selected else Color("9cbbb1"),12)
	if building != "" and world.valid(hovered) and f.seen.has(world.cell_key(hovered)):
		var valid = world.can_place(depth,hovered)
		draw_rect(Rect2(screen(Vector2(hovered)),Vector2.ONE*t),Color(0.3,0.85,0.65,.25) if valid else Color(0.9,0.3,0.25,.3))
	# A restrained dust layer, independent of unseen terrain.
	for i in 22:
		var pos = Vector2(fmod(i*173.2+sin(clock*.1+i)*20,size.x),fmod(i*73.7+clock*2,size.y))
		draw_circle(pos,1.0,Color(.6,.8,.77,.10))
	_draw_minimap(f)

func _coat_box(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(5)
	return style

func _order_name(order:Dictionary)->String:
	match str(order.get("kind","")):
		"walk":return "MOVE"
		"search":return "SEARCH"
		"transfer":return "TAKE" if order.get("extra",{}).get("direction","")=="take" else "STORE"
		"build":return "BUILD"
		"construct":return "CONSTRUCT"
		"dismantle":return "PACK UP"
		"reset_alarm":return "RESET ALARM"
		"rescue":return "RESCUE"
		"tend":return "TEND"
		"retreat":return "RALLY"
		"talk":return "TALK"
		"spring":return "DRINK" if order.get("extra",{}).get("choice","")=="drink" else "HARVEST"
		"pump":return "DRAIN HOMES" if order.get("extra",{}).get("choice","")=="residences" else "DRAIN GRID"
		"outpost":return "AID WARD" if order.get("extra",{}).get("choice","")=="aid" else "TRADE"
		"bellwether":return "COURIER CAGE" if order.get("extra",{}).get("choice","")=="courier" else "BYPASS"
		"spindle":return "GATE WATCH"
		"ashline":return "ACCEPT REQUEST" if order.get("extra",{}).get("action","")=="accept" else "DELIVER FILTER"
		"service":return "CITY SHIFT" if order.get("extra",{}).get("choice","")=="city" else "FIELD CHARTER"
		"foundry":
			var action=str(order.get("extra",{}).get("action",""))
			return "ACCEPT REPAIR" if action=="accept" else "INSTALL REGULATOR" if action=="deliver" else "POST BOND"
		"archive":
			var action=str(order.get("extra",{}).get("action",""))
			return "OPEN STACKS" if action=="open" else "SHARE DOSSIER" if action=="share" else "PRESERVE DOSSIER"
		"wake":return "BEGIN RECOVERY" if order.get("extra",{}).get("action","")=="start" else "ALIGN ROUTE"
		"quiet":return "TUNE POST "+str(order.get("extra",{}).get("stage",0)) if order.get("extra",{}).get("action","")=="tune" else "REPLAY SIGNAL"
		"stillworks":return "RESTORE AIR" if order.get("extra",{}).get("choice","")=="restore" else "KEEP DARK"
		"cistern":return "OPEN RESERVOIR" if order.get("extra",{}).get("action","")=="start" else "INSTALL SEAL"
		"drowned":
			var drowned_action=str(order.get("extra",{}).get("action",""))
			return "CYCLE SLUICE" if drowned_action=="start" else "RESCUE KEEPER" if drowned_action=="rescue" else "CUT REGULATOR"
		"tidecourt":
			var court_action=str(order.get("extra",{}).get("action",""))
			return "OLAN SPONSOR" if court_action=="sponsor" else "POST BOND" if court_action=="contract" else "OPEN RECORDS" if court_action=="start" else "RETURN DOCKET"
		"sump":return "OPEN PUMP ROUTE" if order.get("extra",{}).get("action","")=="start" else "INSTALL IMPELLER"
		"depot":return "OPEN FREIGHT" if order.get("extra",{}).get("action","")=="start" else "INSTALL FREIGHT"
		"travel":return "TRAVEL"
		"rest":return "REST"
		"attack":return "ATTACK"
	return "ORDER"

func _draw_structure(s: Dictionary,t: float,visible: bool):
	var pos = screen(Vector2(s.x+.5,s.y+.5))
	var dim = 1.0 if visible else .35
	var ink = Color("b99b69")*Color(dim,dim,dim,1)
	match s.kind:
		"lamp":
			for i in range(5,0,-1): draw_circle(pos,t*i*.5,Color(1.0,.72,.34,.013))
			draw_line(pos+Vector2(0,8)*zoom,pos+Vector2(0,-7)*zoom,ink,3*zoom)
			draw_circle(pos+Vector2(0,-8)*zoom,5*zoom,Color("ffe2a0")*Color(dim,dim,dim,1))
		"bench":
			draw_rect(Rect2(pos-Vector2(15,9)*zoom,Vector2(30,22)*zoom),Color("172124"))
			draw_rect(Rect2(pos-Vector2(16,13)*zoom,Vector2(32,19)*zoom),ink)
			draw_line(pos+Vector2(-8,-9)*zoom,pos+Vector2(9,2)*zoom,Color("485e61"),4*zoom)
		"stockpile":
			draw_rect(Rect2(pos-Vector2(14,12)*zoom,Vector2(28,25)*zoom),ink)
			draw_rect(Rect2(pos-Vector2(12,10)*zoom,Vector2(24,10)*zoom),Color("426964")*Color(dim,dim,dim,1))
			if visible:
				var c=world.container_by_id(depth,int(s.id))
				var automatic=bool(c.get("auto_haul",true))
				label_at(pos-Vector2(0,24)*zoom,"AUTO STOCKPILE" if automatic else "MANUAL STOCKPILE",Color("8fd7c2") if automatic else Color("aeaaa0"),10)
		"bed":
			draw_rect(Rect2(pos-Vector2(11,17)*zoom,Vector2(22,34)*zoom),Color("728775")*Color(dim,dim,dim,1))
			draw_rect(Rect2(pos-Vector2(9,15)*zoom,Vector2(18,8)*zoom),Color("c2c0a1")*Color(dim,dim,dim,1))
		"barricade":
			for i in 3: draw_rect(Rect2(pos+Vector2(-17,-13+i*9)*zoom,Vector2(34,6)*zoom),ink)
		"shieldwall":
			for i in 3:draw_rect(Rect2(pos+Vector2(-18,-13+i*8)*zoom,Vector2(36,6)*zoom),Color("6f918a")*Color(dim,dim,dim,1))
			draw_line(pos+Vector2(-12,-14)*zoom,pos+Vector2(-8,13)*zoom,ink,4*zoom);draw_line(pos+Vector2(12,-14)*zoom,pos+Vector2(8,13)*zoom,ink,4*zoom)
			draw_circle(pos+Vector2(-11,13)*zoom,4*zoom,Color("c9b16f")*Color(dim,dim,dim,1));draw_circle(pos+Vector2(11,13)*zoom,4*zoom,Color("c9b16f")*Color(dim,dim,dim,1))
		"tripwire":
			var state=str(s.get("state","armed"));var ring=float(s.get("ring",0))
			draw_line(pos+Vector2(-17,10)*zoom,pos+Vector2(-17,-10)*zoom,ink,3*zoom)
			draw_line(pos+Vector2(17,10)*zoom,pos+Vector2(17,-10)*zoom,ink,3*zoom)
			draw_line(pos+Vector2(-16,-4)*zoom,pos+Vector2(16,5)*zoom,Color("c2aa7c")*Color(dim,dim,dim,1),2*zoom)
			draw_circle(pos+Vector2(0,1)*zoom,4*zoom,Color("d56d52")*Color(dim,dim,dim,1))
			if state=="ringing":
				var pulse=.82+.18*sin(clock*8.0)
				draw_arc(pos,t*HollowWorld.TRIPWIRE_RADIUS*pulse,0,TAU,80,Color(0.96,0.48,0.27,.22*dim),2*zoom)
			if visible or state=="ringing":
				var label="RINGING %.0fs"%ceil(ring) if state=="ringing" else "RESET" if state=="spent" else "ARMED"
				label_at(pos+Vector2(0,-25)*zoom,label,Color("f09a6d") if state=="ringing" else Color("b4d7bd") if state=="armed" else Color("a7a29a"),10)
		"decoy":
			var pulse=.86+.14*sin(clock*4.0)
			draw_arc(pos,t*HollowWorld.DECOY_RADIUS,0,TAU,96,Color(0.92,0.46,0.27,.20*dim),2*zoom)
			draw_arc(pos,t*3.2*pulse,0,TAU,48,Color(0.96,0.67,0.31,.28*dim),2*zoom)
			draw_line(pos+Vector2(-10,13)*zoom,pos+Vector2(0,-12)*zoom,ink,3*zoom)
			draw_line(pos+Vector2(10,13)*zoom,pos+Vector2(0,-12)*zoom,ink,3*zoom)
			draw_circle(pos+Vector2(0,-10)*zoom,7*zoom,Color("dc7a4d")*Color(dim,dim,dim,1))
			draw_arc(pos+Vector2(0,-10)*zoom,12*zoom,-.7,.7,12,Color("ffc36d")*Color(dim,dim,dim,1),2*zoom)
			if visible:label_at(pos+Vector2(0,-29)*zoom,"HUSK LURE",Color("f1a268"),10)
		"relay":
			for i in range(3,0,-1): draw_circle(pos,t*i*.45,Color(.3,.8,.78,.02))
			draw_rect(Rect2(pos-Vector2(11,7)*zoom,Vector2(22,20)*zoom),Color("557c79")*Color(dim,dim,dim,1))
			draw_line(pos,pos-Vector2(0,22)*zoom,ink,3*zoom)
			draw_arc(pos-Vector2(0,22)*zoom,10*zoom,0,PI,12,Color("86dacc"),2*zoom)

func _draw_minimap(f: Dictionary):
	var scale = 1.6
	var origin = Vector2(size.x-HollowWorld.W*scale-14,14)
	draw_rect(Rect2(origin-Vector2.ONE*5,Vector2(HollowWorld.W,HollowWorld.H)*scale+Vector2.ONE*10),Color(.025,.045,.05,.85))
	for cell in f.seen:
		var parts = cell.split(":")
		var p = Vector2i(int(parts[0]),int(parts[1]))
		if f.grid[p.y][p.x] == 1: draw_rect(Rect2(origin+Vector2(p)*scale,Vector2.ONE*scale),Color("465c56"))
	for p in world.data.pawns:
		if p.z == depth and p.hp>0: draw_circle(origin+Vector2(p.x,p.y)*scale,2,Color("d97862") if world.incapacitated(p) else Color("e7c88d"))
	var down = world.vec(f.down)
	if f.seen.has(world.cell_key(down)): draw_circle(origin+Vector2(down)*scale,2,Color("76cfbc"))
