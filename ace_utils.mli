
type editSession
type range
type acetoken

val optionnal_widget : Dom_html.element Js.t -> bool -> Dom_html.element Js.t


val alert : string -> unit
val console_log : string -> unit
val console_debug : 'a -> unit

val get_element_by_id : string -> Dom_html.element Js.t

val coerceTo_input : Dom_html.element Js.t -> Dom_html.inputElement Js.t
val coerceTo_textarea : Dom_html.element Js.t -> Dom_html.textAreaElement Js.t

val create_edit_session : string -> editSession
val change_edit_session : editSession -> unit
val get_editor_value : unit -> string
val set_editor_value : string -> unit

val get_line : int -> string
val get_lines : int -> int -> string
val get_tab_size : unit -> int
val make_range : int -> int -> int -> int -> range
val replace : range -> string -> unit
val get_selection_range : unit -> range
val get_text_range : range -> string

val get_tokens : int -> acetoken array

module AceToken : sig
  val get_value : acetoken -> string
  val get_type : acetoken -> string
end



