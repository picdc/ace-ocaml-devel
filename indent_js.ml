
let kind_num result = IndentPrinter.Numeric
    (fun n -> result := n)

let kind_print result = IndentPrinter.Print (fun s ->
  Buffer.add_string result s)


let my_indent_channel kind result str lines =

  let kind = kind result in
  let char_left = ref (String.length str) in
  let pos_str = ref 0 in
  let start, last = lines in

  let f_config = IndentConfig.default in
  let f_in_lines n = (n >= start && n <= last) in
  let output = {
    IndentPrinter.
    debug = false;
    config = f_config;
    in_lines = f_in_lines;
    indent_empty = true;
    kind; }
  in

  let reader buf n =
    (* Le nombre maximum de caractère à traiter pendant cette passe *)
    let n =
      if n > !char_left then !char_left
      else n
    in
    (* Traitement et mise à jour *)
    String.blit str !pos_str buf 0 n;
    char_left := !char_left - n;
    pos_str := !pos_str + n;
    n
  in


  let state = IndentPrinter.initial in
  let stream = Nstream.make reader in
  let _state = IndentPrinter.stream output ~resume:state stream in
      
  (* (\* let s = IndentPrinter.save state in *\) *)
  (* (\* output_string oc s *\) *)

  result

let indent_line_num str start last =
  let c = start, last in
  let res = ref 0 in
  let str = Js.to_string str in
  !(my_indent_channel kind_num res str c)


let indent_line_print str start last =
  let c = start, last in
  let res = Buffer.create 511 in
  let str = Js.to_string str in
  let res = my_indent_channel kind_print res str c in
  let res = Buffer.contents res in
  Js.string res

let () =
  (Js.Unsafe.coerce Dom_html.window)##ocpiNum <- Js.wrap_callback
  indent_line_num;
  
  (Js.Unsafe.coerce Dom_html.window)##ocpiPrint <- Js.wrap_callback
  indent_line_print;
 (*  let code = "let x = *)
(*   let y = *)
(*   10 *)
(*   in *)
(*   let z = 10 in *)
(*   y + z *)

(* let kind_num result = IndentPrinter.Numeric *)
(*     (fun n -> result := n) *)
    
(* let kind_print result = IndentPrinter.Print (fun s -> *)
(*     Buffer.add_string result s) *)
    

(* let my_indent_channel kind result str lines = *)
  
(*   let kind = kind result in *)
(*   let r = ref 0 in *)
(*   let start, last = lines in *)
  
(*   let f_config = IndentConfig.default in *)
(*   let f_in_lines n = (n >= start && n <= last) in *)
(*   let output = { *)
(*     IndentPrinter. *)
(*     debug = false; *)
(*     config = f_config; *)
(*     in_lines = f_in_lines; *)
(*     indent_empty" *)
(*   in *)
(*   let s = indent_line_print code 0 500 in *)
(*   Format.printf "@.@.Result:@.@.%s" s *)
