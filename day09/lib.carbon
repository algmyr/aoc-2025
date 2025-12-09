library "lib";

import Core library "io";
import Core library "range";

var unread_char: i32 = 0;

fn ReadChar() -> i32 {
  if (unread_char != 0) {
    var result: i32 = unread_char - 2;
    unread_char = 0;
    return result;
  }

  return Core.ReadChar();
}

fn UnreadChar(c: i32) {
  unread_char = c + 2;
}

fn ReadInt(p: i32*) -> bool {
  var read_any_digits: bool = false;
  *p = 0;

  while (true) {
    var c: i32 = ReadChar();
    if (c < 0x30 or c > 0x39) {
      UnreadChar(c);
      break;
    }
    *p *= 10;
    *p += c - 0x30;
    read_any_digits = true;
  }
  return read_any_digits;
}

fn ConsumeChar(c: i32) -> bool {
  var next: i32 = ReadChar();
  if (next != c) {
    UnreadChar(next);
    return false;
  }
  return true;
}

fn Range(l: i32, r: i32) -> Core.IntRange(32) {
  return Core.IntRange(32).Make(l, r);
}

fn Abs(n: i32) -> i32 { return if n < 0 then -n else n; }
