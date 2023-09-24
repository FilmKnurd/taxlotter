defmodule TaxLotter.OperatorsTest do
  use ExUnit.Case

  alias TaxLotter.InvalidTrade
  alias TaxLotter.Operators

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
end
