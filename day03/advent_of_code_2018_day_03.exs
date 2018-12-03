defmodule Day3 do
  def reject_intersecting(rectangles, area) do
    rectangles
    |> Enum.filter(fn %{area: rectangle_area} ->
      MapSet.disjoint?(area, rectangle_area)
    end)
  end

  def find_intersecting_area([]), do: MapSet.new()

  def find_intersecting_area([current_rectangle | other_rectangles]) do
    current_rectangle
    |> find_intersecting_area(other_rectangles)
    |> MapSet.union(find_intersecting_area(other_rectangles))
  end

  def find_intersecting_area(current_rectangle, other_rectangles) do
    other_rectangles
    |> Enum.reduce(MapSet.new(), fn other_rectangle, intersecting_area ->
      MapSet.union(
        intersecting_area,
        MapSet.intersection(
          current_rectangle.area,
          other_rectangle.area
        )
      )
    end)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.split([" ", ",", "x", ":", "@", "#"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> into_map
    |> put_area
  end

  defp into_map([id, left, top, width, height]) do
    %{
      id: id,
      left: left,
      top: top,
      width: width,
      height: height
    }
  end

  defp put_area(rectangle) do
    rectangle
    |> Map.put(:area, area(rectangle))
  end

  defp area(%{top: top, left: left, width: width, height: height}) do
    Range.new(left + 1, left + width)
    |> Enum.reduce(MapSet.new(), fn x, acc ->
      Range.new(top + 1, top + height)
      |> Enum.reduce(acc, fn y, acc -> acc |> MapSet.put({x, y}) end)
    end)
  end
end

case System.argv() do
  [] ->
    ExUnit.start()

    defmodule Day3Test do
      use ExUnit.Case

      test "Part 1" do
        rectangles =
          Day3.parse_input("""
          #1 @ 1,3: 4x4
          #2 @ 3,1: 4x4
          #3 @ 5,5: 2x2
          """)

        assert rectangles |> Day3.find_intersecting_area() |> MapSet.size() == 4
      end

      test "Part 2" do
        rectangles =
          Day3.parse_input("""
          #1 @ 1,3: 4x4
          #2 @ 3,1: 4x4
          #3 @ 5,5: 2x2
          """)

        intersecting_area = rectangles |> Day3.find_intersecting_area()

        assert rectangles
               |> Day3.reject_intersecting(intersecting_area)
               |> List.first()
               |> Map.get(:id) == 3
      end
    end

  [input_file] ->
    rectangles = input_file |> File.read!() |> Day3.parse_input()

    intersecting_area = rectangles |> Day3.find_intersecting_area()

    non_intersecting_rectangle_id =
      rectangles |> Day3.reject_intersecting(intersecting_area) |> List.first() |> Map.get(:id)

    IO.puts("""
    Part1: #{MapSet.size(intersecting_area)}
    Part2: #{non_intersecting_rectangle_id}
    """)
end
