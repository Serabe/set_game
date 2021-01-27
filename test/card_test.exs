defmodule CardTest do
  use ExUnit.Case

  doctest SetGame.Card

  alias SetGame.Card

  test "creates a card with any values" do
    card = %Card{color: :clear, number: 42, shape: :whatever, pattern: :plaid}

    assert card.color == :clear
    assert card.number == 42
    assert card.shape == :whatever
    assert card.pattern == :plaid
  end
end
