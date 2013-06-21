
type project = string 
type file = int * ( project * string )

exception Bad_project_name of project
exception Bad_file_name of project * string
exception Project_not_found of project

val is_project_opened : project -> bool

(* val exec_if_file_exists : iftrue:(unit -> unit) -> iffalse:(unit -> unit) -> *)
(*   project:project -> filename:string -> unit *)

val add_project : string -> unit
val add_file : project -> string -> int

val get_file : int -> (project * string)
val get_id : project -> string -> int

val open_project : callback:(string list -> unit) -> project:project -> unit
val create_file : callback:(int -> unit) -> project:project ->
  filename:string -> unit
