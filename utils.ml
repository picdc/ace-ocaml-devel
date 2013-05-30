
open Dom_html

let get_element_by_id id =
  Js.Opt.get (document##getElementById (Js.string id))
    (fun () -> assert false)

let () =
  let container = get_element_by_id "input" in
  let button = createButton document in
  Dom.appendChild container button

