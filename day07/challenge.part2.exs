defmodule Challenge do
  def solve(input, options) do
    input
    |> parse
    |> process(options)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn "Step " <>
                             <<a::bytes-size(1)>> <>
                             " must be finished before step " <>
                             <<b::bytes-size(1)>> <> " can begin.",
                           jobs ->
      jobs
      |> Map.update(a, %{following_jobs: [b]}, fn job ->
        job |> Map.update(:following_jobs, [b], &[b | &1])
      end)
      |> Map.update(b, %{dependant_jobs: MapSet.new([a])}, fn job ->
        job |> Map.update(:dependant_jobs, MapSet.new(), &MapSet.put(&1, a))
      end)
    end)
  end

  def process(
        current_seconds,
        all_workers,
        work_factor,
        all_jobs,
        available_jobs,
        completed_jobs,
        ordered_jobs
      ) do
    {all_workers, available_jobs, completed_jobs, ordered_jobs} =
      Enum.reduce(
        available_workers(all_workers, current_seconds),
        {all_workers, available_jobs, completed_jobs, ordered_jobs},
        fn {current_worker, %{job: current_job}},
           {all_workers, available_jobs, completed_jobs, ordered_jobs} ->
          {available_jobs, completed_jobs, ordered_jobs} =
            if current_job != nil do
              following_jobs = Map.get(all_jobs[current_job], :following_jobs, [])
              completed_jobs = MapSet.put(completed_jobs, current_job)
              ordered_jobs = [current_job | ordered_jobs]

              available_jobs =
                Enum.reduce(following_jobs, available_jobs, fn new_job, available_jobs ->
                  dependant_jobs = Map.get(all_jobs[new_job], :dependant_jobs, [])

                  if MapSet.subset?(dependant_jobs, completed_jobs) do
                    [new_job | available_jobs]
                  else
                    available_jobs
                  end
                end)

              {available_jobs, completed_jobs, ordered_jobs}
            else
              {available_jobs, completed_jobs, ordered_jobs}
            end

          {all_workers, available_jobs} =
            if not Enum.empty?(available_jobs) do
              {next_job, updated_available_jobs} =
                available_jobs
                |> Enum.sort()
                |> List.pop_at(0)

              {
                all_workers
                |> assign_work(current_worker, current_seconds, work_factor, next_job),
                updated_available_jobs
              }
            else
              {
                all_workers |> assign_work(current_worker, nil),
                available_jobs
              }
            end

          {
            all_workers,
            available_jobs,
            completed_jobs,
            ordered_jobs
          }
        end
      )

    if Enum.count(completed_jobs) == Enum.count(all_jobs) do
      {ordered_jobs |> Enum.reverse() |> Enum.join(), current_seconds}
    else
      busy_until =
        all_workers
        |> Enum.reject(&(Map.get(elem(&1, 1), :job) == nil))
        |> Enum.min_by(&Map.get(elem(&1, 1), :busy_until))
        |> elem(1)
        |> Map.get(:busy_until)

      process(
        busy_until,
        all_workers,
        work_factor,
        all_jobs,
        available_jobs,
        completed_jobs,
        ordered_jobs
      )
    end
  end

  def process(all_jobs, options) do
    num_workers = Keyword.get(options, :num_workers, 1)

    work_factor = Keyword.get(options, :work_factor, 0)

    current_seconds = 0

    workers = for worker <- 1..num_workers, do: {worker, %{job: nil, busy_until: nil}}, into: %{}

    available_jobs =
      all_jobs
      |> Enum.reject(&Map.has_key?(elem(&1, 1), :dependant_jobs))
      |> Enum.map(&elem(&1, 0))

    completed_jobs = MapSet.new()

    ordered_jobs = []

    process(
      current_seconds,
      workers,
      work_factor,
      all_jobs,
      available_jobs,
      completed_jobs,
      ordered_jobs
    )
  end

  def available_workers(all_workers, current_seconds) do
    finishing_workers =
      all_workers
      |> Enum.filter(fn {_, %{job: working_on, busy_until: busy_until}} ->
        working_on != nil && busy_until == current_seconds
      end)
      |> Enum.sort_by(&Map.get(elem(&1, 1), :job))

    unassigned_workers =
      all_workers
      |> Enum.filter(fn {_, %{job: working_on}} ->
        working_on == nil
      end)

    finishing_workers ++ unassigned_workers
  end

  def assign_work(workers, worker, nil) do
    Map.put(workers, worker, %{job: nil, busy_until: nil})
  end

  def assign_work(workers, worker, current_seconds, work_factor, next_job) do
    Map.put(workers, worker, %{
      job: next_job,
      busy_until: busy_until(current_seconds, work_factor, next_job)
    })
  end

  def busy_until(current_seconds, work_factor, next_job) do
    [char] = String.to_charlist(next_job)

    current_seconds + work_factor + (char - ?A + 1)
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

      # test "can parse jobs and deps" do
      #   {jobs, deps} = parse(@example)

      #   assert jobs == %{
      #            "A" => ["D", "B"],
      #            "B" => ["E"],
      #            "C" => ["F", "A"],
      #            "D" => ["E"],
      #            "F" => ["E"]
      #          }

      #   # assert deps == %{
      #   #          "A" => ["C"],
      #   #          "B" => ["A"],
      #   #          "D" => ["A"],
      #   #          "E" => ["F", "D", "B"],
      #   #          "F" => ["C"]
      #   #        }
      # end

      test "can solve challenge" do
        assert solve(@example, work_factor: 0, num_workers: 2) == {"CABFDE", 15}
      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> Challenge.solve(work_factor: 60, num_workers: 5)
    |> IO.inspect(label: "Solution")
end
