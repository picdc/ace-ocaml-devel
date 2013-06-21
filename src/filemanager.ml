
type project = string 
type file = int * ( project * string )

exception Bad_project_name of project
exception Bad_file_name of project * string
exception Project_not_found of project
exception Project_closed of project

module H = Hashtbl

let id = ref 0
let existing_projects = H.create 19
let opened_files = ref []

let project_exists name =
  H.mem existing_projects name

let is_file_opened project name =
  List.exists (fun (_, (p,n)) -> p = project && n = name) !opened_files
 
let exec_if_file_exists ~iftrue ~iffalse ~project ~filename =
  let callback lstr =
    let b = List.exists (fun n -> n = filename) lstr in
    if b then iftrue ()
    else iffalse ()
  in
  Request.get_list_of_files ~callback project 

let is_project_opened project =
  try H.find existing_projects project
  with Not_found -> raise (Project_not_found project)

let add_project name =
  if not (project_exists name) then
    H.add existing_projects name false
  else raise (Bad_project_name name)

let add_file project name =
  (* Ace_utils.console_log project; *)
  (* Ace_utils.console_log name; *)
  (* Ace_utils.console_debug (project_exists project); *)
  (* Ace_utils.console_debug (is_project_opened project); *)
  (* (\* Ace_utils.console_debug (file_exists project name); *\) *)
  (* Ace_utils.console_debug (Array.of_list (!opened_files)); *)
  if project_exists project then
    if not (is_file_opened project name) then
      (let new_id = !id in
       let file = new_id, (project, name) in
       incr id;
       opened_files := file::(!opened_files);
       new_id)
    else raise (Bad_file_name (project, name))
  else raise (Project_not_found name)

let get_file id =
  List.assoc id !opened_files

let get_id project file =
  let id, _ = List.find (fun (_, (p,n)) ->
    p = project && n = file) !opened_files in
  id


let open_project ~callback ~project =
 if not (is_project_opened project) then
   let callback lstr = 
     H.replace existing_projects project true;
     callback lstr in
   Request.get_list_of_files ~callback project
       

let create_file ~callback ~project ~filename =
  let iftrue () =
    let id = add_file project filename in
    let callback () = callback id in
    Request.create_file ~callback ~project ~filename
  in
  let iffalse () =
    raise (Bad_file_name (project, filename))
  in
  exec_if_file_exists ~iftrue ~iffalse ~project ~filename

