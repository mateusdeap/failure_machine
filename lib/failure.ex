defmodule Failure do
  defstruct [:description, :file_path, :line_number, :full_description, :id, :status, :exception]

  def message(failure) do
    failure.exception["message"]
  end

  def sort_into(map, failure) do
    failure_message =
      Map.keys(map)
      |> Enum.find(Failure.message(failure), fn message ->
        String.jaro_distance(message, Failure.message(failure)) > 0.8
      end)

    Map.update(map, failure_message, [failure], fn failure_list -> failure_list ++ [failure] end)
  end
end
