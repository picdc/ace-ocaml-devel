
class ['a, 'b] event : (('a -> unit) -> 'b -> unit) -> object
  method add_event : ('a -> unit) -> unit
  method trigger : 'b -> unit
end


val create_file : (Filemanager.file , (string * string)) event 
val rename_file : (Filemanager.file , (int * string)) event
