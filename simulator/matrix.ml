
open Voxel
open Coordinate

module Coordinates =
  struct
    type t = coordinate_t
    let compare (x0, y0, z0) (x1, y1, z1) =
      match Pervasives.compare x0 x1 with
      | 0 -> (match Pervasives.compare y0 y1 with
        | 0 -> Pervasives.compare z0 z1
        | c -> c)
      | c -> c
  end

module CoordinateSet = Set.Make(Coordinates)

type matrix_t = CoordinateSet.t

let empty_matrix () = CoordinateSet.empty

let voxel_count m = CoordinateSet.cardinal m

let set m c v =
  match v with
  | Full -> CoordinateSet.add c m
  | Void -> CoordinateSet.remove c m

let get m c =
  if CoordinateSet.mem c m
  then Full
  else Void

let toggle m c =
  match get m c with
  | Full -> set m c Void
  | Void -> set m c Full

let touches_something_in grounded unknown_v =
  CoordinateSet.exists (touches unknown_v) grounded

let also_grounded grounded unknown =
  CoordinateSet.partition (touches_something_in grounded) unknown

let rec is_grounded' grounded unknown =
  let also_grounded, unknown = also_grounded grounded unknown in
  if CoordinateSet.is_empty also_grounded then
    grounded
  else
    let also_grounded = is_grounded' also_grounded unknown in
    CoordinateSet.union grounded also_grounded

let is_grounded m =

  (* Get our seed of things we know are grounded *)
  let grounded, unknown = CoordinateSet.partition (fun (x,y,z) -> y == 0) m in

  (* Ruturn whether everything else is grounded *)
  CoordinateSet.equal (is_grounded' grounded unknown) m
