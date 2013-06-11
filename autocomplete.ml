(**
 ocamlc -I ~/.opam/4.00.1/lib/re re.cma re_emacs.cma re_str.cma -o autocomplete autocomplete.ml && ./autocomplete 
**)


open Completion_data

(* module Words = Set.Make(String) *)

(* let words = ref Words.empty *)

(* type env = *)
(*     { mutable actual : Words.t; *)
(*       parent : env } *)

(* let completions = ref (Array.make 0 "") *)
(* let actual_index = ref 0 *)

(* let rec glob_env =  *)
(*   { actual = Words.empty; *)
(*     parent = glob_env } *)

(* let actual_env = ref glob_env *)

(* let new_block env =  *)
(*   { actual = Words.empty; parent = env } *)

(* let end_block env = *)
(*   env.parent *)
  
(* let begin_block () = *)
(*   actual_env := new_block !actual_env *)

(* let close_block () = *)
(*   actual_env := end_block !actual_env *)

(* let new_word w = *)
(*   !actual_env.actual <- Words.add w !actual_env.actual *)

let rec print_words = function
  | [] -> ()
  | w :: l -> Ace_utils.console w; print_words l

(* let change_glob_env env = *)
(*   glob_env := env *)

let find_completion w =
  let re = "^" ^ w ^ "*" in
  let re = Re_str.regexp re in
  (* let re = Re.compile re in *)
  
  let rec step env acc =
    let acc = Words.fold
      (fun s acc ->
        (* Format.printf "%s@." s; *)
        if  Re_str.string_match re s 0 then 
          begin
            Words.add s acc
          end
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

let set_to_array s =
  let a = Array.make (Words.cardinal s) "" in
  ignore (Words.fold (fun elt i -> a.(i) <- elt; i+1) s 0);
  a


(** Functions to compute completion **)

let compute_completions w =
  let w = Js.to_string w in
  let words = find_completion w in
  let words = set_to_array words in
  completions := words;
  actual_index := 0

let next_completion () =
  let n = !completions.(!actual_index) in
  actual_index := (!actual_index + 1) mod Array.length !completions;
  Js.string n
  
    

(** Js bindings of OCaml functions **)

let list_to_js_array l =
  let rec convert acc = function 
    | [] -> acc
    | w :: l -> convert ((Js.string w) :: acc) l
  in 
  let a = Array.of_list (convert [] l) in
  Js.array a

let find_completion_js w =
  let w = Js.to_string w in
  let l = set_to_list (find_completion w) in
  (* print_words l *)
  list_to_js_array l

let new_word_from_js w =
  new_word (Js.to_string w)



let _ = 
  (Js.Unsafe.coerce Dom_html.window)##complete <- find_completion_js;
  (Js.Unsafe.coerce Dom_html.window)##newWord <- new_word_from_js;
  (Js.Unsafe.coerce Dom_html.window)##computeCompletions <-
  compute_completions;
  (Js.Unsafe.coerce Dom_html.window)##nextCompletion <- next_completion
  (* Ace_utils.console "Test"; *)
  
  (* new_word "get_id"; *)
  (* new_word "match_str"; *)
  (* begin_block (); *)
  (* new_word "get_str_id"; *)
  (* let w = "get" in *)
  (* (\* print_words (set_to_list (find_completion w)); *\) *)
  (* (\* find_completion_js w; *\) *)
  (* close_block (); *)
  (* print_words (set_to_list (find_completion w)) *)
  
