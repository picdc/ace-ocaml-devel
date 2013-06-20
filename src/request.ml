
exception Bad_request_url of string

let pull_request ~meth ~url ~asyn ~msg =
(* let pull_request ~post_args ~url = *)
  (* let open XmlHttpRequest in *)
  (* let urlopt = Url.url_of_string url in *)
  (* match urlopt with  *)
  (* | None -> raise (Bad_request_url url) *)
  (* | Some url -> *)
  (*   let httpframe = Lwt_main.run (perform ~post_args url) in *)
  (*   httpframe.content *)
  let b = Buffer.create 5003 in
  let req = XmlHttpRequest.create () in
  req##_open(Js.string meth, Js.string url, Js.bool asyn);
  req##setRequestHeader(Js.string "Content-Type",
			Js.string "application/x-www-form-urlencoded");
  let toto = ref 10000 in
  let rec loop () =
    Ace_utils.console_debug req##readyState;
    match req##readyState with
    | XmlHttpRequest.DONE ->
      Buffer.add_string b (Js.to_string req##responseText)
    | _ -> decr toto; if !toto > 0 then loop () else ()
  in
  let f () = Ace_utils.console_log "coucou" in
  req##onreadystatechange <- Js.wrap_callback f;
  req##send(Js.some (Js.string msg));
  loop ();
  Buffer.contents b
  


let get_list_of_projects () =
  (* let res = pull_request ~post_args:[] ~url:"project" in *)
  let res = pull_request "POST" "project" true "" in
  [res]

let get_list_of_files project =
  []

let get_content_of_file ~project ~filename =
  ""

let create_project name =
  true

let create_file ~project ~filename =
  true

let save_content_of_file ~project ~filename =
  true
