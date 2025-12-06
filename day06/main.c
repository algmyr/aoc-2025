#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

#define BUFSIZE (1 << 12)

int read_all_lines(char** lines) {
  int n_lines = 0;
  while (true) {
    char* buffer = calloc(BUFSIZE, sizeof(char));
    char* res = fgets(buffer, BUFSIZE, stdin);
    if (!res) {
      free(buffer);
      break;
    }
    *lines++ = buffer;
    n_lines++;
  }
  return n_lines;
}

long solve1(char** lines, int n_lines, int n_cols) {
  char op = lines[n_lines - 1][0];
  long result = op == '+' ? 0 : 1;
  for (int i = 0; i < n_lines - 1; i++) {
    int val = 0;
    for (int j = 0; j < n_cols; j++) {
      if (isdigit(lines[i][j])) {
        val = val * 10 + (lines[i][j] - '0');
      }
    }
    result = op == '+' ? result + val : result * val;
  }
  return result;
}

long solve2(char** lines, int n_lines, int n_cols) {
  char op = lines[n_lines - 1][0];
  long result = op == '+' ? 0 : 1;
  for (int j = 0; j < n_cols; j++) {
    int val = 0;
    for (int i = 0; i < n_lines - 1; i++) {
      if (isdigit(lines[i][j])) {
        val = val * 10 + (lines[i][j] - '0');
      }
    }
    result = op == '+' ? result + val : result * val;
  }
  return result;
}

int main() {
  char* lines[10];
  int n_lines = read_all_lines(lines);

  long res1 = 0;
  long res2 = 0;
  for (;;) {
    char* start[10];
    for (int i = 0; i < n_lines; i++) start[i] = lines[i];
    int n_cols = 0;
    for (;;) {
      bool all_space = true;
      for (int i = 0; i < n_lines; i++) {
        char c = *(lines[i]++);
        if (isdigit(c) || c == '*' || c == '+') {
          all_space = false;
        }
      }
      if (all_space) break;
      n_cols++;
    }
    res1 += solve1(start, n_lines, n_cols);
    res2 += solve2(start, n_lines, n_cols);
    if (lines[0][0] == '\0') {
      break;
    }
  }
  printf("Part 1: %ld\n", res1);
  printf("Part 2: %ld\n", res2);
}
