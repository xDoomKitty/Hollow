extends "res://tests/ui_playtest.gd"
## Real viewport gestures complement the campaign's selected-target checks.
var row_taps = 0

func mouse_button(at:Vector2,pressed:bool,device:int=0):
	var event=InputEventMouseButton.new()
	event.position=at;event.global_position=at;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=pressed;event.device=device
	root.push_input(event,true)

func gesture(start:Vector2,delta:Vector2,touch:bool,canceled:bool=false):
	if touch:
		var press=InputEventScreenTouch.new();press.index=0;press.position=start;press.pressed=true
		root.push_input(press,true)
	else:mouse_button(start,true)
	await process_frame
	for step in range(1,5):
		var at=start+delta*float(step)/4.0
		if touch:
			var drag=InputEventScreenDrag.new();drag.index=0;drag.position=at;drag.relative=delta/4.0
			root.push_input(drag,true)
		else:
			var drag=InputEventMouseMotion.new();drag.position=at;drag.global_position=at;drag.relative=delta/4.0;drag.button_mask=MOUSE_BUTTON_MASK_LEFT
			root.push_input(drag,true)
		await process_frame
	if touch:
		var release=InputEventScreenTouch.new();release.index=0;release.position=start+delta;release.pressed=false;release.canceled=canceled
		root.push_input(release,true)
	else:mouse_button(start+delta,false)
	await settle()

func tap_tile(at:Vector2i):
	game.map.follow=false;game.map.focus=Vector2(at)+Vector2.ONE*.5
	await settle()
	var screen=game.map.global_position+game.map.screen(Vector2(at)+Vector2.ONE*.5)
	check(game.map.get_global_rect().has_point(screen),"Object is on the visible map")
	mouse_button(screen,true);mouse_button(screen,false)
	await settle()

func run():
	root.size=Vector2i(844,390)
	game=load("res://main.tscn").instantiate();root.add_child(game)
	await settle();await click(find_button(game.popup,"Begin the descent"))
	game.world.data.paused=true
	var w=game.world;var pawn=w.data.pawns[0];var cache=w.floor_at(0).containers[0]
	cache.searched=true
	game.open_inventory(int(cache.id));await settle()
	var rows=game.inv_rows
	var storage_scroll=rows["take:timber"].get_parent().get_parent()
	var pack_scroll=rows["store:rations"].get_parent().get_parent()
	check(storage_scroll is ScrollContainer and pack_scroll is ScrollContainer,"Both physical inventories have scroll panes")
	game.inv_item="scrap";game.refresh_inventory()
	rows["take:timber"].pressed.connect(func():row_taps+=1)
	var row_start=rows["take:timber"].get_global_rect().get_center()
	var camera=game.map.focus
	await gesture(row_start,Vector2(0,-110),true)
	check(storage_scroll.scroll_vertical>80 and game.inv_item=="scrap" and row_taps==0,"Dragging an active row scrolls without selecting it")
	check(pack_scroll.scroll_vertical==0 and game.map.focus==camera,"Inventory dragging does not scroll the other pack or pan the map")
	var disabled_start=storage_scroll.get_global_rect().get_center()
	await gesture(disabled_start,Vector2(0,-95),true)
	check(storage_scroll.scroll_vertical>170,"Disabled and empty item rows also drag")
	await gesture(storage_scroll.get_global_rect().get_center(),Vector2(0,240),false)
	check(storage_scroll.scroll_vertical==0,"Mouse drag scrolls in the reverse direction and clamps at the top")
	await gesture(row_start,Vector2(1,2),true)
	check(row_taps==1 and game.inv_item=="timber","A short touch with small jitter selects exactly one row")
	mouse_button(row_start,true,InputEvent.DEVICE_ID_EMULATION);mouse_button(row_start,false,InputEvent.DEVICE_ID_EMULATION);await settle()
	check(row_taps==1,"Emulated Android mouse events do not duplicate the touch action")
	await gesture(row_start,Vector2.ZERO,true,true)
	check(row_taps==1,"A canceled touch never clicks the row")
	await gesture(pack_scroll.get_global_rect().get_center(),Vector2(0,-100),false)
	check(pack_scroll.scroll_vertical>70 and storage_scroll.scroll_vertical==0,"Each inventory pane scrolls independently with mouse input")
	check_bounds(game.popup)
	game.close_popup();await settle()
	var sidebar=game.pawn_info.get_parent().get_parent().get_parent()
	var selected_before=game.selected
	await gesture(game.pawn_buttons[0].get_global_rect().get_center(),Vector2(0,-140),true)
	check(sidebar.scroll_vertical>0 and game.selected==selected_before,"The colonist command list drags without pressing its buttons")
	sidebar.scroll_vertical=0;await settle()
	for i in 40:w.data.log.append("Journey note %d: a long passage under the old city."%i)
	game.show_journal();await settle()
	var journal_scroll=game.popup.find_children("*","ScrollContainer",true,false)[0]
	await gesture(journal_scroll.get_global_rect().get_center(),Vector2(0,-120),true)
	check(journal_scroll.scroll_vertical>90,"Journal text drags to older entries")
	game.close_popup();await settle()
	game.show_build();await settle()
	var recipes_scroll=game.popup.find_children("*","ScrollContainer",true,false)[0]
	await gesture(recipes_scroll.get_global_rect().get_center(),Vector2(0,-110),true)
	check(recipes_scroll.scroll_vertical>0 and game.building=="","Dragging the build list reveals recipes without arming placement")
	check_bounds(game.popup)
	game.close_popup();await settle()
	cache.searched=false
	var contents=cache.items.duplicate(true);var pack=pawn.inventory.duplicate(true);var start=w.point(pawn)
	await tap_tile(w.point(cache))
	check(pawn.job.get("kind","")=="interact" and not pawn.job.path.is_empty() and game.popup==null,"One map click starts walking without opening remote storage")
	check(w.point(pawn)==start and not cache.searched,"Paused object orders wait for Play")
	game.select_pawn(1);await finish_order(0)
	check(cache.searched and game.popup_kind=="inventory" and game.inv_id==cache.id and game.selected==0,"Arrival searches and opens the correct container for the original colonist")
	check(cache.items==contents and pawn.inventory==pack,"Arrival never guesses transfer quantities or changes ownership")
	w.data.paused=true
	await click(game.inv_rows["take:timber"]);await click(game.inv_plus);await click(game.inv_action);await finish_order(0)
	check(pawn.inventory.get("timber",0)==2 and cache.items.timber==contents.timber-2,"The arrival picker still transfers only the two chosen units")
	game.close_popup();w.cancel(0);w.data.paused=true;pawn.x=start.x;pawn.y=start.y;w.reveal_all();game.map.follow=true;await settle()
	await tap_tile(w.point(cache));await click(game.cancel_button)
	w.data.paused=false;w.tick(.25);await settle()
	check(pawn.job.is_empty() and game.popup==null,"Clear cancels the approach and its future popup")
	w.data.paused=true
	var no_order=pawn.job.duplicate(true)
	await gesture(game.map.get_global_rect().get_center(),Vector2(90,40),false)
	check(pawn.job==no_order and not game.map.follow,"Dragging the map still pans without issuing an object command")
	game.map.follow=true;await settle()
	await tap_tile(Vector2i(9,9))
	check(pawn.job.get("kind","")=="talk","A traveler click starts the physical conversation order")
	await finish_order(0)
	check(w.data.traveler and game.popup_kind=="story","The traveler speaks only once the colonist arrives")
	game.close_popup();w.data.paused=true
	# A choice-bearing object opens its options only after arrival.
	w.ensure_floor(3);pawn.z=3;var spring=w.floor_at(3).landmarks.filter(func(mark):return mark.kind=="spring")[0]
	var spring_path=w.path_to(3,w.vec(w.floor_at(3).up),w.point(spring),true)
	var approach=w.vec(spring_path[max(0,spring_path.size()-4)])
	pawn.x=approach.x;pawn.y=approach.y;w.floor_at(3).enemies.clear();w.reveal_all();game.select_pawn(0);game.map.focus=Vector2(approach)+Vector2.ONE*.5;await settle()
	await tap_tile(w.point(spring))
	check(pawn.job.get("kind","")=="interact" and game.popup==null,"Clicking a spring approaches before showing choices")
	await finish_order(0)
	check(game.popup_kind=="spring" and spring.state=="untouched","Arrival displays drink or harvest without choosing either")
	if game.popup:check_bounds(game.popup)
	game.close_popup();w.data.paused=true
	var bed_spot=Vector2i(-1,-1)
	for direction in w.DIRS:
		var candidate=w.point(pawn)+direction
		if w.can_place(3,candidate) and not w.floor_at(3).landmarks.any(func(mark):return w.point(mark)==candidate):bed_spot=candidate;break
	check(w.valid(bed_spot),"Rest fixture uses an empty reachable floor tile")
	w.floor_at(3).structures.append(w.make_structure("bed",bed_spot));w.reveal_all()
	await tap_tile(bed_spot)
	check(pawn.job.get("kind","")=="rest","A bedroll click directly orders physical rest")
	game.world.cancel(0)
	# Releasing a drag over the map must not turn into a stray click.
	var orphan_release=game.map.get_global_rect().get_center()
	mouse_button(orphan_release,false,InputEvent.DEVICE_ID_EMULATION);await settle()
	check(pawn.job.is_empty(),"A list drag released over the map cannot issue a stray order")
	w.data.paused=true
	var stair=w.vec(w.floor_at(3).up)
	w.floor_at(3).seen[w.cell_key(stair)]=true
	await tap_tile(stair)
	check(pawn.job.get("kind","")=="travel","A stair click directly orders connected floor travel")
	await finish_order(0)
	check(int(pawn.z)==2,"The stair click physically moves the colonist to the connected floor")
	print("INPUT RESULT: "+str(checks)+" checks / "+str(failures)+" failures")
	quit(0 if failures==0 else 1)
