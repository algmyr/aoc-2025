use std::collections::HashMap;
use std::io::Read;

#[derive(Debug)]
struct Input {
  target_mask: u32,
  schematics: Vec<Vec<i32>>,
  numbers: Vec<i32>,
}

fn solve1(input: &Input) -> usize {
  let masks: Vec<u32> = input
    .schematics
    .iter()
    .map(|schem| {
      let mut mask = 0u32;
      for num in schem {
        mask |= 1 << *num as u32;
      }
      mask
    })
    .collect();

  let mut layer = vec![0u32];
  let mut steps = 0;
  while !layer.is_empty() {
    let mut new_layer = vec![];
    for cur in layer {
      for m in &masks {
        let new_mask = cur ^ m;
        if new_mask == input.target_mask {
          return steps + 1;
        } else {
          new_layer.push(new_mask);
        }
      }
    }
    new_layer.sort();
    new_layer.dedup();
    layer = new_layer;
    steps += 1;
  }
  usize::MAX
}

fn part1(inputs: &[Input]) -> Result<usize, Box<dyn std::error::Error>> {
  let mut res = 0;
  for input in inputs {
    let steps = solve1(input);
    res += steps;
  }
  Ok(res)
}

const INF: i32 = 1_000_000;

// Credit to https://www.reddit.com/r/adventofcode/comments/1pk87hl/2025_day_10_part_2_bifurcate_your_way_to_victory/
// The idea:
//   Deal with all "odd" number of button presses.
//   Try all combinations of schematics, keep those that make even targets.
//   Divide targets by 2 to get a smaller otherwise identical problem.
fn f(target: &Vec<i32>, input: &Input, cache: &mut HashMap<Vec<i32>, i32>) -> i32 {
  if let Some(&res) = cache.get(target.as_slice()) {
    return res;
  }
  if target.iter().all(|&x| x == 0) {
    return 0;
  }

  // Try the up to 2^k schematic combinations.
  let mut vec = vec![(target.clone(), 0)];
  for schem in &input.schematics {
    vec = vec
      .into_iter()
      .flat_map(|(t, s)| {
        let mut t1 = t.clone();
        for &n in schem {
          if t1[n as usize] == 0 {
            return vec![(t.clone(), s)];
          } else {
            t1[n as usize] -= 1;
          }
        }
        vec![(t.clone(), s), (t1, s + 1)]
      })
      .collect();
  }
  // Recurse into the even-only targets.
  let res = vec
    .into_iter()
    .filter_map(|(new_target, steps_added)| {
      if new_target.iter().any(|&x| x % 2 != 0) {
        None
      } else {
        let new_target = new_target.into_iter().map(|x| x / 2).collect();
        let cand = 2 * f(&new_target, input, cache) + steps_added;
        Some(cand)
      }
    })
    .min()
    .unwrap_or(INF);

  cache.insert(target.clone(), res);
  res
}

fn part2(inputs: &[Input]) -> Result<f64, Box<dyn std::error::Error>> {
  let mut res = 0.0;
  for input in inputs {
    let steps = f(&input.numbers, input, &mut HashMap::new()) as f64;
    res += steps;
  }
  Ok(res)
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
  let mut s = String::new();
  std::io::stdin().read_to_string(&mut s)?;

  let mut inputs = vec![];

  for x in s.lines() {
    let mut target_mask = 0u32;
    let mut schematics = vec![];
    let mut numbers = vec![];

    for part in x.split(' ') {
      let c = part.bytes().next().unwrap();
      if c == b'[' {
        let mut mask = 0u32;
        for (i, ch) in part.bytes().enumerate().skip(1) {
          if ch == b'#' {
            mask |= 1 << i - 1;
          }
        }
        target_mask = mask;
      } else if c == b'(' {
        let schematic = part
          .trim_matches(|x| x == '(' || x == ')')
          .split(',')
          .map(|num_str| num_str.parse::<i32>().unwrap())
          .collect::<Vec<i32>>();
        schematics.push(schematic);
      } else if c == b'{' {
        numbers = part
          .trim_matches(|x| x == '{' || x == '}')
          .split(',')
          .map(|num_str| num_str.parse::<i32>().unwrap())
          .collect();
      }
    }
    inputs.push(Input { target_mask, schematics, numbers });
  }

  println!("Part 1: {}", part1(&inputs)?);
  println!("Part 2: {}", part2(&inputs)?);
  Ok(())
}
