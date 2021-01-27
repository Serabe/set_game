defmodule DeckTest do
  use ExUnit.Case

  doctest SetGame.Deck

  alias SetGame.Deck

  def card_count(deck, property, value) do
    deck
    |> Enum.filter(fn card -> Map.get(card, property, value) == value end)
    |> Enum.count
  end

  test "prepare: creates a deck with defaults" do
    deck = Deck.prepare()

    assert Enum.count(deck) == 81
    assert card_count(deck, :color, :red) == 27
    assert card_count(deck, :color, :blue) == 27
    assert card_count(deck, :color, :green) == 27
    assert card_count(deck, :number, 1) == 27
    assert card_count(deck, :number, 2) == 27
    assert card_count(deck, :number, 3) == 27
    assert card_count(deck, :shape, :oval) == 27
    assert card_count(deck, :shape, :squiggle) == 27
    assert card_count(deck, :shape, :diamond) == 27
    assert card_count(deck, :pattern, :solid) == 27
    assert card_count(deck, :pattern, :striped) == 27
    assert card_count(deck, :pattern, :outlined) == 27
  end

  test "prepare: creates a deck with custom card properties" do
    deck = Deck.prepare(
      [42, 45, 90],
      [:black, :purple, :teal],
      [:triangle, :pentagon, :rectangle],
      [:plaid, :polka, :shaded]
    )

    assert Enum.count(deck) == 81
    assert card_count(deck, :color, :black) == 27
    assert card_count(deck, :color, :purple) == 27
    assert card_count(deck, :color, :teal) == 27
    assert card_count(deck, :number, 42) == 27
    assert card_count(deck, :number, 45) == 27
    assert card_count(deck, :number, 90) == 27
    assert card_count(deck, :shape, :triangle) == 27
    assert card_count(deck, :shape, :pentagon) == 27
    assert card_count(deck, :shape, :rectangle) == 27
    assert card_count(deck, :pattern, :plaid) == 27
    assert card_count(deck, :pattern, :polka) == 27
    assert card_count(deck, :pattern, :shaded) == 27
  end

  # TODO: Prepare: Test shuffled

  test "deal: returns a deck spilt into the dealt cards and the remaining card" do
    deck = Deck.prepare()
    {dealt_cards, remaining_deck} = Deck.deal(deck, 15)

    assert Enum.count(dealt_cards) == 15
    assert Enum.count(remaining_deck) == 66
  end

end
