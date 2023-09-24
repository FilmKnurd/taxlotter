defmodule TaxLotter.Operators do
  @moduledoc """
  Stream operations to process tades into tax lots
  """
  alias Decimal, as: D
  alias TaxLotter.InvalidTrade
  alias TaxLotter.Trade

  def remove_blanks([""]), do: false
  def remove_blanks(_), do: true

  def validate_trade({[date, type, price, qty], index}) do
    case Trade.create(%{
           line: index + 1,
           date: date,
           type: type,
           price: price,
           qty: qty
         }) do
      {:ok, trade} -> trade
      {:error, changeset} -> raise InvalidTrade, changeset
    end
  end

  def process_lots(%{type: :buy} = trade, lot_acc) do
    lots =
      case lot_exists?(lot_acc.lots, trade.date) do
        true -> update_lot(trade, lot_acc)
        false -> build_lot(trade, lot_acc)
      end

    %{lot_acc | id: lot_acc.id + 1, lots: lots}
  end

  def process_lots(%{type: :sell} = trade, lot_acc) do
  end

  defp lot_exists?(lots, date) do
    case Enum.find(lots, fn lot ->
           Date.compare(lot.date, date) == :eq
         end) do
      nil -> false
      _ -> true
    end
  end

  defp build_lot(trade, %{id: id, lots: lots}), do: [Map.merge(trade, %{id: id + 1}) | lots]

  defp update_lot(trade, %{lots: lots}) do
    update_in(
      lots,
      [Access.filter(&(Date.compare(&1.date, trade.date) == :eq))],
      &Map.merge(&1, %{
        qty: D.add(trade.qty, &1.qty),
        price: D.div(D.add(trade.price, &1.price), D.add(trade.qty, &1.qty))
      })
    )
  end
end
