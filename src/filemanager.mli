
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

val is_project_opened : string -> bool
val is_file_opened : project:string -> filename:string -> bool

val get_file : int -> file
val get_id : project:string -> filename:string -> int

val open_workspace : callback:(string list -> unit) -> unit
val open_project : callback:(string list -> unit) -> project:string -> unit
val open_file : callback:(int -> string -> unit) -> project:string ->
  filename:string -> unit

val create_project : callback:(unit -> unit) -> project:string -> unit


val create_file : (file -> unit) -> (string * string) -> unit
