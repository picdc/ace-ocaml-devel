module Words = Set.Make(String)

let words = ref Words.empty

type env =
    { mutable actual : Words.t;
      parent : env }


let rec glob_env = 
  { actual = Words.empty;
    parent = glob_env }

let actual_env = ref glob_env

let new_block env = 
  { actual = Words.empty; parent = env }

let end_block env =
  env.parent
  
let begin_block () =
  actual_env := new_block !actual_env

let close_block () =
  actual_env := end_block !actual_env

let new_word w =
  !actual_env.actual <- Words.add w !actual_env.actual

let rec print_words = function
  | [] -> ()
  | w :: l -> Format.printf "%s@." w; print_words l


let find_completion w =
  let re = "^" ^ w ^ "*" in
  let re = Str.regexp re in
  let rec step env acc =
    let acc = Words.fold
      (fun s acc ->
        if  Str.string_match re s 0 then Words.add s acc
        else acc)
      env.actual
      acc
    in
    if env == glob_env then acc
    else step env.parent acc
  in
  step !actual_env Words.empty

let set_to_list s =
  List.rev (Words.fold (fun elt l -> elt :: l) s [])

let list_to_js_array l =
  let a = Array.of_list l in
  Js.array a

let find_completion_js w =
  list_to_js_array (set_to_list (find_completion w)) 

let _ = 
  (Js.Unsafe.coerce Dom_html.window)##complete <- find_completion_js;
  new_word "get_id";
  new_word "match_str";
  begin_block ();
  new_word "get_str_id";
  let w = "get" in
  print_words (set_to_list (find_completion w));
  close_block ();
  Format.printf "End of block@.";
  print_words (set_to_list (find_completion w))
  
