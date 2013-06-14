
open Dom_html

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

(* let tabs_widget_count = ref 0 *)
(* let tabs_widget title_list element_list tab_active = *)
(*   let nb_tabs = ref 0 in *)
(*   let div = createDiv document in *)
(*   List.iter (fun element -> *)
  





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
