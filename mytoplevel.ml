(* XXX START HACK *)
let split_primitives p =
  let len = String.length p in
  let rec split beg cur =
    if cur >= len then []
    else if p.[cur] = '\000' then
      String.sub p beg (cur - beg) :: split (cur + 1) (cur + 1)
    else
      split beg (cur + 1) in
  Array.of_list(split 0 0)

class type global_data = object
  method toc : (string * string) list Js.readonly_prop
  method compile : (string -> string) Js.writeonly_prop
end

external global_data : unit -> global_data Js.t = "caml_get_global_data"

let g = global_data ()

let _ =
  let toc = g##toc in
  let prims = split_primitives (List.assoc "PRIM" toc) in

  let compile s =
    let output_program = Driver.from_string prims s in
    let b = Buffer.create 100 in
    output_program (Pretty_print.to_buffer b);
    Buffer.contents b
  in
  g##compile <- compile (* XXX HACK! *)
(* XXX END HACK *)



let print_toplevel (str: string) =
  let container = Ace_utils.get_element_by_id "toplevel" in
  let s = container##innerHTML##concat(Js.string str) in
  container##innerHTML <- s
  

let execute (str: string) =
  let ppf =
    let b = Buffer.create 80 in
    Format.make_formatter
      (fun s i l -> Buffer.add_substring b s i l)
      (fun () -> print_toplevel (Buffer.contents b); Buffer.clear b)
  in
  let lb = Lexing.from_string str in
  try
    List.iter
      (fun phr ->
	ignore(Toploop.execute_phrase true ppf phr))
      (!Toploop.parse_use_file lb)
  with
    _ -> print_toplevel "Aie, there is an error somewhere..."


let init (container: Dom_html.element Js.t) =
  let open Dom_html in
  let toplevel = createDiv document in
  toplevel##id <- Js.string "toplevel";
  Dom.appendChild container toplevel;
  
  execute "let x = 10"
