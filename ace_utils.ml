
open Dom_html

(* Bindings des fonctions JS utiles *)

let alert str =
  Dom_html.window##alert(Js.string str)

let console_log str =
  Firebug.console##log(Js.string str)

let console_debug o =
  Firebug.console##debug(o)

let get_element_by_id id =
  Js.Opt.get (document##getElementById (Js.string id))
    (fun () -> assert false)

let coerceTo_input el =
  match Js.Opt.to_option (Dom_html.CoerceTo.input el) with
  | Some s -> s
  | None -> failwith "coerco_input failed"

let coerceTo_textarea el =
  match Js.Opt.to_option (Dom_html.CoerceTo.textarea el) with
  | Some s -> s
  | None -> failwith "coerco_textarea failed"





(* Création de widgets spécifiques *)

let optionnal_widget_count = ref 0
let optionnal_widget element init_display =
  let id = 
    let i = Js.to_string element##id in
    if i = "" then
      (let i = Format.sprintf "optionnal_widget_%d"
	 !optionnal_widget_count in
       incr optionnal_widget_count;
       i)
    else i
  in
  element##id <- Js.string id;

  let div = createDiv document in
  let button = createButton document in
  let button_text, display_text =
    if init_display then "-", "" else "+", "none" in
  
  element##style##display <- Js.string display_text;
  button##style##cssFloat <- Js.string "right";
  button##style##fontSize <- Js.string "8px";
  button##style##width <- Js.string "15px";
  button##style##height <- Js.string "15px";
  button##innerHTML <- Js.string button_text;
  button##onclick <- handler (fun _ ->
    let t = Js.to_string element##style##display in
    if t = "" then 
      (element##style##display <- Js.string "none";
       button##innerHTML <- Js.string "+")
    else (element##style##display <- Js.string "";
       button##innerHTML <- Js.string "-");
    Js._true);
  Dom.appendChild div button;
  Dom.appendChild div element;
  div

let tabs_widget_count = ref 0
let tabs_widget title_list element_list init_num_tab =
  let div = createDiv document in
  let div_titles = createDiv document in
  let id_tabs = Format.sprintf "tabs_widget_%d" !tabs_widget_count in
  let letnum = createInput ~_type:(Js.string "hidden") document in
  letnum##value <- Js.string "0";

  Dom.appendChild div letnum;
  Dom.appendChild div div_titles;
  
  ignore (List.fold_left2 (fun num element title ->
    let div_tab = createDiv document in
    let span_title = createSpan document in

    let id_tab = Format.sprintf "%s_tab_%d" id_tabs num in

    if num = init_num_tab then
      (letnum##value <- Js.string (string_of_int num);
       span_title##className <- Js.string (id_tabs^"_class_active");
       div_tab##style##display <- Js.string "")
    else
      (span_title##className <- Js.string (id_tabs^"_class_noactive");
       div_tab##style##display <- Js.string "none");

    div_tab##id <- Js.string (id_tab^"_content");
    span_title##id <- Js.string (id_tab^"_title");
    span_title##innerHTML <- Js.string title;
    span_title##onclick <- handler (fun _ ->
      let oldnum_active = int_of_string (Js.to_string letnum##value) in
      let oldid_active = Format.sprintf "%s_tab_%d" id_tabs oldnum_active in
      let oldtab_active = get_element_by_id (oldid_active^"_title") in
      let oldcontent_active = get_element_by_id (oldid_active^"_content") in
      oldtab_active##className <- Js.string (id_tabs^"_class_noactive");
      oldcontent_active##style##display <- Js.string "none";
      span_title##className <- Js.string (id_tabs^"_class_active");
      div_tab##style##display <- Js.string "";

      letnum##value <- Js.string (string_of_int num);
      Js._true
    );

    Dom.appendChild div_tab element;
    Dom.appendChild div_titles span_title;
    Dom.appendChild div div_tab;
    num+1
  ) 0 element_list title_list );

  incr tabs_widget_count;
  div







(* Bindings des fonctions Ace *)

let load_range = ref false

type editSession
type range
type acetoken

let create_edit_session (content: string) : editSession =
  let text = Js.Unsafe.inject (Js.string content) in
  let mode = Js.Unsafe.inject (Js.string "ace/mode/ocaml_ocp") in
  Js.Unsafe.fun_call (Js.Unsafe.variable "ace.createEditSession")
    [| text;mode |]

let change_edit_session (es : editSession) =
  ignore (Js.Unsafe.fun_call (Js.Unsafe.variable "editor.setSession")
	    [| Js.Unsafe.inject es |])

let get_editor_value () =
  let res = Js.Unsafe.fun_call
    (Js.Unsafe.variable
       "editor.getSession().getDocument().getValue")
    [| Js.Unsafe.inject () |] in 
  Js.to_string res

let set_editor_value str =
  ignore (Js.Unsafe.fun_call
	    (Js.Unsafe.variable
	       "editor.getSession().getDocument().setValue")
	    [| Js.Unsafe.inject str |])

let get_line (row: int) : string =
  Js.to_string (Js.Unsafe.fun_call
		  (Js.Unsafe.variable
		     "editor.getSession().getDocument().getLine")
		  [| Js.Unsafe.inject row |])

let get_lines row_start row_end : string =
  let res = Js.to_array (Js.Unsafe.fun_call
			   (Js.Unsafe.variable
			      "editor.getSession().getDocument().getLines")
			   [| Js.Unsafe.inject row_start;
			      Js.Unsafe.inject row_end |]) in
  let res = List.fold_right (fun str acc ->
    let str = Js.to_string str in
    str::acc
  ) (Array.to_list res) [] in
  String.concat "\n" res

let get_tab_size () =
  Js.Unsafe.fun_call
    (Js.Unsafe.variable "editor.getSession().getTabSize") [||]

let make_range startRow startColumn endRow endColumn : range =
  Js.Unsafe.fun_call
    (Js.Unsafe.variable "new Range")
    [| Js.Unsafe.inject startRow ;
       Js.Unsafe.inject startColumn ;
       Js.Unsafe.inject endRow ;
       Js.Unsafe.inject endColumn |]


let replace (range: range) (text: string) : unit =
  ignore (Js.Unsafe.fun_call
	    (Js.Unsafe.variable 
	       "editor.getSession().getDocument().replace")
	    [| Js.Unsafe.inject range ;
	       Js.Unsafe.inject (Js.string text) |])


let get_selection_range () =
  Js.Unsafe.fun_call
    (Js.Unsafe.variable "editor.getSelectionRange")
    [||]


let get_text_range r =
  Js.to_string (Js.Unsafe.fun_call
		  (Js.Unsafe.variable
		     "editor.getSession().getDocument().getTextRange")
		     [| Js.Unsafe.inject r |])


let get_tokens row : acetoken array =
  Js.to_array (Js.Unsafe.fun_call
		 (Js.Unsafe.variable
		    "editor.getSession().getTokens")
		 [| Js.Unsafe.inject row |])




module AceToken = struct
  type t = acetoken

  let get_value (token: t) : string = 
    Js.to_string (Js.Unsafe.get token "value")

  let get_type (token: t) : string =
    Js.to_string (Js.Unsafe.get token "type")
end
