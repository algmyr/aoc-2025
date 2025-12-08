module Main

import Data.Either
import Data.SortedMap as M
import Data.Stream
import Data.String
import Deriving.Show
import System.File

Point : Type
Point = (Integer, Integer, Integer)

Edge : Type
Edge = (Point, Point)

toInt' : String -> Integer
toInt' = cast

toTriple : List Integer -> Point
toTriple [x, y, z] = (x, y, z)
toTriple _ = (-1, -1, -1) -- Fallback case, should not happen

parseTriple : String -> Point
parseTriple line =
  Data.String.split (\c => c == ',') line
  |> forget |> map toInt' |> toTriple

distance : Point -> Point -> Integer
distance (x1, y1, z1) (x2, y2, z2) =
  dx * dx + dy * dy + dz * dz
  where
    dx = x1 - x2
    dy = y1 - y2
    dz = z1 - z2

find : SortedMap Point Point -> Point -> Point
find parentMap v =
  case M.lookup v parentMap of
    Just parent =>
      if parent == v then
        v
      else
        find parentMap parent
    Nothing => (0, 0, 0) -- Fallback case, should not happen

update : SortedMap k v -> k -> v -> SortedMap k v
update m key value = M.insert key value m

merge : SortedMap Point Point -> SortedMap Point Integer -> Edge -> (Integer, SortedMap Point Point, SortedMap Point Integer)
merge parentMap sizeMap (u, v) =
  let rootU = find parentMap u
      rootV = find parentMap v
  in
    if rootU == rootV then
      (0, parentMap, sizeMap) -- Already in the same set
    else
      let sizeU = fromMaybe 0 (M.lookup rootU sizeMap)
          sizeV = fromMaybe 0 (M.lookup rootV sizeMap)
      in
        if sizeU < sizeV then
          let newParentMap = update parentMap rootU rootV
              newSizeMap = update sizeMap rootV (sizeU + sizeV)
          in (1, newParentMap, newSizeMap)
        else
          let newParentMap = update parentMap rootV rootU
              newSizeMap = update sizeMap rootU (sizeU + sizeV)
          in (1, newParentMap, newSizeMap)


kruskalStep : (Integer, Edge, SortedMap Point Point, SortedMap Point Integer) -> Edge -> (Integer, Edge, SortedMap Point Point, SortedMap Point Integer)
kruskalStep (count, last_e, parentMap, sizeMap) e =
  let (merged, newParentMap, newSizeMap) = merge parentMap sizeMap e
    in if merged == 1 then
          (count + merged, e, newParentMap, newSizeMap)
        else
          (count, last_e, parentMap, sizeMap)

pairwise : List a -> List (a, a)
pairwise xs = [ (x, y) | (i, x) <- e, (j, y) <- e, i < j ]
  where
    indices = [1..length xs]
    e = zip indices xs

process : List Point -> (Integer, Edge, SortedMap Point Point, SortedMap Point Integer) -> String
process vertices (c, last, p, s) =
  vertices
  |> List.filter (\v => M.lookup v p == Just v )
  |> map (\v => M.lookup v s |> fromMaybe 0)
  |> sort |> reverse |> take 3 |> product
  |> show
  
solve1 : List Point -> List Edge -> String
solve1 vertices edges =
  res |> process vertices
  where
    parentMap = M.fromList [(v, v) | v <- vertices]
    sizeMap = M.fromList [(v, 1) | v <- vertices]
    res = foldl kruskalStep (0, ((0,0,0), (0,0,0)), parentMap, sizeMap) edges

solve2 : List Point -> List Edge -> String
solve2 vertices edges =
  res |> \(_, ((x1, _, _), (x2, _, _)), _, _) => x1*x2 |> show
  where
    parentMap = M.fromList [(v, v) | v <- vertices]
    sizeMap = M.fromList [(v, 1) | v <- vertices]
    res = foldl kruskalStep (0, ((0,0,0), (0,0,0)), parentMap, sizeMap) edges

solve : Nat -> String -> String
solve n s =
  res1 ++ "\n" ++ res2
  where
    vertices = lines s |> map parseTriple
    edges = [((distance v1 v2), v1, v2) | (v1, v2) <- pairwise vertices]
    sortedEdges = sort edges |> map (\(d, u, v) => (u, v))
    res1 = solve1 vertices (sortedEdges |> take n)
    res2 = solve2 vertices sortedEdges

run : String -> Nat -> IO ()
run path n = do
  contents <- readFile path
  putStrLn $ solve n $ (fromMaybe ":(" $ getRight contents)
  
main : IO ()
main = do
  run "sample" 10
  run "input" 1000
