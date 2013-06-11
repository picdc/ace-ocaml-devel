(**
 ocamlc -I ~/.opam/4.00.1/lib/re re.cma re_emacs.cma re_str.cma -o autocomplete autocomplete.ml && ./autocomplete 
**)


open Completion_data

let add_word = new_word

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
  let words = find_completion w in
  let words = set_to_array words in
  completions := words;
  actual_index := 0

let next_completion () =
  let n = !completions.(!actual_index) in
  actual_index := (!actual_index + 1) mod Array.length !completions;
  n


  
   
