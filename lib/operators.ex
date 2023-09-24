defmodule TaxLotter.Operators do
  @moduledoc """
  Stream operations to process tades into tax lots
  """
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
end
