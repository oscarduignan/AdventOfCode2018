defmodule Day5 do
  @case_difference ?a - ?A

  def part1(input) do
    trigger(input) |> String.length()
  end

  def part2(input) do
    Enum.min(
      Enum.map(?a..?z, fn c ->
        input
        |> String.replace(~r/#{List.to_string([c])}/i, "")
        |> part1()
      end)
    )
  end

  def trigger(input) do
    input
    |> String.trim()
    |> String.to_charlist()
    |> List.foldr([], fn
      c, [] ->
        [c]

      c, [head] = acc ->
        if abs(c - head) == @case_difference do
          []
        else
          [c] ++ acc
        end

      c, [head | tail] = acc ->
        if abs(c - head) == @case_difference do
          tail
        else
          [c] ++ acc
        end
    end)
    |> List.to_string()
  end
end

case System.argv() do
  [] ->
    ExUnit.start()

    defmodule Day6Test do
      use ExUnit.Case

      import Day6

      test "the truth" do
        assert true
      end

      test "can trigger reactions" do
        assert trigger("dabAcCaCBAcCcaDA") == "dabCBAcaDA"
      end

      test "can solve part1" do
        assert part1("dabAcCaCBAcCcaDA") == 10
      end

      test "can solve part2" do
        assert part2("dabAcCaCBAcCcaDA") == 4
      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> Day5.part1()
    |> IO.inspect(label: "Part 1")

    input_file
    |> File.read!()
    |> Day5.part2()
    |> IO.inspect(label: "Part 2")
end
