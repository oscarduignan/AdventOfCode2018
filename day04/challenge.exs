defmodule Day4 do
  def part1(input) do
    {guard_id, %{asleep_during: asleep_during}} =
      input
      |> parse_events()
      |> find_out_how_much_guards_slept()
      |> find_who_slept_most()

    {minute_most_asleep, _} = asleep_during |> find_minute_most_asleep()

    guard_id * minute_most_asleep
  end

  def part2(input) do
    {guard_id, minute, _} =
      input
      |> parse_events()
      |> find_out_how_much_guards_slept()
      |> find_out_who_slept_most_frequently_during_one_minute()

    guard_id * minute
  end

  def parse_events(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.sort()
    |> Enum.map(&parse_event/1)
  end

  def find_out_how_much_guards_slept(events) do
    events
    |> Enum.reduce(%{}, &project_event/2)
    |> Map.get(:guards)
  end

  defp find_out_who_slept_most_frequently_during_one_minute(how_much_guards_slept) do
    how_much_guards_slept
    |> Enum.map(fn {guard_id, %{asleep_during: asleep_during}} ->
      {minute_most_asleep, occurences} = asleep_during |> find_minute_most_asleep()
      {guard_id, minute_most_asleep, occurences}
    end)
    |> Enum.max_by(fn x -> elem(x, 2) end)
  end

  def find_who_slept_most(how_much_guards_slept) do
    how_much_guards_slept
    |> Enum.max_by(&(elem(&1, 1) |> Map.get(:asleep_for)))
  end

  def find_minute_most_asleep(asleep_during) do
    asleep_during
    |> Enum.reduce(
      %{},
      &Enum.reduce(&1, &2, fn minute, counts ->
        Map.update(counts, minute, 1, fn x -> x + 1 end)
      end)
    )
    |> Enum.max_by(fn x -> elem(x, 1) end)
  end

  defp project_event({:begins_shift, _, guard_id}, state) do
    Map.put(state, :current_guard, guard_id)
  end

  defp project_event({:falls_asleep, timestamp}, %{current_guard: current_guard} = state) do
    asleep = minutes(timestamp)

    Map.update(state, :guards, Map.put(%{}, current_guard, sleeping_guard(asleep)), fn guards ->
      Map.update(
        guards,
        current_guard,
        sleeping_guard(asleep),
        fn guard ->
          Map.put(guard, :asleep, asleep)
        end
      )
    end)
  end

  defp project_event({:wakes_up, timestamp}, %{current_guard: current_guard} = state) do
    asleep = get_in(state, [:guards, current_guard, :asleep])
    awake = minutes(timestamp)
    asleep_for = awake - asleep
    asleep_during = Range.new(asleep, awake - 1)

    state
    |> update_in([:guards, current_guard], &Map.delete(&1, :asleep))
    |> update_in([:guards, current_guard, :asleep_for], fn so_far -> so_far + asleep_for end)
    |> update_in([:guards, current_guard, :asleep_during], fn so_far ->
      so_far ++ [asleep_during]
    end)
  end

  defp minutes(<<_::bytes-size(10)>> <> minutes) do
    minutes |> String.to_integer()
  end

  defp sleeping_guard(asleep) do
    %{asleep_for: 0, asleep_during: [], asleep: asleep}
  end

  defp parse_event(line) when is_binary(line) do
    line
    |> String.split("] ")
    |> parse_event
  end

  defp parse_event([datetime, event]) do
    timestamp = datetime |> String.replace(~r/[^0-9]/, "")

    event
    |> String.split([" ", "#"], trim: true)
    |> case do
      ["wakes", "up"] ->
        {:wakes_up, timestamp}

      ["falls", "asleep"] ->
        {:falls_asleep, timestamp}

      ["Guard", guard_id, "begins", "shift"] ->
        {:begins_shift, timestamp, String.to_integer(guard_id)}
    end
  end
end

case System.argv() do
  [] ->
    ExUnit.start()

    defmodule Day4Test do
      use ExUnit.Case

      import Day4

      test "the truth" do
        assert true
      end

      test "Can parse events" do
        events =
          """
          [1518-11-01 00:25] wakes up
          [1518-11-01 00:00] Guard #10 begins shift
          [1518-11-01 00:05] falls asleep
          """
          |> parse_events()

        assert events == [
                 {:begins_shift, "151811010000", "10"},
                 {:falls_asleep, "151811010005"},
                 {:wakes_up, "151811010025"}
               ]
      end

      test "Can project a list of ordered events into a current state" do
        state =
          """
          [1518-11-02 00:25] wakes up
          [1518-11-02 00:00] Guard #10 begins shift
          [1518-11-02 00:05] falls asleep
          [1518-11-01 00:10] wakes up
          [1518-11-01 00:00] Guard #99 begins shift
          [1518-11-01 00:40] wakes up
          [1518-11-01 00:05] falls asleep
          [1518-11-01 00:20] falls asleep
          [1518-11-03 00:00] Guard #99 begins shift
          [1518-11-03 00:05] falls asleep
          [1518-11-03 00:20] wakes up
          """
          |> parse_events()
          |> order_events()
          |> find_who_slept_most()

        assert {"99",
                %{
                  asleep_for: 40,
                  asleep_during: [5..9, 20..39, 5..19]
                }} = state
      end

      test "Can calculate answer to part1 and part2" do
        input = """
        [1518-11-01 00:00] Guard #10 begins shift
        [1518-11-01 00:05] falls asleep
        [1518-11-01 00:25] wakes up
        [1518-11-01 00:30] falls asleep
        [1518-11-01 00:55] wakes up
        [1518-11-01 23:58] Guard #99 begins shift
        [1518-11-02 00:40] falls asleep
        [1518-11-02 00:50] wakes up
        [1518-11-03 00:05] Guard #10 begins shift
        [1518-11-03 00:24] falls asleep
        [1518-11-03 00:29] wakes up
        [1518-11-04 00:02] Guard #99 begins shift
        [1518-11-04 00:36] falls asleep
        [1518-11-04 00:46] wakes up
        [1518-11-05 00:03] Guard #99 begins shift
        [1518-11-05 00:45] falls asleep
        [1518-11-05 00:55] wakes up
        """

        assert part1(input) == 240
        assert part2(input) == 4455
      end
    end

  [input_file] ->
    part1 =
      input_file
      |> File.read!()
      |> Day4.part1()

    part2 =
      input_file
      |> File.read!()
      |> Day4.part2()

    IO.puts("""
    Part1: #{part1}
    Part2: #{part2}
    """)
end
