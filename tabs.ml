
open Dom_html
open Ace_utils



let id = ref 0
module H = Hashtbl

let htbl = H.create 19


let add_tab title content =
  let i = !id in
  H.add htbl i (title, content);
  incr id;
  let ul = get_element_by_id "tabs" in
  let new_span = createSpan document in
  let new_li = createLi document in
  new_li##id <- Js.string (string_of_int i);
  new_span##innerHTML <- Js.string title;

  Dom.appendChild new_li new_span;
  Dom.appendChild ul new_li



let _ =
  add_tab "untitled.ml" "let _ = \"coucou\"";
  add_tab "untitled(2).ml" "let _ = \"coucou\""

  



