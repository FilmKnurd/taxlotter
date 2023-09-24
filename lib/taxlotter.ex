defmodule TaxLotter do
  @moduledoc """
  Tax lot calculator
  """

  import TaxLotter.Operators

  def compute(input_stream, algo) do
    input_stream
    |> Stream.filter(&remove_blanks/1)
    |> Stream.with_index()
    |> Stream.map(&validate_trade/1)
    |> Enum.to_list()
    |> Enum.reduce(%{id: 0, algo: algo, lots: []}, &process_lots/2)
    |> Map.get(:lots)
  end
end
