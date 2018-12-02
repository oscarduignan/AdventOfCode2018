const input = require("fs")
  .readFileSync("input.txt", "utf-8")
  .split("\n")
  .filter(x => !!x.trim().length);

const part1 = input
  .map(id =>
    Array.from(
      id
        .split("")
        .reduce(
          (frequencies, char) =>
            frequencies.set(char, (frequencies.get(char) || 0) + 1),
          new Map()
        )
        .values()
    ).reduce(
      ([doubleFound, tripleFound], frequency) => [
        doubleFound || frequency === 2,
        tripleFound || frequency === 3
      ],
      [false, false]
    )
  )
  .reduce(
    (totals, next) => totals.map((total, i) => (total + (next[i] ? 1 : 0))),
    [0, 0]
  )
  .reduce((a, b) => a * b);

function part2() {
  for (var i = 0; i < input.length; i++) {
    for (var j = 0; j < input.length; j++) {
      let shared = Array.from(input[i]).filter(
        (_, k) => input[i][k] === input[j][k]
      );

      if (shared.length === input[0].length - 1) return shared.join("");
    }
  }
}

console.log(`
Part1: ${part1}
Part2: ${part2()}
`);
