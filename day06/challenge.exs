defmodule Challenge do
  def solve(input, safe_manhattan_sum) do
    coords = parse_coords(input)

    {{x_min, _}, {x_max, _}} = Enum.min_max_by(coords, &elem(&1, 0))
    {{_, y_min}, {_, y_max}} = Enum.min_max_by(coords, &elem(&1, 1))
    grid = for x <- x_min..x_max, y <- y_min..y_max, do: {x, y}

    {size_of_safe_region, areas} =
      Enum.reduce(grid, {0, %{}}, fn {x, y} = a, {size_of_safe_region, areas} ->
        [{coord, d1} | [{_, d2} | _]] =
          distances =
          coords
          |> Enum.map(fn b -> {b, manhattan_distance(a, b)} end)
          |> Enum.sort_by(&elem(&1, 1))

        {if Enum.sum(distances |> Enum.map(&elem(&1, 1))) < safe_manhattan_sum do
           size_of_safe_region + 1
         else
           size_of_safe_region
         end,
         if d1 == d2 do
           areas
         else
           on_edge = x == x_min || x == x_max || y == y_min || y == y_max

           areas
           |> Map.update(coord, {1, on_edge}, fn {size, infinite} ->
             {size + 1, infinite || on_edge}
           end)
         end}
      end)

    size_of_largest_non_infinite_area =
      areas
      |> Map.values()
      |> Enum.filter(fn {_size, infinite} -> not infinite end)
      |> Enum.max_by(fn {size, _infinite} -> size end)
      |> elem(0)

    {size_of_largest_non_infinite_area, size_of_safe_region}
  end

  def parse_coords(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x, y] =
        line
        |> String.split(", ")
        |> Enum.map(&String.to_integer/1)

      {x, y}
    end)
  end

  def manhattan_distance({a_x, a_y}, {b_x, b_y}) do
    abs(a_x - b_x) + abs(a_y - b_y)
  end
end

case System.argv() do
  [] ->
    ExUnit.start()

    defmodule ChallengeTest do
      use ExUnit.Case

      import Challenge

      @coords """
      1, 1
      1, 6
      8, 3
      3, 4
      5, 5
      8, 9
      """

      test "the truth" do
        assert true
      end

      test "can parse input into coords" do
        assert parse_coords(@coords) == [{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}]
      end

      test "can solve part1 example" do
        {part1, _} = solve(@coords, 32)

        assert part1 == 17
      end

      test "can solve part2 example" do
        {_, part2} = solve(@coords, 32)

        assert part2 == 16
      end
    end

  [input_file] ->
    safe_manhattan_sum = 10_000

    {part1, part2} =
      input_file
      |> File.read!()
      |> Challenge.solve(safe_manhattan_sum)

    IO.puts("""
    Part1: #{part1}
    Part2: #{part2}
    """)
end
