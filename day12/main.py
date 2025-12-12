import string
import sys

# Let's build a: python
def zip(a, b):
  res = []
  for i in range(len(a)):
    res.append((a[i], b[i]))
  return res

def sum(l):
  res = 0
  for x in l:
    res = res + x
  return res

def map(f, l):
  res = []
  for x in l:
    res.append(f(x))
  return res

###

def parse_case(s):
  parts = string.splitfields(s, ': ')
  size = string.splitfields(parts[0], 'x')
  size = (string.atoi(size[0]), string.atoi(size[1]))
  block_counts = []
  for count in string.split(parts[1]):
    block_counts.append(string.atoi(count))
  return size, block_counts

def parse_blocks(blocks):
  res = []
  for block in blocks:
    res.append(string.splitfields(block, '\n')[1:])
  return res

s = string.strip(sys.stdin.read(100000))
chunks = string.splitfields(s, '\n\n')
blocks = parse_blocks(chunks[:-1])
cases = string.splitfields(chunks[len(chunks)-1], '\n')

def block_occupancy(block):
  res = 0
  for row in block:
    for c in row:
      if c = '#':
        res = res + 1
  return res

res = 0
for case in cases:
  size, block_counts = parse_case(case)
  blocks_placeable = (size[0] / 3) * (size[1] / 3)
  total_blocks = sum(block_counts)
  area_needed = 0
  for count, block in zip(block_counts, blocks):
    area_needed = area_needed + count * block_occupancy(block)
  area_available = size[0] * size[1]
  if total_blocks <= blocks_placeable:
    res = res + 1
  elif area_needed > area_available:
    pass
  else:
    print 'Maybe possible with packing. Eric pls.'
    1/0
print 'Part 1:', res
