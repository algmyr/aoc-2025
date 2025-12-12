package main

import "core:fmt"
import "core:os"
import "core:strings"

Node :: distinct string
Graph :: distinct map[Node][dynamic]Node

ways :: proc(start: Node, end: Node, graph: ^Graph) -> int {
  dfs :: proc(node: Node, graph: ^Graph, count: ^map[Node]int) {
    if node in count {return}
    if node in graph {
      for neighbor in graph[node] {dfs(neighbor, graph, count)}
      sum := 0
      for neighbor in graph[node] {sum += count[neighbor]}
      count[node] = sum
    }
  }

  count := make(map[Node]int)
  defer delete(count)
  count[end] = 1
  dfs(start, graph, &count)
  return count[start]
}

ways3 :: proc(start: Node, via1: Node, via2: Node, end: Node, graph: ^Graph) -> int {
  return ways(start, via1, graph) * ways(via1, via2, graph) * ways(via2, end, graph)
}

solve :: proc(graph: ^Graph) {
  res1 := ways("you", "out", graph)
  fmt.println("Part 1:", res1)
  res2 := ways3("svr", "dac", "fft", "out", graph) + ways3("svr", "fft", "dac", "out", graph)
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
