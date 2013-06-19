


exception Empty_cgi_argument
exception Bad_cgi_argument
exception Fail_shell_call

let get_argument (cgi: Netcgi.cgi_activation) name =
  if cgi#argument_exists name then begin
    let value = cgi#argument_value name in
    if value <> "" then value
    else raise Empty_cgi_argument end
  else raise Bad_cgi_argument

let print_string str (cgi: Netcgi.cgi_activation) =
  (* cgi#set_header ~content_type:"plain/text" (); (\* TELECHARGE Oo? *\) *)
  cgi#out_channel#output_string str;
  cgi#out_channel#commit_work ()

let get_list_of_project user =
  let path = Format.sprintf "/home/dmaison/test_ocamlnet/data/%s" user in
  let res = Shell.cmd "ls" [ path ] in
  let b = Buffer.create 503 in
  try
    Shell.call ~stdout:(Shell.to_buffer b) [ res ];
    Buffer.contents b
  with _ -> raise Fail_shell_call


let get_list_of_files user project =
  let path = Format.sprintf "/home/dmaison/test_ocamlnet/data/%s/%s"
    user project in
  let res = Shell.cmd "ls" [ path ] in
  let b = Buffer.create 503 in
  try
    Shell.call ~stdout:(Shell.to_buffer b) [ res ];
    Buffer.contents b
  with _ -> raise Fail_shell_call


let get_file_content user project file =
  let path = Format.sprintf "/home/dmaison/test_ocamlnet/data/%s/%s/%s"
    user project file in
  let res = Shell.cmd "cat" [ path ] in
  let b = Buffer.create 503 in
  try
    Shell.call ~stdout:(Shell.to_buffer b) [ res ];
    Buffer.contents b
  with _ -> raise Fail_shell_call

let create_dir user dir =
  let path = Format.sprintf "/home/dmaison/test_ocamlnet/data/%s/%s"
    user dir in
  let res = Shell.cmd "mkdir" [ path ] in
  let b = Buffer.create 503 in
  try
    Shell.call ~stdout:(Shell.to_buffer b) [ res ];
    Buffer.contents b
  with _ -> raise Fail_shell_call

let create_file user project file =
  let path = Format.sprintf "/home/dmaison/test_ocamlnet/data/%s/%s/%s"
    user project file in
  let res = Shell.cmd "touch" [ path ] in
  let b = Buffer.create 503 in
  try
    Shell.call ~stdout:(Shell.to_buffer b) [ res ];
    Buffer.contents b
  with _ -> raise Fail_shell_call

let save_file user project file content =
  let path = Format.sprintf "/home/dmaison/test_ocamlnet/data/%s/%s/%s"
    user project file in
  let res = Shell.cmd "echo" [ content ] in
  let stdout = Shell.to_file ~append:false path in
  try
    Shell.call ~stdout [ res ]
  with _ -> raise Fail_shell_call

let empty_dyn_service = 
  { Nethttpd_services.dyn_handler = (fun _ _ -> ());
    dyn_activation = Nethttpd_services.std_activation
      `Std_activation_buffered;
    dyn_uri = None;
    dyn_translator = (fun _ -> "");
    dyn_accept_all_conditionals=false; }

let project_service =
  { empty_dyn_service with
    Nethttpd_services.dyn_handler =
      (fun _ cgi -> 
	try
	  let user = get_argument cgi "user" in
	  let res = get_list_of_project user in
	  print_string res cgi
	with
	  _ -> print_string "Error !" cgi
      ); }

let project_list_service =
  { empty_dyn_service with
    Nethttpd_services.dyn_handler =
      (fun _ cgi -> 
	try
	  let user = get_argument cgi "user" in
	  let project = get_argument cgi "project" in
	  let res = get_list_of_files user project in
	  print_string res cgi
	with
	  _ -> print_string "Error !" cgi
      ); }


let project_load_service =
  { empty_dyn_service with
    Nethttpd_services.dyn_handler =
      (fun _ cgi -> 
	try
	  let user = get_argument cgi "user" in
	  let project = get_argument cgi "project" in
	  let file = get_argument cgi "file" in
	  let res = get_file_content user project file in
	  print_string res cgi
	with
	  _ -> print_string "Error !" cgi
      ); }

let project_create_service =
  { empty_dyn_service with
    Nethttpd_services.dyn_handler =
      (fun _ cgi -> 
	try
	  let user = get_argument cgi "user" in
	  let project = get_argument cgi "dir" in
	  let _ = create_dir user project in
	  print_string "Project created successfully" cgi
	with
	  _ -> print_string "Error !" cgi
      ); }

let file_create_service =
  { empty_dyn_service with
    Nethttpd_services.dyn_handler =
      (fun _ cgi -> 
	try
	  let user = get_argument cgi "user" in
	  let project = get_argument cgi "project" in
	  let file = get_argument cgi "file" in
	  let _ = create_file user project file in
	  print_string "File created successfully" cgi
	with
	  _ -> print_string "Error !" cgi
      ); }

let project_save_service =
  { empty_dyn_service with
    Nethttpd_services.dyn_handler =
      (fun _ cgi -> 
	try
	  let user = get_argument cgi "user" in
	  let project = get_argument cgi "project" in
	  let file = get_argument cgi "file" in
	  let content = get_argument cgi "content" in
	  save_file user project file content;
	  print_string "Saved" cgi
	with
	  _ -> print_string "Error !" cgi
      ); }

let my_factory =
  (* let def_config = *)
  (*   { Netcgi.default_config  *)
  (*     with Netcgi.permitted_http_methods = [ `GET ; `POST ]; *)
  (*   } in *)
  Nethttpd_plex.nethttpd_factory
    ~name:"ace-edit_processor"
    (* ~config_cgi:def_config *)
    ~handlers: [ "list_of_projects", project_service ;
		 "list_of_files", project_list_service ;
		 "load_file", project_load_service;
		 "create_project", project_create_service;
		 "create_file", file_create_service;
		 "project_save", project_save_service;
	       ]
    ()

let main() =
  (* Create a parser for the standard Netplex command-line arguments: *)
  let (opt_list, cmdline_cfg) = Netplex_main.args() in

  (* Parse the command-line arguments: *)
  Arg.parse
    opt_list
    (fun s -> raise (Arg.Bad ("Don't know what to do with: " ^ s)))
    "usage: netplex [options]";

  (* Select multi-processing: *)
  let parallelizer = Netplex_mp.mp() in  

  (* Start the Netplex system: *)
  Netplex_main.startup
    parallelizer
    Netplex_log.logger_factories
    Netplex_workload.workload_manager_factories
    [ my_factory ]
    cmdline_cfg

let _ =
  Netsys_signal.init ();
  main()
