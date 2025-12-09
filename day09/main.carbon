import Core library "io";
import Core library "range";

import library "lib";

fn ReadPair() -> (i32, i32) {
  var x: i32 = -1;
  var y: i32 = -1;
  if (not (ReadInt(&x) and ConsumeChar(0x2C) and ReadInt(&y) and ConsumeChar(0xA))) {
    return (-1, -1);
  }
  return (x as i32, y as i32);
}

fn PrInt(n: i64) {
  if (n >= 10) {
    PrInt(n/10);
  }
  Core.PrintChar((((n%10) + 48) as u8) as char);
}

fn Order(a: i32*, b: i32*) {
  if (*a > *b) {
    var temp: i32 = *a;
    *a = *b;
    *b = temp;
  }
}

fn ToCompress(ref data: array(i32, 100000)) {
  var i: i32 = 0;
  for (var v: i32 in Range(0, 100000)) {
    if (data[v] == 1) {
      data[v] = i;
      i += 2;
    } else {
      data[v] = -1;
    }
  }
}

fn FloodFill(ref grid: array(array(i32, 1000), 1000), x: i32, y: i32) {
  if (grid[x][y] != 0) {
    return;
  }
  grid[x][y] = 2;
  FloodFill(ref grid, x + 1, y);
  FloodFill(ref grid, x - 1, y);
  FloodFill(ref grid, x, y + 1);
  FloodFill(ref grid, x, y - 1);
}

fn Run() -> i32 {
  // Read input and compress coordinates.
  var pairs: array((i32, i32), 500);
  var size: i32 = 0;
  var compress_x: array(i32, 100000);
  var compress_y: array(i32, 100000);
  for (var i: i32 in Range(0, 100000)) {
    compress_x[i] = 0;
    compress_y[i] = 0;
  }
  while (true) {
    var pair: (i32, i32) = ReadPair();
    if (pair.0 == -1) {
      break;
    }
    pairs[size] = pair;
    compress_x[pair.0] = 1;
    compress_y[pair.1] = 1;
    size += 1;
  }
  ToCompress(ref compress_x);
  ToCompress(ref compress_y);

  // Build compressed grid.
  var grid: array(array(i32, 1000), 1000);
  for (var i: i32 in Range(0, 1000)) {
    for (var j: i32 in Range(0, 1000)) {
      grid[i][j] = 0;
    }
  }
  for (var i: i32 in Range(0, size)) {
    var p: (i32, i32) = pairs[i];
    var q: (i32, i32) = pairs[(i + 1) % size];
    var x1: i32 = compress_x[p.0];
    var y1: i32 = compress_y[p.1];
    var x2: i32 = compress_x[q.0];
    var y2: i32 = compress_y[q.1];
    Order(&x1, &x2);
    Order(&y1, &y2);
    if (y1 == y2) {
      for (var x: i32 in Range(x1, x2 + 1)) {
        grid[x][y1] = 1;
      }
    } else {
      for (var y: i32 in Range(y1, y2 + 1)) {
        grid[x1][y] = 1;
      }
    }
  }
  var fill_y: i32 = 0;
  while (grid[0][fill_y] == 0) {
    fill_y += 1;
  }
  fill_y += 1;
  FloodFill(ref grid, 1, fill_y);

  // Try all pairs of corners.
  var max1: i64 = 0;
  var max2: i64 = 0;
  for (var j: i32 in Range(0, size)) {
    var pj: (i32, i32) = pairs[j];
    for (var i: i32 in Range(0, j)) {
      var pi: (i32, i32) = pairs[i];
      var area: i64 = ((Abs(pi.0 - pj.0) + 1) as i64)*((Abs(pi.1 - pj.1) + 1) as i64);
      if (area > max1) {
        max1 = area;
      }
      if (area > max2) {
        // Check if all points are inside.
        var x1: i32 = compress_x[pi.0];
        var y1: i32 = compress_y[pi.1];
        var x2: i32 = compress_x[pj.0];
        var y2: i32 = compress_y[pj.1];
        Order(&x1, &x2);
        Order(&y1, &y2);
        var inside: bool = true;
        for (var x: i32 in Range(x1, x2 + 1)) {
          for (var y: i32 in Range(y1, y2 + 1)) {
            if (grid[x][y] == 0) {
              inside = false;
              break;
            }
          }
          if (not inside) {
            break;
          }
        }
        if (inside) {
          max2 = area;
        }
      }
    }
  }
  PrInt(max1);
  Core.PrintChar('\n');
  PrInt(max2);
  Core.PrintChar('\n');
  return 0;
}
