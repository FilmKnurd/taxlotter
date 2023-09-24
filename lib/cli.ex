defmodule TaxLotter.CLI do
  @moduledoc """
  Command line entry point for TaxLotter tax lot calculator

  Functionality:
    - Enforce correct script usage and arguments
    - Catch parser and validation errors and halt with non
      zero exit code
    - Stream stdin and pass to TaxLotter.compute

  Usage:
    $ echo -e '2021-01-01,buy,10000.00,1.00000000\n...<more trade lines>' | taxlotter -a <fifo or hifo>
  """

  # The input is basically CSV format even though it is piped
  # into the script instead of reading from a file.
  NimbleCSV.define(TradeParser, separator: ",")

  alias OptionParser.ParseError
  alias TaxLotter.InvalidTrade

  @algos ~W(fifo hifo)a

  def main(argv) do
    try do
      argv
      |> parse_args()
      |> run()
    rescue
      e -> print_error(e)
    end
  end

  defp run(algo) do
    IO.stream(:line)
    |> TradeParser.parse_stream(skip_headers: false)
    |> TaxLotter.compute(algo)
  end

  defp parse_args([]), do: raise(ParseError, "Must provide an algorithm")

  defp parse_args(args) do
    parsed_args = OptionParser.parse_head!(args, aliases: [a: :algo], strict: [algo: :string])

    case parsed_args do
      {[algo: algo], _} ->
        validate_algo(algo)

      _ ->
        raise ParseError, "Invalid option"
    end
  end

  defp validate_algo(algo) when algo in ["fifo", "hifo"], do: String.to_existing_atom(algo)
  defp validate_algo(algo), do: raise(OptionParser.ParseError, "Invalid algorithm: #{algo}")

  defp print_error(%ParseError{} = e) do
    Bunt.puts([:darkred, "SCRIPT ERROR: "])
    Bunt.puts([:orangered, e.message])
    print_help()
    System.halt(1)
  end

  defp print_error(%InvalidTrade{} = e) do
    Bunt.puts([:darkred, "INPUT ERROR: ", e.message])
    Bunt.puts(e.errors)
    System.halt(1)
  end

  defp print_help() do
    Bunt.puts([
      :steelblue,
      """

      Correct usage:

      $ echo -e '<trades>' | taxlotter -a <algo>

      Trade lines are of the format <date>,<buy | sell>,<price>,<quantity>\n
        - Price must be a decimal value of precision 2
        - Quantity must be a decimal value of precision 8

      Example: '2023-09-01,buy,200.00,1000.00000000\\n'

      -a, --algo    Algorithm
                    Supported algorithms:
                    - fifo: Sells will take from earliest lots
                    - hifo: Sells will take from higest priced lots

      """
    ])
  end
end
