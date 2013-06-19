
let kind_num result = IndentPrinter.Numeric
    (fun n -> result := n)

let kind_print result = IndentPrinter.Print (fun s ->
  Buffer.add_string result s)

let kind_multinum result = IndentPrinter.Numeric
  (fun n -> Queue.add n result) 
    

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

let indent_line_num str row =
  let c = row, row in
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

let indent_line_multinum str start last =
  let res = my_indent_channel kind_multinum
    (Queue.create ())
    (Js.to_string str)
    (start, last)
  in
  (* let ret = Array.make (Queue.length res) 0 in *)
  let ret = jsnew Js.array_length (Queue.length res) in
  ignore(Queue.fold (fun acc el ->
    Js.array_set ret acc el;
    (* Array.set ret acc el; *)
    acc+1) 0 res);
  ret

let _ =
  (Js.Unsafe.coerce Dom_html.window)##ocpiNum <- Js.wrap_callback
    indent_line_num;
  
  (Js.Unsafe.coerce Dom_html.window)##ocpiPrint <- Js.wrap_callback
    indent_line_print;

  (Js.Unsafe.coerce Dom_html.window)##ocpiMultinum <- Js.wrap_callback
    indent_line_multinum
  (* let file = open_in "ocp-indent-src/indentBlock.ml" in *)
  (* let buf = Buffer.create 5003 in *)
  (* try *)
  (*   while true do *)
  (*     Buffer.add_string buf (input_line file); *)
  (*     Buffer.add_string buf "\n" *)
  (*   done *)
  (* with End_of_file -> *)
  (*   begin *)
  (*     print_endline (string_of_float (Sys.time ())); *)
  (*     let tab = indent_line_multinum (Buffer.contents buf) 10 900 in *)
  (*     print_endline (string_of_float (Sys.time ())) *)
  (* 		       (\* Array.iter (fun n -> print_endline (string_of_int n)) tab *\) *)

  (*   end *)
