
open Dom_html

module H = Hashtbl


let add_file container project title =
  let li = createLi document in
  let is_open = ref false in

  li##className <- Js.string "side_class_file_name";
  li##innerHTML <- Js.string title;
  li##onclick <- handler (fun _ -> 
    if not !is_open then 
      (let callback s =
	 let id = Filemanager.add_file project title in
	 Tabs.add_tab id title s;
	 Tabs.change_tab id
       in
       Request.get_content_of_file ~callback ~project ~filename:title;
       is_open := true)
    else
      begin
	let id = Filemanager.get_id project title in
	if Tabs.exist_tab id then Tabs.change_tab id
	else 
	  (let callback s = Tabs.add_tab id title s in
	   Request.get_content_of_file ~callback ~project ~filename:title)
      end;
    Js._true);
  
  Dom.appendChild container li





let focused_project = ref None

let create_file project name =
  let title = "untitled.ml" in
  let id_container = "side_class_file_list_container_"^project in
  let container = Ace_utils.get_element_by_id id_container in
  
  (* Fonction à appeler pour créer un fichier *)
  let create_fun () =
    let callback id =
      add_file container project name;
      Tabs.add_tab id name "";
      Tabs.change_tab id in
    Filemanager.create_file ~callback ~project ~filename:title
  in

  (* Si le dossier n'est pas ouvert alors on l'ouvre puis après son 
     ouverture, on crée le fichier (donc dans son callback) *)
  if not (Filemanager.is_project_opened project) then
   let callback lstr =
     create_fun ();
     List.iter (fun el ->
	  add_file container name el) lstr in
   Filemanager.open_project ~callback ~project

  (* Sinon on crée directement le fichier *)
  else create_fun ()


let open_project title =
  let id_container = "side_class_file_list_container_"^title in
  let container = Ace_utils.get_element_by_id id_container in
  let callback ls = List.iter (fun el ->
    add_file container title el
  ) ls in
  Filemanager.open_project ~callback ~project:title

let right_clic_dialog_project =
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

let add_project container title =
  let li = createLi document in
  let ul = createUl document in
  let span = createSpan document in
  let is_shown = ref false in

  Filemanager.add_project title;

  li##className <- Js.string "side_class_project_item";
  ul##className <- Js.string "side_class_file_list";
  ul##id <- Js.string ("side_class_file_list_container_"^title);
  span##className <- Js.string "side_class_project_name";
  span##innerHTML <- Js.string title;
  span##onclick <- handler (fun ev ->
    if not (Filemanager.is_project_opened title) then
      (open_project title;
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
    Dialog.Right_clic_dialog.show right_clic_dialog_project x y;
    Js._false
  ) in
  Ace_utils.make_event_oncontextmenu span hand;
  
  Dom.appendChild li span;
  Dom.appendChild li ul;
  Dom.appendChild container li




let make_sidepanel () =
  let div = createDiv document in
  let ulprojects = createUl document in
  div##id <- Js.string "sidepanel";


  ulprojects##id <- Js.string "side_projects";
  let callback ls =
    List.iter (fun el -> add_project ulprojects el) ls in
  Request.get_list_of_projects ~callback;
  
  Dom.appendChild div ulprojects;
  div
    
