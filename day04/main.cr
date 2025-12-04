class Grid
  property data : Array(String)
  property rows : Int32
  property cols : Int32
  
  def initialize(@data : Array(String))
    @rows = data.size
    @cols = data[0].size
  end

  def at(i : Int32, j : Int32) : Bool
    ok(i, j) && @data[i][j] == '@'
  end

  def ok(i : Int32, j : Int32) : Bool
    return 0 <= i && i < @rows && 0 <= j && j < @cols
  end

  def neighs(i : Int32, j : Int32) : Array(Tuple(Int32, Int32))
    neighbors = [] of Tuple(Int32, Int32)
    (-1..1).each do |di|
      (-1..1).each do |dj|
        next if di == 0 && dj == 0
        if ok(i + di, j + dj)
          neighbors << {i + di, j + dj}
        end
      end
    end
    return neighbors
  end
end

grid = Grid.new(STDIN.each_line.to_a)
leaves = [] of Tuple(Int32, Int32)
neigh_counts = Array.new(grid.rows) { Array.new(grid.cols, 0) }
(0...grid.rows).each do |i|
  (0...grid.cols).each do |j|
    neigh_counts[i][j] = grid.neighs(i, j).map { |y, x|
      grid.at(y, x) ? 1 : 0
    }.sum(0)
    if grid.at(i, j) && neigh_counts[i][j] < 4
      leaves << {i, j}
    end
  end
end
p leaves.size

res = 0
while leaves.size > 0
  i, j = leaves.pop
  res += 1
  grid.neighs(i, j).each do |y, x|
    neigh_counts[y][x] -= 1
    leaves << {y, x} if grid.at(y, x) && neigh_counts[y][x] == 3
  end
end
p res
