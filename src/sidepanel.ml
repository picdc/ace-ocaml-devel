
open Dom_html

module H = Hashtbl


let add_file container file =
  let id, project, filename =
    file.Filemanager.id,
    file.Filemanager.project,
    file.Filemanager.filename
  in
  let li = createLi document in
  let is_open = ref false in

  Ace_utils.console_debug id;
  Ace_utils.console_debug filename;


  li##className <- Js.string "side_class_file_name";
  li##id <- Js.string (Format.sprintf "side_file_%d" id);
  li##innerHTML <- Js.string filename;
  li##onclick <- handler (fun _ -> 
    if not !is_open then 
      (let callback _ content =
	 Ace_utils.console_debug id;
	 Tabs.add_tab id filename content;
	 Tabs.change_tab id
       in
       Filemanager.open_file ~callback ~project ~filename;
       is_open := true)
    else
      begin
	if Tabs.exist_tab id then Tabs.change_tab id
	else 
	  let callback _ content =
	    Tabs.add_tab id filename content;
	    Tabs.change_tab id
	  in
	  Filemanager.open_file ~callback ~project ~filename
      end;
    Js._true);
  
  Dom.appendChild container li

let rename_file container filename =
  container##innerHTML <- (Js.string filename)



let focused_project = ref None

let create_file project filename =
  let filename = "untitled.ml" in (* FOR TEST *)
  Event_manager.create_file#trigger (project, filename)


let right_clic_dialog_opened_project =
  let lstr = [ "Create new file" ] in
  let handler_new_file = handler (fun _ ->
    match !focused_project with
    | None -> assert false
    | Some project ->
      create_file project "untitled.ml";
      Js._true)
  in		 
  let lhandler = [ handler_new_file ] in
  Dialog.Right_clic_dialog.create lstr lhandler

let right_clic_dialog_closed_project =
  let lstr = [ "Open project" ] in
  let handler_open_project = handler (fun _ ->
    match !focused_project with
    | None -> assert false
    | Some project ->
      Event_manager.open_project#trigger project;
      Js._true)
  in		 
  let lhandler = [ handler_open_project ] in
  Dialog.Right_clic_dialog.create lstr lhandler

let add_project container title =
  let li = createLi document in
  let ul = createUl document in
  let span = createSpan document in
  let is_shown = ref false in

  li##className <- Js.string "side_class_project_item";
  ul##className <- Js.string "side_class_file_list";
  ul##id <- Js.string ("side_project_"^title);
  span##className <- Js.string "side_class_project_name";
  span##innerHTML <- Js.string title;
  span##onclick <- handler (fun ev ->
    if not (Filemanager.is_project_opened title) then
      (Event_manager.open_project#trigger title;
       is_shown := true)
    else if not !is_shown then
      (ul##style##display <- Js.string "";
       is_shown := true)
    else
      (ul##style##display <- Js.string "none";
       is_shown := false);
    Js._true);
  let hand = handler (fun ev ->
    let ev = Js.Opt.get (Dom_html.CoerceTo.mouseEvent ev) (fun () ->
      failwith "fail on coerceTo mouseEvent TAG:#48977") in
    focused_project := Some title;
    let x = ev##clientX in
    let y = ev##clientY in
    if Filemanager.is_project_opened title then
      Dialog.Right_clic_dialog.show right_clic_dialog_opened_project x y
    else Dialog.Right_clic_dialog.show right_clic_dialog_closed_project x y;
    Js._false
  ) in
  Ace_utils.make_event_oncontextmenu span hand;
  
  Dom.appendChild li span;
  Dom.appendChild li ul;
  Dom.appendChild container li




let make_sidepanel () =
  let div = createDiv document in
  let sideprojects = createUl document in
  div##id <- Js.string "sidepanel";


  sideprojects##id <- Js.string "side_projects";
  let callback ls =
    List.iter (fun el -> add_project sideprojects el) ls in
  Filemanager.open_workspace ~callback; 
  

  let callback_rename_file file =
    let id, project, filename =
      file.Filemanager.id,
      file.Filemanager.project,
      file.Filemanager.filename in
    let id_container = Format.sprintf "side_file_%d" id in
    let container = Ace_utils.get_element_by_id id_container in
    rename_file container filename
  in

  let callback_create_file file =
    let project = file.Filemanager.project in
    let id_container = "side_project_"^project in
    let container = Ace_utils.get_element_by_id id_container in
    add_file container file
  in

  let callback_open_project files =
    let project = (List.hd files).Filemanager.project in
    let id_container = "side_project_"^project in
    let container = Ace_utils.get_element_by_id id_container in
    List.iter (fun file ->
      add_file container file) files
  in

  Event_manager.create_file#add_event callback_create_file;
  Event_manager.rename_file#add_event callback_rename_file;
  Event_manager.open_project#add_event callback_open_project;

  Dom.appendChild div sideprojects;
  div
    
