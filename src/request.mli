
val get_list_of_projects :
  callback:(string list -> unit) -> unit

val get_list_of_files :
  callback:(string list -> unit) -> string -> unit

val get_content_of_file :
  callback:(string -> unit) -> project:string -> filename:string -> unit

(* val create_project : *)
(*   callback:(unit -> unit) -> unit *)

(* val create_file :  *)
(*   callback:(unit -> unit) -> project:string -> filename:string -> unit *)

(* val save_content_of_file : *)
(*   callback:(unit -> unit) -> project:string -> filename:string -> unit *)
