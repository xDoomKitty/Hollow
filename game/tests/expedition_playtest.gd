extends "res://tests/input_playtest.gd"
## Exercise the expedition planner through real viewport input.

func run():
	root.size=Vector2i(844,390)
	game=load("res://main.tscn").instantiate();root.add_child(game)
	await settle();await click(find_button(game.popup,"Begin the descent"))
	var w=game.world
	w.data.paused=true
	w.ensure_floor(1);w.ensure_floor(2)
	for z in 3:w.floor_at(z).enemies.clear()
	for name in ["Vale","Tavi","Pell","Kest"]:w.data.pawns.append(w.make_pawn(name,8,6,"teal"))
	for pawn in w.data.pawns:pawn.work={"haul":0,"build":0}
	var ash=w.data.pawns[0];var iona=w.data.pawns[1]
	ash.z=2;var landing=w.vec(w.floor_at(2).up);ash.x=landing.x;ash.y=landing.y
	iona.inventory={"convoy_tally":1,"scrap":2}
	w.reveal_all();game.select_pawn(0);await settle()
	w.data.paused=false
	await click(find_button(game,"Crew"))
	check(w.data.paused and game.popup_kind=="expedition","Crew opens a paused planning overview")
	var scroll=game.popup.find_child("ExpeditionScroll",true,false)
	check(scroll is ScrollContainer and scroll.get_v_scroll_bar().max_value>scroll.size.y,"Six colonists fit in a bounded scrolling list")
	var jobs=JSON.stringify(w.data.pawns.map(func(pawn):return pawn.job))
	await gesture(scroll.get_global_rect().get_center(),Vector2(0,-120),true)
	check(scroll.scroll_vertical>60 and JSON.stringify(w.data.pawns.map(func(pawn):return pawn.job))==jobs,"Dragging the crew cards scrolls without issuing an order")
	check_bounds(game.popup)
	await click(find_button(game.popup,"Find Iona"))
	check(game.selected==1 and game.map.depth==0 and game.map.follow and w.data.paused,"Find selects the correct colonist and floor while remaining paused")
	game.select_pawn(0);game.show_expedition();await settle()
	var iona_card=find_button(game.popup,"Find Iona").get_parent().get_parent()
	await click(find_button(iona_card,"Join depth 3"))
	check(iona.job.get("kind","")=="travel" and iona.z==0 and w.data.paused,"Join depth issues physical multi-floor travel without teleporting")
	check(game.popup_kind=="expedition" and find_button(game.popup,"Find Iona")!=null,"Planning stays open after a regroup order")
	w.cancel(1)
	await click(find_button(game.popup,"Cargo"))
	var search=game.popup.find_child("CargoSearch",true,false)
	check(search is LineEdit,"Cargo has a mobile search field")
	search.text="tally";search.text_changed.emit(search.text);await settle()
	check(game.expedition_list.get_child_count()==1,"Searching cargo filters to the actual matching owner")
	await click(find_button(game.popup,"Find owner"))
	check(game.selected==1 and game.map.depth==0 and iona.inventory.convoy_tally==1,"Cargo owner lookup changes selection without moving goods")
	game.show_expedition("cargo");await settle()
	search=game.popup.find_child("CargoSearch",true,false);search.text="scrap";search.text_changed.emit(search.text);await settle()
	check(find_button(game.popup,"Find owner")==null,"Essential cargo hides ordinary supplies")
	await click(find_button(game.popup,"Essential cargo"))
	check(find_button(game.popup,"Find owner")!=null,"All cargo reveals the selected supply and preserves the search")
	var cache=w.floor_at(1).containers[0];cache.searched=true;cache.items={"roadstead_jack":1}
	w.floor_at(1).seen[w.cell_key(w.point(cache))]=true
	game.expedition_query="jack";game.show_expedition("cargo");await settle()
	await click(find_button(game.popup,"Locate storage"))
	check(game.map.depth==1 and game.selected==1 and not game.map.follow and game.header.text.contains("VIEW ONLY"),"Stored cargo locates its remembered floor without teleporting a colonist")
	var before_job=iona.job.duplicate(true);var before_pack=iona.inventory.duplicate(true)
	await tap_tile(w.point(cache))
	check(iona.job==before_job and iona.inventory==before_pack and game.popup==null,"Clicks on a remote remembered floor cannot issue orders on the selected pawn's floor")
	await click(find_button(game,"Follow"))
	check(game.map.depth==int(iona.z),"Follow returns from remembered storage to the actual colonist")
	game.expedition_query="";game.expedition_essentials=false
	for viewport in [Vector2i(844,390),Vector2i(960,540),Vector2i(1280,800)]:
		root.size=viewport;await settle()
		for tab in ["crew","cargo"]:
			game.show_expedition(tab);await settle();check_bounds(game.popup)
			scroll=game.popup.find_child("ExpeditionScroll",true,false)
			check(root.get_visible_rect().encloses(scroll.get_global_rect()),"Planner scroll pane fits "+str(viewport)+" "+tab)
			await capture("expedition-"+tab+"-"+str(viewport.x))
	game.close_popup();w.cancel(1)
	check(w.data.paused,"Closing planning waits for an explicit Play")
	print("EXPEDITION INPUT RESULT: "+str(checks)+" checks / "+str(failures)+" failures")
	quit(0 if failures==0 else 1)
