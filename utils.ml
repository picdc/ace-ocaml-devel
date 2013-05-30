
open Dom_html

let alert str =
  Dom_html.window##alert(Js.string str)

let get_element_by_id id =
  Js.Opt.get (document##getElementById (Js.string id))
    (fun () -> assert false)

let set_editor_value str =
  ignore (Js.Unsafe.fun_call (Js.Unsafe.variable
			"editor.getSession().getDocument().setValue")
    [| Js.Unsafe.inject str |])

let () =
  let container = get_element_by_id "input" in
  let button = createInput
    ~name:(Js.string "importFileButton")
    ~_type:(Js.string "file")
    document
  in
  button##innerHTML <- Js.string "coucou";
  button##onchange <- handler (fun _ ->
    begin
      match Js.Optdef.to_option button##files with
      | None -> ()
      | Some fl ->
	match Js.Opt.to_option fl##item(0) with
	| None -> ()
	| Some f -> 
	  begin
	    let reader = jsnew File.fileReader () in
	    reader##onload <- Dom.handler (fun _ ->
	      let s =
		match Js.Opt.to_option
		  (File.CoerceTo.string (reader##result)) with
		  | None -> Js.string "je suis la"
		  | Some str -> str
	      in
	
	      set_editor_value s;
	      Js._false);
	    reader##readAsText (( f :> (File.blob Js.t)));
	  end
    end;
    Js._true
  );
  Dom.appendChild container button

