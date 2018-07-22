
open Test
open State
open Printf
(* open Yojson.Basic *)

let js str = Yojson.Basic.from_string str

let _ =
  let empty_state = initial () in
  let empty_state = { empty_state with resolution = 20 } in

  is "Starts with no energy used" empty_state.energy 0;
  is "Starts with no voxels" (Matrix.voxel_count empty_state.matrix) 0;

  let commands = Stream.of_list [
    js "{ cmd: \"wait\", sequence: 1 }"
  ] in
  let state = execute_step empty_state commands in
  is "Waiting costs energy" state.energy 24020;

  let commands = Stream.of_list [
    js "{ cmd: \"wait\" }"
  ] in
  let state = execute_step empty_state commands in
  is "Sequence is optional" state.energy 24020;

  let commands = Stream.of_list [
    js "{ cmd: \"fill\", sequence: 1, nd: [0,0,1] }"
  ] in
  let state = execute_step empty_state commands in
  is "Fill energy" state.energy 24032;
  is "Has one voxel" (Matrix.voxel_count state.matrix) 1;
  is "Original state still has zero voxels" (Matrix.voxel_count empty_state.matrix) 0;

  done_testing ()
