defmodule FailureMachine do
  @moduledoc """
  Documentation for `FailureMachine`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> FailureMachine.hello()
      :world

  """
  def main(args) do
    {parsed, _, invalid} =
      args
      |> OptionParser.parse(aliases: [h: :help], strict: [info: :string, help: :boolean])

    case invalid do
      [] ->
        process_command(parsed)

      [{"--info", nil}] ->
        IO.puts("The --info option requires a path")

      _ ->
        IO.inspect(invalid)
    end
  end

  def process_command(info: file_name) do
    case File.read(file_name) do
      {:ok, content} -> print_info(content)
      {:error, _} -> IO.puts("Unable to read file")
    end
  end

  def process_command(help: _) do
    IO.puts("TODO: Implement help message")
  end

  def print_info(content) do
    content
    |> Poison.decode!()
    |> extract_failures()
    |> classify()
    |> print()
  end

  def extract_failures(test_run_data) do
    test_run_data["examples"]
    |> Enum.map(fn elem -> atomize_keys(elem) end)
    |> Enum.filter(fn example -> example[:status] == "failed" end)
    |> Enum.map(fn elem -> struct(Failure, elem) end)
  end

  def atomize_keys(map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Map.new()
  end

  def classify(failures) do
    failures
    |> create_failure_groups()
    |> order_descending()
  end

  def create_failure_groups(failures) do
    failures
    |> Enum.chunk_while([], &chunk_by_root_cause/2, &chunk_by_root_cause/1)
    |> FailureGroup.from_failure_lists()
  end

  def chunk_by_root_cause(failure, failure_group) do
    last_failure = List.first(failure_group)

    cond do
      last_failure == nil || failure.exception["message"] == last_failure.exception["message"] ->
        {:cont, [failure | failure_group]}

      failure.exception["message"] != last_failure.exception["message"] ->
        {:cont, Enum.reverse([failure | failure_group]), []}
    end
  end

  def chunk_by_root_cause(failure_group) do
    case failure_group do
      [] -> {:cont, []}
      remaining_failures -> {:cont, Enum.reverse(remaining_failures), []}
    end
  end

  def order_descending(failure_groups) do
    failure_groups
    |> Enum.sort({:desc, FailureGroup})
  end

  def print(failure_groups) do
    failure_groups
    |> Enum.each(fn fg -> print_to_console(fg) end)
  end

  def print_to_console(failure_group) do
    IO.puts("""
    NUMBER OF FAILURES: #{failure_group.number_of_failures}
    MESSAGES:
    #{failure_group.messages}
    WHERE:
    #{format(failure_group.where)}
    """)
  end

  def format(file_paths) do
    file_paths
    |> Enum.reduce(List.first(file_paths), fn path, acc -> acc <> "\n#{path}" end)
  end
end
