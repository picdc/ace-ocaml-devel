
let r = ref 0

let my_indent_channel str line =

  let result = ref 0 in

  let f_kind = IndentPrinter.Numeric
    (fun n -> result := n)
  in

  (* let f_kind_print = IndentPrinter.Print (fun s -> *)
  (*   Buffer.add_string result s) *)
  (* in *)

  let f_config = IndentConfig.default in
  let f_in_lines n = (n = line) in
  let output = {
    IndentPrinter.
    debug = false;
    config = f_config;
    in_lines = f_in_lines;
    indent_empty = true;
    kind = f_kind; }
  in

  let reader buf n =
    let ls = String.length str in
    Format.printf "%s@.@." str;
    let n =
      if n > ls then ls
      else n
    in
    String.blit str 0 buf 0 n;
    let lr = n - !r in
    r := n;
    lr
  in


  let _state = IndentPrinter.initial in
  let stream = Nstream.make reader in
  let _state = IndentPrinter.stream output ~resume:_state stream in
      
  (* (\* let s = IndentPrinter.save state in *\) *)
  (* (\* output_string oc s *\) *)

  !result

let f a = "Test"

let indent_channel' str c = 
  (* let str = Js.to_string str in *)
  my_indent_channel str c

let () =
  (* (Js.Unsafe.coerce Dom_html.window)##ocpi <- Js.wrap_callback indent_channel'; *)
  let code = "let x =
  let y = 10 in
  let z = 10 in
  y + z" 
  in
  Format.printf "%s@." code;
  let res = my_indent_channel code 2 in
  Format.printf "%d@." res;
  let res = my_indent_channel code 3 in
  Format.printf "%d@." res
