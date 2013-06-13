
open Completion_data

let range = ref 0

type token = LET | IN | BEGIN | END | TRY | WITH | IDENT of string | UNIT | SEMICOL
             | FOR | WHILE | DO | DONE | MATCH | EQ | DBLSEMC | OTHER | BLOCK
             | MATCHCASE | TYPE

let t_pile = ref []

let print_token t = 
  let t = match t with
    | LET -> "let"
    | IN -> "in"
    | IDENT s -> Format.sprintf "indent(%s)" s
    | OTHER -> "other"
    | BLOCK -> "block"
    | MATCH -> "match"
    | WITH -> "with"
    | _ -> "stg else"
  in
  Format.printf "%s@." t
      
let push t =
  (* Format.printf "Push : "; *)
  (* print_token t; *)
  t_pile := t :: !t_pile

let pop () =
  let t = List.hd !t_pile in
  t_pile := List.tl !t_pile;
  (* Format.printf "Pop : "; *)
  (* print_token t; *)
  t

let clear_let () =
  (* Format.printf "clearing LET @."; *)

  let t = ref OTHER in
  while !t <> LET do
    t := pop ()
  done

let clear () = 
  (* Format.printf "clear@."; *)
  range := 0;
  t_pile := []

let is_ident = function 
  | IDENT _ -> true
  | _ -> false


let compute t = 
  match t with
    | EQ | BEGIN | DO -> push BLOCK; incr range
    | SEMICOL -> push t
    | MATCH | TYPE -> incr range; push t
    | IN | END | DONE -> 
        let t' = ref OTHER in
        while !t' <> BLOCK do
          t' := pop ()
        done;
        if t = IN then 
          clear_let ()
        else
          decr range
    | OTHER -> ()
    | MATCHCASE ->
        decr range;
        let t' = ref OTHER in
        (* Format.printf "Start searching MATCH or CASE@."; *)
        while !t' <> MATCH && !t' <> TYPE do
          t' := pop ()
        done;
        (* Format.printf "Found@."; *)
        push !t'
    | LET -> 
        if (List.length !t_pile <> 0) then
          begin
            let p = pop () in
            (* print_token p; *)
            push p;
            if is_ident p then          
              clear ()
            else if not (p = SEMICOL || p = BLOCK || p = MATCH) then
              clear_let ()
            else ();
          end
        else ();
        push t
    | IDENT s ->
        if (List.length !t_pile <> 0) then
          let p = pop () in
          if !range = 0 && p = LET then
            begin
              Format.printf "Ajouté : %s@." s;
              new_word s
            end;
          push p;
          (* Format.printf "Push de %s@." s; *)
          push t;
          (* print_token (List.hd !t_pile) *)
              
    | _ -> ()


