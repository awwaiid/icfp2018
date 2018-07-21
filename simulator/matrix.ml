
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

