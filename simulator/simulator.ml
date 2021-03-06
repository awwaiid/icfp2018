
open Printf
open Yojson.Basic.Util

exception Error of string

let state = ref (State.initial())

let main () =

  let resolution = int_of_string Sys.argv.(1) in
  state := { !state with State.resolution = resolution };
  flush stdout;

  let trace_stream = Yojson.Basic.stream_from_channel stdin in
  while List.length !state.State.bots > 0 do
    state := State.execute_step !state trace_stream
  done

let () = main ()

