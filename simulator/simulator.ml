
open Printf
open Yojson.Basic.Util

exception Error of string

type resolution = int
type harmonics = High | Low
let harmonics_to_string = function
  | High -> "high"
  | Low -> "low"

let opposite_harmonics = function
  | High -> Low
  | Low -> High

type state = {
  mutable energy: int;
  mutable harmonics: harmonics;
  mutable matrix: Matrix.matrix_t;
  mutable bots: Bot.bot_t list;
}

let state = {
  energy    = 0;
  harmonics = Low;
  matrix    = Matrix.empty_matrix();
  bots      = [Bot.initial_bot ()];
}

let state_to_string state =
  (sprintf "Energy: %i\n" state.energy)
  ^ (sprintf "Harmonics: %s\n" (harmonics_to_string state.harmonics))

let extract_cmd json =
  [json]
    |> filter_member "cmd"
    |> filter_string

let wait args =
  printf "... waiting\n"

let flip args =
  printf "... flipping\n";
  state.harmonics <- (opposite_harmonics state.harmonics)

let execute_cmd cmd args =
  match cmd with
  | "wait" -> wait args
  | "flip" -> flip args
  | _ -> raise (Error ("Invalid cmd: " ^ cmd))


let main () =

  let json_model = Yojson.Basic.from_file "world.json" in
  let resolution = member "resolution" json_model |> to_int in
  printf "Model resolution: %i\n" resolution;
  flush stdout;

  let cmd_stream = Yojson.Basic.stream_from_channel stdin in
  Stream.iter (fun cmd_json ->
    let command = member "cmd" cmd_json |> to_string in
    printf "Command: %s\n" command;
    execute_cmd command cmd_json;
    printf "State:\n%s" (state_to_string state);
    flush stdout
  ) cmd_stream

let () = main ()

