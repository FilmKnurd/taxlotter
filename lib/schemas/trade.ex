defmodule TaxLotter.Trade do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  embedded_schema do
    field(:line, :integer)
    field(:date, :date)
    field(:type, Ecto.Enum, values: [:buy, :sell])
    field(:price, :decimal)
    field(:qty, :decimal)
  end

  def changeset(trade, attrs \\ %{}) do
    trade
    |> cast(attrs, [:line, :date, :type, :price, :qty])
    |> validate_required([:line, :date, :type, :price, :qty])
    |> validate_precision(:price, 2)
    |> validate_precision(:qty, 8)
  end

  def create(attrs) do
    %Trade{}
    |> changeset(attrs)
    |> apply_action(:insert)
  end

  defp validate_precision(changeset, field, p) do
    validate_change(changeset, field, fn field, value ->
      as_string = Decimal.to_string(value) |> String.split(".")

      case confirm_decimal(as_string) && confirm_precision(Enum.at(as_string, 1), p) do
        true -> []
        false -> [{field, "should be of precision #{p}"}]
      end
    end)
  end

  defp confirm_decimal(split), do: Enum.count(split) == 2
  defp confirm_precision(str, precision), do: String.length(str) == precision
end
