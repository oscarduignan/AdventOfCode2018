defmodule Day3 do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.split([" ", ",", "x", ":", "@", "#"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> calculate_coords_covered
  end

  defp calculate_coords_covered([id, left, top, width, height]) do
    x_points = Range.new(left + 1, left + width)
    y_points = Range.new(top + 1, top + height)

    {id, MapSet.new(for x <- x_points, y <- y_points, do: {x, y})}
  end

  def find_intersecting_area([current_rectangle | other_rectangles]) do
    current_rectangle
    |> find_intersecting_area(other_rectangles)
    |> MapSet.union(find_intersecting_area(other_rectangles))
  end

  def find_intersecting_area([]) do
    MapSet.new()
  end

  def find_intersecting_area({_, outer_area}, rectangles) do
    Enum.reduce(rectangles, MapSet.new(), fn {_, inner_area}, intersecting_area ->
      MapSet.union(
        intersecting_area,
        MapSet.intersection(outer_area, inner_area)
      )
    end)
  end

  def find_non_intersecting(rectangles) do
    Enum.find(rectangles, fn {outer_id, outer_area} ->
      Enum.all?(rectangles, fn {inner_id, inner_area} ->
        outer_id == inner_id || MapSet.disjoint?(outer_area, inner_area)
      end)
    end)
  end
end

case System.argv() do
  [] ->
    ExUnit.start()

    defmodule Day3Test do
      use ExUnit.Case

      import Day3

      test "Part 1" do
        rectangles =
          parse_input("""
          #1 @ 1,3: 4x4
          #2 @ 3,1: 4x4
          #3 @ 5,5: 2x2
          """)

        assert rectangles
               |> find_intersecting_area()
               |> MapSet.size() == 4
      end

      test "Part 2" do
        rectangles =
          parse_input("""
          #1 @ 1,3: 4x4
          #2 @ 3,1: 4x4
          #3 @ 5,5: 2x2
          """)

        assert rectangles
               |> find_non_intersecting()
               |> elem(0) == 3
      end
    end

  [input_file] ->
    rectangles =
      input_file
      |> File.read!()
      |> Day3.parse_input()

    intersecting_area =
      rectangles
      |> Day3.find_intersecting_area()
      |> MapSet.size()

    non_intersecting_rectangle_id =
      rectangles
      |> Day3.find_non_intersecting()
      |> elem(0)

    IO.puts("""
    Part1: #{intersecting_area}
    Part2: #{non_intersecting_rectangle_id}
    """)
end
