defmodule TaxLotter do
  @moduledoc """
  Tax lot calculator
  """

  import TaxLotter.Operators

  def compute(input_stream, _algo) do
    input_stream
    |> Stream.filter(&remove_blanks/1)
    |> Stream.with_index()
    |> Stream.map(&validate_trade/1)
  end
end
