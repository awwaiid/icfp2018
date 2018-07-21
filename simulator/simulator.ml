
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
  mutable prev_harmonics: harmonics;
  mutable matrix: Matrix.matrix_t;
  mutable bots: Bot.bot_t list;
  mutable prev_botcount: int;
}

let resolution = ref 0

let state = {
  energy    = 0;
  harmonics = Low;
  prev_harmonics = Low;
  matrix    = Matrix.empty_matrix();
  bots      = [Bot.initial_bot ()];
  prev_botcount = 1;
}

let state_to_string state =
  (sprintf "Energy: %i\n" state.energy)
  ^ (sprintf "Harmonics: %s\n" (harmonics_to_string state.harmonics))
  ^ (sprintf "Bots: %s\n" (String.concat ";" (List.map Bot.bot_to_string state.bots)))

let halt bot args =
  printf "... halting\n";
  state.bots <- []

let wait bot args =
  printf "... waiting\n"

let flip bot args =
  printf "... flipping\n";
  state.harmonics <- (opposite_harmonics state.harmonics)

let smove bot args =
  let lld = args |> member "lld" |> to_list |> filter_int |> Coordinate.from_list in
  bot.Bot.pos <- Coordinate.add bot.Bot.pos lld;
  state.energy <- state.energy + (2 * Coordinate.mlen(lld))

let fill bot args =
  let nd = args |> member "nd" |> to_list |> filter_int |> Coordinate.from_list in
  let c = Coordinate.add bot.Bot.pos nd in
  if Matrix.get state.matrix c == Voxel.Void then begin
    Matrix.set state.matrix c Voxel.Full;
    state.energy <- state.energy + 12
  end else begin
    Matrix.set state.matrix c Voxel.Void;
    state.energy <- state.energy + 6
  end

let execute_cmd cmd bot args =
  match cmd with
  | "halt" -> halt bot args
  | "wait" -> wait bot args
  | "flip" -> flip bot args
  | "smove " -> smove bot args
  | "fill " -> fill bot args
  | _ -> raise (Error ("Invalid cmd: " ^ cmd))

let add_step_world_energy () =
  match state.prev_harmonics with
  | High -> (state.energy <- state.energy + 30 * !resolution * !resolution * !resolution)
  | Low  -> (state.energy <- state.energy +  3 * !resolution * !resolution * !resolution)

let add_step_bot_energy () =
  state.energy <- state.energy + 20 * state.prev_botcount

let execute_step trace_stream =
  state.prev_harmonics <- state.harmonics;
  state.prev_botcount <- (List.length state.bots);
  let bots = state.bots in
  List.iter (fun bot ->
    let cmd_json = Stream.next trace_stream in
    let cmd = member "cmd" cmd_json |> to_string in
    execute_cmd cmd bot cmd_json
  ) bots;
  add_step_world_energy ();
  add_step_bot_energy ();
  printf "State:\n%s" (state_to_string state);
  flush stdout

let main () =

  let json_model = Yojson.Basic.from_file "world.json" in
  resolution := member "resolution" json_model |> to_int;
  printf "Model resolution: %i\n" !resolution;
  flush stdout;

  let trace_stream = Yojson.Basic.stream_from_channel stdin in
  while List.length state.bots > 0 do
    execute_step trace_stream
  done

  (*
  Stream.iter (fun cmd_json ->
    let command = member "cmd" cmd_json |> to_string in
    printf "Command: %s\n" command;
    let bot = (List.hd state.bots) in
    execute_cmd command bot cmd_json;
    printf "State:\n%s" (state_to_string state);
    flush stdout
  ) trace_stream
  *)

let () = main ()

