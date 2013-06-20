
val get_list_of_projects : unit -> string list
val get_list_of_files : string -> string list
val get_content_of_file : project:string -> filename:string -> string
val create_project : unit -> bool
val create_file : project:string -> filename:string -> bool
val save_content_of_file : project:string -> filename:string -> bool
