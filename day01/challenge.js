const changes = require("fs")
  .readFileSync("input.txt", "utf-8")
  .split("\n")
  .filter(x => !!x.trim().length)
  .map(x => Number(x));

function part1() {
  return changes.reduce((x, y) => x + y, 0);
}

function part2() {
  let previous = [0];
  let current = 0;

  while (true) {
    for (var i = 0; i < changes.length; i++) {
      current = current + changes[i];

      if (previous.includes(current)) return current;

      previous.push(current);
    }
  }
}

console.log(`
Part1: ${part1()}
Part2: ${part2()}
`);
