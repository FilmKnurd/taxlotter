defmodule TaxLotter.OperatorsTest do
  use ExUnit.Case

  alias TaxLotter.InvalidTrade
  alias TaxLotter.Operators
  alias TaxLotter.Trade

  describe "remove_blanks/1" do
    test "returns false if passed list with empty binary" do
      refute Operators.remove_blanks([""])
    end
  end

  describe "validate_trade/1" do
    test "checks date" do
      given_trade = {["", "buy", "100.00", "1.00000000"], 1}

      assert_raise InvalidTrade, fn ->
        Operators.validate_trade(given_trade)
      end
    end

    test "checks type" do
      given_trade = {["2023-09-01", "", "100.00", "1.00000000"], 1}

      assert_raise InvalidTrade, fn ->
        Operators.validate_trade(given_trade)
      end
    end

    test "checks precision of price" do
      given_trade = {["2023-09-01", "buy", "100", "1.00000000"], 1}

      assert_raise InvalidTrade, fn ->
        Operators.validate_trade(given_trade)
      end
    end

    test "checks precision of qty" do
      given_trade = {["2023-09-01", "buy", "100.00", "1.00"], 1}

      assert_raise InvalidTrade, fn ->
        Operators.validate_trade(given_trade)
      end
    end
  end

  describe "process_lots/2" do
    test "creates a new lot for a buy trade" do
      {:ok, given_trade} =
        Trade.create(%{
          line: 1,
          date: "2023-07-21",
          type: "buy",
          price: "100.00",
          qty: "1.00000000"
        })

      given_acc = %{id: 0, algo: :fifo, lots: []}

      %{lots: [lot]} = Operators.process_lots(given_trade, given_acc)

      assert lot.id == 1
      assert Decimal.compare(given_trade.price, lot.price) == :eq
      assert Decimal.compare(given_trade.qty, lot.qty) == :eq
    end

    test "aggregates buy trades on the same lot by date" do
      {:ok, given_trade1} =
        Trade.create(%{
          line: 1,
          date: "2023-07-21",
          type: "buy",
          price: "100.00",
          qty: "1.00000000"
        })

      {:ok, given_trade2} =
        Trade.create(%{
          line: 2,
          date: "2023-07-21",
          type: "buy",
          price: "200.00",
          qty: "1.00000000"
        })

      given_acc = %{id: 0, algo: :fifo, lots: []}
      expected_price = Decimal.new("150.00")
      expected_qty = Decimal.new("2.00000000")

      %{lots: [lot]} =
        Enum.reduce([given_trade1, given_trade2], given_acc, &Operators.process_lots/2)

      assert lot.id == 1
      assert Decimal.compare(expected_price, lot.price) == :eq
      assert Decimal.compare(expected_qty, lot.qty) == :eq
    end
  end
end
