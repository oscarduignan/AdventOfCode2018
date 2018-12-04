defmodule Day4 do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
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
        """
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

        # "[1518-11-05 00:03] Guard #99 begins shift" |> String.replace(~r/[^0-9a-zA-Z ]/, "")

        # TODO: refactor from tuples to maps so I can do %{current_guard | last_asleep_at: event_time}

        # dates = for date <- dates, do: date |> String.replace(~r/[^0-9a-zA-Z ]/, "") |> String.to_integer()

        # ordered_dates_in_maps = dates |> Enum.map(&(Map.new() |> Map.put(:id, &1))) |> Enum.sort_by(&(Map.get(&1, :id)))

        # iex(1)> "[1518-11-05 00:03] Guard #99 begins shift" |> String.split("] ")
        # ["[1518-11-05 00:03", "Guard #99 begins shift"]
        # iex(2)> [datetime, message] = "[1518-11-05 00:03] Guard #99 begins shift" |> String.split("] ")
        # ["[1518-11-05 00:03", "Guard #99 begins shift"]
        # iex(3)> datetime |> String.replace(~r/[^0-9]/, "") |> String.to_integer()
        # 151811050003
        # "[1518-11-05 00:03] Guard #99 begins shift" |> String.split("] ") |> List.update_at(0, &(&1 |> String.replace(~r/[^0-9]/, "") |> String.to_integer())) |> List.update_at(1, &(String.split(&1, [" ", "#"], trim: true)))

        # "[1518-11-05 00:03] Guard #99 begins shift"
        # |> String.split("] ")
        # |> List.update_at(0, &String.to_integer(String.replace(&1, ~r/[^0-9]/, "")))
        # |> List.update_at(1, &String.split(&1, [" ", "#"], trim: true))

        # {_, {guard_asleep_most, _, asleep_most_minutes}} = input -> split -> sort_by_newest_first -> reduce({nil, nil},
        #   line, {current_guard, guard_most_asleep} ->
        #     case parse(line) event, time, [, guard_id] do
        #       guard_begins, _ , _ ->
        #         {{id, :awake, 0, %{}},
        #           case {previous_guard, guard_most_asleep} do
        #             {nil, nil} ->
        #               nil
        #             {_, nil} ->
        #               previous_guard
        #             {{_, _, previous_total, _}, {_, _, most_so_far, _}} ->
        #               case (previous_total > most_so_far) do
        #                 true  -> previous_guard
        #                 false -> guard_most_asleep
        #               end

        #       guard_falls_asleep, asleep_at ->
        #         {{id, asleep_at, asleep_total, minutes_asleep}, guard_most_asleep}

        #       guard_wakes_up ->
        #         {{id, last_asleep_at, asleep_total + (awake_at - asleep_at), asleep_at..awake_at |> reduce(minutes_asleep, minute_asleep -> Map.update(minute_asleep, 1, &inc/1))}
        #     end

        #   {minute_most_asleep, _} = asleep_most_minutes |> max_by(&(max(elem(&1, 1), elem(&2, 1)))))

        #   guard_asleep_most * minute_most_asleep

        #   part1()
        #     guard = input |> split |> Enum.map(&parse_event/1) |> sort_by(&List.first/1) |> reduce &reduce_event(&1, &2) |> elem(1) |> find_minute_most_asleep
        #     guard.id * guard.minute_most_often_asleep


        assert ###
      end

      # test "Part 2" do
      #   rectangles =
      #     parse_input("""
      #     """)

      #   assert
      # end
    end

  [input_file] ->
    ###

    IO.puts("""
    Part1: #{}
    Part2: #{}
    """)
end
