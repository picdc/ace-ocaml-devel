
type editSession
type range
type acetoken

val alert : string -> unit
val console_log : string -> unit
val console_debug : string -> unit

val get_element_by_id : string -> Dom_html.element Js.t

val create_edit_session : string -> editSession
val change_edit_session : editSession -> unit
val get_editor_value : unit -> string
val set_editor_value : string -> unit

val get_line : int -> string
val get_lines : int -> int -> string
val get_tab_size : unit -> int
val make_range : int -> int -> int -> int -> range
val replace : range -> string -> unit

val get_tokens : int -> acetoken array

module AceToken : sig
  val get_value : acetoken -> string
  val get_type : acetoken -> string
end



