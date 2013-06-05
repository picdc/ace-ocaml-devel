
open Dom_html
open Ace_utils

let id = ref 0
module H = Hashtbl

let htbl = H.create 19

let curr_tab = ref 0
let nb_untitled = ref 0
let is_list_shown = ref false
let offset = ref 0
let len = ref 4



let get_line_width () =
  let container = get_element_by_id "tabline" in
  container##clientWidth

let get_line_max_width () =
  let w_sc_left = (get_element_by_id "tabscleft")##clientWidth in
  let w_sc_right = (get_element_by_id "tabscright")##clientWidth in
  let w_new_tab = (get_element_by_id "tabnewtab")##clientWidth in
  let w_show_all = (get_element_by_id "tabshowall")##clientWidth in
  let w_container = (get_element_by_id "tabs")##clientWidth in
  w_container - w_sc_left - w_sc_right - w_new_tab - w_show_all


let update_len () =
  let t_size = 105
    (* match Js.Opt.to_option (get_element_by_id "tabline")##firstChild with *)
    (* | None -> assert false *)
    (* | Some c ->  *)
    (*   let el = Dom_html.CoerceTo.element c in *)
    (*   match Js.Opt.to_option el with *)
    (*   | None -> assert false *)
    (*   | Some el -> (el##clientWidth) + 4 *)
  in
  let l_width = get_line_max_width () in
  let new_len = l_width / t_size in
  len := new_len
  

let refresh_tabs () = 
  let tabs = get_element_by_id "tabs" in
  let listtabs = get_element_by_id "listtabs" in
  let tabs_childs = (get_element_by_id "tabline")##childNodes in
  let list_childs = (get_element_by_id "listul")##childNodes in
  (* Refresh des tabs *)
  for i=0 to tabs_childs##length do
    match Js.Opt.to_option tabs_childs##item(i) with
    | None -> ()
    | Some tab_opt ->
      match Js.Opt.to_option (Dom_html.CoerceTo.element tab_opt) with
      | None -> ()
      | Some tab ->
	let cssdecl = tab##style in
	if i >= !offset && i < !offset + !len then
	  cssdecl##display <- Js.string ""	   
	else cssdecl##display <- Js.string "none" 
  done;
  (* Refresh de la liste *)
  for i=0 to list_childs##length do
    match Js.Opt.to_option list_childs##item(i) with
    | None -> ()
    | Some li_opt ->
      match Js.Opt.to_option (Dom_html.CoerceTo.element li_opt) with
      | None -> ()
      | Some li ->
  	let cssdecl = li##style in
  	if i >= !offset && i < !offset + !len then
  	  cssdecl##display <- Js.string "none"
  	else
  	  begin
  	    if i = !curr_tab then
  	      cssdecl##fontWeight <- Js.string "bold"
  	    else cssdecl##fontWeight <- Js.string "";
  	    cssdecl##display <- Js.string ""
  	  end
  done;
  (* Refresh de la position de la liste *)
  (** NE PAS FAIRE CA ICI MAIS QUAND ON LE DISPLAY **)
  let left_pos = Format.sprintf "%dpx"
    (tabs##offsetLeft + tabs##clientWidth - listtabs##clientWidth)
  in
  listtabs##style##left <- Js.string left_pos;
  ()

let change_tab id =
  (* Changement du tab *)
  let title = fst (H.find htbl !curr_tab) in
  let content = get_editor_value () in
  H.replace htbl !curr_tab (title, content);
  let content = snd (H.find htbl id) in
  set_editor_value (Js.string content);

  (* Changement du focus du tab *)
  let old_tab = get_element_by_id (Format.sprintf "tabnum%d" !curr_tab) in
  old_tab##className <- Js.string "tab";
  let new_tab = get_element_by_id (Format.sprintf "tabnum%d" id) in
  new_tab##className <- Js.string "tab active";
  curr_tab := id


let rec add_tab title content =
  (* Choix de l'id *)
  let i = !id in
  H.add htbl i (title, content);
  incr id;

  (* Création du tab *)
  let line = get_element_by_id "tabline" in
  let new_tab = createTd document in
  let id = Format.sprintf "tabnum%d" i in
  let span_title = createSpan document in
  let span_close = createSpan document in
  new_tab##id <- Js.string id;
  new_tab##className <- Js.string "tab";
  span_title##innerHTML <- Js.string title;
  span_title##className <- Js.string "tabtitle";
  span_title##onclick <- handler ( fun _ ->
    change_tab i;
    Js._true);
  span_close##innerHTML <- Js.string "x";
  span_close##className <- Js.string "tabclose";
  span_close##onclick <- handler ( fun _ ->
    close_tab i;
    Js._true);

  Dom.appendChild new_tab span_title;
  Dom.appendChild new_tab span_close;
  Dom.appendChild line new_tab;


  (* Création de l'item de la liste des tabs *)
  let listul = get_element_by_id "listul" in
  let li_tab = createLi document in
  let id = Format.sprintf "listulnum%d" i in
  li_tab##id <- Js.string id;
  li_tab##innerHTML <- Js.string title;
  li_tab##style##display <- Js.string "none";
  li_tab##onclick <- handler ( fun _ ->
    change_tab i;
    is_list_shown := false;
    let listtabs = get_element_by_id "listtabs" in
    listtabs##style##display <- Js.string "none";
    offset := i;
    refresh_tabs ();
    Js._true);

  Dom.appendChild listul li_tab;


  let nbtabs = H.length htbl in
  if !offset + !len < nbtabs then
      offset := nbtabs - !len;
  refresh_tabs ();
  i


and add_untitled_tab () =
  let id = !nb_untitled in
  let title =
    if id = 0 then "untitled.ml"
    else Format.sprintf "untitled%d.ml" !nb_untitled
  in
  let content = "let _ =\n  print_endline \"Hello world !\"" in
  incr nb_untitled;
  add_tab title content

and close_tab id =
  let tab_id = Format.sprintf "tabnum%d" id in
  let td = get_element_by_id tab_id in
  let tr = get_element_by_id "tabline" in

  (* Choix du prochain tab à afficher *)
  let sibling =
    match Js.Opt.to_option td##previousSibling with
    | Some s -> Dom_html.CoerceTo.element s
    | None -> 
      begin
	match Js.Opt.to_option td##previousSibling with
	| Some s -> Dom_html.CoerceTo.element s
	| None -> Js.Opt.empty
      end
  in
  let next_tab =
    match Js.Opt.to_option sibling with
    | Some s -> s
    | None ->
      let t = add_untitled_tab () in
      let tab_id = Format.sprintf "tabnum%d" t in
      get_element_by_id tab_id
  in
  let next_id =
    let i = Js.to_string next_tab##id in
    let len = (String.length i) - 6 in
    int_of_string (String.sub i 6 len)
  in

  (* Changement du tab et remove de celui qu'on voulait *)
  change_tab next_id;
  (* H.remove htbl id; *)
  (* tabs_list := List.remove_assoc id !tabs_list; *)
  (* update_tabs_drawing (); *)
  Dom.removeChild tr td





let init_tabs_drawing () =
  let container = get_element_by_id "tabs" in
  let table = createTable document in
  let line = createTr document in
  let sc_left = createSpan document in
  let sc_right = createSpan document in
  let new_tab = createSpan document in
  let show_all = createSpan document in

  let button = createInput ~_type:(Js.string "button") document in
  button##value <- Js.string "+";
  button##id <- Js.string "newEmptyTab";
  button##onclick <- handler (fun _ ->
    let id = add_untitled_tab () in
    change_tab id;    
    Js._true);
  Dom.appendChild new_tab button;

  let button = createInput ~_type:(Js.string "button") document in
  button##value <- Js.string "<";
  button##id <- Js.string "scrollTabLeft";
  button##onclick <- handler (fun _ ->
    offset := max 0 (!offset-1);
    refresh_tabs ();
    Js._true);
  Dom.appendChild sc_left button;

  let button = createInput ~_type:(Js.string "button") document in
  button##value <- Js.string ">";
  button##id <- Js.string "scrollTabRight";
  button##onclick <- handler (fun _ ->
    let nbmax = H.length htbl in
    offset := min (nbmax-1) (!offset+1);
    refresh_tabs ();  
    Js._true);
  Dom.appendChild sc_right button;

  let button = createInput ~_type:(Js.string "button") document in
  button##value <- Js.string "...";
  button##id <- Js.string "showAllTabs";
  button##onclick <- handler (fun _ ->
    let container = get_element_by_id "listtabs" in
    let s = if !is_list_shown then "none" else "" in
    container##style##display <- Js.string s;
    is_list_shown := not !is_list_shown;
    Js._true);
  Dom.appendChild show_all button;

  line##id <- Js.string "tabline";
  table##id <- Js.string "tabtable";
  table##className <- Js.string "tabwidget";
  sc_left##id <- Js.string "tabscleft";
  sc_left##className <- Js.string "tabwidget";
  sc_right##id <- Js.string "tabscright";
  sc_right##className <- Js.string "tabwidget";
  new_tab##id <- Js.string "tabnewtab";
  new_tab##className <- Js.string "tabwidget";
  show_all##id <- Js.string "tabshowall";
  show_all##className <- Js.string "tabwidget";

  Dom.appendChild table line;
  Dom.appendChild container sc_left; 
  Dom.appendChild container table;
  Dom.appendChild container sc_right;
  Dom.appendChild container new_tab;
  Dom.appendChild container show_all



let init_listtabs () =
  let container = get_element_by_id "listtabs" in
  let ul = createUl document in
  ul##id <- Js.string "listul";
  container##style##display <- Js.string "none";
  container##style##position <- Js.string "absolute";
  Dom.appendChild container ul
  


let _ =
  (* Création du bouton d'importation des fichiers *)
  let container = get_element_by_id "input" in
  let button = createInput
    ~name:(Js.string "importFileButton")
    ~_type:(Js.string "file")
    document
  in
  button##innerHTML <- Js.string "coucou";
  button##onchange <- handler (fun _ ->
    begin
      match Js.Optdef.to_option button##files with
      | None -> ()
      | Some fl ->
	match Js.Opt.to_option fl##item(0) with
	| None -> ()
	| Some f -> 
	  begin
	    let reader = jsnew File.fileReader () in
	    reader##onload <- Dom.handler (fun _ ->
	      let s =
		match Js.Opt.to_option
		  (File.CoerceTo.string (reader##result)) with
		  | None -> Js.string "je suis la"
		  | Some str -> str
	      in
	      let id = add_tab (Js.to_string f##name) (Js.to_string s) in
	      change_tab id;
	      Js._false);
	    reader##readAsText (( f :> (File.blob Js.t)));
	  end
    end;
    Js._true
  );
  Dom.appendChild container button;

  (* Création des tabs *)
  init_tabs_drawing ();
  init_listtabs ();
  ignore (add_untitled_tab ());
  let first_tab = get_element_by_id "tabnum0" in
  first_tab##className <- Js.string "tab active";

  (* Création de l'event pour recalculer le nb de tab affiché
     à la redimention de la fenêtre *)
  update_len ();
  Dom_html.window##onresize <- Dom_html.handler
    (fun _ -> update_len ();
      refresh_tabs ();
      Js._true)



