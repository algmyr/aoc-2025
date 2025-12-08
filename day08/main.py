import sys

class mergefind:
    def __init__(self,n):
        self.parent = list(range(n))
        self.size = [1]*n
        self.num_sets = n

    def find(self,a):
        to_update = []
       
        while a != self.parent[a]:
            to_update.append(a)
            a = self.parent[a]
       
        for b in to_update:
            self.parent[b] = a

        return self.parent[a]

    def merge(self,a,b):
        a = self.find(a)
        b = self.find(b)

        if a==b:
            return

        if self.size[a]<self.size[b]:
            a,b = b,a

        self.num_sets -= 1
        self.parent[b] = a
        self.size[a] += self.size[b]

    def set_size(self, a):
        return self.size[self.find(a)]

    def __len__(self):
        return self.num_sets

points = [[int(x) for x in s.split(',')] for s in sys.stdin.read().splitlines()]

def dist(p1, p2):
  return sum((a - b) ** 2 for a, b in zip(p1, p2))

edges = [(dist(p1, p2), i, j) for i, p1 in enumerate(points) for j, p2 in enumerate(points) if i < j]
edges.sort()

mf = mergefind(len(points))

updates = 0
curlen = len(mf)
for d, p1, p2 in edges:
  mf.merge(p1, p2)
  newlen = len(mf)

  if newlen < curlen:
    curlen = newlen
  updates += 1
  if updates == 1000:
    break

last = 3
largest = sorted([mf.set_size(p) for p in range(len(points)) if mf.find(p) == p])[-3:]
print(largest)
print(len(mf))

