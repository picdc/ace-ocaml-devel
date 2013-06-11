(**
   Tiny lexing module to retrieve potentials idents
**)

{
  open Completion_data

  let keywords = ["let", "in", "match", "with", "begin", "end", "try",
  "failwith"]

  let keywords_htbl = 
    let h = Hashtbl.create 19 in
    List.iter (fun s -> Hashtbl.add h s ()) keywords;
    h

}

let alpha = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let char = (alpha | digit | '_' | '-' | '/' | '.')
let ident = (alpha | '_') (alpha | '_' | digit)*
let space = (' ' | '\t' | '\r' )

rule token = parse
  | ident as s 
      { if Hashtbl.mem keywords_htbl s then token lexbuf
        else new_word s; token lexbuf }
  | _ 
      { token lexbuf }

      

