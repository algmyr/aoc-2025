def solve(inp, n)
  inp.map{|s|
    lim = s.length - n
    stack = []
    for c, i in s.chars.each_with_index
      while !stack.empty? and stack.last < c and lim > stack.length + i
        stack.pop
      end
      stack << c
    end
    stack.first(n).join.to_i
  }.sum
end

inp = $<.map{|s| s.chomp}
p solve(inp, 2)
p solve(inp, 12)
