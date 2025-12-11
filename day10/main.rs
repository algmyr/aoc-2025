use std::io::Read;

use microlp::{ComparisonOp, LinearExpr, OptimizationDirection, Problem};

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

fn solve2(input: &Input) -> f64 {

  let mut problem = Problem::new(OptimizationDirection::Minimize);
  let mut vars = vec![];
  for _ in 0..input.schematics.len() {
    vars.push(problem.add_integer_var(1.0, (0, 10000)));
  }

  let mut lexps = vec![LinearExpr::empty(); input.numbers.len()];
  for (i, schem) in input.schematics.iter().enumerate() {
    for &n in schem {
      lexps[n as usize].add(vars[i], 1.0);
    }
  }
  for (&n, lexp) in input.numbers.iter().zip(lexps) {
    problem.add_constraint(lexp, ComparisonOp::Eq, n.into());
  }

  if let Ok(solution) = problem.solve() {
    solution.objective()
  } else {
    f64::INFINITY
  }
}

fn part2(inputs: &[Input]) -> Result<f64, Box<dyn std::error::Error>> {
  let mut res = 0.0;
  for input in inputs {
    let steps = solve2(input);
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
