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

let halt state bot args =
  printf "... halting\n";
  { state with bots = [] }

let wait state bot args =
  printf "... waiting\n";
  state

let flip state bot args =
  printf "... flipping\n";
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

let saved_state = ref []
let save state bot args =
  saved_state := state::!saved_state;
  state

let restore state bot args =
  let state = List.hd !saved_state in
  saved_state := List.tl !saved_state;
  state

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
  | "save" -> save state bot args
  | "restore" -> restore state bot args

  | _ -> raise (Error ("Invalid cmd: " ^ cmd))

let add_step_world_energy state =
  match state.harmonics with
  | High -> {state with energy = state.energy + 30 * state.resolution * state.resolution * state.resolution }
  | Low  -> {state with energy = state.energy +  3 * state.resolution * state.resolution * state.resolution }

let add_step_bot_energy state =
  { state with energy = state.energy + 20 * (List.length state.bots) }

let execute_step state trace_stream =
  let state = add_step_world_energy state in
  let state = add_step_bot_energy state in
  let bots = state.bots in

  let state = ref state in (* Switch to ref during iter *)

  List.iter (fun bot ->
    let cmd_json = Stream.next trace_stream in
    let cmd = cmd_json |> member "cmd" |> to_string in
    let sequence_num = cmd_json |> member "sequence" |> to_int in
    printf "cmd %i: %s\n" sequence_num cmd;
    state := execute_cmd !state cmd bot cmd_json
  ) bots;
  printf "State:\n%s" (state_to_string !state);

  (* Note that we only really need to do this if there was a fill in this step *)
  let is_grounded = Matrix.is_grounded !state.matrix in
  printf "Grounded: %s\n" (string_of_bool is_grounded);

  flush stdout;

  !state
