
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



(* Bindings des fonctions Ace *)

type editSession

let create_edit_session content : editSession =
  let text = Js.Unsafe.inject (Js.string content) in
  let mode = Js.Unsafe.inject (Js.string "ace/mode/ocaml_ocp") in
  Js.Unsafe.fun_call (Js.Unsafe.variable "ace.createEditSession")
    [| text;mode |]

let change_edit_session (es : editSession) =
  ignore (Js.Unsafe.fun_call (Js.Unsafe.variable "editor.setSession")
	    [| Js.Unsafe.inject es |])

let get_editor_value () =
  let res = Js.Unsafe.fun_call (Js.Unsafe.variable
			"editor.getSession().getDocument().getValue")
    [| Js.Unsafe.inject () |] in 
  Js.to_string res

let set_editor_value str =
  ignore (Js.Unsafe.fun_call (Js.Unsafe.variable
			"editor.getSession().getDocument().setValue")
    [| Js.Unsafe.inject str |])
