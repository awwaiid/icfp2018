open Printf
open Yojson.Basic.Util

exception Error of string

type harmonics = High | Low
let harmonics_to_string = function
  | High -> "high"
  | Low -> "low"

let opposite_harmonics = function
  | High -> Low
  | Low -> High

type state = {
  energy: int;
  harmonics: harmonics;
  matrix: Matrix.matrix_t;
  bots: Bot.bot_t list;
  resolution: int;
}

let initial () = {
  energy    = 0;
  harmonics = Low;
  matrix    = Matrix.empty_matrix();
  bots      = [Bot.initial_bot ()];
  resolution = 0;
}

let state_to_string state =
  (sprintf "Energy: %i\n" state.energy)
  ^ (sprintf "Harmonics: %s\n" (harmonics_to_string state.harmonics))
  ^ (sprintf "Bots: %s\n" (String.concat ";" (List.map Bot.bot_to_string state.bots)))

let state_to_json state =
  `Assoc [
    "energy", `Int state.energy;
    "harmonics", `String (harmonics_to_string state.harmonics);
    "bots", `List ( List.map Bot.bot_to_json state.bots );
  ]

let output_state state =
  Yojson.Basic.to_channel stdout (state_to_json state);
  printf "\n";
  flush stdout

let halt state bot args =
  (* printf "... halting\n"; *)
  { state with bots = [] }

let wait state bot args =
  (* printf "... waiting\n"; *)
  state

let flip state bot args =
  (* printf "... flipping\n"; *)
  { state with harmonics = (opposite_harmonics state.harmonics) }

let coord_arg name args =
  args |> member name |> to_list |> filter_int |> Coordinate.from_list

let smove state bot args =
  let lld = args |> coord_arg "lld" in
  bot.Bot.pos <- Coordinate.add bot.Bot.pos lld;
  { state with energy = state.energy + (2 * Coordinate.mlen(lld)) }

let lmove state bot args =
  let sld1 = args |> coord_arg "sld1" in
  let sld2 = args |> coord_arg "sld2" in
  let c = bot.Bot.pos in
  let c' = Coordinate.add c sld1 in
  let c'' = Coordinate.add c' sld2 in
  bot.Bot.pos <- c'';
  { state with energy = state.energy + 2 * (Coordinate.mlen(sld1) + 2 + Coordinate.mlen(sld2)) }

let fill state bot args =
  let nd = args |> coord_arg "nd" in
  let c = Coordinate.add bot.Bot.pos nd in
  if Matrix.get state.matrix c == Voxel.Void then begin
    {
      state with
      matrix = Matrix.set state.matrix c Voxel.Full;
      energy = state.energy + 12;
    }
  end else begin
    {
      state with
      matrix = Matrix.set state.matrix c Voxel.Void;
      energy = state.energy + 6;
    }
  end


let execute_cmd state cmd bot args =
  match cmd with
  (* Standard Commands *)
  | "halt" -> halt state bot args
  | "wait" -> wait state bot args
  | "flip" -> flip state bot args
  | "smove" -> smove state bot args
  | "lmove" -> lmove state bot args
  | "fill" -> fill state bot args

  (* Custom Commands *)

  | _ -> raise (Error ("Invalid cmd: " ^ cmd))

let add_step_world_energy state =
  match state.harmonics with
  | High -> {state with energy = state.energy + 30 * state.resolution * state.resolution * state.resolution }
  | Low  -> {state with energy = state.energy +  3 * state.resolution * state.resolution * state.resolution }

let add_step_bot_energy state =
  { state with energy = state.energy + 20 * (List.length state.bots) }

let saved_state = ref []
let save state bot args =
  saved_state := state::!saved_state;
  state

let restore state bot args =
  let state = List.hd !saved_state in
  saved_state := List.tl !saved_state;
  state

let output_grounded_status state =
  let is_grounded = Matrix.is_grounded state.matrix in
  let is_grounded_json = `Assoc [ "is_grounded", `Bool is_grounded ] in
  Yojson.Basic.to_channel stdout is_grounded_json;
  printf "\n";
  flush stdout

let rec execute_bot_cmd trace_stream state bot =
    let cmd_json = Stream.next trace_stream in
    let cmd = cmd_json |> member "cmd" |> to_string in
    match cmd with
    | "state" ->
      output_state state;
      execute_bot_cmd trace_stream state bot
    | "save" ->
      let state = save state bot cmd_json in
      output_state state;
      execute_bot_cmd trace_stream state bot
    | "restore" ->
      let state = restore state bot cmd_json in
      output_state state;
      execute_bot_cmd trace_stream state bot
    | "grounded-check" ->
      output_grounded_status state;
      execute_bot_cmd trace_stream state bot
    | _ -> execute_cmd state cmd bot cmd_json

let execute_step state trace_stream =
  let state = add_step_world_energy state in
  let state = add_step_bot_energy state in
  let bots = state.bots in
  let state = List.fold_left (execute_bot_cmd trace_stream) state bots in

  output_state state;


  state
