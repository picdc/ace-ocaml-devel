
class ['a, 'b] event : (('a -> unit) -> 'b -> unit) -> object
  method add_event : ('a -> unit) -> unit
  method trigger : 'b -> unit
end


val create_file : (int , (string * string)) event 
