
open Dom_html

let alert str =
  Dom_html.window##alert(Js.string str)

let console str =
  Firebug.console##log(str)

let get_element_by_id id =
  Js.Opt.get (document##getElementById (Js.string id))
    (fun () -> assert false)

let get_editor_value () =
  let res = Js.Unsafe.fun_call (Js.Unsafe.variable
			"editor.getSession().getDocument().getValue")
    [| Js.Unsafe.inject () |]
  in 
  Js.to_string res

let set_editor_value str =
  ignore (Js.Unsafe.fun_call (Js.Unsafe.variable
			"editor.getSession().getDocument().setValue")
    [| Js.Unsafe.inject str |])
