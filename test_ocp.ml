
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
    let n =
      if n > ls then ls
      else n
    in
    String.blit str 0 buf 0 n;
    let lr = n - !r in
    r := n;
    lr
  in


  let state = IndentPrinter.initial in
  let stream = Nstream.make reader in
  let _state = IndentPrinter.stream output ~resume:state stream in
      
  (* let s = IndentPrinter.save state in *)
  (* output_string oc s *)

  !result

let f a = "Test"

let () =
  (Js.Unsafe.coerce Dom_html.window)##ocp_indent <- Js.wrap_callback my_indent_channel;
  let code = "let a =\nlet b =\n10\nin\n10" in
  let res = my_indent_channel code 3 in

  print_int res
