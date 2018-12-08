defmodule Challenge do
  def part1(input) do
    input
    |> parse
    |> process
    |> Enum.join()
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce({%{}, %{}}, fn "Step " <>
                                    <<a::bytes-size(1)>> <>
                                    " must be finished before step " <>
                                    <<b::bytes-size(1)>> <> " can begin.",
                                  {jobs, deps} ->
      {
        Map.update(jobs, a, [b], &[b | &1]),
        Map.update(deps, b, MapSet.new([a]), &MapSet.put(&1, a))
      }
    end)
  end

  def process({jobs, deps}) do
    ready =
      MapSet.difference(
        MapSet.new(Map.keys(jobs)),
        MapSet.new(Map.keys(deps))
      )

    process(jobs, deps, ready, MapSet.new(), [])
  end

  def process(jobs, deps, ready, completed, ordered) do
    [job | remaining] = Enum.sort(ready)

    children = Map.get(jobs, job, [])

    completed = MapSet.put(completed, job)

    ordered = [job | ordered]

    ready =
      Enum.reduce(children, MapSet.new(remaining), fn child, ready ->
        if MapSet.subset?(Map.get(deps, child), completed) do
          ready |> MapSet.put(child)
        else
          ready
        end
      end)

    if (Enum.empty?(ready)) do
      ordered |> Enum.reverse
    else
      process(jobs, deps, ready, completed, ordered)
    end
  end
end

case System.argv() do
  [] ->
    ExUnit.start()

    defmodule ChallengeTest do
      use ExUnit.Case

      import Challenge

      @example """
      Step C must be finished before step A can begin.
      Step C must be finished before step F can begin.
      Step A must be finished before step B can begin.
      Step A must be finished before step D can begin.
      Step B must be finished before step E can begin.
      Step D must be finished before step E can begin.
      Step F must be finished before step E can begin.
      """

      test "the truth" do
        assert true
      end

      test "can parse jobs and deps" do
        {jobs, deps} = parse(@example)

        assert jobs == %{
                 "A" => ["D", "B"],
                 "B" => ["E"],
                 "C" => ["F", "A"],
                 "D" => ["E"],
                 "F" => ["E"]
               }

        # assert deps == %{
        #          "A" => ["C"],
        #          "B" => ["A"],
        #          "D" => ["A"],
        #          "E" => ["F", "D", "B"],
        #          "F" => ["C"]
        #        }
      end

      test "can solve part1" do
        part1 = Challenge.part1(@example)

        assert part1 == "CABDFE"
      end
    end

  [input_file] ->
    part1 =
      input_file
      |> File.read!()
      |> Challenge.part1()
      |> IO.inspect(label: "Part 1")

    # IO.puts("""
    # Part1: #{part1}
    # Part2: #{part2}
    # """)
end
