(**
   Tiny lexing module to retrieve potentials idents
**)

{
  open Completion_data
  open Completion_tokens

  let keywords = ["let", LET; 
                  "and", LET;
                  "in", IN; 
                  "match", MATCH; 
                  "with", WITH; 
                  "function", MATCH;
                  "begin", BEGIN; 
                  "end", END; 
                  "try", TRY;
                  "for", FOR;
                  "type", TYPE;
                  "while", WHILE;
                  "do", DO;
                  "if", OTHER;
                  "then", OTHER;
                  "else", OTHER;
                  "done", DONE;
                  "failwith", OTHER; 
                  "raise", OTHER; 
                  "assert", OTHER;
                  "open", OTHER;
                  "rec", OTHER ]

  let opening_keywords = ["let"; "begin"; "do"]

  let closing_keywords = ["in"; "end"; "done"]


  let keywords_htbl = 
    let h = Hashtbl.create 19 in
    List.iter (fun s -> Hashtbl.add h (fst s) (snd s)) keywords;
    h

}

let alpha = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let number = digit+ ('.') digit*
let char = (alpha | digit | '_' | '-' | '/' | '.')
let ident = (alpha | '_') (alpha | '_' | digit)*
let space = (' ' | '\t' | '\r' | '\n')


rule global = parse
  | ("let"|"and") space+ ("rec")? space? (ident as s) [^'=']* "=" 
      { (* Format.printf "Ajouté : %s@." s; *)
        new_word s; 
        let_block lexbuf;
        global lexbuf }
  | "module" { Format.printf "Module@."; modl lexbuf; global lexbuf }
  | "(*" { comment lexbuf; global lexbuf }
  | eof { }
  | _ { global lexbuf }

and let_block = parse
  | "let" _* "in" { let_block lexbuf }
  | _ { instr lexbuf }

and instr = shortest
    | "let" _* "in" { instr lexbuf }
    | _* ";" { instr lexbuf }
    | space { instr lexbuf }
    | _* { }

and modl = parse
  | "begin" space { beginrule lexbuf; modl lexbuf }
  | "end" { Format.printf "End of module@." }
  | _ { modl lexbuf }

and beginrule = parse
  | "end" space { }
  | "begin" space { beginrule lexbuf; beginrule lexbuf }
  | _ { beginrule lexbuf }

(* rule global = parse  *)
(*   | "module" space+ ident space+ "=" space+ "struct" *)
(*       { module_block lexbuf; *)
(*         global lexbuf } *)
(*   | ([^'\r']|[^' ']) ("let"|"and") space+ ("rec")? space? (ident as s) [^'=']* "=" *)
(*       {  *)
(*         Format.printf "Ajouté : %s@." s; *)
(*         new_word s;  *)
(*         (\* Format.printf "Beginning block@."; *\) *)
(*         block lexbuf; *)
(*         (\* Format.printf "End of block@."; *\) *)
(*         global lexbuf } *)
(*   | "=" *)
(*       { block lexbuf; global lexbuf } *)
(*   | "(\*" { comment lexbuf; global lexbuf } *)
(*   | eof {} *)
(*   | _ { global lexbuf } *)

(* and module_block = parse *)
(*   | "end" { } *)
(*   | _ { module_block lexbuf } *)

(* and block = parse *)
(*   | space+ "let" space+ { new_instr lexbuf; block lexbuf } *)
(*   (\* | "in" space+ { } *\) *)
(*   | ("let"|"and") space+ ("rec")? space? ident (space* _*\) "=" *)
(*       { block lexbuf; block lexbuf } *)
(*   | ([^'\r']|[^' '][^'l'][^'e'][^'t']) { } *)
(*   | _ { block lexbuf } *)


(* and new_instr = parse *)
(*   | "let" _* [^'i'][^'n'] { new_instr lexbuf } *)
(*   | space* ((ident|number) space)* [^';']  { } *)
(*   | _ { new_instr lexbuf } *)

and comment = parse
  | "*)" { }
  | "(*" { comment lexbuf; comment lexbuf }
  | _ { comment lexbuf }

(* and matching = parse *)
(*   | (ident as i) space *)
(*       { if List.mem i closing_keywords then  *)
(*         else matching lexbuf } *)
(*   | "->" { block lexbuf; matching lexbuf } *)
