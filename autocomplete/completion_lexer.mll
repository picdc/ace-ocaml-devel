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
                  "begin", BEGIN; 
                  "end", END; 
                  "try", TRY;
                  "for", FOR;
                  "while", WHILE;
                  "do", DO;
                  "done", DONE;
                  "failwith", OTHER; 
                  "raise", OTHER; 
                  "assert", OTHER;
                  "open", OTHER;
                  "rec", OTHER ]

  let opening_keywords = ["let"; "begin"]

  let closing_keywords = ["in"; "end"]


  let keywords_htbl = 
    let h = Hashtbl.create 19 in
    List.iter (fun s -> Hashtbl.add h (fst s) (snd s)) keywords;
    h

}

let alpha = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let char = (alpha | digit | '_' | '-' | '/' | '.')
let ident = (alpha | '_') (alpha | '_' | digit)*
let space = (' ' | '\t' | '\r' | '\n')

rule token = parse
  | ";" { compute SEMICOL; token lexbuf }
  | ";;" { compute DBLSEMC; token lexbuf }
  | "=" { compute EQ; token lexbuf }
  | (digit)+(".")?(digit)* {compute (IDENT "constant_number"); token lexbuf }
  | (ident as s) space
      { 
        if Hashtbl.mem keywords_htbl s then
          begin
            let t = Hashtbl.find keywords_htbl s in
            compute t;
            (* Format.printf "ident : %s, range : %d @." s !range; *)
            token lexbuf
          end
        else 
          begin
            compute (IDENT s);
            (* Format.printf "ident : %s, range : %d @." s !range; *)
            token lexbuf
          end }
  | eof { }
  | "(*" { comment lexbuf; token lexbuf }
  | _ 
      { token lexbuf }

and comment = parse
  | "*)" { }
  | "(*" { comment lexbuf; comment lexbuf }
  | _ { comment lexbuf }

      

