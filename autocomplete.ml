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
  
let add_new_block () =
  actual_env := new_block !actual_env

let close_block () =
  actual_env := end_block !actual_env

let new_keyword w =
  !actual_env.actual <- Words.add w !actual_env.actual

let rec print_words = function
  | [] -> ()
  | w :: l -> Format.printf "%s@." w; print_words l


let find_completion w =
  let re = "^" ^ w ^ "*" in
  let re = Str.regexp re in
  let rec step env acc =
    let acc = Words.fold
      (fun s l ->
        if  Str.string_match re s 0 then s :: l
        else l)
      env.actual
      acc
    in
    if env == glob_env then acc
    else step env.parent acc
  in
  step !actual_env []

let _ = 
  (* (Js.Unsafe.coerce Dom_html.window)##complete <- find_completion; *)
  new_keyword "get_id";
  new_keyword "match_str";
  add_new_block ();
  new_keyword "get_str_id";
  let w = "get" in
  print_words (find_completion w);
  close_block ();
  Format.printf "End of block@.";
  print_words (find_completion w)
  
