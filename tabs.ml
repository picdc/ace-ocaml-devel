
open Dom_html
open Ace_utils



let id = ref 0
module H = Hashtbl

let htbl = H.create 19


let curr_tab = ref 0

let change_tab id =
  let title = fst (H.find htbl !curr_tab) in
  let content = get_editor_value () in
  H.replace htbl !curr_tab (title, content);
  let content = snd (H.find htbl id) in
  set_editor_value (Js.string content);
  curr_tab := id


let rec add_tab title content =
  let i = !id in
  H.add htbl i (title, content);
  incr id;
  let ul = get_element_by_id "tabs" in
  let new_span_title = createDiv document in
  let new_span_close = createDiv document in
  let new_li = createLi document in
  let span_id = Format.sprintf "tabnum%d" i in
  new_li##id <- Js.string span_id;
  new_li##onclick <- handler ( fun _ ->
    change_tab i;
    Js._true);
  new_span_title##innerHTML <- Js.string title;
  new_span_title##className <- Js.string "tabtitle";
  new_span_close##innerHTML <- Js.string "x";
  new_span_close##className <- Js.string "tabclose";
  new_span_close##onclick <- handler ( fun _ ->
    close_tab i;
    Js._true);
  Dom.appendChild new_li new_span_title;
  Dom.appendChild new_li new_span_close;
  Dom.appendChild ul new_li;
  i


and close_tab id =
  H.remove htbl id;
  let span_id = Format.sprintf "tabnum%d" id in
  let li = get_element_by_id span_id in
  let ul = get_element_by_id "tabs" in
  let sibling = 
    match Js.Opt.to_option li##previousSibling with
    | Some s -> s
    | None -> 
      match Js.Opt.to_option li##nextSibling with
      | Some s -> s
      | None -> 
	let t = add_tab "untitled.ml" "" in
	let tab_id = Format.sprintf "tabnum%d" t in
	assert false
	(* get_element_by_id tab_id *)
  in
  let next_id =
    let i = Js.to_string sibling##id in
    let len = (String.length i) - 6 in
    int_of_string (String.sub i 6 len)
  in
  change_tab next_id;
  Dom.removeChild ul li


let _ =
  ignore (add_tab "untitled.ml" "let _ = \"coucou\"");
  ignore (add_tab "untitled(2).ml" "let _ = \"coucou\"")

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
  Dom.appendChild container button

