
type project = {
  name : string ;
  mutable is_open : bool;
  mutable files : string list
} 
type file = {
  id : int;
  project: string;
  filename: string
}

exception Bad_project_name of string
exception Bad_file_name of string * string
exception Project_not_found of string
exception Project_closed of string
exception Workspace_already_open

module H = Hashtbl

let id = ref 0
let existing_projects = H.create 19
let opened_files = ref []

let project_exists name =
  H.mem existing_projects name

let file_exists ~project ~filename =
  let p = H.find existing_projects project in
  List.mem filename p.files

let is_file_opened ~project ~filename =
  List.exists (fun f -> f.project = project && f.filename = filename)
    !opened_files

let is_project_opened project =
  try (H.find existing_projects project).is_open
  with Not_found -> raise (Project_not_found project)

let add_project name =
  let project = { name ; is_open = false ; files = [] } in
  H.add existing_projects name project

let add_new_project name =
  let project = { name ; is_open = true ; files = [] } in
  H.add existing_projects name project

let add_opened_file file =
  opened_files := file::(!opened_files)

let add_file_to_project project filename =
  let p = H.find existing_projects project in
  p.files <- filename :: p.files




(* Pour retrouver la correspondance entre id <-> fichier *)
let get_file id =
  List.find (fun f -> f.id = id) !opened_files

let get_id ~project ~filename =
  let file = List.find
    (fun f -> f.project = project && f.filename = filename)
    !opened_files in
  file.id



(* Fonctions pour utiliser le filemanager *)
let open_workspace =
  let already_open = ref false in
  fun ~callback ->
    if not !already_open then
      (let callback ls =
	 List.iter (fun el -> add_project el) ls;
	 callback ls in
       Request.get_list_of_projects ~callback;
       already_open := true)
    else raise Workspace_already_open


let open_project ~callback ~project =
 if not (is_project_opened project) then
   let callback lstr = 
     let p = H.find existing_projects project in
     p.is_open <- true;
     p.files <- lstr;
     callback lstr in
   Request.get_list_of_files ~callback project
       

let open_file ~callback ~project ~filename =
  let callback =
    if not (is_file_opened ~project ~filename) then
      (let i = !id in
       let file = { id = i ; project ; filename } in
       add_opened_file file;
       incr id;
       callback i)
    else
      callback (get_id ~project ~filename)
  in
  Request.get_content_of_file ~callback ~project ~filename


let create_project ~callback ~project =
  if not (project_exists project) then
    let callback =
      add_new_project project;
      callback
    in
    Request.create_project callback project 
  else raise (Bad_project_name project)


let create_file callback (project, filename) =
  if is_project_opened project then
    if not (file_exists ~project ~filename) then
      let callback () =
	let i = !id in
	let file = { id = i ; project ; filename } in
	add_opened_file file;
	incr id;
	add_file_to_project project filename;
	callback file
      in
      Request.create_file ~callback ~project ~filename
    else raise (Bad_file_name (project, filename))
  else raise (Project_closed project)

