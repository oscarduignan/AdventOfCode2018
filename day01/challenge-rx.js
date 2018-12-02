const { from } = require("rxjs");
const { scan, last, map, filter, repeat, take } = require("rxjs/operators");

const changes$ = from(
  require("fs")
    .readFileSync("input.txt", "utf-8")
    .split("\n")
).pipe(
  filter(x => !!x.trim().length),
  map(x => Number(x))
);

const part1$ = changes$
  .pipe(
    scan((x, y) => x + y),
    last()
  )
  .subscribe(x => console.log(`Part1: ${x}`));

const part2$ = changes$
  .pipe(
    repeat(),
    scan(
      ({ current, previous }, change) => ({
        current: current + change,
        previous: previous.add(current)
      }),
      { current: 0, previous: new Set() }
    ),
    filter(({ current, previous }) => previous.has(current)),
    map(({ current }) => current),
    take(1)
  )
  .subscribe(x => console.log(`Part2: ${x}`));
