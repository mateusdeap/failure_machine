defmodule FailureGroup do
  defstruct [:messages, where: [], number_of_failures: 0]

  def from_failures_map(failures_map) do
    failures_map
    |> Enum.map(fn {_, failures} -> from_failures(failures) end)
  end

  def from_failures(failures) do
    messages = Enum.map(failures, fn failure -> failure.exception["message"] end)
    where = Enum.map(failures, fn failure -> "#{failure.file_path}:#{failure.line_number}" end)

    %FailureGroup{
      messages: messages,
      where: where,
      number_of_failures: length(failures)
    }
  end

  def add_failure(failure, failure_group) do
    Map.merge(failure_group, %{
      where: failure_group.where ++ ["#{failure.file_path}:#{failure.line_number}"]
    })
  end

  def compare(fg1, fg2) do
    cond do
      fg1.number_of_failures > fg2.number_of_failures -> :gt
      fg1.number_of_failures == fg2.number_of_failures -> :eq
      fg1.number_of_failures < fg2.number_of_failures -> :lt
    end
  end
end
