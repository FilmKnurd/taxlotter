defmodule TaxLotter.InvalidTrade do
  defexception [:message, :line, :errors]

  alias __MODULE__

  @impl true
  def exception(%Ecto.Changeset{} = changeset) do
    msg = "Invalid trade on line #{changeset.changes.line}"

    %InvalidTrade{
      message: msg,
      line: changeset.changes.line,
      errors:
        Enum.map(changeset.errors, fn {key, {msg, _}} ->
          [:gold, "#{key} ", :orangered, "#{msg}\n"]
        end)
    }
  end
end
