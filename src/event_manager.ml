
class ['a, 'b] event act = object
  val action = (act: ('a -> unit) -> 'b -> unit)
  val mutable events = []

  method add_event e = events <- e::events
  method trigger args = 
    let f s = List.iter (fun f -> f s) events in
    act f args
end


let create_file = new event Filemanager.create_file
let rename_file = new event Filemanager.rename_file
let open_project = new event Filemanager.open_project
