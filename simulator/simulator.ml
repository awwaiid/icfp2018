
open Printf
open Yojson.Basic.Util

type resolution = int
type harmonics = High | Low

type state = {
  energy: int;
  harmonics: harmonics;
  matrix: Matrix.matrix_t;
  bots: Bot.bot_t list;
}

let state = {
  energy    = 0;
  harmonics = Low;
  matrix    = Matrix.empty_matrix();
  bots      = [];
}

let extract_cmd json =
  [json]
    |> filter_member "cmd"
    |> filter_string



let main () =

  let json_model = Yojson.Basic.from_file "world.json" in
  let resolution = member "resolution" json_model |> to_int in
  printf "Model resolution: %i\n" resolution;
  flush stdout;

  let cmd_stream = Yojson.Basic.stream_from_channel stdin in
  Stream.iter (fun cmd_json ->
    let command = member "cmd" cmd_json |> to_string in
    printf "Command: %s\n" command;
    flush stdout
  ) cmd_stream

let () = main ()

