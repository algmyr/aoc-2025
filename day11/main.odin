package main

import "core:fmt"
import "core:os"
import "core:strings"

Node :: distinct string
Graph :: distinct map[Node][dynamic]Node

toposort :: proc(start: Node, banned: Node, graph: ^Graph) -> [dynamic]Node {
  dfs :: proc(
    node: Node,
    banned: Node,
    order: ^[dynamic]Node,
    graph: ^Graph,
    visited: ^map[Node]bool,
  ) {
    if node == banned {return}
    if visited[node] {return}
    if node in graph {
      for neighbor in graph[node] {
        dfs(neighbor, banned, order, graph, visited)
      }
    }
    visited[node] = true
    append(order, node)
  }

  visited := make(map[Node]bool)
  defer delete(visited)
  order := make([dynamic]Node)
  dfs(start, banned, &order, graph, &visited)
  return order
}

ways_from_toposort :: proc(ways: ^map[Node]int, order: [dynamic]Node, graph: ^Graph) {
  for node in order {
    if node in graph {
      for neighbor in graph[node] {
        ways[node] += ways[neighbor]
      }
    }
  }
}

compute_ways :: proc(start: Node, end: Node, banned: Node, graph: ^Graph) -> int {
  order := toposort(start, banned, graph)
  defer delete(order)

  ways := make(map[Node]int)
  defer delete(ways)

  ways[end] = 1
  ways_from_toposort(&ways, order, graph)
  return ways[start]
}

compute_3ways :: proc(start: Node, via1: Node, via2: Node, end: Node, graph: ^Graph) -> int {
  return(
    compute_ways(start, via1, via2, graph) *
    compute_ways(via1, via2, "", graph) *
    compute_ways(via2, end, via1, graph) \
  )
}

solve :: proc(graph: ^Graph) {
  res1 := compute_ways("you", "out", "", graph)
  fmt.println("Part 1:", res1)
  res2 :=
    compute_3ways("svr", "dac", "fft", "out", graph) +
    compute_3ways("svr", "fft", "dac", "out", graph)
  fmt.println("Part 2:", res2)
}

main :: proc() {
  data, success := os.read_entire_file_from_handle(os.stdin)
  if !success {
    fmt.println("Failed to read from stdin")
    return
  }
  defer delete(data, context.allocator)

  graph := make(Graph)
  defer delete(graph)

  it := string(data)
  for line in strings.split_lines_iterator(&it) {
    ss := strings.split(line, " ")
    defer delete(ss)
    src := Node(strings.trim_suffix(ss[0], ":"))
    graph[src] = make([dynamic]Node)
    for name in ss[1:] {
      append(&graph[src], Node(name))
    }
  }

  solve(&graph)
}
